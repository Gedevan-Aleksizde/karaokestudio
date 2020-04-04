#! /usr/bin/env python
# -*- encoding: utf-8 -*-

import pyaudio
import wave
from pathlib import Path
import argparse

def start_record(seconds, outpath):
  CHUNK = 1024
  FORMAT = pyaudio.paInt16 # int16型
  CHANNELS = 1             # モノラル
  RATE = 44100             # 441.kHz
  outpath = Path(outpath)
  p = pyaudio.PyAudio()
  stream = p.open(
    format=FORMAT,
    channels=CHANNELS,
    rate=RATE,
    input=True,
    frames_per_buffer=CHUNK)
  frames = []
  for i in range(0, int(RATE / CHUNK * seconds)):
    data = stream.read(CHUNK)
    frames.append(data)
  stream.stop_stream()
  stream.close()
  p.terminate()
  with wave.open(outpath.__str__(), "wb") as wf:
    wf.setnchannels(CHANNELS)
    wf.setsampwidth(p.get_sample_size(FORMAT))
    wf.setframerate(RATE)
    wf.writeframes(b''.join(frames))
    wf.close()

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument('seconds', type=float)
  parser.add_argument('outpath', type=str)
  params = parser.parse_args()
  print(params.seconds)
  start_record(params.seconds, params.outpath)
