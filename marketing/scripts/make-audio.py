#!/usr/bin/env python3
"""Compose the preview soundtrack: a 120 BPM groove in E major plus handy's own feedback sounds.

Uses only the Python standard library. Event times come from src/video-timeline.json so the
chimes land exactly on the on-screen completions. Writes build/audio.wav (48 kHz stereo).
"""
import json
import math
import random
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOUNDS = ROOT.parent / "HandyTodo" / "Sounds"
TL = json.loads((ROOT / "src" / "video-timeline.json").read_text())
RATE = 48000
LENGTH = TL["duration"]
BEAT = 60 / TL["bpm"]
N = int(RATE * LENGTH)
left = [0.0] * N
right = [0.0] * N
rng = random.Random(7)
TAU = 2 * math.pi


def add(start, samples, gain=1.0, pan=0.0):
    i0 = int(start * RATE)
    gl, gr = gain * math.sqrt((1 - pan) / 2), gain * math.sqrt((1 + pan) / 2)
    for k, v in enumerate(samples):
        i = i0 + k
        if 0 <= i < N:
            left[i] += v * gl
            right[i] += v * gr


def kick(amp=1.0, length=0.38):
    out, phase = [], 0.0
    for k in range(int(RATE * length)):
        t = k / RATE
        phase += TAU * (44 + 110 * math.exp(-t * 30)) / RATE
        out.append(math.sin(phase) * math.exp(-t * 8) * amp + (rng.uniform(-1, 1) * math.exp(-t * 400) * 0.25))
    return out


def noise_hit(decay, length, hp=2, amp=1.0):
    out, prev, prev2 = [], 0.0, 0.0
    for k in range(int(RATE * length)):
        t = k / RATE
        x = rng.uniform(-1, 1)
        y = x - prev if hp >= 1 else x
        z = y - prev2 if hp >= 2 else y
        prev, prev2 = x, y
        out.append(z * math.exp(-t * decay) * amp)
    return out


def clap():
    body = noise_hit(24, 0.25, hp=1, amp=0.6)
    for offset in (0.0, 0.011, 0.022):
        i = int(offset * RATE)
        for k in range(min(len(body) - i, 300)):
            body[i + k] += rng.uniform(-1, 1) * 0.5 * (1 - k / 300)
    return body


def tone(freqs, length, decay, amp, attack=0.004, harmonics=((1, 1.0),)):
    out = []
    for k in range(int(RATE * length)):
        t = k / RATE
        env = min(t / attack, 1) * math.exp(-t * decay) * min((length - t) / 0.01, 1)
        v = sum(h_amp * math.sin(TAU * f * h * t) for f in freqs for h, h_amp in harmonics)
        out.append(v * env * amp)
    return out


def pluck(freq, amp=0.1):
    return tone([freq], 0.55, 7.5, amp, harmonics=((1, 1.0), (2, 0.25), (3, 0.08)))


def bass(freq, length=0.24, amp=0.32):
    return tone([freq], length, 5, amp, attack=0.006, harmonics=tuple((h, 1 / h) for h in range(1, 7)))


def load_wav(path, gain=1.0, speed=1.0):
    with wave.open(str(path)) as w:
        rate, frames = w.getframerate(), w.readframes(w.getnframes())
    data = [s / 32768 for s in struct.unpack(f"<{len(frames) // 2}h", frames)]
    step = rate / RATE * speed
    out, pos = [], 0.0
    while pos < len(data) - 1:
        i = int(pos)
        out.append((data[i] + (data[i + 1] - data[i]) * (pos - i)) * gain)
        pos += step
    return out


def whoosh(length=0.45, amp=0.35):
    out, lp = [], 0.0
    for k in range(int(RATE * length)):
        t = k / RATE
        p = t / length
        cutoff = 0.02 + 0.5 * math.sin(math.pi * p) ** 2
        lp += cutoff * (rng.uniform(-1, 1) - lp)
        out.append(lp * math.sin(math.pi * p) ** 2 * amp)
    return out


def riser(length, amp=0.25):
    out, lp, phase = [], 0.0, 0.0
    for k in range(int(RATE * length)):
        t = k / RATE
        p = t / length
        lp += (0.01 + 0.6 * p * p) * (rng.uniform(-1, 1) - lp)
        phase += TAU * (180 + 1400 * p * p) / RATE
        out.append((lp * 0.8 + math.sin(phase) * 0.25) * p * p * amp)
    return out


# Chords: E, C#m, A, B. Arp tones sit two octaves up, where handy's E5/B5 chime lives.
CHORDS = {
    "E": ([82.41], [164.81, 207.65, 246.94]),
    "C#m": ([69.30], [138.59, 164.81, 207.65]),
    "A": ([110.0], [110.0, 138.59, 164.81]),
    "B": ([61.74], [123.47, 155.56, 185.0]),
}
PROGRESSION = ["E", "C#m", "A", "B"]
ARP = [0, 1, 2, 3, 2, 1, 2, 3]  # indices into chord tones + octave


