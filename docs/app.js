"use strict";
/* Brush Blast — web version. Same themes, voices, timers and look as the iPhone app. */

// ============================================================ data
const P = {
  dark: "#131F24", card: "#202F36", border: "#37464F", muted: "#8FA3AD", ink: "#3C3C3C", bubbleBorder: "#E2E2E2",
  toothShade: "#D6E2EA", green: "#5BCB0C", greenLip: "#46A005", blue: "#1FB2F5", blueLip: "#1592CC",
  yellow: "#FFCB05", yellowLip: "#DDA704", orange: "#FF9A0A", orangeLip: "#D97C00", red: "#FF5050", redLip: "#D63636",
  pink: "#FF8AD2", pinkLip: "#DD62AE", purple: "#B876FF", purpleLip: "#9455D9", teal: "#2EC4B6", tealLip: "#219E92",
  mouth: "#B8261A", tongue: "#FF5A6A", cheek: "#FFB3C3", pupil: "#2B2B2B",
};
const S = (theme, list) => list.map((s, i) => ({ id: theme + "-" + i, emoji: s[0], name: s[1], rarity: s[2] }));
const THEMES = [
  { id: "marble", name: "Marble Drop", tagline: "Fill the whole board with marbles!", costume: "propeller", timer: "plinko",
    bg: ["#1B2A4A", "#0F1830"], primary: P.red, lip: P.redLip, light: "#FF9A9A", text: "#FFFFFF",
    shapes: [P.red, P.yellow, P.blue, P.green], finale: "Board full!",
    stickers: S("marble", [["🎱","Eight Ball","common"],["🎯","Bullseye","common"],["🪀","Yo-yo","common"],["🔮","Crystal Orb","rare"],["🧿","Lucky Eye","rare"],["💎","Diamond Marble","legendary"]]) },
  { id: "sand", name: "Sand Art", tagline: "Fill the jar with rainbow sand!", costume: "sunHat", timer: "sandJar", jarPets: ["cat", "bunny", "shark", "owl", "dog", "turtle", "bear", "fish"], mystery: true,
    bg: ["#2A1E4A", "#160F2C"], primary: P.teal, lip: P.tealLip, light: "#8FF0E6", text: "#FFFFFF",
    shapes: [P.yellow, P.pink, P.teal, P.orange], finale: "Jar full!",
    stickers: S("sand", [["⏳","Hourglass","common"],["🌵","Cactus","common"],["🐪","Camel","common"],["🐱","Kitty Jar","rare"],["🐶","Puppy Jar","rare"],["🦈","Golden Shark","legendary"]]) },
  { id: "tiles", name: "Secret Picture", tagline: "Flip the tiles to find a secret pet!", costume: "beret", timer: "tiles",
    bg: ["#0F3B3A", "#08201F"], primary: P.purple, lip: P.purpleLip, light: "#D8B4FF", text: "#FFFFFF",
    shapes: [P.purple, P.yellow, P.teal], finale: "Surprise!",
    stickers: S("tiles", [["🧩","Puzzle Piece","common"],["🖼️","Picture Frame","common"],["🃏","Joker Card","common"],["🐾","Paw Print","rare"],["🎀","Big Bow","rare"],["🦁","Lion Cub","legendary"]]) },
  { id: "space", name: "Rocket Brush", tagline: "Fly past the planets to Planet Zoom!", costume: "helmet", timer: "rocket",
    bg: ["#131F3A", "#241650"], primary: P.blue, lip: P.blueLip, light: "#6FE3FF", text: "#FFFFFF",
    shapes: [P.yellow, P.blue, P.purple, "#FFFFFF"], finale: "Mission complete!",
    stickers: S("space", [["🌙","Moon Buddy","common"],["⭐️","Super Star","common"],["☄️","Comet Zoom","common"],["🛸","Flying Saucer","rare"],["👽","Alien Pal","rare"],["🌌","Galaxy Swirl","legendary"]]) },
  { id: "ocean", name: "Ocean Dive", tagline: "Fill the crab with rainbow sand!", costume: "snorkel", timer: "sandJar", jarPets: ["crab", "turtle", "fish"],
    bg: ["#0C6FA8", "#073A63"], primary: P.yellow, lip: P.yellowLip, light: "#FFE46B", text: "#5A3D00",
    shapes: ["#FFFFFF", "#6FE3FF", P.yellow], finale: "Crab full!",
    stickers: S("ocean", [["🐚","Shiny Shell","common"],["🦀","Snappy Crab","common"],["🐢","Turtle Pal","common"],["🐬","Dolphin Flip","rare"],["🐙","Octo Hugs","rare"],["🐳","Whale King","legendary"]]) },
  { id: "dino", name: "Dino Stomp", tagline: "Color in the dinosaur!", costume: "dinoHood", timer: "coloring",
    bg: ["#1E3B1A", "#10230D"], primary: P.green, lip: P.greenLip, light: "#A6F04A", text: "#FFFFFF",
    shapes: [P.green, P.orange, "#A6F04A"], finale: "All colored in!",
    stickers: S("dino", [["🥚","Dino Egg","common"],["🦴","Big Bone","common"],["🌴","Palm Snack","common"],["🦕","Long Neck","rare"],["🦣","Fuzzy Mammoth","rare"],["🐉","Dragon Legend","legendary"]]) },
  { id: "rainbow", name: "Unicorn Magic", tagline: "Make a magic rainbow appear!", costume: "unicorn", timer: "ring",
    bg: ["#8A4FD8", "#3A1B6E"], primary: P.pink, lip: P.pinkLip, light: "#FFC2E8", text: "#FFFFFF",
    shapes: [P.pink, P.yellow, "#FFFFFF", P.blue], finale: "Rainbow magic!",
    stickers: S("rainbow", [["🌸","Blossom","common"],["🧁","Cupcake","common"],["🍭","Swirly Pop","common"],["🦋","Butterfly","rare"],["👑","Royal Crown","rare"],["🦄","Golden Unicorn","legendary"]]) },
  { id: "robot", name: "Robot Power", tagline: "Charge up to 100%!", costume: "robot", timer: "ring",
    bg: ["#1C2A31", "#0E171B"], primary: P.orange, lip: P.orangeLip, light: "#FFC56B", text: "#FFFFFF",
    shapes: [P.orange, P.border, P.blue], finale: "Fully charged!",
    stickers: S("robot", [["⚙️","Gear Spin","common"],["💡","Bright Idea","common"],["🔧","Wrench","common"],["🛰️","Satellite","rare"],["🦾","Robo Arm","rare"],["👾","Pixel Legend","legendary"]]) },
];
const PICTURES = ["cat", "dog", "bunny", "panda", "fox", "frog"];
const VARIANT_NAMES = { cat: "Kitty", dog: "Puppy", shark: "Shark", crab: "Crab", bunny: "Bunny", owl: "Owl", turtle: "Turtle", bear: "Bear", fish: "Fish" };
/** which jar animal / hidden picture each theme uses next; they take turns */
const variants = {
  list(theme) { return theme.timer === "sandJar" ? theme.jarPets : theme.timer === "tiles" ? PICTURES : theme.timer === "coloring" ? DINO_ORDER : []; },
  index(theme) { const l = this.list(theme); return l.length ? (store.get("variant." + theme.id, 0) % l.length + l.length) % l.length : 0; },
  current(theme) { return this.list(theme)[this.index(theme)]; },
  advance(theme) { if (this.list(theme).length) store.set("variant." + theme.id, this.index(theme) + 1); },
};
const RARITY = {
  common: { label: "Cool find", color: P.blue, lip: P.blueLip, weight: 60 },
  rare: { label: "Rare!", color: P.purple, lip: P.purpleLip, weight: 30 },
  legendary: { label: "Legendary!!", color: P.yellow, lip: P.yellowLip, weight: 10 },
};
// The 8 mouth zones, brushed in order. Screen-left is the kid's left (like a mirror).
const ZONES = [
  { key: "top_front", title: "Top Front", sym: "↑", top: true, sec: "front", look: 0 },
  { key: "top_left", title: "Top Left Side", sym: "↖", top: true, sec: "left", look: -1 },
  { key: "top_right", title: "Top Right Side", sym: "↗", top: true, sec: "right", look: 1 },
  { key: "top_inside", title: "Inside Top Teeth", sym: "⤵", top: true, sec: null, look: 0 },
  { key: "bottom_front", title: "Bottom Front", sym: "↓", top: false, sec: "front", look: 0 },
  { key: "bottom_left", title: "Bottom Left Side", sym: "↙", top: false, sec: "left", look: -1 },
  { key: "bottom_right", title: "Bottom Right Side", sym: "↘", top: false, sec: "right", look: 1 },
  { key: "bottom_inside", title: "Inside Bottom + Tongue", sym: "⤴", top: false, sec: null, look: 0 },
];
const RAINBOW = [P.red, P.orange, P.yellow, P.green, P.teal, P.blue, P.purple, P.pink];
const MARBLES = [[P.blue, P.blueLip], [P.yellow, P.yellowLip], [P.green, P.greenLip], [P.pink, P.pinkLip],
  [P.orange, P.orangeLip], [P.purple, P.purpleLip], [P.red, P.redLip]];
const VOICE_LINES = ["intro", ...ZONES.map(z => z.key), "finale", "cheer1", "cheer2", "cheer3"];
const SFX = ["tap", "chime", "sparkle", "beep", "beep_final", "whoosh", "boom", "rattle", "pop", "fanfare", "star", "clack", "flip", "zone"];

// ============================================================ storage (this browser only)
const store = {
  get(k, d) { try { const v = localStorage.getItem("bb." + k); return v == null ? d : JSON.parse(v); } catch (e) { return d; } },
  set(k, v) { try { localStorage.setItem("bb." + k, JSON.stringify(v)); } catch (e) { /* private mode: keep going */ } },
};
const settings = {
  themeId: store.get("theme", "marble"),
  duration: [30, 60, 90].includes(store.get("duration", 60)) ? store.get("duration", 60) : 60,
  music: store.get("music", true),
  voice: store.get("voice", true),
};
const themeById = id => THEMES.find(t => t.id === id) || THEMES[0];

const rewards = {
  counts: store.get("counts", {}), streak: store.get("streak", 0), last: store.get("lastDay", null), lastWasNew: false,
  dayNum(d) { const x = new Date(d); return Math.floor(new Date(x.getFullYear(), x.getMonth(), x.getDate()).getTime() / 864e5); },
  init() { if (this.last != null && this.dayNum(Date.now()) - this.last > 1) this.streak = 0; },
  get collected() { return Object.keys(this.counts).length; },
  get total() { return THEMES.reduce((a, t) => a + t.stickers.length, 0); },
  award(theme, jackpot = false) {
    const regular = theme.stickers.filter(s => s.rarity !== "legendary");
    const missing = regular.filter(s => !this.counts[s.id]);
    const pool = jackpot ? theme.stickers.filter(s => s.rarity === "legendary")
      : (missing.length && Math.random() < 0.7 ? missing : regular);
    let roll = Math.random() * pool.reduce((a, s) => a + RARITY[s.rarity].weight, 0), pick = pool[0];
    for (const s of pool) { roll -= RARITY[s.rarity].weight; if (roll < 0) { pick = s; break; } }
    this.lastWasNew = !this.counts[pick.id];
    this.counts[pick.id] = (this.counts[pick.id] || 0) + 1;
    const today = this.dayNum(Date.now());
    if (this.last == null) this.streak = 1;
    else if (today - this.last === 1) this.streak += 1;
    else if (today - this.last > 1) this.streak = 1;
    else if (this.streak === 0) this.streak = 1;
    this.last = today;
    store.set("counts", this.counts); store.set("streak", this.streak); store.set("lastDay", this.last);
    return pick;
  },
};
rewards.init();

// ============================================================ audio (Web Audio)
const AudioEngine = {
  ctx: null, master: null, musicGain: null, buffers: {}, pending: {}, music: null, voice: null, queue: [],
  speaking: false, rate: 1, musicVol: 0.45, duckVol: 0.12,
  init() {
    if (this.ctx) return;
    const AC = window.AudioContext || window.webkitAudioContext;
    if (!AC) return;
    this.ctx = new AC();
    this.master = this.ctx.createGain(); this.master.connect(this.ctx.destination);
    this.musicGain = this.ctx.createGain(); this.musicGain.gain.value = 0; this.musicGain.connect(this.master);
  },
  unlock() { this.init(); if (this.ctx && this.ctx.state !== "running") this.ctx.resume().catch(() => {}); },
  load(file) {
    this.init();
    if (!this.ctx) return Promise.resolve(null);
    if (this.buffers[file]) return Promise.resolve(this.buffers[file]);
    if (!this.pending[file]) {
      this.pending[file] = fetch("audio/" + file).then(r => r.arrayBuffer())
        .then(b => new Promise((ok, bad) => this.ctx.decodeAudioData(b, ok, bad)))
        .then(buf => (this.buffers[file] = buf))
        .catch(() => null);
    }
    return this.pending[file];
  },
  loadTheme(id) {
    return Promise.all([this.load("music_" + id + ".wav"), ...VOICE_LINES.map(l => this.load("voice_" + id + "_" + l + ".mp4"))]);
  },
  play(name, vol = 1) {
    const buf = this.buffers["sfx_" + name + ".wav"];
    if (!buf || !this.ctx) return;
    const src = this.ctx.createBufferSource(), g = this.ctx.createGain();
    src.buffer = buf; g.gain.value = vol; src.connect(g); g.connect(this.master); src.start();
  },
  /** background effects during brushing: always quiet, and quieter while the narrator talks */
  playQuiet(name, vol) { this.play(name, this.speaking ? vol * 0.35 : vol); },
  say(theme, line) {
    if (!settings.voice) return;
    this.queue.push({ file: "voice_" + theme + "_" + line + ".mp4", at: performance.now() });
    if (!this.speaking) this.next();
  },
  sayNow(theme, line) {
    if (!settings.voice) return;
    this.stopVoice();
    this.say(theme, line);
  },
  next() {
    const now = performance.now();
    this.queue = this.queue.filter(q => now - q.at < 6000);
    const item = this.queue.shift();
    if (!item) { this.speaking = false; this.duck(false); return; }
    const buf = this.buffers[item.file];
    if (!buf || !this.ctx) { this.next(); return; }
    const src = this.ctx.createBufferSource();
    src.buffer = buf; src.playbackRate.value = this.rate; src.connect(this.master);
    src.onended = () => { if (this.voice === src) { this.voice = null; this.next(); } };
    this.voice = src; this.speaking = true; this.duck(true); src.start();
  },
  stopVoice() {
    this.queue = [];
    if (this.voice) { const v = this.voice; this.voice = null; try { v.stop(); } catch (e) {} }
    this.speaking = false; this.duck(false);
  },
  duck(on) {
    if (!this.ctx || !this.music) return;
    this.musicGain.gain.setTargetAtTime(on ? this.duckVol : this.musicVol, this.ctx.currentTime, on ? 0.08 : 0.25);
  },
  startMusic(id) {
    this.stopMusic();
    const buf = this.buffers["music_" + id + ".wav"];
    if (!settings.music || !buf || !this.ctx) return;
    const src = this.ctx.createBufferSource();
    src.buffer = buf; src.loop = true; src.connect(this.musicGain);
    this.musicGain.gain.cancelScheduledValues(this.ctx.currentTime);
    this.musicGain.gain.setValueAtTime(0, this.ctx.currentTime);
    this.musicGain.gain.linearRampToValueAtTime(this.speaking ? this.duckVol : this.musicVol, this.ctx.currentTime + 1);
    src.start(); this.music = src;
  },
  stopMusic(fade = 0) {
    const m = this.music; if (!m) return; this.music = null;
    if (fade > 0 && this.ctx) {
      this.musicGain.gain.setTargetAtTime(0, this.ctx.currentTime, fade / 3);
      setTimeout(() => { try { m.stop(); } catch (e) {} }, fade * 1000 + 50);
    } else { try { m.stop(); } catch (e) {} }
  },
  pauseAll() { if (this.ctx) this.ctx.suspend().catch(() => {}); },
  resumeAll() { if (this.ctx) this.ctx.resume().catch(() => {}); },
};
const buzz = ms => { try { navigator.vibrate && navigator.vibrate(ms); } catch (e) {} };

