# 🪥 Brush Blast!

A tooth-brushing timer for iPhone that kids actually want to watch.

The look is flat and chunky: bold solid colors, big rounded type, 3D "squishy" buttons,
a thick glossy progress bar and speech bubbles. The star is **Chompy**, an original tooth
mascot drawn entirely in code. Chompy blinks, talks while the narrator speaks, looks toward
the side of the mouth being brushed, scrubs with a toothbrush and wears a costume per theme
(space helmet, snorkel mask, dino spikes, unicorn horn, robot antenna).

- **5 themes** kids pick from: 🚀 Rocket Brush, 🐠 Ocean Dive, 🦖 Dino Stomp, 🦄 Unicorn Magic, 🤖 Robot Power.
  Each one has its own colors, floating background art, hero character, music loop and **its own narrator voice**.
- **Spoken brushing coaching** made with [Kokoro TTS](https://github.com/hexgrad/kokoro) (Apache-2.0).
  The mouth is split into 8 zones (top front → top left → top right → top insides → bottom front → …).
  At each zone the narrator says where to brush ("Rocket over to the top teeth on the left side!"),
  a mouth map lights up the right teeth, and a little 🪥 scrubs there. There are cheers in between too.
- **Timer**: 1, 2 or 3 minutes (2 is what dentists recommend). The hero flies around a glowing ring
  toward its goal (🚀 → 🪐, 🦖 → 🌋, 🤖 → 🔋 …). Big 5-4-3-2-1 countdown at the end.
- **The payoff**: white flash + screen shake + explosion + confetti and emoji fireworks, the goal
  blows up, the narrator celebrates, then a **mystery gift** drops in. Tap it → it rattles → POP →
  a spinning sunburst reveals a **collectible sticker** (common, rare or ✨LEGENDARY✨).
- **Sticker Book** with 30 stickers to collect (uncollected ones are mystery silhouettes) and a
  **daily streak** 🔥 — reasons to come back tomorrow.
- Plays even with the silent switch on, keeps the screen awake while brushing, haptic buzzes,
  music ducks while the narrator talks, music/voice toggles on the home screen.

## Run it on your iPhone

You need a Mac with **Xcode 15 or newer** (free on the Mac App Store), or **Swift Playgrounds** on iPad/Mac.

1. Open `BrushBlast.swiftpm` in Xcode (double-click it).
2. Plug in your iPhone and pick it as the run destination at the top of the window.
3. Xcode will ask for a signing team the first time: choose your Apple ID
   (a free Apple ID works; the app then needs re-installing every 7 days. A $99/yr developer account removes that).
4. Press ▶ Run. On the phone, the first time: *Settings → General → VPN & Device Management* → trust your developer profile.

Tip for grown-ups: **long-press the time** in the top-right corner of the brushing screen for 1.5 s to jump to the
last few seconds — handy for testing the finale without brushing for 2 minutes.

## Project layout

```
BrushBlast.swiftpm/
  Package.swift              app settings (name, bundle id, icon placeholder)
  App/BrushBlastApp.swift    app entry + screen switching
  Models/Theme.swift         ⭐ the 5 themes + their stickers — easiest place to customize
  Models/BrushZone.swift     the 8 mouth zones
  Models/BrushSession.swift  the timer engine (zones, cheers, countdown)
  Models/RewardStore.swift   sticker collection, streak, saved settings
  Audio/AudioManager.swift   narrator queue, sound effects, music + ducking, haptics
  Views/Mascot.swift         Chompy the tooth mascot + costumes
  Views/Design.swift         colors, chunky buttons, progress bar, speech bubble, background, confetti
  Views/                     Home, Brushing, Finale, Sticker Book screens
  Resources/Audio/           all generated sounds (voice_*.m4a, sfx_*.wav, music_*.wav)
tools/
  voice_lines.json           every narrator line + which Kokoro voice each theme uses
  generate_voices.py         Kokoro → voice clips
  generate_sfx.py            synthesizes all sound effects and music loops from scratch
```

## Changing the voices

Edit the text (or the `voice`) in `tools/voice_lines.json`, then:

```bash
pip install kokoro-onnx soundfile          # also needs ffmpeg installed
curl -LO https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/kokoro-v1.0.onnx
curl -LO https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/voices-v1.0.bin
python3 tools/generate_voices.py                 # all themes
python3 tools/generate_voices.py --only dino     # just one theme
```

Voices used now: space `am_puck`, ocean `af_bella`, dino `bm_george` (British), rainbow `af_heart`, robot `am_echo`.
Other fun ones to try: `am_santa`, `bf_emma`, `af_sky`, `am_fenrir`, `bm_fable`, `af_nova`.
Your kid's name works too — e.g. `"intro": "Welcome aboard, Captain Maya!"`.

## Sound effects & music

Every sound effect and music loop is **synthesized from math** by `tools/generate_sfx.py`
(chimes, sparkles, countdown beeps, whoosh, explosion, gift rattle, pop, fanfare, and a chiptune loop
per theme), so they're 100% original with no license strings attached. Tweak and re-run `python3 tools/generate_sfx.py`.

If you want richer / more "real" sounds, these are great **free** sources — just drop files into
`Resources/Audio/` with the same names (e.g. replace `sfx_boom.wav`):

| Source | License | Good for |
|---|---|---|
| [Kenney.nl audio packs](https://kenney.nl/assets/category:Audio) | CC0 (public domain) | UI clicks, interface, sci-fi, impact, "jingles" packs — perfect for this app |
| [Freesound.org](https://freesound.org) (filter by *Creative Commons 0*) | CC0 / CC-BY | explosions, fireworks, bubbles, dino roars |
| [OpenGameArt.org](https://opengameart.org) | CC0 / CC-BY / GPL (check each) | chiptune music loops, fanfares |
| [jsfxr](https://sfxr.me) / [ChipTone](https://sfbgames.itch.io/chiptone) | you own what you make | instantly make retro "power-up", "coin", "explosion" sounds |
| [Pixabay Sound Effects](https://pixabay.com/sound-effects/) | Pixabay license (free, not open source) | big library, no attribution needed |
| [Sonniss GDC bundles](https://sonniss.com/gameaudiogdc) | royalty-free | Hollywood-quality explosions & whooshes |

Kokoro itself is Apache-2.0, so the generated narration is fine to ship in an app.

## Ideas for next steps

- Real app icon (replace `.placeholder(icon: .sparkle)` in `Package.swift`).
- Kid's name in the narration, multiple kids with their own sticker books.
- Morning / evening reminders with local notifications.
- More themes: add a `Theme` in `Theme.swift`, a block in `voice_lines.json`, a `music(...)` line in `generate_sfx.py`, regenerate.