def chord_at(t):
    return CHORDS[PROGRESSION[int(t // 2) % 4]]


def arp_note(t, step):
    tones = chord_at(t)[1]
    idx = ARP[step % len(ARP)]
    return (tones[idx] if idx < 3 else tones[0] * 2) * 4


# ── Intro (0–2): sparse plucks, a breath before the hits
for step in range(8):
    t = step * BEAT / 2
    add(t, pluck(arp_note(4.0, step), 0.07 + step * 0.006), pan=(-0.35 if step % 2 else 0.35))
add(1.0, riser(1.0, 0.18))

# ── Kinetic hits (2–4): a hit per word, then a snare roll into the groove
for t in (2.0, 2.25, 2.5, 2.75):
    add(t, kick(0.9))
    add(t, clap(), 0.55)
    add(t, bass(CHORDS["E"][0][0], 0.2, 0.3))
add(3.0, kick(1.0))
add(3.0, tone([329.63, 415.3, 493.88], 0.9, 3, 0.07, harmonics=((1, 1.0), (2, 0.2))))
for k in range(8):
    add(3.5 + k * BEAT / 8, noise_hit(30, 0.08, amp=0.15 + k * 0.05), pan=0.1)

# ── Groove (4–16) and return (18–20); the night scene (16–18) drops the kick
for b in range(int(4 / BEAT), int(20 / BEAT)):
    t = b * BEAT
    night = 16.0 <= t < 18.0
    if not night:
        add(t, kick(0.95))
        if b % 2 == 1:
            add(t, clap(), 0.5)
    for half in (0, 1):
        th = t + half * BEAT / 2
        add(th, bass(chord_at(th)[0][0] * (1 if half == 0 else 2), 0.22, 0.26 if not night else 0.18))
        if half == 1 or night:
            add(th, noise_hit(70, 0.06, amp=0.22), pan=0.45)
    for q in range(4):
        tq = t + q * BEAT / 4
        add(tq, noise_hit(110, 0.03, amp=0.08), pan=-0.45)
        add(tq, pluck(arp_note(tq, b * 4 + q), 0.075 if not night else 0.06), pan=(-0.3 if q % 2 else 0.3))
    if night and b % 4 == 0:
        add(t, tone(chord_at(t)[1], 1.9, 1.2, 0.05, attack=0.25, harmonics=((1, 1.0), (2, 0.3))))
add(18.0, riser(2.0, 0.22))
for k in range(16):
    add(19.0 + k * BEAT / 8, noise_hit(30, 0.07, amp=0.1 + k * 0.025), pan=-0.1)

# ── Outro (20–24): impact, ringing E major, slow plucks under the tagline
add(20.0, kick(1.3, 0.8))
add(20.0, noise_hit(5, 1.2, hp=1, amp=0.18))
add(20.0, tone([41.2, 82.41], 1.6, 2.2, 0.35))
add(20.0, tone([164.81, 207.65, 246.94, 329.63], 4.0, 0.9, 0.06, attack=0.02, harmonics=((1, 1.0), (2, 0.35), (3, 0.1))))
for k, t in enumerate([20.5, 21.0, 21.5, 22.0, 22.5, 23.0]):
    add(t, pluck([659.25, 830.61, 987.77, 1318.5, 987.77, 659.25][k], 0.08), pan=(-0.3 if k % 2 else 0.3))

# ── handy's own sounds, synced to the picture
chime = load_wav(SOUNDS / "complete.wav", 2.2)
click = load_wav(SOUNDS / "delete.wav", 0.9, speed=1.6)
for t in TL["sfx"]["chime"]:
    add(t, chime)
for t in TL["sfx"]["tap"]:
    add(t, click, 0.8)
for k, t in enumerate(TL["sfx"]["key"]):
    add(t, click, 0.55, pan=(-0.15 if k % 2 else 0.15))
for t in TL["sfx"]["pop"]:
    add(t, load_wav(SOUNDS / "complete.wav", 1.6, speed=1.5))
for t in TL["sfx"]["whoosh"]:
    add(t - 0.2, whoosh())

# Master: gentle fade-out, soft clip, normalize to about -2 dBFS
fade = int(0.7 * RATE)
for i in range(N - fade, N):
    g = (N - i) / fade
    left[i] *= g
    right[i] *= g
peak = max(max(abs(v) for v in left), max(abs(v) for v in right))
norm = 0.78 / math.tanh(peak * 1.1) if peak else 1
out = ROOT / "build" / "audio.wav"
out.parent.mkdir(parents=True, exist_ok=True)
with wave.open(str(out), "wb") as w:
    w.setparams((2, 2, RATE, 0, "NONE", "not compressed"))
    w.writeframes(b"".join(
        struct.pack("<hh", int(math.tanh(l * 1.1) * norm * 32767), int(math.tanh(r * 1.1) * norm * 32767))
        for l, r in zip(left, right)))
print(f"wrote {out.relative_to(ROOT)} ({LENGTH}s)")