// ============================================================ drawing helpers
function fitCanvas(cv) {
  const r = cv.getBoundingClientRect();
  const dpr = Math.min(window.devicePixelRatio || 1, 2);
  const w = Math.max(1, Math.round(r.width * dpr)), h = Math.max(1, Math.round(r.height * dpr));
  if (cv.width !== w || cv.height !== h) { cv.width = w; cv.height = h; }
  const ctx = cv.getContext("2d");
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.clearRect(0, 0, r.width, r.height);
  return { ctx, w: r.width, h: r.height };
}
const rad = d => d * Math.PI / 180;
function ell(ctx, cx, cy, rx, ry, fill, rot = 0) {
  ctx.beginPath(); ctx.ellipse(cx, cy, Math.max(rx, 0.01), Math.max(ry, 0.01), rot, 0, Math.PI * 2);
  if (fill) { ctx.fillStyle = fill; ctx.fill(); }
}
function circ(ctx, cx, cy, r, fill) { ell(ctx, cx, cy, r, r, fill); }
function rrect(ctx, x, y, w, h, r) {
  r = Math.max(0, Math.min(r, w / 2, h / 2));
  ctx.beginPath();
  ctx.moveTo(x + r, y); ctx.arcTo(x + w, y, x + w, y + h, r); ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r); ctx.arcTo(x, y, x + w, y, r); ctx.closePath();
}
function fillRR(ctx, x, y, w, h, r, fill) { rrect(ctx, x, y, w, h, r); ctx.fillStyle = fill; ctx.fill(); }
/** capsule centered at cx,cy with size w,h, rotated by deg */
function capsule(ctx, cx, cy, w, h, fill, deg = 0) {
  ctx.save(); ctx.translate(cx, cy); ctx.rotate(rad(deg)); fillRR(ctx, -w / 2, -h / 2, w, h, Math.min(w, h) / 2, fill); ctx.restore();
}
/** triangle (point up) centered at cx,cy */
function tri(ctx, cx, cy, w, h, fill, deg = 0) {
  ctx.save(); ctx.translate(cx, cy); ctx.rotate(rad(deg));
  ctx.beginPath(); ctx.moveTo(0, -h / 2); ctx.lineTo(w / 2, h / 2); ctx.lineTo(-w / 2, h / 2); ctx.closePath();
  ctx.fillStyle = fill; ctx.fill(); ctx.restore();
}
function sparkle(ctx, cx, cy, s, fill, deg = 0) {
  ctx.save(); ctx.translate(cx, cy); ctx.rotate(rad(deg));
  const r = s / 2; ctx.beginPath(); ctx.moveTo(0, -r);
  ctx.quadraticCurveTo(0, 0, r, 0); ctx.quadraticCurveTo(0, 0, 0, r); ctx.quadraticCurveTo(0, 0, -r, 0); ctx.quadraticCurveTo(0, 0, 0, -r);
  ctx.closePath(); ctx.fillStyle = fill; ctx.fill(); ctx.restore();
}
function halfDome(ctx, x, y, w, h, fill) {
  ctx.beginPath(); ctx.moveTo(x, y + h);
  ctx.bezierCurveTo(x, y - h * 0.3, x + w, y - h * 0.3, x + w, y + h); ctx.closePath();
  ctx.fillStyle = fill; ctx.fill();
}
/** small repeatable random numbers */
function seeded(seed) {
  let s = seed >>> 0 || 1;
  return () => { s = (s + 0x6D2B79F5) >>> 0; let t = s; t = Math.imul(t ^ (t >>> 15), t | 1); t ^= t + Math.imul(t ^ (t >>> 7), t | 61); return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
}
function shuffle(a, rnd = Math.random) { for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(rnd() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; }
const hash = i => { const v = Math.sin(i) * 43758.5453; return v - Math.floor(v); };

// ============================================================ Chompy the tooth mascot
/** draws Chompy with his top-left at x,y; `size` is his width (height is size * 1.15) */
function drawMascot(ctx, x, y, size, o, t) {
  ctx.save(); ctx.translate(x, y); ctx.scale(size / 200, size / 200);
  const cheer = o.mood === "cheer";
  const bounce = cheer ? Math.abs(Math.sin(t * 6)) * 26 : Math.sin(t * 2.2) * 3;
  const squash = cheer ? 1 + Math.abs(Math.cos(t * 6)) * 0.04 : 1;
  ctx.globalAlpha = 0.22; ell(ctx, 100, 222, (120 - bounce) / 2, 7, "#000"); ctx.globalAlpha = 1;
  ctx.save(); ctx.translate(0, -bounce); ctx.translate(100, 230); ctx.scale(squash, 2 - squash); ctx.translate(-100, -230);
  costumeBack(ctx, o.costume, t);
  arm(ctx, 30, 140, cheer ? 150 + Math.sin(t * 12) * 12 : 25 + Math.sin(t * 2) * 4);
  // tooth body, two-tone shading
  toothPath(ctx, 20, 38, 160, 172); ctx.fillStyle = P.toothShade; ctx.fill();
  ctx.save(); ctx.beginPath(); ctx.rect(20, 0, 118, 230); ctx.clip(); toothPath(ctx, 20, 38, 160, 172); ctx.fillStyle = "#fff"; ctx.fill(); ctx.restore();
  face(ctx, o, t);
  costumeFront(ctx, o.costume, t);
  const wiggle = o.brushing ? Math.sin(t * 16) * 12 : Math.sin(t * 2.4) * 5;
  arm(ctx, 166, 138, cheer ? -160 + Math.sin(t * 12) * 12 : -145 + wiggle, true);
  ctx.restore(); ctx.restore();
}
function toothPath(ctx, x0, y0, w, h) {
  const p = (x, y) => [x0 + x * w, y0 + y * h];
  const segs = [[[0.03, -0.02], [0.36, -0.02], [0.5, 0.1]], [[0.64, -0.02], [0.97, -0.02], [0.94, 0.3]], [[0.92, 0.55], [0.88, 0.66], [0.84, 0.8]],
    [[0.82, 0.92], [0.78, 1], [0.7, 1]], [[0.62, 1], [0.6, 0.86], [0.56, 0.82]], [[0.53, 0.77], [0.47, 0.77], [0.44, 0.82]],
    [[0.4, 0.86], [0.38, 1], [0.3, 1]], [[0.22, 1], [0.18, 0.92], [0.16, 0.8]], [[0.12, 0.66], [0.08, 0.55], [0.06, 0.3]]];
  ctx.beginPath(); ctx.moveTo(...p(0.06, 0.3));
  for (const [a, b, c] of segs) ctx.bezierCurveTo(...p(...a), ...p(...b), ...p(...c));
  ctx.closePath();
}
function arm(ctx, x, y, deg, withBrush) {
  ctx.save(); ctx.translate(x, y); ctx.rotate(rad(deg));
  rrect(ctx, -10, -4, 20, 52, 10); ctx.fillStyle = "#fff"; ctx.fill(); ctx.lineWidth = 3; ctx.strokeStyle = P.toothShade; ctx.stroke();
  if (withBrush) { ctx.translate(0, 70); ctx.rotate(Math.PI); drawBrush(ctx, 22, 84, P.blue); }
  ctx.restore();
}
/** flat toothbrush centered at the origin: bristles at the top, handle down */
function drawBrush(ctx, w, h, color) {
  ctx.save(); ctx.translate(-w / 2, -h / 2);
  fillRR(ctx, -0.25 * w, 0, 0.9 * w, 0.16 * h, 3, "#9BE7FF");
  fillRR(ctx, 0.225 * w, 0.05 * h, 0.55 * w, 0.95 * h, 0.275 * w, color);
  ctx.globalAlpha = 0.35; fillRR(ctx, 0.33 * w, 0.3 * h, 0.14 * w, 0.55 * h, 0.07 * w, "#fff"); ctx.globalAlpha = 1;
  ctx.restore();
}
function face(ctx, o, t) {
  ctx.globalAlpha = 0.75; circ(ctx, 50, 138, 11, P.cheek); circ(ctx, 150, 138, 11, P.cheek); ctx.globalAlpha = 1;
  const blink = (t % 3.7) < 0.12 && o.mood !== "wow";
  const sy = blink ? 0.1 : (o.mood === "wow" ? 1.15 : 1);
  const look = o.look || 0;
  const px = look * 6 + (look === 0 ? Math.sin(t * 0.7) * 2 : 0), py = o.mood === "cheer" ? -4 : 3;
  for (const ex of [72, 128]) {
    ctx.save(); ctx.translate(ex, 108); ctx.scale(1, sy);
    ell(ctx, 0, 0, 18, 21, "#fff"); ctx.lineWidth = 3; ctx.strokeStyle = P.toothShade; ctx.stroke();
    circ(ctx, px, py, 9, P.pupil); circ(ctx, px + 3, py - 4, 3, "#fff");
    ctx.restore();
  }
  if (o.mood === "wow") {
    ell(ctx, 100, 150, 14, 17, P.mouth); ell(ctx, 100, 156, 8, 5, P.tongue);
    return;
  }
  const open = o.talking ? 0.35 + 0.65 * Math.abs(Math.sin(t * 14)) : (o.mood === "cheer" ? 1 : 0.55);
  const w = 48, h = Math.max(8, 34 * open), x = 76, y = 133, c = Math.min(h * 0.3, 8);
  ctx.save();
  ctx.beginPath(); ctx.moveTo(x + c, y); ctx.lineTo(x + w - c, y); ctx.quadraticCurveTo(x + w, y, x + w, y + c);
  ctx.bezierCurveTo(x + w, y + h * 1.3, x, y + h * 1.3, x, y + c); ctx.quadraticCurveTo(x, y, x + c, y); ctx.closePath();
  ctx.fillStyle = P.mouth; ctx.fill(); ctx.clip();
  circ(ctx, x + w - 18, y + h - 4, 12, P.tongue);
  ctx.restore();
}
function costumeBack(ctx, c, t) {
  if (c === "dinoHood") {
    for (let i = 0; i < 4; i++) tri(ctx, 58 + i * 28, 42 - (i === 1 || i === 2 ? 8 : 0), 30, 34, i % 2 === 0 ? P.green : P.greenLip, (i - 2) * 14 + 7);
    tri(ctx, 18, 190, 40, 60, P.green, -70 + Math.sin(t * 3) * 8);
  } else if (c === "unicorn") {
    [[72, 34], [50, 42], [34, 60], [26, 84], [24, 110]].forEach(([x, y], i) => circ(ctx, x, y, 19, i % 2 === 0 ? P.pink : P.purple));
  } else if (c === "snorkel") {
    capsule(ctx, 100, 104, 176, 10, P.orange);
  } else if (c === "robot") {
    capsule(ctx, 100, 40, 7, 34, P.border);
    ctx.globalAlpha = 0.6 + 0.4 * Math.abs(Math.sin(t * 3)); circ(ctx, 100, 22, 10, P.red);
    ctx.globalAlpha *= 0.5; circ(ctx, 97, 19, 3, "#fff"); ctx.globalAlpha = 1;
  } else if (c === "helmet") {   // jetpack with flickering flames
    for (const x of [16, 184]) {
      const f = 0.8 + 0.25 * Math.abs(Math.sin(t * 18 + x));
      tri(ctx, x, 178 + 17 * f, 22, 34 * f, P.orange, 180);
      tri(ctx, x, 176 + 10 * f, 12, 20 * f, P.yellow, 180);
      fillRR(ctx, x - 15, 98, 30, 76, 12, "#B9C7D1");
      ctx.save(); rrect(ctx, x - 15, 98, 30, 76, 12); ctx.clip(); ctx.fillStyle = P.blue; ctx.fillRect(x - 15, 148, 30, 12); ctx.restore();
    }
  }
}
function costumeFront(ctx, c, t) {
  if (c === "helmet") {
    capsule(ctx, 100, 34, 7, 30, P.border);
    sparkle(ctx, 100, 16, 30, P.yellow, Math.sin(t * 2) * 15);
  } else if (c === "snorkel") {
    rrect(ctx, 41, 79, 118, 58, 22); ctx.fillStyle = "rgba(155,231,255,0.35)"; ctx.fill(); ctx.lineWidth = 7; ctx.strokeStyle = P.orange; ctx.stroke();
    capsule(ctx, 176, 76, 13, 86, P.yellow); capsule(ctx, 176, 34, 17, 14, P.orange);
  } else if (c === "unicorn") {
    tri(ctx, 100, 22, 30, 58, P.yellow);
    for (let i = 0; i < 3; i++) capsule(ctx, 100, 22 + 14 - i * 13, 16 - i * 4, 4, P.yellowLip, -18);
  } else if (c === "robot") {
    for (const x of [14, 186]) { fillRR(ctx, x - 8, 97, 16, 30, 5, P.border); circ(ctx, x, 112, 3.5, P.orange); }
  } else if (c === "propeller") {
    ctx.save(); ctx.beginPath(); ctx.moveTo(44, 59); ctx.bezierCurveTo(44, -6, 156, -6, 156, 59); ctx.closePath(); ctx.clip();
    ctx.fillStyle = P.red; ctx.fillRect(40, 0, 120, 60);
    ctx.fillStyle = P.blue; ctx.fillRect(44, 0, 22, 60); ctx.fillRect(134, 0, 22, 60);
    ctx.fillStyle = P.yellow; ctx.fillRect(87, 0, 26, 60); ctx.restore();
    capsule(ctx, 100, 59, 120, 12, P.redLip); capsule(ctx, 100, 4, 5, 16, P.border);
    ctx.save(); ctx.translate(100, -4); ctx.scale(Math.cos(t * 18) || 0.01, 1);
    ell(ctx, -15, 0, 15, 5, P.green); ell(ctx, 15, 0, 15, 5, P.purple); ctx.restore();
    circ(ctx, 100, -4, 4.5, P.yellow);
  } else if (c === "sunHat") {
    ell(ctx, 100, 58, 84, 15, "#E0A905"); ell(ctx, 100, 55, 84, 13, P.yellow);
    halfDome(ctx, 48, 6, 104, 48, P.yellow);
    ctx.fillStyle = P.teal; ctx.fillRect(48, 43, 104, 10); circ(ctx, 140, 46, 9, P.pink);
  } else if (c === "beret") {
    ctx.save(); ctx.translate(92, 40); ctx.rotate(rad(-10));
    ell(ctx, 0, 4, 65, 23, P.purpleLip); ell(ctx, 0, 0, 65, 23, P.purple); capsule(ctx, 0, -28, 6, 16, P.purpleLip);
    ctx.restore();
  }
}

// ============================================================ mouth picture (where to brush)
const mouthState = { bx: null, by: null };
function drawMouth(ctx, w, h, zoneIdx, theme, t) {
  const zone = ZONES[zoneIdx];
  const oh = h * 0.92, ow = Math.min(w * 0.9, oh * 1.75), lip = h * 0.11;
  const iw = ow - lip * 2, ih = oh - lip * 2, cx = w / 2, cy = h / 2;
  ell(ctx, cx, cy + 5, ow / 2, oh / 2, "#D94F78");
  ell(ctx, cx, cy, ow / 2, oh / 2, "#FF6F96");
  // inside: throat, uvula, tongue
  ctx.save(); ell(ctx, cx, cy, iw / 2, ih / 2); ctx.clip();
  ell(ctx, cx, cy, iw / 2, ih / 2, "#9E2342");
  ell(ctx, cx, cy - ih * 0.02, iw * 0.21, ih * 0.25, "#5C0F25");
  capsule(ctx, cx, cy - ih * 0.2, iw * 0.035, ih * 0.2, "#9E2342");
  const glow = zoneIdx === 7, ts = glow ? 1 + 0.03 * Math.sin(t * 8) : 1, ty = cy + ih * 0.3;
  ell(ctx, cx, ty + 4, iw * 0.25 * ts, ih * 0.26 * ts, "#E86F8C");
  ell(ctx, cx, ty, iw * 0.25 * ts, ih * 0.26 * ts, glow ? theme.light : "#FF8FA8");
  ctx.globalAlpha = 0.08; capsule(ctx, cx, ty - ih * 0.04, 3, ih * 0.18, "#000");
  ctx.globalAlpha = 0.35; capsule(ctx, cx + iw * 0.1, ty - ih * 0.06, iw * 0.08, ih * 0.05, "#fff"); ctx.globalAlpha = 1;
  ctx.restore();
  // lip shine
  for (const [deg, len, op] of [[238, 0.22, 0.5], [60, 0.14, 0.35]]) {
    const a = rad(deg), rx = ow / 2 - lip / 2, ry = oh / 2 - lip / 2;
    ctx.globalAlpha = op;
    capsule(ctx, cx + Math.cos(a) * rx, cy + Math.sin(a) * ry, ow * len, lip * 0.3, "#fff", Math.atan2(Math.cos(a) * ry, -Math.sin(a) * rx) * 180 / Math.PI);
    ctx.globalAlpha = 1;
  }
  // teeth, spaced evenly around each half
  const N = 10, R = 0.84, rx = iw / 2 * R, ry = ih / 2 * R;
  const top = evenAngles(N, Math.PI, Math.PI * 2, rx, ry), bot = evenAngles(N, Math.PI, 0, rx, ry);
  const tw = top.len / N * 0.9;
  for (const isTop of [true, false]) {
    const angles = isTop ? top.angles : bot.angles;
    for (let i = 0; i < N; i++) {
      const a = angles[i];
      const sec = i <= 2 ? "left" : (i <= 6 ? "front" : "right");
      const active = zone.top === isTop && (zone.sec === null || zone.sec === sec);
      const inside = active && zone.sec === null;
      const front = i >= 3 && i <= 6, th = tw * (front ? 1.2 : 1), r = tw * 0.3;
      const rot = Math.atan2(Math.sin(a) / (ih / 2), Math.cos(a) / (iw / 2)) + Math.PI / 2;
      const sc = active ? 1.08 + 0.05 * Math.sin(t * 9 + i) : 1;
      ctx.save(); ctx.translate(cx + Math.cos(a) * rx, cy + Math.sin(a) * ry); ctx.rotate(rot); ctx.scale(sc, sc);
      fillRR(ctx, -tw / 2, -th / 2 + 3, tw, th, r, active ? theme.lip : P.toothShade);
      fillRR(ctx, -tw / 2, -th / 2, tw, th, r, active ? theme.primary : "#fff");
      if (inside) { rrect(ctx, -tw / 2, -th / 2, tw, th, r); ctx.setLineDash([3, 3]); ctx.lineWidth = 2; ctx.strokeStyle = "#fff"; ctx.stroke(); ctx.setLineDash([]); }
      ctx.restore();
    }
  }
  // the toothbrush scrubs over the spot to brush
  const angles = zone.top ? top.angles : bot.angles;
  const a = zone.sec === "left" ? angles[1] : zone.sec === "right" ? angles[N - 2] : (zone.top ? -Math.PI / 2 : Math.PI / 2);
  const sc = zone.sec === null ? 0.45 : 1.15;
  const tx = cx + Math.cos(a) * iw / 2 * sc, tyy = cy + Math.sin(a) * ih / 2 * sc;
  if (mouthState.bx == null) { mouthState.bx = tx; mouthState.by = tyy; }
  mouthState.bx += (tx - mouthState.bx) * 0.12; mouthState.by += (tyy - mouthState.by) * 0.12;
  const tilt = zone.sec === "left" ? (zone.top ? 45 : 135) : zone.sec === "right" ? (zone.top ? -45 : -135) : 90;
  ctx.save(); ctx.translate(mouthState.bx + Math.sin(t * 14) * 10, mouthState.by + Math.cos(t * 7) * 3); ctx.rotate(rad(tilt));
  drawBrush(ctx, h * 0.13, h * 0.5, theme.primary); ctx.restore();
}
const evenCache = {};
function evenAngles(n, a0, a1, rx, ry) {
  const key = [n, a0, a1, rx.toFixed(1), ry.toFixed(1)].join();
  if (evenCache[key]) return evenCache[key];
  const steps = 240, L = [0]; let px = Math.cos(a0) * rx, py = Math.sin(a0) * ry;
  for (let s = 1; s <= steps; s++) {
    const a = a0 + (a1 - a0) * s / steps, x = Math.cos(a) * rx, y = Math.sin(a) * ry;
    L.push(L[s - 1] + Math.hypot(x - px, y - py)); px = x; py = y;
  }
  const len = L[steps], angles = [];
  for (let k = 0; k < n; k++) { const target = len * (k + 0.5) / n; let i = 0; while (i < steps && L[i] < target) i++; angles.push(a0 + (a1 - a0) * i / steps); }
  return (evenCache[key] = { angles, len });
}

// ============================================================ timers
// ---- big countdown ring with Chompy inside
function drawRing(ctx, w, h, sess, t) {
  const th = sess.theme, d = Math.min(w, h - 2, 340), cx = w / 2, cy = h / 2;
  const line = d * 0.085, r = (d - line) / 2, rem = 1 - sess.progress;
  const hurry = sess.remaining <= 10, color = hurry ? P.red : th.primary, lip = hurry ? P.redLip : th.lip;
  ctx.globalAlpha = 0.28; circ(ctx, cx, cy, d / 2 - line / 2, "#000"); ctx.globalAlpha = 1;
  ctx.lineWidth = line; ctx.strokeStyle = P.border; ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI * 2); ctx.stroke();
  for (let i = 0; i < 8; i++) { const a = rad(-90 + i * 45); ctx.globalAlpha = 0.35; circ(ctx, cx + Math.cos(a) * r, cy + Math.sin(a) * r, line * 0.14, "#fff"); }
  ctx.globalAlpha = 1;
  const a0 = -Math.PI / 2, a1 = a0 + rem * Math.PI * 2;
  if (rem > 0.002) {
    ctx.lineCap = "round";
    ctx.strokeStyle = lip; ctx.beginPath(); ctx.arc(cx, cy + line * 0.14, r, a0, a1); ctx.stroke();
    ctx.strokeStyle = color; ctx.beginPath(); ctx.arc(cx, cy, r, a0, a1); ctx.stroke();
    ctx.lineWidth = line * 0.18; ctx.strokeStyle = "rgba(255,255,255,0.35)"; ctx.beginPath(); ctx.arc(cx, cy, r + line * 0.26, a0, a1); ctx.stroke();
    ctx.lineCap = "butt";
    circ(ctx, cx + Math.cos(a1) * r, cy + Math.sin(a1) * r, line * 0.45, "#fff");
    ctx.lineWidth = line * 0.18; ctx.strokeStyle = color; ctx.stroke();
  }
  const ms = d * 0.5;
  drawMascot(ctx, cx - ms / 2, cy - ms * 1.15 / 2 - d * 0.03, ms,
    { costume: th.costume, mood: sess.countdown ? "wow" : "happy", talking: AudioEngine.speaking, look: ZONES[sess.zone].look, brushing: true }, t);
  return cy + d / 2;      // where the time pill should sit
}

// ---- Marble Drop: plinko board that is exactly full when time runs out
let plinkoCache = null;
function plinkoModel(w, h, duration) {
  const key = [Math.round(w), Math.round(h), duration].join();
  if (plinkoCache && plinkoCache.key === key) return plinkoCache;
  const rnd = seeded(42), d = Math.max(14, Math.min(w / 16, h / 15));
  const cols = Math.floor(w / d), x0 = (w - cols * d) / 2 + d / 2, slots = [];
  for (let y = h - d / 2, row = 0; y > d * 0.4; y -= d * 0.866, row++) {
    const n = row % 2 === 0 ? cols : cols - 1, sx = row % 2 === 0 ? x0 : x0 + d / 2;
    const rowSlots = []; for (let c = 0; c < n; c++) rowSlots.push([sx + c * d, y]);
    slots.push(...shuffle(rowSlots, rnd));
  }
  const mx = (w - Math.floor(w / d) * d) / 2, maxM = Math.floor((w - mx) / d), pegRows = [], pegs = [];
  for (let py = d * 1.8, pr = 0; py < h - d * 1.2; py += d * 1.6, pr++) {
    const ms = []; for (let m = 1; m < maxM; m++) if (m % 2 === (pr % 2 === 0 ? 1 : 0)) ms.push(m);
    pegRows.push({ y: py, ms }); ms.forEach(m => pegs.push([mx + m * d, py]));
  }
  const finish = duration * 0.985, marbles = [];
  slots.forEach((slot, i) => {
    const rows = pegRows.filter(r => r.y < slot[1] - d * 0.9);
    let pts;
    if (!rows.length) pts = [[slot[0], -d], slot];
    else {
      const ms = new Array(rows.length), last = rows.length - 1;
      ms[last] = rows[last].ms.reduce((b, m) => Math.abs(mx + m * d - slot[0]) < Math.abs(mx + b * d - slot[0]) ? m : b, rows[last].ms[0]);
      for (let k = last - 1; k >= 0; k--) {
        const opts = rows[k].ms.filter(m => Math.abs(m - ms[k + 1]) === 1);
        ms[k] = opts.length ? opts[Math.floor(rnd() * opts.length)] : rows[k].ms[0];
      }
      pts = [[mx + ms[0] * d, -d], ...rows.map((r, k) => [mx + ms[k] * d, r.y - d * 0.55]), slot];
    }
    let cum = [0];
    for (let k = 1; k < pts.length; k++) {
      const dist = Math.hypot(pts[k][0] - pts[k - 1][0], pts[k][1] - pts[k - 1][1]) / d;
      cum.push(cum[k - 1] + (k === 1 ? 0.2 + dist * 0.035 : k === pts.length - 1 ? 0.1 + dist * 0.05 : 0.13));
    }
    const land = (i + 1) / slots.length * finish; let fall = cum[cum.length - 1];
    if (fall > land) { cum = cum.map(c => c * land / fall); fall = land; }
    marbles.push({ slot, pts, cum, land, start: land - fall, color: Math.floor(rnd() * 7) });
  });
  return (plinkoCache = { key, d, pegs, marbles, finish });
}
function marblePos(m, e, d) {
  if (e >= m.land) return m.slot;
  const u = e - m.start; let k = 0;
  while (k < m.cum.length - 2 && u >= m.cum[k + 1]) k++;
  const f = Math.min(Math.max((u - m.cum[k]) / Math.max(m.cum[k + 1] - m.cum[k], 1e-4), 0), 1);
  const [ax, ay] = m.pts[k], [bx, by] = m.pts[k + 1], x = ax + (bx - ax) * f;
  return k === 0 ? [x, ay + (by - ay) * f * f] : [x, ay + (by - ay) * f - Math.sin(Math.PI * f) * d * 0.45];
}
function drawMarble(ctx, x, y, r, ci) {
  const [main, lip] = MARBLES[ci % MARBLES.length];
  circ(ctx, x, y, r, lip); circ(ctx, x, y - r * 0.12, r * 0.86, main);
  ctx.globalAlpha = 0.75; circ(ctx, x - r * 0.38, y - r * 0.45, r * 0.24, "#fff"); ctx.globalAlpha = 1;
}
function drawPlinko(ctx, w, h, sess) {
  fillRR(ctx, 0, 5, w, h - 5, 24, P.border); fillRR(ctx, 0, 0, w, h - 5, 24, P.card);
  rrect(ctx, 2, 2, w - 4, h - 9, 22); ctx.lineWidth = 4; ctx.strokeStyle = P.border; ctx.stroke();
  const iw = w - 20, ih = h - 25, m = plinkoModel(iw, ih, sess.duration), e = sess.elapsed;
  ctx.save(); rrect(ctx, 10, 10, iw, ih, 16); ctx.clip(); ctx.translate(10, 10);
  const pr = m.d * 0.17;
  for (const [x, y] of m.pegs) { circ(ctx, x, y + 2, pr, P.border); ctx.globalAlpha = 0.85; circ(ctx, x, y, pr, "#fff"); ctx.globalAlpha = 1; }
  for (const mb of m.marbles) { if (mb.start > e) break; const [x, y] = marblePos(mb, e, m.d); drawMarble(ctx, x, y, m.d / 2, mb.color); }
  ctx.restore();
  const landed = Math.floor(Math.min(Math.max(e / m.finish, 0), 1) * m.marbles.length);
  if (landed > (sess.landed || 0)) AudioEngine.playQuiet("clack", 0.06);
  sess.landed = landed;
  return h - 5;
}

// ---- pet-shaped jars for the sand timers
const JARS = {
  cat: { aspect: 0.85, add: [["e", 0.08, 0.36, 0.92, 1.0], ["e", 0.14, 0.08, 0.86, 0.62], ["p", [[0.18, 0.26], [0.2, 0], [0.4, 0.12]]], ["p", [[0.82, 0.26], [0.8, 0], [0.6, 0.12]]]], cut: [], mouth: 0.5 },
  dog: { aspect: 0.85, add: [["e", 0.12, 0.44, 0.88, 1.0], ["e", 0.2, 0.06, 0.8, 0.58], ["e", 0.04, 0.1, 0.3, 0.5], ["e", 0.7, 0.1, 0.96, 0.5]], cut: [], mouth: 0.5 },
  shark: { aspect: 1.35, add: [["e", 0.02, 0.3, 0.8, 0.88], ["p", [[0.34, 0.36], [0.5, 0.02], [0.6, 0.36]]], ["p", [[0.72, 0.58], [0.98, 0.22], [0.9, 0.58], [0.98, 0.94]]], ["p", [[0.32, 0.8], [0.28, 0.99], [0.5, 0.82]]]], cut: [], mouth: 0.42 },
  bunny: { aspect: 0.75, add: [["e", 0.14, 0.44, 0.86, 1.0], ["e", 0.2, 0.2, 0.8, 0.68], ["e", 0.24, 0.0, 0.42, 0.44], ["e", 0.58, 0.0, 0.76, 0.44]], cut: [], mouth: 0.5 },
  owl: { aspect: 0.8, add: [["e", 0.1, 0.12, 0.9, 1.0], ["p", [[0.12, 0.34], [0.14, 0.0], [0.4, 0.18]]], ["p", [[0.88, 0.34], [0.86, 0.0], [0.6, 0.18]]]], cut: [], mouth: 0.5 },
  turtle: { aspect: 1.4, add: [["e", 0.1, 0.16, 0.8, 0.84], ["e", 0.72, 0.36, 0.98, 0.62], ["e", 0.14, 0.68, 0.32, 0.96], ["e", 0.56, 0.68, 0.74, 0.96], ["p", [[0.12, 0.54], [0.0, 0.6], [0.14, 0.64]]]], cut: [], mouth: 0.45 },
  bear: { aspect: 0.95, add: [["e", 0.08, 0.14, 0.92, 1.0], ["e", 0.04, 0.0, 0.34, 0.32], ["e", 0.66, 0.0, 0.96, 0.32]], cut: [], mouth: 0.5 },
  fish: { aspect: 1.4, add: [["e", 0.02, 0.18, 0.74, 0.86], ["p", [[0.66, 0.52], [1.0, 0.14], [0.9, 0.52], [1.0, 0.9]]], ["p", [[0.28, 0.24], [0.42, 0.02], [0.58, 0.22]]]], cut: [], mouth: 0.4 },
  crab: { aspect: 1.3, add: [["e", 0.2, 0.4, 0.8, 1.0], ["e", 0.01, 0.06, 0.27, 0.44], ["e", 0.73, 0.06, 0.99, 0.44],
    ["p", [[0.26, 0.66], [0.1, 0.42], [0.2, 0.36], [0.34, 0.54]]], ["p", [[0.74, 0.66], [0.9, 0.42], [0.8, 0.36], [0.66, 0.54]]],
    ["e", 0.37, 0.22, 0.47, 0.52], ["e", 0.53, 0.22, 0.63, 0.52], ["e", 0.07, 0.68, 0.27, 0.78], ["e", 0.73, 0.68, 0.93, 0.78], ["e", 0.1, 0.82, 0.3, 0.92], ["e", 0.7, 0.82, 0.9, 0.92]],
    cut: [[[0.14, 0.26], [0.09, 0], [0.2, 0]], [[0.86, 0.26], [0.8, 0], [0.91, 0]]], mouth: 0.5 },
};
function jarShapePath(ctx, spec, list, x, y, w, h) {
  ctx.beginPath();
  for (const s of list) {
    if (s[0] === "e") { const [, x0, y0, x1, y1] = s; ctx.moveTo(x + x1 * w, y + (y0 + y1) / 2 * h); ctx.ellipse(x + (x0 + x1) / 2 * w, y + (y0 + y1) / 2 * h, (x1 - x0) / 2 * w, (y1 - y0) / 2 * h, 0, 0, Math.PI * 2); }
    else { const pts = s[1]; ctx.moveTo(x + pts[0][0] * w, y + pts[0][1] * h); for (const p of pts.slice(1)) ctx.lineTo(x + p[0] * w, y + p[1] * h); ctx.closePath(); }
  }
}
const jarCache = {};
/** offscreen pieces for a jar at a given size: the shape mask, its outline, and how full it is at each height */
function jarAssets(pet, w, h) {
  const dpr = Math.min(window.devicePixelRatio || 1, 2), key = [pet, Math.round(w), Math.round(h), dpr].join();
  if (jarCache[key]) return jarCache[key];
  const spec = JARS[pet], pad = 8;
  const mk = () => { const c = document.createElement("canvas"); c.width = Math.ceil((w + pad * 2) * dpr); c.height = Math.ceil((h + pad * 2) * dpr); const x = c.getContext("2d"); x.setTransform(dpr, 0, 0, dpr, 0, 0); return [c, x]; };
  const [mask, mctx] = mk();
  mctx.fillStyle = "#fff"; jarShapePath(mctx, spec, spec.add.map(s => s), pad, pad, w, h); mctx.fill("nonzero");
  // the shape is a union of ellipses and triangles; fill each separately so overlaps never cancel out
  for (const s of spec.add) { jarShapePath(mctx, spec, [s], pad, pad, w, h); mctx.fill(); }
  mctx.globalCompositeOperation = "destination-out";
  for (const c of spec.cut) { jarShapePath(mctx, spec, [["p", c]], pad, pad, w, h); mctx.fill(); }
  mctx.globalCompositeOperation = "source-over";
  // outline: grow the mask a few pixels in every direction, then cut the mask back out
  const [outline, octx] = mk();
  for (let k = 0; k < 16; k++) { const a = k / 16 * Math.PI * 2; octx.drawImage(mask, Math.cos(a) * 3.2, Math.sin(a) * 3.2, mask.width / dpr, mask.height / dpr); }
  octx.globalCompositeOperation = "destination-out"; octx.drawImage(mask, 0, 0, mask.width / dpr, mask.height / dpr);
  // area below each height, from the mask pixels
  const img = mctx.getImageData(0, 0, mask.width, mask.height).data, rows = [];
  const y0 = Math.round(pad * dpr), y1 = Math.round((pad + h) * dpr);
  for (let y = y0; y < y1; y++) { let n = 0; for (let x = 0; x < mask.width; x += 2) if (img[(y * mask.width + x) * 4 + 3] > 128) n++; rows.push(n); }
  const total = rows.reduce((a, b) => a + b, 0) || 1, cum = [];
  let acc = 0; for (let i = rows.length - 1; i >= 0; i--) { acc += rows[i]; cum.push(acc / total); }
  const level = f => {     // fraction full -> distance from the jar top
    if (f <= 0) return h; if (f >= 1) return 0;
    let i = 0; while (i < cum.length - 1 && cum[i] < f) i++;
    const prev = i ? cum[i - 1] : 0, within = (f - prev) / Math.max(cum[i] - prev, 1e-4);
    return h - (i + within) / cum.length * h;
  };
  const [tmp, tctx] = mk();
  return (jarCache[key] = { mask, outline, tmp, tctx, level, pad, dpr });
}
function jarRect(pet, w, h, top = 26) {
  const a = JARS[pet].aspect, availH = h - top - 6;
  let jw = Math.min(w, availH * a), jh = jw / a;
  if (jh > availH) { jh = availH; jw = jh * a; }
  return { x: (w - jw) / 2, y: top, w: jw, h: jh };
}
function drawJarFace(ctx, pet, x, y, w, h) {
  const e = Math.min(w, h) * 0.07, P_ = (u, v) => [x + u * w, y + v * h];
  const eye = (u, v, s = 1) => { const [cx, cy] = P_(u, v), E = e * s; circ(ctx, cx, cy, E * 0.75, "#fff"); circ(ctx, cx, cy, E / 2, P.pupil); circ(ctx, cx + E * 0.15, cy - E * 0.2, E * 0.17, "#fff"); };
  const smile = (u, v, r, a0 = 0, a1 = Math.PI) => { const [cx, cy] = P_(u, v); ctx.beginPath(); ctx.arc(cx, cy, r, a0, a1); ctx.lineWidth = Math.max(2, e * 0.25); ctx.lineCap = "round"; ctx.strokeStyle = P.ink; ctx.stroke(); ctx.lineCap = "butt"; };
  if (pet === "cat" || pet === "dog") {
    eye(0.38, 0.3); eye(0.62, 0.3);
    const [nx, ny] = P_(0.5, 0.39); ell(ctx, nx, ny, e * 0.55, e * 0.37, pet === "cat" ? P.pink : P.ink);
    smile(0.5, 0.42, e * 0.7);
  } else if (pet === "crab") {
    eye(0.42, 0.31, 0.8); eye(0.58, 0.31, 0.8); smile(0.5, 0.64, e * 1.1);
    ctx.globalAlpha = 0.7; for (const u of [0.36, 0.64]) { const [cx, cy] = P_(u, 0.68); ell(ctx, cx, cy, e * 0.6, e * 0.35, P.pink); } ctx.globalAlpha = 1;
  } else if (pet === "bunny") {
    eye(0.4, 0.42); eye(0.6, 0.42);
    const [nx, ny] = P_(0.5, 0.5); ell(ctx, nx, ny, e * 0.5, e * 0.34, P.pink); smile(0.5, 0.53, e * 0.6);
  } else if (pet === "owl") {
    for (const u of [0.34, 0.66]) { const [cx, cy] = P_(u, 0.36); circ(ctx, cx, cy, e * 1.6, "rgba(255,255,255,0.85)"); }
    eye(0.34, 0.36, 1.5); eye(0.66, 0.36, 1.5);
    const [bx, by] = P_(0.5, 0.48); tri(ctx, bx, by, e * 1.1, e * 1.1, P.orange, 180);
  } else if (pet === "bear") {
    eye(0.36, 0.46); eye(0.64, 0.46);
    const [mx, my] = P_(0.5, 0.64); ell(ctx, mx, my, e * 1.6, e * 1.15, "rgba(255,255,255,0.75)");
    ell(ctx, mx, my - e * 0.45, e * 0.6, e * 0.4, P.ink); smile(0.5, 0.65, e * 0.55);
  } else if (pet === "turtle") {
    eye(0.88, 0.45, 0.8); smile(0.86, 0.5, e * 0.8, 0.2, 2.4);
  } else if (pet === "fish") {
    eye(0.18, 0.44); smile(0.12, 0.54, e * 1.1, 0.4, 2.6);
  } else {
    eye(0.18, 0.5); smile(0.16, 0.56, e * 1.5, 0.3, 2.8);
    ctx.globalAlpha = 0.5; for (let i = 0; i < 3; i++) { const [cx, cy] = P_(0.32 + i * 0.035, 0.55); capsule(ctx, cx, cy, 3, h * 0.1, P.ink); } ctx.globalAlpha = 1;
  }
}
function sandSurface(ctx, x0, x1, y, phase, mound) {
  ctx.beginPath();
  for (let x = x0 - 4, first = true; x <= x1 + 6; x += 6) {
    let yy = y + Math.sin(x / 22 + phase) * 4;
    if (mound != null) yy -= 9 * Math.exp(-(((x - mound) / 22) ** 2));
    first ? ctx.moveTo(x, yy) : ctx.lineTo(x, yy); first = false;
  }
}
/** sand jar: `fill` is 0...1; when `live` it pours with a stream and wavy layers (one per zone) */
function drawSandJar(ctx, pet, R, fill, t, opts = {}) {
  const A = jarAssets(pet, R.w, R.h), { pad, dpr } = A, live = !!opts.live;
  const show = opts.show == null ? 1 : opts.show;     // 0 = only the sand is visible (mystery shape)
  const cw = A.mask.width / dpr, chh = A.mask.height / dpr, ox = R.x - pad, oy = R.y - pad;
  // shadow + glass
  const tc = A.tctx; tc.clearRect(0, 0, cw, chh);
  tc.globalCompositeOperation = "source-over"; tc.drawImage(A.mask, 0, 0, cw, chh);
  tc.globalCompositeOperation = "source-in"; tc.fillStyle = "rgba(0,0,0,0.25)"; tc.fillRect(0, 0, cw, chh);
  ctx.globalAlpha = show; ctx.drawImage(A.tmp, ox, oy + 5, cw, chh); ctx.globalAlpha = 1;
  tc.globalCompositeOperation = "source-over"; tc.clearRect(0, 0, cw, chh); tc.drawImage(A.mask, 0, 0, cw, chh);
  tc.globalCompositeOperation = "source-in"; tc.fillStyle = opts.glass || "rgba(255,255,255,0.1)"; tc.fillRect(0, 0, cw, chh);
  ctx.globalAlpha = show; ctx.drawImage(A.tmp, ox, oy, cw, chh); ctx.globalAlpha = 1;
  // sand layers, masked to the jar
  const layers = live ? 8 : 4, cur = live ? Math.min(Math.floor(fill * 8), 7) : layers - 1;
  const streamX = R.x + R.w * (JARS[pet].mouth + (live ? 0.1 * Math.sin(t * 0.5) : 0));
  if (fill > 0) {
    tc.globalCompositeOperation = "source-over"; tc.clearRect(0, 0, cw, chh);
    for (let k = cur; k >= 0; k--) {
      const f = live ? (k === cur ? fill : (k + 1) / 8) : fill * (k + 1) / layers;
      const top = pad + (live ? A.level(f) : R.h * (1 - f));
      if (live) sandSurface(tc, pad, pad + R.w, top, k * 1.7, k === cur && opts.pouring ? streamX - ox : null);
      else { tc.beginPath(); tc.moveTo(0, top); tc.lineTo(cw, top); }
      tc.lineTo(cw, chh); tc.lineTo(0, chh); tc.closePath(); tc.fillStyle = RAINBOW[k]; tc.fill();
      if (live) { sandSurface(tc, pad, pad + R.w, top, k * 1.7, k === cur && opts.pouring ? streamX - ox : null); tc.lineWidth = 3; tc.strokeStyle = "rgba(255,255,255,0.35)"; tc.stroke(); }
    }
    tc.globalCompositeOperation = "destination-in"; tc.drawImage(A.mask, 0, 0, cw, chh);
    tc.globalCompositeOperation = "source-over";
    ctx.drawImage(A.tmp, ox, oy, cw, chh);
  }
  // pouring stream
  if (live && opts.pouring) {
    const level = R.y + A.level(fill), col = RAINBOW[cur];
    fillRR(ctx, streamX - 3, 0, 6, Math.max(level - 4, 0), 3, col);
    for (let g = 0; g < 10; g++) {
      const span = Math.max(level, 1), gy = (t * 260 + g * span / 10) % span;
      circ(ctx, streamX + Math.sin(g * 2.3 + t * 3) * 5, gy, 2, col);
    }
  }
  if (show <= 0) return;
  ctx.globalAlpha = 0.92 * show; ctx.drawImage(A.outline, ox, oy, cw, chh);
  if (live) { ctx.globalAlpha = 0.4 * show; capsule(ctx, R.x + R.w * 0.2, R.y + R.h * 0.62, 9, R.h * 0.22, "#fff", 12); }
  ctx.globalAlpha = show; drawJarFace(ctx, pet, R.x, R.y, R.w, R.h); ctx.globalAlpha = 1;
}
function drawSandTimer(ctx, w, h, sess, t) {
  const R = jarRect(sess.pet, w, h);
  const show = sess.theme.mystery ? Math.min(Math.max((sess.progress - 0.955) / 0.03, 0), 1) : 1;
  drawSandJar(ctx, sess.pet, R, sess.progress, t, { live: true, pouring: sess.progress < 1 && !sess.paused, show });
  return R.y + R.h;
}

// ---- Secret Picture: tiles flip to reveal a cat or puppy
const picCache = {};
function petPicture(pet, w, h) {
  const dpr = Math.min(window.devicePixelRatio || 1, 2), key = [pet, Math.round(w), Math.round(h), dpr].join();
  if (picCache[key]) return picCache[key];
  const c = document.createElement("canvas"); c.width = Math.ceil(w * dpr); c.height = Math.ceil(h * dpr);
  const x = c.getContext("2d"); x.setTransform(dpr, 0, 0, dpr, 0, 0);
  const bgCol = { cat: "#FFE8A3", dog: "#BDE8FF", bunny: "#D9F7C9", panda: "#FFD6E5", fox: "#CDEBFF", frog: "#FFF1B8" }[pet] || "#FFE8A3";
  const rayCol = { cat: "#FFD36B", dog: "#8FD3FF", bunny: "#B4EC98", panda: "#FFB3CF", fox: "#9FD6FF", frog: "#FFE07A" }[pet] || "#FFD36B";
  x.fillStyle = bgCol; x.fillRect(0, 0, w, h);
  // sunburst rays fill the whole picture
  const cx = w / 2, cy = h * 0.56, R = Math.hypot(w, h);
  x.fillStyle = rayCol;
  for (let i = 0; i < 16; i++) { const a = i / 16 * Math.PI * 2; x.beginPath(); x.moveTo(cx, cy); x.arc(cx, cy, R, a, a + Math.PI / 16); x.closePath(); x.fill(); }
  // soft glow behind the face
  const glow = x.createRadialGradient(cx, cy, 0, cx, cy, Math.min(w, h) * 0.6);
  glow.addColorStop(0, "rgba(255,255,255,0.75)"); glow.addColorStop(1, "rgba(255,255,255,0)");
  x.fillStyle = glow; x.fillRect(0, 0, w, h);
  // hearts and sparkles all around the edges
  for (let i = 0; i < 18; i++) {
    const a = hash(i * 7 + 40), b = hash(i * 13 + 41), cc = hash(i * 17 + 42);
    const px = w * (0.04 + 0.92 * b), py = h * (0.03 + 0.94 * cc);
    if (i % 2 === 0) { x.globalAlpha = 0.8; heart(x, px, py, 16 + a * 18, P.pink); }
    else { x.globalAlpha = 0.9; sparkle(x, px, py, 18 + a * 14, "#fff"); }
  }
  x.globalAlpha = 1;
  // the animal, as big as the picture allows
  const s = Math.min(w * 1.08, h * 0.86);
  drawPetFace(x, pet, cx - s / 2, cy - s / 2, s);
  return (picCache[key] = c);
}
function heart(ctx, cx, cy, s, fill) {
  ctx.save(); ctx.translate(cx, cy); ctx.scale(s / 20, s / 20); ctx.beginPath();
  ctx.moveTo(0, 6); ctx.bezierCurveTo(-10, -2, -8, -10, 0, -5); ctx.bezierCurveTo(8, -10, 10, -2, 0, 6);
  ctx.fillStyle = fill; ctx.fill(); ctx.restore();
}
function drawPetFace(ctx, pet, x, y, s) {
  const A = (u, v) => [x + u * s, y + v * s];
  const eyes = (v, spread) => { for (const k of [-1, 1]) { const [cx, cy] = A(0.5 + k * spread, v); ell(ctx, cx, cy, s * 0.055, s * 0.07, P.ink); circ(ctx, cx + s * 0.015, cy - s * 0.03, s * 0.02, "#fff"); } };
  const cheeks = v => { ctx.globalAlpha = 0.6; for (const k of [-1, 1]) { const [cx, cy] = A(0.5 + k * 0.25, v); ell(ctx, cx, cy, s * 0.05, s * 0.03, P.pink); } ctx.globalAlpha = 1; };
  if (pet === "bunny") {
    const fur = "#F4F1FA", furLip = "#D9D2E8";
    for (const [u, d] of [[0.36, -8], [0.64, 8]]) { ell(ctx, ...A(u, 0.22), s * 0.09, s * 0.23, fur, rad(d)); ell(ctx, ...A(u, 0.24), s * 0.045, s * 0.16, P.cheek, rad(d)); }
    const [hx, hy] = A(0.5, 0.62); ell(ctx, hx, hy + s * 0.02, s * 0.36, s * 0.3, furLip); ell(ctx, hx, hy, s * 0.36, s * 0.3, fur);
    eyes(0.58, 0.14); cheeks(0.7);
    ell(ctx, ...A(0.5, 0.68), s * 0.04, s * 0.028, P.pink);
    fillRR(ctx, ...A(0.465, 0.73), s * 0.035, s * 0.06, 3, "#fff"); fillRR(ctx, ...A(0.5, 0.73), s * 0.035, s * 0.06, 3, "#fff");
    ctx.lineWidth = s * 0.012; ctx.strokeStyle = P.ink; ctx.lineCap = "round";
    for (const k of [-1, 1]) { const [cx, cy] = A(0.5 + k * 0.03, 0.705); ctx.beginPath(); ctx.arc(cx, cy, s * 0.03, 0.2, Math.PI - 0.2); ctx.stroke(); }
    ctx.lineCap = "butt";
    return;
  }
  if (pet === "panda") {
    const [hx, hy] = A(0.5, 0.58);
    circ(ctx, ...A(0.24, 0.3), s * 0.11, P.ink); circ(ctx, ...A(0.76, 0.3), s * 0.11, P.ink);
    ell(ctx, hx, hy + s * 0.02, s * 0.4, s * 0.34, "#D9DEE2"); ell(ctx, hx, hy, s * 0.4, s * 0.34, "#FFFFFF");
    ell(ctx, ...A(0.35, 0.56), s * 0.09, s * 0.12, P.ink, rad(25)); ell(ctx, ...A(0.65, 0.56), s * 0.09, s * 0.12, P.ink, rad(-25));
    for (const u of [0.36, 0.64]) { circ(ctx, ...A(u, 0.55), s * 0.035, "#fff"); circ(ctx, ...A(u, 0.555), s * 0.022, P.ink); circ(ctx, ...A(u + 0.008, 0.545), s * 0.008, "#fff"); }
    cheeks(0.7);
    ell(ctx, ...A(0.5, 0.67), s * 0.05, s * 0.032, P.ink);
    ctx.lineWidth = s * 0.014; ctx.strokeStyle = P.ink; ctx.lineCap = "round";
    for (const k of [-1, 1]) { const [cx, cy] = A(0.5 + k * 0.035, 0.71); ctx.beginPath(); ctx.arc(cx, cy, s * 0.035, 0, Math.PI); ctx.stroke(); }
    ctx.lineCap = "butt";
    return;
  }
  if (pet === "fox") {
    const fur = "#FF8A3D", furLip = "#E06B22";
    for (const [u, d] of [[0.24, -18], [0.76, 18]]) { tri(ctx, ...A(u, 0.26), s * 0.26, s * 0.34, fur, d); tri(ctx, ...A(u, 0.2), s * 0.11, s * 0.14, P.ink, d); }
    ctx.beginPath(); ctx.moveTo(...A(0.1, 0.42)); ctx.quadraticCurveTo(...A(0.5, 0.18), ...A(0.9, 0.42)); ctx.quadraticCurveTo(...A(0.86, 0.72), ...A(0.5, 0.88)); ctx.quadraticCurveTo(...A(0.14, 0.72), ...A(0.1, 0.42)); ctx.closePath();
    ctx.save(); ctx.translate(0, s * 0.02); ctx.fillStyle = furLip; ctx.fill(); ctx.restore(); ctx.fillStyle = fur; ctx.fill();
    ctx.beginPath(); ctx.moveTo(...A(0.16, 0.56)); ctx.quadraticCurveTo(...A(0.5, 0.52), ...A(0.84, 0.56)); ctx.quadraticCurveTo(...A(0.72, 0.8), ...A(0.5, 0.88)); ctx.quadraticCurveTo(...A(0.28, 0.8), ...A(0.16, 0.56)); ctx.closePath(); ctx.fillStyle = "#FFF4E8"; ctx.fill();
    eyes(0.5, 0.14); cheeks(0.64);
    ell(ctx, ...A(0.5, 0.74), s * 0.045, s * 0.032, P.ink);
    return;
  }
  if (pet === "frog") {
    const g = "#7BD94A", gl = "#5BB42F";
    for (const u of [0.3, 0.7]) { circ(ctx, ...A(u, 0.34), s * 0.14, gl); circ(ctx, ...A(u, 0.33), s * 0.14, g); circ(ctx, ...A(u, 0.33), s * 0.09, "#fff"); circ(ctx, ...A(u, 0.34), s * 0.055, P.ink); circ(ctx, ...A(u + 0.02, 0.31), s * 0.018, "#fff"); }
    const [hx, hy] = A(0.5, 0.62); ell(ctx, hx, hy + s * 0.02, s * 0.44, s * 0.27, gl); ell(ctx, hx, hy, s * 0.44, s * 0.27, g);
    for (const u of [0.32, 0.68]) { const [cx, cy] = A(u, 0.62); ctx.globalAlpha = 0.6; ell(ctx, cx, cy, s * 0.06, s * 0.035, P.pink); ctx.globalAlpha = 1; }
    ctx.lineWidth = s * 0.02; ctx.strokeStyle = "#2F6B18"; ctx.lineCap = "round";
    ctx.beginPath(); ctx.arc(...A(0.5, 0.6), s * 0.16, 0.35, Math.PI - 0.35); ctx.stroke(); ctx.lineCap = "butt";
    circ(ctx, ...A(0.46, 0.57), s * 0.01, "#2F6B18"); circ(ctx, ...A(0.54, 0.57), s * 0.01, "#2F6B18");
    return;
  }
  if (pet === "cat") {
    const fur = "#FFA94D", furLip = "#E88A2E";
    for (const [u, d] of [[0.24, -14], [0.76, 14]]) { tri(ctx, ...A(u, 0.22), s * 0.3, s * 0.32, fur, d); tri(ctx, ...A(u, 0.26), s * 0.15, s * 0.17, P.cheek, d); }
    const [hx, hy] = A(0.5, 0.6); ell(ctx, hx, hy + s * 0.02, s * 0.42, s * 0.34, furLip); ell(ctx, hx, hy, s * 0.42, s * 0.34, fur);
    for (const k of [-1, 0, 1]) capsule(ctx, ...A(0.5 + k * 0.08, 0.32), s * 0.05, s * 0.12, furLip, k * 18);
    ell(ctx, ...A(0.5, 0.72), s * 0.17, s * 0.11, "#FFF1DE");
    eyes(0.56, 0.15); cheeks(0.68);
    tri(ctx, ...A(0.5, 0.66), s * 0.08, s * 0.06, P.pink, 180);
    ctx.lineWidth = s * 0.014; ctx.lineCap = "round"; ctx.strokeStyle = P.ink;
    for (const k of [-1, 1]) { const [cx, cy] = A(0.5 + k * 0.035, 0.7); ctx.beginPath(); ctx.arc(cx, cy, s * 0.035, 0, Math.PI); ctx.stroke(); }
    ctx.lineCap = "butt"; ctx.globalAlpha = 0.9;
    for (const k of [-1, 1]) for (const tl of [-8, 6]) capsule(ctx, ...A(0.5 + k * 0.3, 0.7), s * 0.2, s * 0.012, "#fff", k * tl);
    ctx.globalAlpha = 1;
  } else {
    const fur = "#E8B07A", furLip = "#C98E55", ear = "#8B5A2B";
    const [hx, hy] = A(0.5, 0.56); ell(ctx, hx, hy + s * 0.02, s * 0.37, s * 0.35, furLip); ell(ctx, hx, hy, s * 0.37, s * 0.35, fur);
    ctx.globalAlpha = 0.55; ell(ctx, ...A(0.66, 0.48), s * 0.1, s * 0.11, ear); ctx.globalAlpha = 1;
    for (const [u, d] of [[0.16, 18], [0.84, -18]]) ell(ctx, ...A(u, 0.48), s * 0.11, s * 0.22, ear, rad(d));
    ell(ctx, ...A(0.5, 0.7), s * 0.19, s * 0.14, "#fff");
    eyes(0.5, 0.14); cheeks(0.66);
    capsule(ctx, ...A(0.5, 0.8), s * 0.1, s * 0.14, P.tongue); capsule(ctx, ...A(0.5, 0.79), s * 0.012, s * 0.06, "#D63F52");
    ell(ctx, ...A(0.5, 0.64), s * 0.065, s * 0.045, P.ink);
    ctx.globalAlpha = 0.5; ell(ctx, ...A(0.48, 0.625), s * 0.02, s * 0.01, "#fff"); ctx.globalAlpha = 1;
  }
}
function drawTileCover(ctx, theme, i, cx, cy, size, scaleX, deg, font = 26, corner = 12, lipOff = 4) {
  const alt = (Math.floor(i / 5) + i % 5) % 2 === 0;
  ctx.save(); ctx.translate(cx, cy); ctx.rotate(rad(deg)); ctx.scale(Math.max(scaleX, 0.001), 1);
  fillRR(ctx, -size / 2, -size / 2 + lipOff, size, size, corner, theme.lip);
  fillRR(ctx, -size / 2, -size / 2, size, size, corner, alt ? theme.primary : theme.light);
  ctx.font = `900 ${font}px Nunito, ui-rounded, system-ui, sans-serif`; ctx.textAlign = "center"; ctx.textBaseline = "middle";
  ctx.fillStyle = theme.lip; ctx.fillText("?", 0, 2 + 2); ctx.fillStyle = "rgba(255,255,255,0.9)"; ctx.fillText("?", 0, 2);
  ctx.restore();
}
function drawTiles(ctx, w, h, sess, t) {
  const cols = 5, rows = 6, n = cols * rows, tile = Math.min(w / cols, (h - 6) / rows);
  const bw = tile * cols, bh = tile * rows, bx = (w - bw) / 2, by = (h - 6 - bh) / 2;
  if (!sess.tileEnds) {
    const order = shuffle([...Array(n).keys()], seeded(sess.seed)), finish = sess.duration * 0.985;
    sess.tileEnds = []; order.forEach((tileIdx, rank) => (sess.tileEnds[tileIdx] = (rank + 1) / n * finish));
  }
  const ends = sess.tileEnds, e = sess.elapsed, FL = 0.45, WB = 0.8, pic = petPicture(sess.pet, bw, bh);
  fillRR(ctx, bx, by + 5, bw, bh, 22, P.border);
  ctx.save(); rrect(ctx, bx, by, bw, bh, 22); ctx.clip(); ctx.fillStyle = P.card; ctx.fillRect(bx, by, bw, bh);
  const dpr = pic.width / bw;
  for (let i = 0; i < n; i++) {
    const f = (e - (ends[i] - FL)) / FL, col = i % cols, row = Math.floor(i / cols);
    const cx = bx + tile * (col + 0.5), cy = by + tile * (row + 0.5);
    if (f >= 0.5) {      // picture side swinging in
      const open = f >= 1 ? 1 : Math.sin((f - 0.5) * Math.PI);
      ctx.save(); ctx.translate(cx, cy); ctx.scale(Math.max(open, 0.001), 1);
      ctx.drawImage(pic, col * tile * dpr, row * tile * dpr, tile * dpr, tile * dpr, -tile / 2, -tile / 2, tile + 0.5, tile + 0.5);
      ctx.restore();
    }
  }
  ctx.restore();
  for (let i = 0; i < n; i++) {
    const f = (e - (ends[i] - FL)) / FL;
    if (f >= 0.5) continue;
    const wob = f <= 0 && e > ends[i] - FL - WB;
    const cx = bx + tile * (i % cols + 0.5), cy = by + tile * (Math.floor(i / cols) + 0.5);
    drawTileCover(ctx, sess.theme, i, cx, cy, (tile - 6) * (wob ? 1.06 : 1), Math.cos(Math.max(f, 0) * Math.PI), wob ? Math.sin(t * 30) * 6 : 0);
  }
  rrect(ctx, bx, by, bw, bh, 22); ctx.lineWidth = 5; ctx.strokeStyle = "rgba(255,255,255,0.9)"; ctx.stroke();
  const flipped = ends.filter(x => x <= e).length;
  if (flipped > (sess.flipped || 0)) { AudioEngine.playQuiet("flip", 0.15); buzz(8); }
  sess.flipped = flipped;
  return by + bh;
}

// ---- Dino coloring book: a crayon colors in the dinosaur, one part at a time
// Pictures are drawn on a 120 x 90 page. Each region is one closed outline:
// ["M",x,y] move, ["L",x,y] line, ["Q",cx,cy,x,y] curve, ["C",c1x,c1y,c2x,c2y,x,y] curve, ["E",cx,cy,rx,ry] ellipse, ["Z"] close.
const INK = "#2B3A40", PAPER = "#FFFDF6";
const SCENE_GROUND = { color: "#F2C27B", d: [["M", 0, 80], ["Q", 30, 72, 62, 79], ["Q", 92, 86, 120, 76], ["L", 120, 90], ["L", 0, 90], ["Z"]] };
const SCENE_SUN = { color: P.yellow, d: [["E", 15, 14, 9, 9]] };
const DINOS = {
  trex: { name: "T. rex", eye: [88, 18], mouth: [[92, 27], [103, 25]], regions: [
    { color: P.greenLip, d: [["M", 47, 60], ["L", 58, 60], ["L", 60, 79], ["Q", 54, 81, 49, 79], ["Z"]] },
    { color: P.greenLip, d: [["M", 60, 61], ["L", 70, 61], ["L", 71, 79], ["Q", 65, 81, 60, 79], ["Z"]] },
    { color: P.green, d: [["M", 4, 60], ["Q", 24, 50, 42, 44], ["C", 54, 40, 62, 38, 68, 30], ["L", 80, 33], ["C", 80, 45, 77, 56, 70, 63], ["C", 63, 70, 50, 71, 41, 69], ["Q", 24, 67, 4, 60], ["Z"]] },
    { color: P.green, d: [["M", 66, 24], ["C", 67, 12, 84, 8, 97, 12], ["C", 106, 15, 108, 22, 105, 27], ["L", 91, 29], ["C", 90, 34, 84, 36, 77, 36], ["C", 69, 35, 65, 31, 66, 24], ["Z"]] },
    { color: P.yellow, d: [["M", 30, 62], ["C", 42, 66, 58, 66, 70, 57], ["C", 67, 66, 57, 70, 46, 69], ["Q", 37, 68, 30, 62], ["Z"]] },
    { color: P.orange, d: [["M", 24, 52], ["L", 28, 44], ["L", 32, 49], ["L", 37, 41], ["L", 41, 46], ["L", 47, 38], ["L", 50, 43], ["L", 56, 36], ["L", 58, 41], ["Q", 42, 46, 24, 52], ["Z"]] },
    { color: P.greenLip, d: [["M", 74, 42], ["Q", 82, 42, 84, 48], ["L", 81, 50], ["Q", 79, 46, 74, 47], ["Z"]] },
  ] },
  triceratops: { name: "Triceratops", eye: [89, 45], mouth: [[98, 56], [106, 54]], regions: [
    { color: P.purpleLip, d: [["M", 30, 62], ["L", 40, 62], ["L", 40, 80], ["Q", 35, 82, 30, 80], ["Z"]] },
    { color: P.purpleLip, d: [["M", 62, 62], ["L", 72, 62], ["L", 72, 80], ["Q", 67, 82, 62, 80], ["Z"]] },
    { color: P.purpleLip, d: [["M", 18, 66], ["L", 28, 66], ["L", 28, 80], ["Q", 23, 82, 18, 80], ["Z"]] },
    { color: P.purpleLip, d: [["M", 50, 66], ["L", 60, 66], ["L", 60, 80], ["Q", 55, 82, 50, 80], ["Z"]] },
    { color: P.purple, d: [["M", 6, 56], ["Q", 14, 52, 22, 50], ["C", 30, 34, 62, 32, 76, 42], ["C", 80, 52, 78, 64, 68, 68], ["C", 52, 72, 32, 72, 22, 64], ["Q", 14, 60, 6, 56], ["Z"]] },
    { color: P.pink, d: [["M", 70, 46], ["C", 66, 30, 74, 18, 84, 22], ["C", 92, 26, 92, 40, 88, 48], ["Q", 80, 52, 70, 46], ["Z"]] },
    { color: P.purple, d: [["M", 76, 44], ["C", 84, 38, 98, 42, 106, 50], ["Q", 112, 56, 106, 60], ["C", 98, 63, 86, 62, 80, 58], ["C", 74, 55, 72, 48, 76, 44], ["Z"]] },
    { color: "#FFF4D6", d: [["M", 86, 40], ["Q", 92, 28, 106, 24], ["Q", 98, 34, 92, 42], ["Z"]] },
    { color: "#FFF4D6", d: [["M", 104, 50], ["Q", 112, 42, 116, 38], ["Q", 114, 46, 108, 53], ["Z"]] },
  ] },
  stego: { name: "Stegosaurus", eye: [97, 50], mouth: [[99, 57], [106, 56]], regions: [
    { color: P.orange, d: [["M", 30, 40], ["L", 34, 24], ["L", 42, 36], ["L", 48, 18], ["L", 56, 34], ["L", 64, 20], ["L", 70, 36], ["L", 78, 28], ["L", 80, 44], ["Z"]] },
    { color: P.blueLip, d: [["M", 32, 62], ["L", 42, 62], ["L", 42, 80], ["Q", 37, 82, 32, 80], ["Z"]] },
    { color: P.blueLip, d: [["M", 66, 62], ["L", 76, 62], ["L", 76, 80], ["Q", 71, 82, 66, 80], ["Z"]] },
    { color: P.blueLip, d: [["M", 20, 66], ["L", 30, 64], ["L", 31, 80], ["Q", 26, 82, 21, 80], ["Z"]] },
    { color: P.blueLip, d: [["M", 54, 66], ["L", 64, 66], ["L", 64, 80], ["Q", 59, 82, 54, 80], ["Z"]] },
    { color: P.blue, d: [["M", 2, 50], ["L", 12, 48], ["Q", 26, 34, 52, 34], ["C", 74, 34, 86, 42, 92, 50], ["C", 98, 46, 108, 48, 110, 54], ["C", 110, 60, 100, 62, 92, 60], ["C", 84, 68, 64, 70, 48, 68], ["Q", 26, 66, 12, 56], ["L", 2, 50], ["Z"]] },
    { color: "#A6F04A", d: [["M", 24, 60], ["C", 40, 66, 66, 66, 84, 60], ["C", 72, 68, 50, 70, 36, 66], ["Z"]] },
    { color: "#FFF4D6", d: [["M", 2, 50], ["L", 0, 42], ["L", 7, 48], ["L", 4, 38], ["L", 11, 47], ["Z"]] },
  ] },
  longneck: { name: "Long-neck", eye: [101, 14], mouth: [[104, 19], [110, 18]], regions: [
    { color: P.tealLip, d: [["M", 30, 62], ["L", 40, 62], ["L", 40, 80], ["Q", 35, 82, 30, 80], ["Z"]] },
    { color: P.tealLip, d: [["M", 62, 62], ["L", 72, 62], ["L", 72, 80], ["Q", 67, 82, 62, 80], ["Z"]] },
    { color: P.tealLip, d: [["M", 20, 64], ["L", 30, 64], ["L", 30, 80], ["Q", 25, 82, 20, 80], ["Z"]] },
    { color: P.tealLip, d: [["M", 52, 66], ["L", 62, 66], ["L", 62, 80], ["Q", 57, 82, 52, 80], ["Z"]] },
    { color: P.teal, d: [["M", 2, 62], ["Q", 14, 54, 24, 50], ["C", 32, 38, 60, 36, 72, 44], ["C", 80, 34, 84, 20, 92, 12], ["C", 98, 6, 110, 8, 112, 14], ["C", 114, 20, 106, 22, 100, 22], ["C", 92, 30, 88, 46, 80, 58], ["C", 72, 70, 44, 72, 28, 66], ["Q", 14, 64, 2, 62], ["Z"]] },
    { color: P.yellow, d: [["M", 30, 64], ["C", 44, 68, 64, 66, 76, 58], ["C", 70, 68, 50, 72, 36, 68], ["Z"]] },
    { color: P.pink, d: [["E", 40, 46, 5, 3.5], ], },
    { color: P.pink, d: [["E", 54, 43, 5, 3.5]] },
    { color: P.pink, d: [["E", 66, 47, 4.5, 3]] },
  ] },
};
const DINO_ORDER = ["trex", "triceratops", "stego", "longneck"];
function regionPath(ctx, d, ox, oy, k) {
  ctx.beginPath();
  for (const c of d) {
    const X = v => ox + v * k;
    if (c[0] === "M") ctx.moveTo(X(c[1]), oy + c[2] * k);
    else if (c[0] === "L") ctx.lineTo(X(c[1]), oy + c[2] * k);
    else if (c[0] === "Q") ctx.quadraticCurveTo(X(c[1]), oy + c[2] * k, X(c[3]), oy + c[4] * k);
    else if (c[0] === "C") ctx.bezierCurveTo(X(c[1]), oy + c[2] * k, X(c[3]), oy + c[4] * k, X(c[5]), oy + c[6] * k);
    else if (c[0] === "E") { ctx.moveTo(X(c[1] + c[3]), oy + c[2] * k); ctx.ellipse(X(c[1]), oy + c[2] * k, c[3] * k, c[4] * k, 0, 0, Math.PI * 2); }
    else if (c[0] === "Z") ctx.closePath();
  }
}
function regionBox(d) {
  let x0 = 1e9, y0 = 1e9, x1 = -1e9, y1 = -1e9;
  const add = (x, y) => { x0 = Math.min(x0, x); y0 = Math.min(y0, y); x1 = Math.max(x1, x); y1 = Math.max(y1, y); };
  for (const c of d) {
    if (c[0] === "E") { add(c[1] - c[3], c[2] - c[4]); add(c[1] + c[3], c[2] + c[4]); }
    else for (let i = 1; i + 1 < c.length; i += 2) add(c[i], c[i + 1]);
  }
  return { x0, y0, x1, y1 };
}
/** the order things get colored in: the dinosaur's parts first, then the ground, then the sun */
function coloringPlan(dinoId) {
  const dino = DINOS[dinoId];
  const regions = [...dino.regions, SCENE_GROUND, SCENE_SUN].map(r => {
    const b = regionBox(r.d);
    return { ...r, box: b, weight: Math.pow(Math.max((b.x1 - b.x0) * (b.y1 - b.y0), 20), 0.55) };
  });
  const total = regions.reduce((a, r) => a + r.weight, 0);
  let acc = 0;
  regions.forEach(r => { r.start = acc / total; acc += r.weight; r.end = acc / total; });
  return { dino, regions, drawOrder: [SCENE_SUN, SCENE_GROUND, ...dino.regions].map(src => regions.find(r => r.d === src.d)) };
}
/** zig-zag crayon path that covers a region's box; returns points in page units */
function scribble(box, spacing) {
  const pts = [], pad = spacing * 0.6;
  let left = true;
  for (let y = box.y0 - pad; y <= box.y1 + pad + spacing; y += spacing) {
    pts.push(left ? [box.x0 - pad, y] : [box.x1 + pad, y + spacing * 0.5]);
    left = !left;
  }
  return pts;
}
function polyPrefix(pts, f) {
  const lens = [0];
  for (let i = 1; i < pts.length; i++) lens.push(lens[i - 1] + Math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1]));
  const target = lens[lens.length - 1] * Math.min(Math.max(f, 0), 1), out = [pts[0]];
  for (let i = 1; i < pts.length; i++) {
    if (lens[i] <= target) { out.push(pts[i]); continue; }
    const u = (target - lens[i - 1]) / Math.max(lens[i] - lens[i - 1], 1e-6);
    out.push([pts[i - 1][0] + (pts[i][0] - pts[i - 1][0]) * u, pts[i - 1][1] + (pts[i][1] - pts[i - 1][1]) * u]);
    break;
  }
  return out;
}
function drawCrayon(ctx, x, y, color, lip, t) {
  ctx.save(); ctx.translate(x, y); ctx.rotate(rad(-35 + Math.sin(t * 20) * 4));
  // tip at the origin, crayon body up and to the right
  ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(7, -12); ctx.lineTo(-7, -12); ctx.closePath(); ctx.fillStyle = color; ctx.fill();
  fillRR(ctx, -8, -52, 16, 42, 4, lip); fillRR(ctx, -8, -54, 14, 42, 4, color);
  ctx.fillStyle = "rgba(255,255,255,0.85)"; ctx.fillRect(-8, -40, 14, 12);
  ctx.globalAlpha = 0.35; fillRR(ctx, -5, -52, 3, 38, 1.5, "#fff"); ctx.globalAlpha = 1;
  ctx.restore();
}
/** draws the coloring page into a box; `p` 0...1 is how much is colored in */
function drawColoringPage(ctx, dinoId, x, y, w, h, p, t, live) {
  const plan = coloringPlan(dinoId), k = w / 120;
  // paper card with a chunky edge
  const cr = Math.min(22, w * 0.1);
  fillRR(ctx, x, y + 5, w, h, cr, P.border); fillRR(ctx, x, y, w, h, cr, PAPER);
  ctx.save(); rrect(ctx, x, y, w, h, cr); ctx.clip();
  const lw = Math.max(2, 1.6 * k), spacing = 4.2;
  let tip = null;
  for (const r of plan.drawOrder) {
    regionPath(ctx, r.d, x, y, k); ctx.fillStyle = PAPER; ctx.fill();
    const f = (p - r.start) / (r.end - r.start);
    if (f >= 1) { ctx.fillStyle = r.color; ctx.fill(); }
    else if (f > 0) {
      const pts = scribble(r.box, spacing), part = polyPrefix(pts, f);
      ctx.save(); regionPath(ctx, r.d, x, y, k); ctx.clip();
      ctx.beginPath(); part.forEach(([px, py], i) => i ? ctx.lineTo(x + px * k, y + py * k) : ctx.moveTo(x + px * k, y + py * k));
      ctx.lineWidth = spacing * k * 1.5; ctx.lineCap = "round"; ctx.lineJoin = "round"; ctx.strokeStyle = r.color; ctx.stroke();
      ctx.restore();
      const last = part[part.length - 1]; tip = { x: x + last[0] * k, y: y + last[1] * k, color: r.color };
    }
    regionPath(ctx, r.d, x, y, k); ctx.lineWidth = lw; ctx.lineJoin = "round"; ctx.strokeStyle = INK; ctx.stroke();
  }
  // eye and smile are printed on the page
  const d = plan.dino, [ex, ey] = d.eye;
  circ(ctx, x + ex * k, y + ey * k, 3.2 * k, "#fff"); ctx.lineWidth = lw * 0.8; ctx.strokeStyle = INK; ctx.stroke();
  circ(ctx, x + (ex + 0.6) * k, y + ey * k, 1.7 * k, INK); circ(ctx, x + (ex + 1.1) * k, y + (ey - 0.7) * k, 0.6 * k, "#fff");
  ctx.beginPath(); ctx.moveTo(x + d.mouth[0][0] * k, y + d.mouth[0][1] * k);
  ctx.quadraticCurveTo(x + (d.mouth[0][0] + d.mouth[1][0]) / 2 * k, y + (Math.max(d.mouth[0][1], d.mouth[1][1]) + 3) * k, x + d.mouth[1][0] * k, y + d.mouth[1][1] * k);
  ctx.lineWidth = lw; ctx.lineCap = "round"; ctx.strokeStyle = INK; ctx.stroke(); ctx.lineCap = "butt";
  ctx.restore();
  rrect(ctx, x, y, w, h, cr); ctx.lineWidth = 3; ctx.strokeStyle = P.border; ctx.stroke();
  if (live && tip && p < 1) drawCrayon(ctx, tip.x, tip.y, tip.color, shade(tip.color), t);
}
function shade(hex) {
  const n = parseInt(hex.slice(1), 16), f = 0.8;
  return "#" + [n >> 16, (n >> 8) & 255, n & 255].map(v => Math.round(v * f).toString(16).padStart(2, "0")).join("");
}
function drawColoringTimer(ctx, w, h, sess, t) {
  const aspect = 120 / 90; let bw = w, bh = bw / aspect;
  if (bh > h - 8) { bh = h - 8; bw = bh * aspect; }
  const bx = (w - bw) / 2, by = (h - 8 - bh) / 2;
  drawColoringPage(ctx, sess.pet, bx, by, bw, bh, sess.progress, t, !sess.paused);
  return by + bh;
}

