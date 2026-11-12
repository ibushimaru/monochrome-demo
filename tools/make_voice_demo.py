"""Run with the Irodori-TTS environment and its repository on PYTHONPATH."""
import argparse
import json
import time
from pathlib import Path
import torch
from irodori_tts.inference_runtime import InferenceRuntime, RuntimeKey, SamplingRequest, save_wav

parser = argparse.ArgumentParser()
parser.add_argument('--checkpoint', required=True)
parser.add_argument('--output', required=True)
args = parser.parse_args()
out = Path(args.output)
out.mkdir(parents=True, exist_ok=True)
torch.set_num_threads(8)
started = time.monotonic()
print('Loading Irodori v4-Large on Apple MPS', flush=True)
runtime = InferenceRuntime.from_key(RuntimeKey(checkpoint=args.checkpoint, model_device='mps', model_precision='fp32', codec_device='cpu'))
print(f'Loaded in {time.monotonic()-started:.1f}s', flush=True)
text = 'あ、ありがとう。落としたの、気づかなかった。私、なつき。あなたも、いつもこの電車に乗ってるの？'
voices = [
 ('01_bright', 4101, '20代の女性。明るくはっきりした、中高音の自然な声。活発で親しみやすく、普通の会話の調子で話す。'),
 ('02_cool', 4102, '20代の女性。少し低めで芯のある、落ち着いた声。さっぱりした性格で、少しぶっきらぼうだが、自然な口調で話す。'),
 ('03_soft', 4103, '20代の女性。柔らかく澄んだ中高音の声。少し照れながらも、明るく自然な会話の調子で話す。'),
]
records=[]
for name, seed, caption in voices:
 print(f'Generating {name}', flush=True)
 t=time.monotonic()
 result=runtime.synthesize(SamplingRequest(text=text,caption=caption,no_ref=True,seed=seed,num_steps=40),log_fn=lambda x:print(x,flush=True))
 path=out/(name+'.wav')
 save_wav(path,result.audio,result.sample_rate)
 record={'file':path.name,'text':text,'caption':caption,'seed':seed,'seconds_to_generate':round(time.monotonic()-t,2),'sample_rate':result.sample_rate,'timings':result.stage_timings}
 records.append(record)
 (out/'manifest.json').write_text(json.dumps({'model':'Aratako/Irodori-TTS-v4-Large','precision':'fp32','device':'Apple MPS','samples':records},ensure_ascii=False,indent=2))
 print(f'SAVED {path}: {record["seconds_to_generate"]}s',flush=True)
print('COMPLETE',flush=True)
