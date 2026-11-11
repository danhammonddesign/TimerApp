#!/usr/bin/env python3
"""Synthesize every sound effect and music loop used by Brush Blast.

Everything here is generated from math (sine waves, noise, envelopes), so the
sounds are 100% original and free to use - no attribution or license needed.

Run:
    pip install numpy
    python3 tools/generate_sfx.py

Writes WAV files to BrushBlast.swiftpm/Resources/Audio/.
(Music loops stay WAV so they loop with no gap; AAC adds silence at the edges.)
"""
import pathlib
import wave

import numpy as np

SR = 22050
OUT = pathlib.Path(__file__).resolve().parent.parent / "BrushBlast.swiftpm" / "Resources" / "Audio"
rng = np.random.default_rng(7)


# ----------------------------------------------------------------- helpers
def t(dur):
    return np.arange(int(dur * SR)) / SR


def env(n, attack=0.005, release=0.1, dur=None):
    """Attack / exponential-decay envelope."""
    x = np.arange(n) / SR
    a = np.clip(x / max(attack, 1e-4), 0, 1)
    d = np.exp(-x / max(release, 1e-4))
    return a * d


def osc(freq, dur, kind="sine", duty=0.5):
    x = t(dur)
    if callable(freq):
        phase = np.cumsum(freq(x)) / SR
    else:
        phase = freq * x
    p = phase % 1.0
    if kind == "sine":
        return np.sin(2 * np.pi * p)
    if kind == "square":
        return np.where(p < duty, 1.0, -1.0)
    if kind == "saw":
        return 2 * p - 1
    if kind == "tri":
        return 4 * np.abs(p - 0.5) - 1
    raise ValueError(kind)


def bell(freq, dur, release=0.4):
    x = osc(freq, dur) + 0.5 * osc(freq * 2.01, dur) + 0.25 * osc(freq * 3.03, dur)
    return x * env(len(x), 0.002, release)


def noise(dur):
    return rng.uniform(-1, 1, int(dur * SR))


def lowpass(x, cutoff):
    """One-pole low-pass; cutoff may be a scalar or per-sample array."""
    cutoff = np.broadcast_to(np.asarray(cutoff, dtype=float), x.shape)
    a = 1 - np.exp(-2 * np.pi * cutoff / SR)
    y = np.zeros_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc += a[i] * (x[i] - acc)
        y[i] = acc
    return y


def mix(*parts):
    n = max(int(start * SR) + len(p) for start, p in parts)
    out = np.zeros(n)
    for start, p in parts:
        s = int(start * SR)
        out[s:s + len(p)] += p
    return out


def place(total, parts):
    out = np.zeros(int(total * SR))
    for start, p in parts:
        s = int(start * SR) % len(out)
        end = min(len(out), s + len(p))
        out[s:end] += p[: end - s]
    return out


def note(n):
    """MIDI note number -> Hz."""
    return 440.0 * 2 ** ((n - 69) / 12)


def save(name, x, peak=0.9):
    x = np.asarray(x, dtype=float)
    m = np.max(np.abs(x)) or 1.0
    x = x / m * peak
    pcm = (x * 32767).astype("<i2")
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / f"{name}.wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    print(f"{name}.wav  {len(x) / SR:.2f}s")


# ----------------------------------------------------------------- one-shots
def sfx():
    # UI tap: bubbly pitch-up blip
    d = 0.12
    save("sfx_tap", osc(lambda x: 500 + 2500 * x / d, d) * env(int(d * SR), 0.002, 0.04))

    # Zone change chime: two-note bell
    save("sfx_chime", mix((0, bell(note(84), 0.6, 0.25)), (0.09, bell(note(91), 0.8, 0.35))))

    # Sparkle: fast twinkly arpeggio
    notes = [84, 88, 91, 96, 100, 103]
    save("sfx_sparkle", mix(*[(i * 0.045, bell(note(n), 0.5, 0.12) * 0.6) for i, n in enumerate(notes)]))

    # Countdown beep and the last "go" beep
    d = 0.14
    save("sfx_beep", osc(note(81), d, "square", 0.25) * env(int(d * SR), 0.002, 0.08) * 0.6)
    d = 0.45
    save("sfx_beep_final", osc(note(93), d, "square", 0.25) * env(int(d * SR), 0.002, 0.2) * 0.6)

    # Whoosh: filtered noise sweeping up then down
    d = 0.6
    x = t(d)
    cutoff = 300 + 4000 * np.sin(np.pi * x / d) ** 2
    save("sfx_whoosh", lowpass(noise(d), cutoff) * np.sin(np.pi * x / d) ** 2)

    # Explosion: sub drop + crunchy noise + rumble tail
    d = 2.2
    x = t(d)
    sub = osc(lambda x: 30 + 90 * np.exp(-x * 6), d) * env(len(x), 0.002, 0.6)
    crack = lowpass(noise(d), 6000 * np.exp(-x * 10) + 200) * env(len(x), 0.001, 0.35)
    rumble = lowpass(noise(d), 180) * env(len(x), 0.05, 0.9) * 3
    save("sfx_boom", sub * 1.6 + crack * 0.45 + rumble)

    # Gift shake: little rattles
    rattle = lambda: lowpass(noise(0.06), 2500) * env(int(0.06 * SR), 0.001, 0.02)
    save("sfx_rattle", mix(*[(i * 0.07, rattle()) for i in range(6)]))

    # Reveal pop: cork pop + upward sweep
    d = 0.35
    pop = osc(lambda x: 200 + 1800 * (x / d) ** 0.5, d, "sine") * env(int(d * SR), 0.001, 0.08)
    save("sfx_pop", mix((0, pop), (0.05, bell(note(96), 0.6, 0.2) * 0.5)))

    # Fanfare: brassy arpeggio into a big chord
    def brass(n, dur):
        f = note(n)
        y = osc(f, dur, "saw") + 0.5 * osc(f * 1.005, dur, "saw")
        y = lowpass(y, 2500)
        e = np.minimum(t(dur) / 0.03, 1) * np.exp(-t(dur) / (dur * 0.8))
        return y * e

    save("sfx_fanfare", mix(
        (0.00, brass(67, 0.18)), (0.15, brass(72, 0.18)), (0.30, brass(76, 0.18)),
        (0.45, brass(79, 1.4)), (0.45, brass(72, 1.4) * 0.7), (0.45, brass(76, 1.4) * 0.7),
        (0.45, brass(60, 1.4) * 0.6),
    ))

    # Star collected (each finished zone)
    save("sfx_star", mix((0, bell(note(88), 0.4, 0.15)), (0.06, bell(note(95), 0.6, 0.25))))