// ---- Rocket Brush: a rocket flies from Earth past planets to its destination
const ROUTE = [
  { name: "Earth", u: 0, kind: "earth" },
  { name: "Moon", u: 0.25, kind: "moon" },
  { name: "Mars", u: 0.5, kind: "mars" },
  { name: "Jupiter", u: 0.75, kind: "jupiter" },
  { name: "Planet Zoom", u: 1, kind: "dest" },
];
let routeCache = null;
function routeModel(w, h) {
  const key = Math.round(w) + "x" + Math.round(h);
  if (routeCache && routeCache.key === key) return routeCache;
  const m = Math.min(w, h), rEnd = m * 0.11, top = rEnd + 22, bottom = h - m * 0.1 - 6;
  const cx = w / 2, amp = Math.min(w * 0.3, 120);
  const at = u => [cx - amp * Math.cos(2 * Math.PI * u), bottom - u * (bottom - top)];
  const N = 240, pts = [], lens = [0];
  for (let i = 0; i <= N; i++) { pts.push(at(i / N)); if (i) lens.push(lens[i - 1] + Math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1])); }
  return (routeCache = { key, pts, lens, total: lens[N], m, at, cx });
}
/** point + direction at a fraction of the route's length */
function routeAt(R, f) {
  const target = R.total * Math.min(Math.max(f, 0), 1);
  let i = 1; while (i < R.lens.length - 1 && R.lens[i] < target) i++;
  const u = (target - R.lens[i - 1]) / Math.max(R.lens[i] - R.lens[i - 1], 1e-6);
  const a = R.pts[i - 1], b = R.pts[i];
  return { x: a[0] + (b[0] - a[0]) * u, y: a[1] + (b[1] - a[1]) * u, ang: Math.atan2(b[1] - a[1], b[0] - a[0]), i };
}
/** route fraction (by length) where each planet sits */
function stopFraction(R, u) { const i = Math.round(u * (R.pts.length - 1)); return R.lens[i] / R.total; }
function drawPlanet(ctx, kind, x, y, r, t) {
  if (kind === "earth") {
    circ(ctx, x, y + r * 0.08, r, "#1A6FB0"); circ(ctx, x, y, r, "#2E9BEA");
    ctx.save(); ell(ctx, x, y, r, r); ctx.clip();
    ell(ctx, x - r * 0.35, y - r * 0.2, r * 0.45, r * 0.3, P.green, 0.4); ell(ctx, x + r * 0.4, y + r * 0.35, r * 0.4, r * 0.25, P.green, -0.3);
    ctx.restore();
  } else if (kind === "moon") {
    circ(ctx, x, y + r * 0.08, r, "#9AA7B0"); circ(ctx, x, y, r, "#D5DDE2");
    circ(ctx, x - r * 0.3, y - r * 0.25, r * 0.22, "#B6C2CA"); circ(ctx, x + r * 0.35, y + r * 0.2, r * 0.16, "#B6C2CA"); circ(ctx, x - r * 0.1, y + r * 0.45, r * 0.12, "#B6C2CA");
  } else if (kind === "mars") {
    circ(ctx, x, y + r * 0.08, r, "#C2410C"); circ(ctx, x, y, r, "#F26B3A");
    circ(ctx, x + r * 0.3, y - r * 0.3, r * 0.2, "#D9542A"); circ(ctx, x - r * 0.35, y + r * 0.25, r * 0.25, "#D9542A");
  } else if (kind === "jupiter") {
    circ(ctx, x, y + r * 0.08, r, "#C98E55"); circ(ctx, x, y, r, "#F2C27B");
    ctx.save(); ell(ctx, x, y, r, r); ctx.clip();
    for (const [dy, c] of [[-0.45, "#E39A57"], [-0.05, "#E8B07A"], [0.35, "#E39A57"]]) { ctx.fillStyle = c; ctx.fillRect(x - r, y + dy * r, r * 2, r * 0.22); }
    ell(ctx, x + r * 0.35, y + r * 0.42, r * 0.2, r * 0.12, "#D9542A");
    ctx.restore();
  } else {   // destination: ringed planet with a flag
    ctx.save(); ctx.translate(x, y); ctx.rotate(-0.35);
    ctx.lineWidth = r * 0.16; ctx.strokeStyle = "#FFE46B";
    ctx.beginPath(); ctx.ellipse(0, 0, r * 1.65, r * 0.5, 0, Math.PI, Math.PI * 2); ctx.stroke();
    ctx.restore();
    circ(ctx, x, y + r * 0.08, r, P.purpleLip); circ(ctx, x, y, r, P.purple);
    circ(ctx, x - r * 0.3, y - r * 0.3, r * 0.18, "#D8B4FF");
    ctx.save(); ctx.translate(x, y); ctx.rotate(-0.35);
    ctx.lineWidth = r * 0.16; ctx.strokeStyle = "#FFE46B";
    ctx.beginPath(); ctx.ellipse(0, 0, r * 1.65, r * 0.5, 0, 0, Math.PI); ctx.stroke();
    ctx.restore();
    // flag on top
    fillRR(ctx, x - 1.5, y - r * 1.75, 3, r * 0.85, 1.5, "#fff");
    const wave = Math.sin(t * 4) * r * 0.06;
    ctx.beginPath(); ctx.moveTo(x + 1.5, y - r * 1.75); ctx.lineTo(x + r * 0.75, y - r * 1.55 + wave); ctx.lineTo(x + 1.5, y - r * 1.35); ctx.closePath();
    ctx.fillStyle = P.red; ctx.fill();
  }
}
function drawRocket(ctx, x, y, size, ang, t, flame = true) {
  ctx.save(); ctx.translate(x, y); ctx.rotate(ang + Math.PI / 2); ctx.scale(size / 100, size / 100);
  if (flame) {
    const f = 0.8 + 0.3 * Math.abs(Math.sin(t * 22));
    tri(ctx, 0, 48 + 16 * f, 26, 34 * f, P.orange, 180); tri(ctx, 0, 46 + 10 * f, 14, 20 * f, P.yellow, 180);
  }
  // fins
  ctx.fillStyle = P.redLip;
  ctx.beginPath(); ctx.moveTo(-14, 10); ctx.lineTo(-30, 40); ctx.lineTo(-14, 38); ctx.closePath(); ctx.fill();
  ctx.beginPath(); ctx.moveTo(14, 10); ctx.lineTo(30, 40); ctx.lineTo(14, 38); ctx.closePath(); ctx.fill();
  // body
  ctx.beginPath(); ctx.moveTo(0, -50); ctx.bezierCurveTo(22, -30, 20, 20, 16, 42); ctx.lineTo(-16, 42); ctx.bezierCurveTo(-20, 20, -22, -30, 0, -50); ctx.closePath();
  ctx.fillStyle = "#fff"; ctx.fill();
  ctx.save(); ctx.clip(); ctx.fillStyle = "#D6E2EA"; ctx.fillRect(6, -60, 30, 110);
  ctx.fillStyle = P.red; ctx.fillRect(-30, -60, 60, 26); ctx.restore();
  circ(ctx, 0, -6, 11, "#fff"); circ(ctx, 0, -6, 8, P.blue); circ(ctx, -3, -9, 2.5, "#fff");
  ctx.fillStyle = P.red; ctx.beginPath(); ctx.moveTo(-4, 20); ctx.lineTo(4, 20); ctx.lineTo(3, 44); ctx.lineTo(-3, 44); ctx.closePath(); ctx.fill();
  ctx.restore();
}
function drawRocketRoute(ctx, w, h, p, t, opts = {}) {
  const R = routeModel(w, h), m = R.m, here = routeAt(R, p);
  // stars twinkling along the way
  for (let i = 0; i < 26; i++) { ctx.globalAlpha = 0.25 + 0.5 * Math.abs(Math.sin(t * (0.6 + hash(i) * 1.5) + i)); circ(ctx, hash(i * 3.1) * w, hash(i * 7.7) * h, 1 + hash(i * 5.3) * 1.6, "#fff"); }
  ctx.globalAlpha = 1;
  // the way still to go: dots
  ctx.save(); ctx.beginPath();
  for (let i = here.i - 1; i < R.pts.length; i++) i === here.i - 1 ? ctx.moveTo(here.x, here.y) : ctx.lineTo(R.pts[i][0], R.pts[i][1]);
  ctx.setLineDash([1, 12]); ctx.lineCap = "round"; ctx.lineWidth = 5; ctx.strokeStyle = "rgba(255,255,255,0.55)"; ctx.stroke(); ctx.restore();
  // the way already traveled: a thick glowing trail
  const trail = () => { ctx.beginPath(); for (let i = 0; i < here.i; i++) i ? ctx.lineTo(R.pts[i][0], R.pts[i][1]) : ctx.moveTo(R.pts[0][0], R.pts[0][1]); ctx.lineTo(here.x, here.y); };
  ctx.lineCap = "round"; ctx.lineJoin = "round";
  ctx.save(); ctx.translate(0, 3); trail(); ctx.lineWidth = 9; ctx.strokeStyle = P.blueLip; ctx.stroke(); ctx.restore();
  trail(); ctx.lineWidth = 9; ctx.strokeStyle = P.blue; ctx.stroke();
  trail(); ctx.lineWidth = 2.5; ctx.strokeStyle = "rgba(255,255,255,0.6)"; ctx.stroke();
  ctx.lineCap = "butt";
  // planets along the route, with a check once the rocket has passed them
  for (const stop of ROUTE) {
    const [x, y] = R.at(stop.u), f = stopFraction(R, stop.u), passed = p >= f && stop.u > 0;
    const r = stop.kind === "dest" ? m * 0.11 : stop.kind === "earth" ? m * 0.085 : m * 0.065;
    ctx.globalAlpha = passed || stop.u === 0 || p >= f - 0.02 ? 1 : 0.85;
    drawPlanet(ctx, stop.kind, x, y, r, t); ctx.globalAlpha = 1;
    if (!opts.mini) {
      const right = x <= R.cx, lx = right ? x + r + 10 : x - r - 10;
      ctx.font = `900 ${Math.max(12, m * 0.045)}px Nunito, ui-rounded, system-ui, sans-serif`; ctx.textAlign = right ? "left" : "right"; ctx.textBaseline = "middle";
      ctx.fillStyle = passed ? P.green : "rgba(255,255,255,0.85)"; ctx.fillText(stop.name, lx, y);
    }
    if (passed && stop.kind !== "dest") { circ(ctx, x + r * 0.75, y - r * 0.75, r * 0.38, "#fff"); circ(ctx, x + r * 0.75, y - r * 0.75, r * 0.3, P.green);
      ctx.lineWidth = Math.max(2, r * 0.09); ctx.strokeStyle = "#fff"; ctx.lineCap = "round"; ctx.beginPath();
      ctx.moveTo(x + r * 0.62, y - r * 0.75); ctx.lineTo(x + r * 0.72, y - r * 0.63); ctx.lineTo(x + r * 0.9, y - r * 0.87); ctx.stroke(); ctx.lineCap = "butt"; }
  }
  // the rocket
  const bob = opts.mini ? 0 : Math.sin(t * 6) * 1.5;
  drawRocket(ctx, here.x, here.y + bob, m * (opts.mini ? 0.2 : 0.14), here.ang, t, p < 1);
  return h;
}

