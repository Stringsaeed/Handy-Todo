"""Generate Handy's original, short feedback sounds using the Python standard library."""
import math
from pathlib import Path
import struct
import wave

ROOT = Path(__file__).resolve().parents[1] / 'HandyTodo' / 'Sounds'
ROOT.mkdir(exist_ok=True)
RATE = 44100
for name, notes, duration in [('complete', [(0, 659.25), (0.085, 987.77)], 0.3),
                               ('delete', [(0, 220), (0.025, 165)], 0.12)]:
    samples = []
    for i in range(int(RATE * duration)):
        t = i / RATE
        value = 0
        for start, frequency in notes:
            age = t - start
            if age >= 0:
                envelope = min(age / 0.005, 1) * math.exp(-age * 24)
                value += math.sin(2 * math.pi * frequency * age) * envelope * 0.18
        # Fade out to a zero crossing envelope to avoid end clicks.
        value *= min((duration - t) / 0.02, 1)
        samples.append(struct.pack('<h', int(value * 32767)))
    with wave.open(str(ROOT / f'{name}.wav'), 'wb') as output:
        output.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        output.writeframes(b''.join(samples))