# ----------------------------------------------------------------- music loops
def music(name, bpm, root, prog, lead="square", arp_pattern=(0, 1, 2, 1), swing=0.0,
          kick=True, hat=True, bass="tri", bars_per_chord=1, lead_gain=0.18, sparkle=False):
    beat = 60 / bpm
    bar = beat * 4
    total = bar * bars_per_chord * len(prog)
    parts = []
    triads = {"I": (0, 4, 7), "ii": (2, 5, 9), "iii": (4, 7, 11), "IV": (5, 9, 12),
              "V": (7, 11, 14), "vi": (9, 12, 16), "i": (0, 3, 7), "bVI": (8, 12, 15),
              "bVII": (10, 14, 17), "iv": (5, 8, 12)}
    for ci, chord in enumerate(prog):
        tones = triads[chord]
        cstart = ci * bar * bars_per_chord
        for b in range(4 * bars_per_chord):
            bstart = cstart + b * beat
            # bass on every beat (root, octave on offbeats)
            bn = root - 24 + tones[0] + (12 if b % 2 else 0)
            d = beat * 0.9
            parts.append((bstart, osc(note(bn), d, bass) * env(int(d * SR), 0.005, beat * 0.6) * 0.5))
            # arpeggio: 8th notes
            for h in range(2):
                st = bstart + h * beat / 2 + (swing * beat / 2 if h == 1 else 0)
                idx = arp_pattern[(b * 2 + h) % len(arp_pattern)]
                n = root + tones[idx % 3] + 12 * (idx // 3)
                d = beat / 2 * 0.9
                parts.append((st, osc(note(n), d, lead, 0.25) * env(int(d * SR), 0.003, beat * 0.25) * lead_gain))
            if kick and b % 2 == 0:
                d = 0.25
                k = osc(lambda x: 45 + 110 * np.exp(-x * 30), d) * env(int(d * SR), 0.001, 0.08)
                parts.append((bstart, k * 0.9))
            if kick and b % 2 == 1:  # snare-ish clap
                d = 0.15
                parts.append((bstart, lowpass(noise(d), 3500) * env(int(d * SR), 0.001, 0.05) * 0.35))
            if hat:
                d = 0.04
                parts.append((bstart + beat / 2, (noise(d) - lowpass(noise(d), 5000)) * env(int(d * SR), 0.001, 0.015) * 0.25))
        if sparkle:
            parts.append((cstart + beat * 3.5, bell(note(root + 24 + tones[2]), 0.8, 0.3) * 0.12))
    loop = place(total, parts)
    save(name, loop, peak=0.6)


def main():
    sfx()
    music("music_space", 112, 62, ["I", "vi", "IV", "V", "I", "vi", "ii", "V"], lead="sine", arp_pattern=(0, 1, 2, 3, 2, 1), sparkle=True, lead_gain=0.25)
    music("music_ocean", 100, 65, ["I", "IV", "vi", "V", "I", "IV", "ii", "V"], lead="tri", swing=0.33, bass="sine", kick=False, lead_gain=0.3)
    music("music_dino", 118, 55, ["i", "bVI", "bVII", "i", "i", "iv", "bVII", "i"], lead="saw", arp_pattern=(0, 0, 2, 1), bass="square", lead_gain=0.12)
    music("music_rainbow", 128, 67, ["I", "V", "vi", "IV", "I", "V", "IV", "V"], lead="sine", arp_pattern=(0, 1, 2, 3, 4, 3, 2, 1), sparkle=True, lead_gain=0.25)
    music("music_robot", 124, 60, ["i", "i", "bVI", "bVII", "i", "i", "iv", "bVII"], lead="square", arp_pattern=(0, 3, 1, 3, 2, 3), bass="square", lead_gain=0.12)


if __name__ == "__main__":
    main()