// ---- Rocket Brush cockpit: planets grow closer and fly past the window, with a distance gauge
const FLYBYS = [
  { kind: "moon", name: "Moon", from: 0.0, to: 0.3, side: -1, dy: -0.15 },
  { kind: "mars", name: "Mars", from: 0.17, to: 0.55, side: 1, dy: 0.1 },
  { kind: "jupiter", name: "Jupiter", from: 0.42, to: 0.8, side: -1, dy: 0.05 },
];
const cockpitStates = {};
function cockpitState(key) {
  if (!cockpitStates[key]) {
    const rnd = seeded(7), stars = [];
    for (let i = 0; i < 90; i++) stars.push({ x: rnd() * 2 - 1, y: rnd() * 2 - 1, z: rnd() * 0.95 + 0.05, c: ["#fff", "#fff", "#BDE8FF", "#FFE46B", "#FFC2E8"][i % 5] });
    cockpitStates[key] = { stars, last: null };
  }
  return cockpitStates[key];
}
function drawCockpit(ctx, w, h, p, t, opts = {}) {
  const mini = !!opts.mini, st = cockpitState(mini ? "mini" : "main");
  const dt = st.last == null ? 0 : Math.min(t - st.last, 0.1); st.last = t;
  const moving = opts.moving !== false && p < 1;
  // layout: window on the left, distance gauge on the right, console along the bottom
  const gw = mini ? w * 0.2 : Math.max(58, w * 0.18), gap = mini ? 3 : 8;
  const winX = mini ? 3 : 6, winY = mini ? 3 : 6, winW = w - gw - gap - winX * 2, consoleTop = h * (mini ? 0.78 : 0.76);
  const winH = consoleTop - winY + h * 0.06, wr = mini ? 10 : 26;
  // cockpit walls
  fillRR(ctx, 0, 0, w, h, mini ? 12 : 22, "#1B3550");
  ctx.fillStyle = "#234466"; ctx.fillRect(0, 0, w, h * 0.05);
  if (!mini) { for (const [x, y] of [[w * 0.02, h * 0.3], [w * 0.02, h * 0.55]]) { fillRR(ctx, x - 2, y, 8, h * 0.12, 3, "#3BD16F"); } }
  // ---- the window
  ctx.save(); rrect(ctx, winX, winY, winW, winH, wr); ctx.clip();
  const g = ctx.createLinearGradient(0, winY, 0, winY + winH);
  g.addColorStop(0, "#1A1250"); g.addColorStop(0.6, "#3A2A9E"); g.addColorStop(1, "#2B5FC2");
  ctx.fillStyle = g; ctx.fillRect(winX, winY, winW, winH);
  const cx = winX + winW / 2, cy = winY + winH * 0.42;
  // nebula glow
  const neb = ctx.createRadialGradient(cx + winW * 0.2, cy - winH * 0.1, 0, cx + winW * 0.2, cy - winH * 0.1, winW * 0.6);
  neb.addColorStop(0, "rgba(255,138,210,0.22)"); neb.addColorStop(1, "rgba(255,138,210,0)"); ctx.fillStyle = neb; ctx.fillRect(winX, winY, winW, winH);
  // stars streaming toward us
  const speed = moving ? 0.22 : 0;
  for (const s of st.stars) {
    const z0 = s.z; s.z -= speed * dt;
    if (s.z <= 0.04) { s.z = 1; s.x = Math.random() * 2 - 1; s.y = Math.random() * 2 - 1; continue; }
    const k = winW * 0.35, x1 = cx + s.x / s.z * k, y1 = cy + s.y / s.z * k, x0 = cx + s.x / z0 * k, y0 = cy + s.y / z0 * k;
    if (x1 < winX - 10 || x1 > winX + winW + 10 || y1 < winY - 10 || y1 > winY + winH + 10) { s.z = 1; continue; }
    const size = Math.max(0.6, (1 - s.z) * (mini ? 1.6 : 3));
    ctx.globalAlpha = Math.min(1, (1 - s.z) * 1.6);
    ctx.strokeStyle = s.c; ctx.lineWidth = size; ctx.lineCap = "round";
    ctx.beginPath(); ctx.moveTo(x0, y0); ctx.lineTo(x1 + (x1 - x0) * 0.3, y1 + (y1 - y0) * 0.3); ctx.stroke();
  }
  ctx.globalAlpha = 1; ctx.lineCap = "butt";
  // comets now and then
  if (!mini) {
    const period = 6.5, k = Math.floor(t / period), u = (t - k * period) / 2.2;
    if (u < 1) {
      const a = hash(k * 3.3), fromLeft = a < 0.5, y0 = winY + winH * (0.08 + hash(k * 5.1) * 0.35);
      const x = fromLeft ? winX - 40 + u * (winW + 80) : winX + winW + 40 - u * (winW + 80), y = y0 + u * winH * 0.35;
      const dx = fromLeft ? -1 : 1, tail = winW * 0.28;
      const tg = ctx.createLinearGradient(x, y, x + dx * tail, y - tail * 0.35);
      tg.addColorStop(0, "rgba(180,240,255,0.95)"); tg.addColorStop(1, "rgba(180,240,255,0)");
      ctx.strokeStyle = tg; ctx.lineWidth = 7; ctx.lineCap = "round";
      ctx.beginPath(); ctx.moveTo(x, y); ctx.lineTo(x + dx * tail, y - tail * 0.35); ctx.stroke(); ctx.lineCap = "butt";
      circ(ctx, x, y, 6, "#fff"); circ(ctx, x, y, 3.5, "#BDE8FF");
    }
  }
  // planets: tiny and far away, then growing faster and faster until they whoosh past
  const base = winH * 0.95;
  for (const f of FLYBYS) {
    if (p < f.from || p > f.to) continue;
    const u = (p - f.from) / (f.to - f.from), zz = Math.pow(14, 1 - u);
    const r = base / zz, x = cx + f.side * winW * 0.95 / zz * (1 + u * 0.6), y = cy + f.dy * winH / zz + winH * 0.05 * u;
    drawPlanet(ctx, f.kind, x, y, r, t);
    if (!mini && u < 0.7) {
      ctx.font = `900 13px Nunito, ui-rounded, system-ui, sans-serif`; ctx.textAlign = "center"; ctx.textBaseline = "top";
      ctx.fillStyle = "rgba(255,255,255,0.85)"; ctx.fillText(f.name, x, y + r + 6);
    }
  }
  // destination: grows from a dot to filling the window as we arrive
  if (p > 0.66) {
    const u = Math.min((p - 0.66) / 0.34, 1), zz = Math.pow(12, 1 - u) * 1.25;
    const r = base * 0.75 / zz, x = cx, y = cy + winH * 0.1 * u;
    drawPlanet(ctx, "dest", x, y, r, t);
    if (!mini && u < 0.85) { ctx.font = `900 14px Nunito, ui-rounded, system-ui, sans-serif`; ctx.textAlign = "center"; ctx.textBaseline = "top"; ctx.fillStyle = "#FFE46B"; ctx.fillText("Planet Zoom", x, y + r * 1.1 + 6); }
  }
  // glass shine
  ctx.globalAlpha = 0.12; ctx.fillStyle = "#fff";
  ctx.beginPath(); ctx.moveTo(winX, winY + winH * 0.55); ctx.lineTo(winX + winW * 0.35, winY); ctx.lineTo(winX + winW * 0.5, winY); ctx.lineTo(winX, winY + winH * 0.8); ctx.closePath(); ctx.fill();
  ctx.globalAlpha = 1;
  ctx.restore();
  rrect(ctx, winX, winY, winW, winH, wr); ctx.lineWidth = mini ? 3 : 6; ctx.strokeStyle = "#4FE3FF"; ctx.stroke();
  // ---- console along the bottom
  const ct = consoleTop;
  ctx.beginPath(); ctx.moveTo(0, h); ctx.lineTo(0, ct + h * 0.06); ctx.quadraticCurveTo(w * 0.04, ct, w * 0.12, ct); ctx.lineTo(w * 0.88, ct); ctx.quadraticCurveTo(w * 0.96, ct, w, ct + h * 0.06); ctx.lineTo(w, h); ctx.closePath();
  ctx.fillStyle = "#2C4F73"; ctx.fill();
  ctx.fillStyle = "#3E6A94"; ctx.fillRect(w * 0.1, ct, w * 0.8, mini ? 2 : 4);
  if (!mini) {
    const sh = (h - ct) * 0.5, sy = ct + (h - ct) * 0.22;
    for (const sx of [w * 0.05, w * 0.73]) {
      fillRR(ctx, sx, sy, w * 0.2, sh, 8, "#1E7A45"); fillRR(ctx, sx + 3, sy + 3, w * 0.2 - 6, sh - 6, 6, "#3BD16F");
      ctx.strokeStyle = "rgba(10,60,30,0.6)"; ctx.lineWidth = 2; ctx.beginPath();
      for (let i = 0; i <= 12; i++) { const xx = sx + 6 + i * (w * 0.2 - 12) / 12, yy = sy + sh / 2 + Math.sin(i * 0.9 + t * 3 + sx) * sh * 0.25; i ? ctx.lineTo(xx, yy) : ctx.moveTo(xx, yy); }
      ctx.stroke();
    }
    // blinking buttons
    [[0.29, P.orange], [0.33, P.green], [0.67, P.red], [0.71, P.yellow]].forEach(([u, c], i) => {
      ctx.globalAlpha = (Math.floor(t * 2 + i * 0.7) % 2) ? 1 : 0.45; circ(ctx, w * u, ct + (h - ct) * 0.45, 5, c); ctx.globalAlpha = 1;
    });
  }
  // ---- distance gauge
  const gx = w - gw - (mini ? 3 : 6), gy = winY, gh = consoleTop - winY - (mini ? 4 : 10);
  fillRR(ctx, gx, gy + 4, gw, gh, mini ? 8 : 16, "#10233A"); fillRR(ctx, gx, gy, gw, gh, mini ? 8 : 16, "#234466");
  const labelH = mini ? 0 : 40, tubeX = gx + gw * 0.5 - (mini ? 5 : 9), tubeW = mini ? 10 : 18;
  const tubeTop = gy + labelH + (mini ? 10 : 30), tubeBot = gy + gh - (mini ? 8 : 16), tubeH = tubeBot - tubeTop;
  if (!mini) {
    ctx.textAlign = "center"; ctx.textBaseline = "top"; ctx.fillStyle = "#8FD3FF"; ctx.font = "900 10px Nunito, ui-rounded, system-ui, sans-serif";
    ctx.fillText("MILES LEFT", gx + gw / 2, gy + 6);
    ctx.fillStyle = "#fff"; ctx.font = `900 ${Math.min(20, gw * 0.34)}px Nunito, ui-rounded, system-ui, sans-serif`;
    ctx.fillText(String(Math.ceil((1 - p) * 1000)), gx + gw / 2, gy + 19);
  }
  fillRR(ctx, tubeX, tubeTop, tubeW, tubeH, tubeW / 2, "#0B1A2C");
  const fillH = Math.max(tubeW, tubeH * p);
  const fg = ctx.createLinearGradient(0, tubeBot, 0, tubeTop); fg.addColorStop(0, P.blue); fg.addColorStop(1, "#4FE3FF");
  rrect(ctx, tubeX, tubeBot - fillH, tubeW, fillH, tubeW / 2); ctx.fillStyle = fg; ctx.fill();
  ctx.globalAlpha = 0.45; fillRR(ctx, tubeX + tubeW * 0.2, tubeBot - fillH + 4, tubeW * 0.22, Math.max(fillH - 8, 0), 3, "#fff"); ctx.globalAlpha = 1;
  // tick marks
  for (let i = 1; i < 10; i++) { const yy = tubeBot - tubeH * i / 10; ctx.fillStyle = "rgba(255,255,255,0.35)"; ctx.fillRect(tubeX - (mini ? 3 : 6), yy - 0.5, mini ? 2 : 4, 1); }
  // planets along the gauge: they light up when passed
  const stops = [["earth", 0], ["moon", 0.25], ["mars", 0.5], ["jupiter", 0.75], ["dest", 1]];
  for (const [kind, u] of stops) {
    const yy = tubeBot - tubeH * u, px = tubeX + tubeW + (mini ? 6 : 12), pr = mini ? 3.5 : (kind === "dest" ? 8 : 6.5);
    ctx.globalAlpha = p >= u - 0.001 ? 1 : 0.4; drawPlanet(ctx, kind, px, yy, pr, t); ctx.globalAlpha = 1;
  }
  // rocket marker riding the gauge
  if (!mini || true) {
    const ry = tubeBot - fillH + tubeW / 2;
    drawRocket(ctx, tubeX + tubeW / 2 - (mini ? 0 : 0), ry - (mini ? 6 : 12), mini ? 13 : 26, -Math.PI / 2, t, moving);
  }
  return h;
}
function drawRocketTimer(ctx, w, h, sess, t) { return drawCockpit(ctx, w, h, sess.progress, t, { moving: !sess.paused }); }

