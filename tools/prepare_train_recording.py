"""Prepare the CC0 train-interior recording by rucisko for gapless game playback.
Source: https://freesound.org/people/rucisko/sounds/164766/
Download the publicly available HQ preview shown on that page to the input path.
No synthetic noise is added. Requires numpy and ffmpeg.
"""
from pathlib import Path
import subprocess, wave, numpy as np
root=Path(__file__).resolve().parents[1]
source=root/'.build-tools/train-recording-source.mp3'
filtered=root/'.build-tools/train-recording-filtered.wav'
subprocess.run(['ffmpeg','-y','-hide_banner','-loglevel','error','-i',str(source),'-af','highpass=f=45,lowpass=f=2200','-ar','44100','-ac','2',str(filtered)],check=True)
with wave.open(str(filtered)) as w:
    rate=w.getframerate()
    a=np.frombuffer(w.readframes(w.getnframes()),'<i2').reshape(-1,2).astype(float)/32768
# Avoid recording start/end. Wrap the last two seconds into the beginning.
a=a[5*rate:55*rate]
k=2*rate
weight=np.sin(np.linspace(0,np.pi/2,k))[:,None]**2
join=a[-k:]*(1-weight)+a[:k]*weight
loop=np.concatenate([a[k:-k],join])
loop-=loop.mean(axis=0)
loop*=min(.65/np.max(np.abs(loop)),.085/np.sqrt(np.mean(loop**2)))
out=root/'.build-tools/train-recording-loop.wav'
with wave.open(str(out),'wb') as w:
    w.setnchannels(2);w.setsampwidth(2);w.setframerate(rate)
    w.writeframes((loop*32767).astype('<i2').tobytes())
subprocess.run(['ffmpeg','-y','-hide_banner','-loglevel','error','-i',str(out),'-c:a','vorbis','-strict','-2','-b:a','160k',str(root/'godot-stage1/assets/train-ambience.ogg')],check=True)
print('Loop seconds:',len(loop)/rate,'Peak:',np.max(np.abs(loop)),'RMS:',np.sqrt(np.mean(loop**2)),'Boundary jump:',np.max(abs(loop[-1]-loop[0])))
