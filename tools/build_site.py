#!/usr/bin/env python3
"""Build the GitHub Pages copy of the web app into docs/.

    python3 tools/build_site.py

web/index.html is written without <html>/<head> (the Claude artifact host adds those),
so this wraps it in a full page, copies app.js and the audio (voice .m4a -> .mp4,
which is what the page loads), and adds a Home Screen icon + web app manifest.
"""
import json, pathlib, shutil

ROOT = pathlib.Path(__file__).resolve().parent.parent
WEB, AUDIO, OUT = ROOT / "web", ROOT / "BrushBlast.swiftpm" / "Resources" / "Audio", ROOT / "docs"

HEAD = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#131F24">
<meta name="apple-mobile-web-app-title" content="Brush Blast">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="description" content="A tooth-brushing timer for kids: pick a theme, follow Chompy around the mouth, and win a sticker at the end.">
<link rel="manifest" href="manifest.webmanifest">
<link rel="apple-touch-icon" href="icon-180.png">
<link rel="icon" type="image/png" href="icon-512.png">
<style>html { box-sizing: border-box; padding-top: env(safe-area-inset-top, 0px); padding-bottom: env(safe-area-inset-bottom, 0px); background: #131F24; }</style>
</head>
<body>
"""

def main():
    OUT.mkdir(exist_ok=True)
    page = (WEB / "index.html").read_text()
    page = page.replace('<meta name="apple-mobile-web-app-capable" content="yes">\n', "")
    (OUT / "index.html").write_text(HEAD + page + "\n</body>\n</html>\n")
    shutil.copy(WEB / "app.js", OUT / "app.js")
    audio = OUT / "audio"
    if audio.exists():
        shutil.rmtree(audio)
    audio.mkdir()
    for f in sorted(AUDIO.iterdir()):
        if f.suffix == ".wav":
            shutil.copy(f, audio / f.name)
        elif f.suffix == ".m4a":
            shutil.copy(f, audio / (f.stem + ".mp4"))
    for icon in ("icon-180.png", "icon-512.png"):
        if (WEB / icon).exists():
            shutil.copy(WEB / icon, OUT / icon)
    (OUT / "manifest.webmanifest").write_text(json.dumps({
        "name": "Brush Blast", "short_name": "Brush Blast", "start_url": "./", "display": "standalone",
        "background_color": "#131F24", "theme_color": "#131F24",
        "icons": [{"src": "icon-180.png", "sizes": "180x180", "type": "image/png"},
                  {"src": "icon-512.png", "sizes": "512x512", "type": "image/png"}],
    }, indent=2))
    (OUT / ".nojekyll").write_text("")
    print("built", OUT, sum(1 for _ in audio.iterdir()), "audio files")

if __name__ == "__main__":
    main()