// ---- small pictures on the home screen theme tiles
function drawThemeIcon(ctx, w, h, theme, t) {
  if (theme.timer === "ring") { const s = Math.min(w / 1.05, h / 1.2); drawMascot(ctx, w / 2 - s / 2, h / 2 - s * 0.6, s, { costume: theme.costume }, t); return; }
  if (theme.timer === "plinko") {
    const S = Math.min(w, h), x = (w - S) / 2, y = (h - S) / 2, d = S / 6, rnd = seeded(11);
    ctx.save(); rrect(ctx, x, y, S, S, 14); ctx.fillStyle = P.card; ctx.fill(); ctx.clip();
    for (let yy = S - d / 2, row = 0; yy > -d / 2; yy -= d * 0.866, row++) {
      const n = row % 2 === 0 ? 6 : 7, x0 = row % 2 === 0 ? d / 2 : 0;
      for (let c = 0; c < n; c++) drawMarble(ctx, x + x0 + c * d, y + yy, d / 2, Math.floor(rnd() * 7));
    }
    ctx.restore(); rrect(ctx, x, y, S, S, 14); ctx.lineWidth = 3; ctx.strokeStyle = P.border; ctx.stroke(); return;
  }
  if (theme.timer === "rocket") { drawCockpit(ctx, w, h, 0.4, t, { mini: true }); return; }
  if (theme.timer === "coloring") {
    let pw = w, ph = pw * 0.75; if (ph > h) { ph = h; pw = ph / 0.75; }
    drawColoringPage(ctx, variants.current(theme), (w - pw) / 2, (h - ph) / 2 - 2, pw, ph - 4, 0.6, t, false); return;
  }
  if (theme.timer === "sandJar") {
    const pet = variants.current(theme), a = JARS[pet].aspect;
    let jw = w * 0.96, jh = jw / a; if (jh > h * 0.92) { jh = h * 0.92; jw = jh * a; }
    drawSandJar(ctx, pet, { x: (w - jw) / 2, y: (h - jh) / 2, w: jw, h: jh }, theme.mystery ? 0.35 : 0.5, t, { show: theme.mystery ? 0 : 1 });
    if (theme.mystery) {
      ctx.font = `900 ${h * 0.5}px Nunito, ui-rounded, system-ui, sans-serif`; ctx.textAlign = "center"; ctx.textBaseline = "middle";
      ctx.fillStyle = "rgba(0,0,0,0.25)"; ctx.fillText("?", w / 2, h * 0.38 + 3); ctx.fillStyle = "#fff"; ctx.fillText("?", w / 2, h * 0.38);
    }
    return;
  }
  // tiles: 3x3, half flipped, part of the cat showing
  const S = Math.min(w, h), x = (w - S) / 2, y = (h - S) / 2, tl = S / 3, shown = [1, 3, 4, 8], pic = petPicture(variants.current(theme), S, S), dpr = pic.width / S;
  ctx.save(); rrect(ctx, x, y, S, S, 14); ctx.clip(); ctx.fillStyle = P.card; ctx.fillRect(x, y, S, S);
  for (const i of shown) ctx.drawImage(pic, (i % 3) * tl * dpr, Math.floor(i / 3) * tl * dpr, tl * dpr, tl * dpr, x + (i % 3) * tl, y + Math.floor(i / 3) * tl, tl, tl);
  for (let i = 0; i < 9; i++) if (!shown.includes(i)) drawTileCover(ctx, theme, i + Math.floor(i / 3) * 2, x + (i % 3 + 0.5) * tl, y + (Math.floor(i / 3) + 0.5) * tl, tl - 4, 1, 0, 15, 7, 2.5);
  ctx.restore(); rrect(ctx, x, y, S, S, 14); ctx.lineWidth = 3; ctx.strokeStyle = "rgba(255,255,255,0.9)"; ctx.stroke();
}

