"""Generate existing Natsuki dialogue using the selected synthetic voice 03."""
import argparse, hashlib, json, time
from pathlib import Path
import torch
import soundfile as sf
from irodori_tts.inference_runtime import InferenceRuntime, RuntimeKey, SamplingRequest, save_wav

p=argparse.ArgumentParser()
p.add_argument('--checkpoint',required=True)
p.add_argument('--only',nargs='*')
p.add_argument('--seed-offset',type=int,default=0)
a=p.parse_args()
root=Path(__file__).resolve().parents[1]
ref=root/'voice-source/natsuki-03-reference.wav'
output=root/'godot-stage1/assets/voice'
raw=root/'builds/voice-stage1'
output.mkdir(parents=True,exist_ok=True);raw.mkdir(parents=True,exist_ok=True)
story=json.loads((root/'godot-stage1/data/story.json').read_text())
lines={key:{'text':s['line'].replace('\n',''),'face':s['face']} for key,s in story.items() if key!='intro'}
lines.update({'shoulder_calm':{'text':'どうしたの？','face':'calm'},'shoulder_wary':{'text':'聞こえてるよ。','face':'wary'}})
manifest_path=root/'voice-source/stage1-manifest.json'
manifest=json.loads(manifest_path.read_text()) if manifest_path.exists() else {'model':'Aratako/Irodori-TTS-v4-Large','precision':'fp32','reference_sha256':hashlib.sha256(ref.read_bytes()).hexdigest(),'lines':{}}
torch.set_num_threads(8)
print('Loading original FP32 model on MPS',flush=True)
runtime=InferenceRuntime.from_key(RuntimeKey(checkpoint=a.checkpoint,model_device='mps',model_precision='fp32',codec_device='cpu'))
assert next(runtime.model.parameters()).dtype==torch.float32
for index,(key,item) in enumerate(lines.items()):
 if a.only and key not in a.only:continue
 text=item['text'].replace('日向夏希','ひなたなつき').replace('夏希','なつき')
 if key=='noticed':text='え？'
 seed=5100+index+a.seed_offset
 mood={'wary':'落ち着いた声で、少し警戒しながら短く話す。','confused':'少し戸惑いながら、自然な会話の口調で話す。','smile':'親しみを込めて、穏やかに明るく話す。','surprise':'軽く驚いてから、自然な会話の口調で話す。'}.get(item['face'],'落ち着いた自然な会話の口調で話す。')
 caption='20代の女性。柔らかく澄んだ中高音の声。'+mood
 fingerprint=hashlib.sha256((text+caption+manifest['reference_sha256']).encode()).hexdigest()
 if not a.only and manifest['lines'].get(key,{}).get('fingerprint')==fingerprint and (output/(key+'.ogg')).exists():
  print('SKIP',key,flush=True);continue
 print(f'GENERATE {index+1}/{len(lines)} {key}: {text}',flush=True)
 start=time.monotonic()
 result=runtime.synthesize(SamplingRequest(text=text,caption=caption,ref_wav=str(ref),seed=seed,num_steps=40),log_fn=lambda x:print(x,flush=True))
 audio=result.audio
 peak=audio.abs().max().item()
 if peak>.89:audio=audio*(.89/peak)
 wav=raw/(key+'.wav');save_wav(wav,audio,result.sample_rate)
 samples,rate=sf.read(wav)
 sf.write(output/(key+'.ogg'),samples,rate,format='OGG',subtype='VORBIS')
 manifest['lines'][key]={'text':item['text'],'spoken_text':text,'caption':caption,'seed':seed,'fingerprint':fingerprint,'duration_seconds':round(audio.shape[-1]/result.sample_rate,3),'generation_seconds':round(time.monotonic()-start,2)}
 manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
 print('SAVED',key,flush=True)
print('COMPLETE',flush=True)
