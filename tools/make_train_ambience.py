"""Original, deterministic train interior ambience. No recordings or third-party samples.
32-second periodic synthesis: low rolling noise, ventilation, motor harmonics and soft rail joints.
Requires numpy; writes PCM WAV, then ffmpeg encodes the game Ogg asset.
"""
from pathlib import Path
import numpy as np
import wave, subprocess

RATE=44100
DURATION=32
N=RATE*DURATION
rng=np.random.default_rng(1122026)
t=np.arange(N)/RATE
freq=np.fft.rfftfreq(N,1/RATE)

def noise(lo, hi):
    spectrum=np.fft.rfft(rng.normal(size=N))
    envelope=(freq/np.maximum(lo,1))**2/(1+(freq/np.maximum(lo,1))**2)
    envelope/=1+(freq/hi)**4
    spectrum*=envelope
    spectrum[0]=0
    data=np.fft.irfft(spectrum,n=N)
    return data/np.std(data)

# All modulation periods divide the loop length; circular synthesis avoids an edit seam.
rolling=noise(28,210)
vent=noise(230,1500)
motor=sum(np.sin(2*np.pi*f*t+.2*i)*a for i,(f,a) in enumerate([(55,.17),(110,.07),(165,.035),(275,.018)]))
bed=.10*rolling*(1+.10*np.sin(2*np.pi*t/8))+.028*vent+motor*.18
clacks=np.zeros(N)
for cycle in range(20):
    for offset,level in [(.14,1),(.36,.65),(.94,.85),(1.16,.55)]:
        onset=cycle*1.6+offset
        length=int(.22*RATE)
        q=np.arange(length)/RATE
        burst=rng.normal(size=length)
        # Soft, damped carriage resonance rather than a sharp click.
        transient=(np.sin(2*np.pi*105*q)*.5+np.sin(2*np.pi*245*q)*.22+burst*.10)
        transient*=(1-np.exp(-q/.004))*np.exp(-q/.045)*.15*level
        indices=(int(onset*RATE)+np.arange(length))%N
        clacks[indices]+=transient
left=bed+clacks+.009*noise(150,1100)
right=np.roll(bed,11)+np.roll(clacks,45)+.009*noise(150,1100)
audio=np.stack([left,right],axis=1)
audio-=np.mean(audio,axis=0)
audio*=.45/np.max(np.abs(audio))
assert np.max(np.abs(audio[-1]-audio[0]))<.025, 'Loop boundary discontinuity'
root=Path(__file__).resolve().parents[1]
wav=root/'.build-tools/train-ambience.wav'
wav.parent.mkdir(exist_ok=True)
with wave.open(str(wav),'wb') as output:
    output.setnchannels(2);output.setsampwidth(2);output.setframerate(RATE)
    output.writeframes((audio*32767).astype('<i2').tobytes())
subprocess.run(['ffmpeg','-y','-hide_banner','-loglevel','error','-i',str(wav),'-c:a','vorbis','-strict','-2','-b:a','160k',str(root/'godot-stage1/assets/train-ambience.ogg')],check=True)
print('32s stereo; peak dBFS:',round(20*np.log10(np.max(np.abs(audio))),2),'RMS dBFS:',round(20*np.log10(np.sqrt(np.mean(audio**2))),2),'boundary delta:',float(np.max(np.abs(audio[-1]-audio[0]))))