// ============================================================ background + confetti
function drawBackground(ctx, w, h, theme, t, speed = 1) {
  const g = ctx.createLinearGradient(0, 0, 0, h); g.addColorStop(0, theme.bg[0]); g.addColorStop(1, theme.bg[1]);
  ctx.fillStyle = g; ctx.fillRect(0, 0, w, h);
  const span = h + 120;
  for (let i = 0; i < 18; i++) {
    const a = hash(i * 12.99 + 1), b = hash(i * 78.23 + 2), c = hash(i * 37.71 + 3), d = hash(i * 93.98 + 4), e = hash(i * 51.12 + 5);
    const y = h + 60 - ((t * (14 + a * 30) * speed + b * 5000) % span), x = c * w + Math.sin(t * (0.4 + d * 0.6) + a * 10) * 18;
    const s = 10 + e * 26, col = theme.shapes[i % theme.shapes.length];
    ctx.globalAlpha = 0.12 + 0.22 * d;
    ctx.save(); ctx.translate(x, y); ctx.rotate(t * 0.35 * (a - 0.5));
    if (i % 3 === 0) circ(ctx, 0, 0, s / 2, col);
    else if (i % 3 === 1) sparkle(ctx, 0, 0, s * 1.4, col);
    else fillRR(ctx, -s / 2, -s / 2, s, s, s * 0.25, col);
    ctx.restore();
  }
  ctx.globalAlpha = 1;
}
const particles = [];
function burst(x, y, colors, big = true, firework = false) {
  const n = big ? 160 : 40;
  for (let i = 0; i < n; i++) {
    const a = Math.random() * Math.PI * 2, v = (big ? 260 : 120) + Math.random() * (big ? 420 : 200);
    particles.push({ x, y, vx: Math.cos(a) * v, vy: Math.sin(a) * v - (big ? 120 : 60), rot: Math.random() * 6, vr: (Math.random() - 0.5) * 12,
      shape: i % 3, color: colors[i % colors.length], life: big ? 3.5 + Math.random() : 1.4 + Math.random() * 0.6, age: 0,
      size: (big ? 9 : 7) * (0.7 + Math.random() * 0.6), g: firework ? 160 : 420 });
  }
}
function drawParticles(ctx, dt) {
  for (let i = particles.length - 1; i >= 0; i--) {
    const p = particles[i];
    p.age += dt; if (p.age > p.life) { particles.splice(i, 1); continue; }
    p.vy += p.g * dt; p.vx *= 0.99; p.x += p.vx * dt; p.y += p.vy * dt; p.rot += p.vr * dt;
    ctx.globalAlpha = Math.min(1, (p.life - p.age) * 1.5);
    ctx.save(); ctx.translate(p.x, p.y); ctx.rotate(p.rot);
    if (p.shape === 0) fillRR(ctx, -p.size, -p.size / 2.5, p.size * 2, p.size / 1.25, 2, p.color);
    else if (p.shape === 1) circ(ctx, 0, 0, p.size * 0.7, p.color);
    else sparkle(ctx, 0, 0, p.size * 2, p.color);
    ctx.restore();
  }
  ctx.globalAlpha = 1;
}

