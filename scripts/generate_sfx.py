#!/usr/bin/env python3
"""효과음 .wav 생성 (기존 main.gd _play_synth_tone 합성음을 오프라인 렌더링).

AudioStreamGenerator(런타임 실시간 합성)가 iOS 실기기에서 소리가 나지 않아,
동일한 톤을 미리 .wav 로 구워 AudioStreamPlayer 로 재생하도록 대체한다.
런타임의 index/flip_count 에 따른 base frequency 변화는 GDScript 에서 pitch_scale 로 재현한다.

출력: godot/assets/audio/{place,flip,big_flip}.wav (44.1kHz, 16-bit stereo)
"""
import math
import os
import struct
import wave

MIX_RATE = 44100
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "godot", "assets", "audio")


def render(base_frequency, duration, volume, sweep=0.0, overtone_mix=0.0):
    frames = int(MIX_RATE * duration)
    phase = 0.0
    overtone_phase = 0.0
    samples = []
    for i in range(frames):
        t = i / MIX_RATE
        progress = t / max(duration, 0.001)
        frequency = base_frequency + sweep * progress
        envelope = math.sin(progress * math.pi)
        phase += math.tau * frequency / MIX_RATE
        sample = math.sin(phase)
        if overtone_mix > 0.0:
            overtone_phase += math.tau * frequency * 1.5 / MIX_RATE
            sample = sample * (1.0 - overtone_mix) + math.sin(overtone_phase) * overtone_mix
        sample *= volume * envelope
        samples.append(sample)
    return samples


def write_wav(path, samples):
    with wave.open(path, "w") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(MIX_RATE)
        frames = bytearray()
        for s in samples:
            v = int(max(-1.0, min(1.0, s)) * 32767)
            frames += struct.pack("<hh", v, v)
        w.writeframes(bytes(frames))
    print(f"wrote {path} ({len(samples)} frames)")


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    # 값 출처: main.gd _play_place_sound / _play_flip_sound / _play_big_flip_sound
    # place 는 고정 재생(pitch_scale=1)이라 sweep(주파수 변조)을 그대로 구워도 된다.
    write_wav(os.path.join(OUT_DIR, "place.wav"), render(360.0, 0.09, 0.15, sweep=140.0))
    # flip/big_flip 은 런타임에 pitch_scale 로 base frequency 를 조정한다. sweep 이 있으면
    # pitch_scale 이 sweep 까지 함께 배속해 주파수 변조가 어긋나므로, sweep 없이 base 순수 톤으로 굽는다.
    write_wav(os.path.join(OUT_DIR, "flip.wav"), render(520.0, 0.055, 0.095))
    write_wav(os.path.join(OUT_DIR, "big_flip.wav"), render(270.0, 0.22, 0.15, overtone_mix=0.35))


if __name__ == "__main__":
    main()
