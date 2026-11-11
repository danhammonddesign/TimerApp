#!/usr/bin/env python3
"""Generate the narrator voice clips with Kokoro TTS (Apache-2.0).

Setup (one time):
    pip install kokoro-onnx soundfile
    curl -LO https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/kokoro-v1.0.onnx
    curl -LO https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/voices-v1.0.bin

Run:
    python3 tools/generate_voices.py --model kokoro-v1.0.onnx --voices voices-v1.0.bin

Writes BrushBlast.swiftpm/Resources/Audio/voice_<theme>_<line>.m4a (needs ffmpeg).
Use --only space to regenerate one theme, or --voice to audition a different narrator.
"""
import argparse
import json
import pathlib
import subprocess
import tempfile

import numpy as np
import soundfile as sf
from kokoro_onnx import Kokoro

ROOT = pathlib.Path(__file__).resolve().parent.parent
LINES = ROOT / "tools" / "voice_lines.json"
OUT = ROOT / "BrushBlast.swiftpm" / "Resources" / "Audio"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default="kokoro-v1.0.onnx")
    ap.add_argument("--voices", default="voices-v1.0.bin")
    ap.add_argument("--only", help="only this theme id")
    ap.add_argument("--voice", help="override narrator voice (e.g. af_sky)")
    args = ap.parse_args()

    kokoro = Kokoro(args.model, args.voices)
    data = json.loads(LINES.read_text())
    OUT.mkdir(parents=True, exist_ok=True)

    for theme, cfg in data.items():
        if theme.startswith("_") or (args.only and theme != args.only):
            continue
        voice = args.voice or cfg["voice"]
        for key, text in cfg["lines"].items():
            samples, sr = kokoro.create(text, voice=voice, speed=cfg.get("speed", 1.0), lang="en-us")
            # trim silence and add a tiny fade so clips start instantly and end cleanly
            samples = np.asarray(samples, dtype=np.float32)
            idx = np.where(np.abs(samples) > 0.01)[0]
            if len(idx):
                samples = samples[max(idx[0] - int(0.02 * sr), 0): idx[-1] + int(0.12 * sr)]
            peak = np.max(np.abs(samples)) or 1.0
            samples = samples / peak * 0.95
            dest = OUT / f"voice_{theme}_{key}.m4a"
            with tempfile.NamedTemporaryFile(suffix=".wav") as tmp:
                sf.write(tmp.name, samples, sr)
                subprocess.run(
                    ["ffmpeg", "-y", "-loglevel", "error", "-i", tmp.name,
                     "-ac", "1", "-c:a", "aac", "-b:a", "64k", str(dest)],
                    check=True,
                )
            print(f"{dest.name}  ({len(samples) / sr:.1f}s)  {text}")


if __name__ == "__main__":
    main()