/** flat gift box centered at the origin; `lid` 0...1 pops the lid off */
function drawGift(ctx, g, color, lip, lid) {
  fillRR(ctx, -g * 0.39, -g * 0.065, g * 0.78, g * 0.55, 14, lip);
  fillRR(ctx, -g * 0.39, -g * 0.06, g * 0.78, g * 0.5, 14, color);
  ctx.fillStyle = P.yellow; ctx.fillRect(-g * 0.07, -g * 0.065, g * 0.14, g * 0.55);
  ctx.save(); ctx.translate(lid * g * 0.4, -g * 0.12 - lid * g * 0.8); ctx.rotate(rad(lid * 35)); ctx.globalAlpha = 1 - lid;
  fillRR(ctx, -g * 0.45, -g * 0.1 + 5, g * 0.9, g * 0.2, 12, lip);
  fillRR(ctx, -g * 0.45, -g * 0.1, g * 0.9, g * 0.2, 12, color);
  ctx.fillStyle = P.yellow; ctx.fillRect(-g * 0.07, -g * 0.1, g * 0.14, g * 0.2);
  ell(ctx, -g * 0.13, -g * 0.15, g * 0.13, g * 0.085, P.yellow, rad(-30));
  ell(ctx, g * 0.13, -g * 0.15, g * 0.13, g * 0.085, P.yellow, rad(30));
  circ(ctx, 0, -g * 0.11, g * 0.06, P.yellowLip);
  ctx.restore(); ctx.globalAlpha = 1;
}

/** chunky slot machine: marquee with blinking bulbs, three reels, and a lever on the right */
function drawSlotMachine(ctx, w, h, f, th, t) {
  const drop = Math.min((t - f.slotT) / 0.5, 1), ease = 1 - Math.pow(1 - drop, 3);
  const B = Math.min(w * 0.74, 290, h * 0.9), bodyH = B * 0.82, markH = B * 0.24;
  const totalH = markH + bodyH, x = (w - B) / 2 - B * 0.06, y = (h - totalH) / 2 + (1 - ease) * -h * 0.6;
  const win = f.jackpot && f.resolved, spinning = f.pullT && !f.resolved;
  // marquee
  fillRR(ctx, x + B * 0.06, y + 5, B * 0.88, markH, 16, P.yellowLip);
  fillRR(ctx, x + B * 0.06, y, B * 0.88, markH, 16, P.yellow);
  ctx.font = `900 ${markH * 0.42}px Nunito, ui-rounded, system-ui, sans-serif`; ctx.textAlign = "center"; ctx.textBaseline = "middle";
  ctx.fillStyle = win && Math.floor(t * 6) % 2 ? P.red : "#5A3D00"; ctx.fillText(win ? "JACKPOT!" : "PRIZE SPIN", x + B / 2, y + markH * 0.52);
  // bulbs around the marquee: chase while spinning, flash on a jackpot
  const bulbs = 12;
  for (let i = 0; i < bulbs; i++) {
    const bx = x + B * 0.06 + (i + 0.5) * B * 0.88 / bulbs;
    const on = win ? Math.floor(t * 8) % 2 === 0 : spinning ? (Math.floor(t * 14) + i) % 3 === 0 : (Math.floor(t * 2) + i) % 2 === 0;
    circ(ctx, bx, y + 6, B * 0.018, on ? "#fff" : "#E0A905"); circ(ctx, bx, y + markH - 6, B * 0.018, on ? "#fff" : "#E0A905");
  }
  // body
  const by = y + markH + 6;
  fillRR(ctx, x, by + 6, B, bodyH, 24, th.lip);
  fillRR(ctx, x, by, B, bodyH, 24, th.primary);
  ctx.globalAlpha = 0.25; fillRR(ctx, x + 12, by + 10, B * 0.12, bodyH - 20, 8, "#fff"); ctx.globalAlpha = 1;
  // reel window
  const pad = B * 0.07, rw = (B - pad * 2 - B * 0.04) / 3, rh = rw * 1.25, ry = by + bodyH * 0.12;
  fillRR(ctx, x + pad - 6, ry - 6, B - pad * 2 + 12, rh + 12, 16, "#20303A");
  for (let i = 0; i < 3; i++) {
    const rx = x + pad + i * (rw + B * 0.02), r = f.reels[i];
    ctx.save(); rrect(ctx, rx, ry, rw, rh, 12); ctx.fillStyle = "#FFFDF6"; ctx.fill(); ctx.clip();
    const n = f.icons.length, base = Math.floor(r.pos), frac = r.pos - base, cell = rh * 0.8;
    ctx.font = `${cell * 0.62}px system-ui, "Apple Color Emoji", "Segoe UI Emoji", sans-serif`; ctx.textAlign = "center"; ctx.textBaseline = "middle";
    for (let k = -2; k <= 2; k++) {
      const idx = ((base + k) % n + n) % n, cy = ry + rh / 2 + (k - frac) * cell;
      const blur = !r.done && f.pullT ? 0.55 : 1;
      ctx.globalAlpha = blur * (k === 0 && frac < 0.01 ? 1 : 0.9);
      ctx.fillText(f.icons[idx], rx + rw / 2, cy);
    }
    ctx.globalAlpha = 1;
    // soft shading at the top and bottom of each reel
    const g = ctx.createLinearGradient(0, ry, 0, ry + rh);
    g.addColorStop(0, "rgba(0,0,0,0.25)"); g.addColorStop(0.25, "rgba(0,0,0,0)"); g.addColorStop(0.75, "rgba(0,0,0,0)"); g.addColorStop(1, "rgba(0,0,0,0.25)");
    ctx.fillStyle = g; ctx.fillRect(rx, ry, rw, rh);
    ctx.restore();
    if (win) { rrect(ctx, rx, ry, rw, rh, 12); ctx.lineWidth = 4; ctx.strokeStyle = Math.floor(t * 8) % 2 ? P.yellow : "#fff"; ctx.stroke(); }
  }
  // pay line
  ctx.globalAlpha = 0.8; fillRR(ctx, x + pad - 10, ry + rh / 2 - 2, B - pad * 2 + 20, 4, 2, P.red); ctx.globalAlpha = 1;
  // coin tray
  fillRR(ctx, x + B * 0.25, by + bodyH * 0.78, B * 0.5, bodyH * 0.12, 10, th.lip);
  fillRR(ctx, x + B * 0.28, by + bodyH * 0.8, B * 0.44, bodyH * 0.06, 6, "#20303A");
  // lever: pivots on the right side; swings down when pulled
  const px = x + B + 4, py = by + bodyH * 0.45, len = B * 0.48;
  let ang = -100;
  if (f.pullT) { const u = t - f.pullT; ang = u < 0.25 ? -100 + 150 * (u / 0.25) : u < 0.7 ? 50 - 150 * ((u - 0.25) / 0.45) : -100; }
  else ang = -100 + Math.sin(t * 5) * 6;     // wiggles: "pull me!"
  fillRR(ctx, px - 4, py - 14, 16, 28, 6, "#9AA7B0");
  ctx.save(); ctx.translate(px + 4, py); ctx.rotate(rad(ang + 90));
  fillRR(ctx, -4, -len, 8, len, 4, "#C9D3D9");
  circ(ctx, 0, -len + 2, B * 0.075, P.redLip); circ(ctx, 0, -len, B * 0.075, P.red); circ(ctx, -B * 0.025, -len - B * 0.025, B * 0.022, "#fff");
  ctx.restore();
  f.leverBox = { x: px - B * 0.1, y: py - len - B * 0.1, w: B * 0.25, h: len + B * 0.3 };
}

// ============================================================ brushing session
class Session {
  constructor(theme, duration) {
    this.theme = theme; this.duration = duration; this.elapsed = 0; this.zone = 0; this.paused = false; this.finished = false;
    this.countdown = null; this.cheered = new Set(); this.cheers = shuffle(["cheer1", "cheer2", "cheer3"]);
    this.seed = Math.floor(Math.random() * 1e9) + 1;
    this.pet = variants.current(theme) || "cat";
  }
  get zoneLength() { return this.duration / 8; }
  get progress() { return Math.min(this.elapsed / this.duration, 1); }
  get remaining() { return Math.max(this.duration - this.elapsed, 0); }
  get zoneProgress() { return Math.min(Math.max((this.elapsed - this.zone * this.zoneLength) / this.zoneLength, 0), 1); }
  start() {
    const zl = this.zoneLength, A = AudioEngine;
    A.rate = zl < 5 ? 1.3 : (zl < 9 ? 1.1 : 1);
    A.startMusic(this.theme.id); A.play("whoosh");
    if (zl >= 9) A.say(this.theme.id, "intro");
    A.say(this.theme.id, ZONES[0].key);
  }
  update(dt) {
    if (this.paused || this.finished) return;
    this.elapsed += Math.min(dt, 0.5);
    const A = AudioEngine, zl = this.zoneLength;
    const nz = Math.min(Math.floor(this.elapsed / zl), 7);
    if (nz !== this.zone) {
      this.zone = nz; A.playQuiet("zone", 0.3); buzz(15); UI.onZone();
      zl < 9 ? A.sayNow(this.theme.id, ZONES[nz].key) : A.say(this.theme.id, ZONES[nz].key);
    }
    const into = this.elapsed - this.zone * zl;
    if (zl >= 10 && into > zl * 0.6 && this.zone % 2 === 1 && !this.cheered.has(this.zone) && !A.speaking && this.remaining > 8) {
      this.cheered.add(this.zone); const line = this.cheers.shift(); this.cheers.push(line); A.say(this.theme.id, line);
    }
    const left = Math.ceil(this.remaining);
    if (left <= 5 && left >= 1) { if (this.countdown !== left) { this.countdown = left; A.play("beep"); buzz(10); UI.showCount(left); } }
    else this.countdown = null;
    if (this.elapsed >= this.duration) {
      this.elapsed = this.duration; this.finished = true; this.countdown = null;
      A.play("beep_final"); A.stopMusic(0.3); A.stopVoice(); A.rate = 1;
      UI.finish();
    }
  }
  stop() { this.finished = true; AudioEngine.rate = 1; AudioEngine.stopVoice(); AudioEngine.stopMusic(); }
}

// ============================================================ screens
const $ = id => document.getElementById(id);
const UI = {
  screen: "home", session: null, finale: null, wakeLock: null,
  get theme() { return this.session ? this.session.theme : themeById(settings.themeId); },
  setThemeVars(th) {
    const r = document.documentElement.style;
    r.setProperty("--primary", th.primary); r.setProperty("--primary-lip", th.lip); r.setProperty("--primary-light", th.light); r.setProperty("--button-text", th.text);
  },
  show(name) { for (const s of ["home", "brush", "finale"]) $(s).hidden = s !== name; this.screen = name; },

  // ---------- home
  buildHome() {
    const th = themeById(settings.themeId);
    this.setThemeVars(th);
    $("tagline").textContent = this.tagline(th);
    $("streak").textContent = "🔥 " + rewards.streak;
    $("bookCount").textContent = rewards.collected + "/" + rewards.total;
    $("musicBtn").classList.toggle("off", !settings.music);
    $("voiceBtn").classList.toggle("off", !settings.voice);
    const box = $("themes");
    if (!box.children.length) {
      for (const t of THEMES) {
        const b = document.createElement("button"); b.className = "tile"; b.dataset.id = t.id;
        b.style.background = `linear-gradient(${t.bg[0]}, ${t.bg[1]})`;
        b.innerHTML = `<canvas></canvas><span>${t.name}</span>`;
        b.style.setProperty("--primary", t.primary); b.style.setProperty("--primary-lip", t.lip);
        b.addEventListener("click", () => this.pickTheme(t));
        box.appendChild(b);
      }
      const durs = $("durations");
      for (const [label, sec] of [["30 sec", 30], ["1 min", 60], ["90 sec", 90]]) {
        const c = document.createElement("button"); c.className = "chip"; c.textContent = label; c.dataset.sec = sec;
        c.addEventListener("click", () => { AudioEngine.unlock(); AudioEngine.play("tap"); settings.duration = sec; store.set("duration", sec); this.buildHome(); });
        durs.appendChild(c);
      }
    }
    for (const b of box.children) b.classList.toggle("sel", b.dataset.id === th.id);
    for (const c of $("durations").children) c.classList.toggle("sel", +c.dataset.sec === settings.duration);
    AudioEngine.loadTheme(th.id);
  },
  tagline(th) {
    const list = variants.list(th);
    if (th.mystery) return "Guess the animal hiding in the sand!";
    if (th.timer === "sandJar" && list.length > 1) return `Fill the ${VARIANT_NAMES[variants.current(th)].toLowerCase()} jar with rainbow sand!`;
    if (th.timer === "tiles") return `Flip the tiles to find secret pet #${variants.index(th) + 1}!`;
    if (th.timer === "coloring") return `Let's color in the ${DINOS[variants.current(th)].name}!`;
    return th.tagline;
  },
  pickTheme(t) {
    AudioEngine.unlock();
    if (t.id === settings.themeId) {
      // tap again: switch to the next jar animal / hidden picture
      if (variants.list(t).length > 1) {
        variants.advance(t); AudioEngine.play("tap"); buzz(8);
        $("tagline").classList.remove("pop"); void $("tagline").offsetWidth; $("tagline").classList.add("pop");
        this.buildHome();
      }
      return;
    }
    settings.themeId = t.id; store.set("theme", t.id);
    variants.advance(t);          // a new jar animal / hidden picture every time this theme is picked
    AudioEngine.play("tap"); buzz(8);
    $("tagline").classList.remove("pop"); void $("tagline").offsetWidth; $("tagline").classList.add("pop");
    this.buildHome();
    AudioEngine.loadTheme(t.id).then(() => { if (settings.themeId === t.id && this.screen === "home") AudioEngine.sayNow(t.id, "intro"); });
  },

  // ---------- brushing
  async start() {
    AudioEngine.unlock();
    const th = themeById(settings.themeId), btn = $("startBtn");
    btn.disabled = true; btn.textContent = "Loading…";
    await Promise.race([AudioEngine.loadTheme(th.id), new Promise(r => setTimeout(r, 4000))]);
    btn.disabled = false; btn.textContent = "Start brushing";
    AudioEngine.stopVoice(); AudioEngine.play("sparkle");
    this.session = new Session(th, settings.duration);
    variants.advance(th);         // next time (after finishing or quitting) it's a different one
    mouthState.bx = null;
    const segs = $("segs"); segs.innerHTML = ZONES.map(() => '<div class="seg"><i></i></div>').join("");
    $("bubbleRow").classList.toggle("side", th.timer !== "ring");
    $("sideMascot").hidden = th.timer === "ring";
    $("zoneBubble").className = "bubble " + (th.timer === "ring" ? "tail-down" : "tail-left");
    this.onZone(true);
    this.show("brush");
    this.requestWake();
    this.session.start();
  },
  onZone(first) {
    const s = this.session, z = ZONES[s.zone], b = $("zoneBubble");
    b.innerHTML = `<span class="sym">${z.sym}</span>${z.title}`;
    b.classList.remove("pop"); void b.offsetWidth; b.classList.add("pop");
    if (!first) { const r = $("timerWrap").getBoundingClientRect(); burst(r.left + r.width / 2, r.top + r.height * 0.3, [s.theme.primary, s.theme.light, "#fff"], false); }
  },
  showCount(n) { $("countdown").innerHTML = `<span>${n}</span>`; },
  pause() {
    const s = this.session; if (!s || s.finished) return;
    AudioEngine.play("tap"); s.paused = true; AudioEngine.stopVoice(); AudioEngine.pauseAll();
    $("pauseText").textContent = `Your teeth are ${Math.round(s.progress * 100)}% sparkly.`;
    $("pauseSheet").hidden = false;
  },
  resume() { AudioEngine.resumeAll(); AudioEngine.play("tap"); $("pauseSheet").hidden = true; if (this.session) this.session.paused = false; },
  quit() {
    AudioEngine.resumeAll(); $("pauseSheet").hidden = true;
    if (this.session) this.session.stop(); this.session = null; $("countdown").innerHTML = "";
    this.releaseWake(); this.show("home"); this.buildHome();
  },
  async requestWake() { try { if (navigator.wakeLock) this.wakeLock = await navigator.wakeLock.request("screen"); } catch (e) { this.wakeLock = null; } },
  releaseWake() { try { this.wakeLock && this.wakeLock.release(); } catch (e) {} this.wakeLock = null; },

  // ---------- finale
  finish() {
    const s = this.session, th = s.theme;
    this.releaseWake();
    $("countdown").innerHTML = "";
    const f = this.finale = { phase: "boom", t0: performance.now() / 1000, sticker: null, isNew: false };
    $("finaleTitle").textContent = th.finale;
    $("finaleTitle").style.animation = "none"; void $("finaleTitle").offsetWidth; $("finaleTitle").style.animation = "";
    $("badge").hidden = true; $("badge").className = "";
    $("finaleFooter").innerHTML = '<div style="height:63px"></div>';
    this.show("finale");
    const A = AudioEngine;
    A.play("boom"); buzz([30, 40, 60]);
    this.flash();
    $("app").classList.remove("shake"); void $("app").offsetWidth; $("app").classList.add("shake");
    burst(innerWidth / 2, innerHeight * 0.45, [...th.shapes, th.primary, P.pink, P.green], true);
    const at = (sec, fn) => setTimeout(() => { if (this.finale === f) fn(); }, sec * 1000);
    at(0.6, () => { A.play("fanfare", 0.8); A.sayNow(th.id, "finale"); burst(innerWidth * 0.18, innerHeight * 0.28, [P.yellow, "#fff"], true, true); burst(innerWidth * 0.82, innerHeight * 0.22, [th.primary, "#fff"], true, true); });
    at(1.4, () => { A.play("sparkle"); burst(innerWidth * 0.5, innerHeight * 0.2, [th.light, "#fff"], true, true); });
    at(3.4, () => {
      A.play("whoosh");
      const icons = th.stickers.map(x => x.emoji);
      f.phase = "slot"; f.slotT = performance.now() / 1000; f.icons = icons;
      f.reels = [0, 1, 2].map(i => ({ pos: (i * 2) % icons.length, from: 0, dist: 0, t0: 0, t1: 0, done: true, lastTick: 0 }));
      f.pullT = null;
      $("finaleTitle").textContent = "Pull the lever!";
      $("finaleFooter").innerHTML = '<button class="btn" id="pullBtn">Pull the lever!</button>';
      $("pullBtn").addEventListener("click", () => this.pullLever());
    });
    at(16, () => this.pullLever());
  },
  flash() { $("flash").classList.remove("on"); void $("flash").offsetWidth; $("flash").classList.add("on"); },
  /** spin the three reels; about 1 in 5 pulls lines up the grand prize */
  pullLever() {
    const f = this.finale; if (!f || f.phase !== "slot" || f.pullT) return;
    const th = this.session.theme, A = AudioEngine, n = f.icons.length;
    const jackpotIcon = th.stickers.findIndex(x => x.rarity === "legendary");
    f.jackpot = Math.random() < 0.2;
    let targets;
    if (f.jackpot) targets = [jackpotIcon, jackpotIcon, jackpotIcon];
    else {
      do { targets = [0, 1, 2].map(() => Math.floor(Math.random() * n)); }
      while (targets[0] === targets[1] && targets[1] === targets[2]);
      if (Math.random() < 0.35) { targets[0] = targets[1] = jackpotIcon; if (targets[2] === jackpotIcon) targets[2] = (jackpotIcon + 1) % n; }  // so close!
    }
    const now = performance.now() / 1000;
    f.pullT = now;
    f.reels.forEach((r, i) => {
      r.from = r.pos; r.t0 = now + 0.35; r.t1 = r.t0 + 1.3 + i * 0.6; r.done = false; r.target = targets[i];
      r.dist = n * (4 + i * 2) + ((targets[i] - Math.round(r.pos)) % n + n) % n;
    });
    const pb = $("pullBtn"); if (pb) { pb.disabled = true; pb.textContent = "Spinning…"; }
    $("finaleTitle").textContent = "Spinning…";
    A.play("rattle"); buzz(20);
    // award now so it's saved even if they leave mid-spin
    f.sticker = rewards.award(th, f.jackpot); f.isNew = rewards.lastWasNew;
  },
  updateSlot(t) {
    const f = this.finale; if (!f || f.phase !== "slot" || !f.pullT) return;
    const A = AudioEngine, n = f.icons.length;
    let all = true;
    f.reels.forEach(r => {
      if (r.done) return;
      const u = Math.min(Math.max((t - r.t0) / (r.t1 - r.t0), 0), 1), e = 1 - Math.pow(1 - u, 3);
      r.pos = r.from + r.dist * e;
      const cell = Math.floor(r.pos);
      if (cell !== r.lastTick) { r.lastTick = cell; if (u > 0 && u < 1) A.playQuiet("clack", 0.12); }
      if (u >= 1) { r.done = true; r.pos = r.target; A.play("tap"); buzz(15); } else all = false;
    });
    if (all && !f.resolved) {
      f.resolved = true;
      const th = this.session.theme;
      if (f.jackpot) {
        f.winT = t; $("finaleTitle").textContent = "JACKPOT!";
        A.play("fanfare"); A.play("sparkle"); buzz([40, 40, 40, 40, 80]); this.flash();
        burst(innerWidth / 2, innerHeight * 0.4, [P.yellow, "#fff", th.primary, P.pink], true);
        setTimeout(() => burst(innerWidth * 0.2, innerHeight * 0.3, [P.yellow, "#fff"], true, true), 400);
        setTimeout(() => burst(innerWidth * 0.8, innerHeight * 0.3, [P.yellow, "#fff"], true, true), 800);
        setTimeout(() => this.reveal(), 2000);
      } else {
        $("finaleTitle").textContent = "You won a prize!";
        A.play("pop"); A.play("sparkle", 0.6);
        setTimeout(() => this.reveal(), 1100);
      }
    }
  },
  reveal() {
    const f = this.finale; if (!f || f.phase !== "slot") return;
    const th = this.session.theme, A = AudioEngine, st = f.sticker, R = RARITY[st.rarity];
    A.play("sparkle"); if (!f.jackpot) A.play("fanfare", 0.6); buzz([30, 30, 50]);
    this.flash();
    f.phase = "reveal";
    $("finaleTitle").textContent = f.jackpot ? "Grand prize!" : "New sticker!";
    const badge = $("badge");
    badge.innerHTML = `<div class="badge" style="width:200px;height:200px;background:${R.color};box-shadow:0 10px 0 ${R.lip}"><div class="ring"></div><span style="font-size:100px;line-height:1">${st.emoji}</span></div>` + (f.isNew ? '<span class="new">NEW</span>' : "");
    badge.hidden = false; badge.classList.remove("show"); void badge.offsetWidth; badge.classList.add("show");
    const sr = $("stage").getBoundingClientRect();
    burst(sr.left + sr.width / 2, sr.top + sr.height / 2, [R.color, "#fff", th.primary], true);
    $("finaleFooter").innerHTML = `
      <div class="card"><canvas id="footMascot"></canvas><div>
        <div class="rarity" style="color:${R.color}">${f.jackpot ? "Grand prize · " : ""}${R.label}</div>
        <div class="sname">${st.name}</div>
        ${rewards.streak > 0 ? `<div class="streakline">🔥 ${rewards.streak} day streak</div>` : ""}
      </div></div>
      <button class="btn" id="contBtn">Continue</button>
      <button class="btn outline" id="bookBtn2">Sticker book</button>`;
    $("contBtn").addEventListener("click", () => { A.play("tap"); A.stopVoice(); A.stopMusic(); this.finale = null; this.session = null; this.show("home"); this.buildHome(); });
    $("bookBtn2").addEventListener("click", () => { A.play("tap"); this.openBook(st.id); });
  },
  drawStage(ctx, w, h, t) {
    const f = this.finale, th = this.session.theme;
    if (f.phase === "boom") {
      const k = Math.min((t - f.t0) / 0.5, 1), s = Math.min(220, w * 0.6) * (0.2 + 0.8 * (1 - Math.pow(1 - k, 3)));
      ctx.globalAlpha = k; drawMascot(ctx, w / 2 - s / 2, h / 2 - s * 0.6, s, { costume: th.costume, mood: "cheer", talking: AudioEngine.speaking }, t); ctx.globalAlpha = 1;
    } else if (f.phase === "slot") {
      this.updateSlot(t);
      drawSlotMachine(ctx, w, h, f, th, t);
    } else if (f.phase === "reveal") {
      const R = RARITY[f.sticker.rarity], a = t * 0.35, r = Math.max(w, h);
      ctx.save(); ctx.translate(w / 2, h / 2); ctx.globalAlpha = 0.22; ctx.fillStyle = R.color;
      for (let i = 0; i < 14; i++) { const a0 = a + i * Math.PI * 2 / 14; ctx.beginPath(); ctx.moveTo(0, 0); ctx.arc(0, 0, r, a0, a0 + Math.PI / 14); ctx.closePath(); ctx.fill(); }
      ctx.restore(); ctx.globalAlpha = 1;
    }
  },

  // ---------- sticker book
  openBook(highlight) {
    $("bookBar").style.width = (rewards.collected / rewards.total * 100) + "%";
    $("bookText").textContent = `${rewards.collected} of ${rewards.total} found`;
    $("bookList").innerHTML = THEMES.map(t => `
      <div class="bsec"><h3>${t.name}</h3><div class="bgrid">${t.stickers.map(s => {
        const n = rewards.counts[s.id] || 0, R = RARITY[s.rarity];
        const bg = n ? R.color : P.card, lip = n ? R.lip : P.border;
        return `<div class="bitem ${s.id === highlight ? "hl" : ""}"><div class="badge" style="width:72px;height:72px;background:${bg};box-shadow:0 4px 0 ${lip}">
          <div class="ring" style="border-width:3px;border-color:${n ? "rgba(255,255,255,.85)" : "rgba(255,255,255,.1)"}"></div>
          <span style="font-size:36px;line-height:1;${n ? "" : "color:" + P.border}">${n ? s.emoji : "?"}</span>${n > 1 ? `<span class="xn">x${n}</span>` : ""}</div>
          <span class="nm ${n ? "" : "unk"}">${n ? s.name : "???"}</span></div>`;
      }).join("")}</div></div>`).join("");
    $("book").hidden = false;
  },
};

// ============================================================ wiring
$("startBtn").addEventListener("click", () => UI.start());
$("stage").addEventListener("click", () => { if (UI.finale && UI.finale.phase === "slot") UI.pullLever(); });
$("bookBtn").addEventListener("click", () => { AudioEngine.unlock(); AudioEngine.play("tap"); UI.openBook(); });
$("bookClose").addEventListener("click", () => { AudioEngine.play("tap"); $("book").hidden = true; });
$("musicBtn").addEventListener("click", () => { AudioEngine.unlock(); settings.music = !settings.music; store.set("music", settings.music); AudioEngine.play("tap"); UI.buildHome(); });
$("voiceBtn").addEventListener("click", () => { AudioEngine.unlock(); settings.voice = !settings.voice; store.set("voice", settings.voice); if (!settings.voice) AudioEngine.stopVoice(); AudioEngine.play("tap"); UI.buildHome(); });
$("quitBtn").addEventListener("click", () => UI.pause());
$("pauseBtn").addEventListener("click", () => UI.pause());
$("resumeBtn").addEventListener("click", () => UI.resume());
$("endBtn").addEventListener("click", () => { AudioEngine.play("tap"); UI.quit(); });
// grown-ups: hold the time for 1.5 seconds to jump to the end and test the finale
let holdTimer = null;
$("pill").addEventListener("pointerdown", () => { holdTimer = setTimeout(() => { const s = UI.session; if (s && !s.finished) { s.elapsed = Math.max(s.elapsed, s.duration - 6); } }, 1500); });
["pointerup", "pointerleave", "pointercancel"].forEach(ev => $("pill").addEventListener(ev, () => clearTimeout(holdTimer)));
document.addEventListener("visibilitychange", () => { if (!document.hidden && UI.wakeLock === null && UI.screen === "brush") UI.requestWake(); });
SFX.forEach(n => AudioEngine.load("sfx_" + n + ".wav"));
document.addEventListener("pointerdown", () => AudioEngine.unlock(), { once: true });

// ============================================================ main loop
let lastT = performance.now();
function frame(nowMs) {
  const t = nowMs / 1000, dt = Math.min((nowMs - lastT) / 1000, 0.1); lastT = nowMs;
  const s = UI.session;
  if (s && UI.screen === "brush") s.update(dt);
  const th = UI.theme;
  { const { ctx, w, h } = fitCanvas($("bg")); drawBackground(ctx, w, h, th, t, UI.screen === "finale" ? 3 : (UI.screen === "brush" ? 1.3 : 1)); }
  if (UI.screen === "home") {
    const { ctx, w, h } = fitCanvas($("homeMascot"));
    drawMascot(ctx, w / 2 - Math.min(w, h / 1.15) / 2, 0, Math.min(w, h / 1.15), { costume: th.costume, talking: AudioEngine.speaking }, t);
    for (const b of $("themes").children) { const c = b.querySelector("canvas"); const r = fitCanvas(c); drawThemeIcon(r.ctx, r.w, r.h, themeById(b.dataset.id), t); }
  } else if (UI.screen === "brush" && s) {
    const z = s.zone;
    $("segs").querySelectorAll(".seg i").forEach((el, i) => { el.style.width = (i < z ? 100 : i === z ? Math.max(s.zoneProgress * 100, 8) : 0) + "%"; });
    if (s.theme.timer !== "ring") { const r = fitCanvas($("sideMascot")); drawMascot(r.ctx, 0, 0, Math.min(r.w, r.h / 1.15), { costume: s.theme.costume, mood: s.countdown ? "wow" : "happy", talking: AudioEngine.speaking, look: ZONES[z].look, brushing: true }, t); }
    const { ctx, w, h } = fitCanvas($("timerCanvas"));
    const pillH = $("pill").offsetHeight || 58;
    const room = s.theme.timer === "ring" ? h : h - pillH / 2;
    let bottom;
    if (s.theme.timer === "ring") bottom = drawRing(ctx, w, room - pillH / 2, s, t);
    else if (s.theme.timer === "plinko") bottom = drawPlinko(ctx, w, room, s);
    else if (s.theme.timer === "sandJar") bottom = drawSandTimer(ctx, w, room, s, t);
    else if (s.theme.timer === "coloring") bottom = drawColoringTimer(ctx, w, room, s, t);
    else if (s.theme.timer === "rocket") bottom = drawRocketTimer(ctx, w, room, s, t);
    else bottom = drawTiles(ctx, w, room, s, t);
    const pill = $("pill"); pill.style.top = (bottom - pillH / 2) + "px";
    const left = Math.ceil(s.remaining); pill.textContent = Math.floor(left / 60) + ":" + String(left % 60).padStart(2, "0");
    pill.classList.toggle("hurry", s.remaining <= 10);
    const m = fitCanvas($("mouthCanvas")); drawMouth(m.ctx, m.w, m.h, z, s.theme, t);
    if (!$("pauseSheet").hidden) { const p = fitCanvas($("pauseMascot")); drawMascot(p.ctx, 0, 0, Math.min(p.w, p.h / 1.15), { costume: s.theme.costume, mood: "wow" }, t); }
  } else if (UI.screen === "finale" && UI.finale) {
    const { ctx, w, h } = fitCanvas($("stageCanvas")); UI.drawStage(ctx, w, h, t);
    const fm = $("footMascot"); if (fm) { const r = fitCanvas(fm); drawMascot(r.ctx, 0, 0, Math.min(r.w, r.h / 1.15), { costume: th.costume, talking: AudioEngine.speaking }, t); }
  }
  { const { ctx } = fitCanvas($("fx")); drawParticles(ctx, dt); }
  requestAnimationFrame(frame);
}
UI.buildHome();
requestAnimationFrame(frame);
