Selected synthetic voice: 03_soft, seed 4103.
Model: Aratako/Irodori-TTS-v4-Large, FP32 (not quantized).
Reference was generated from text; no real-person recording was used.

Setup in .build-tools/Irodori-TTS:
  uv sync --python 3.11 --extra cpu

Run from repository root:
  PYTHONPATH=.build-tools/Irodori-TTS PYTORCH_ENABLE_MPS_FALLBACK=1 .build-tools/Irodori-TTS/.venv/bin/python tools/make_stage1_voices.py --checkpoint .build-tools/irodori-large-fp32/model.safetensors

Completed matching lines are skipped. --only <scene IDs> regenerates selected lines.
Source WAV files go to builds/voice-stage1; game Ogg files go to godot-stage1/assets/voice.
stage1-manifest.json records text, seed, conditioning, duration, and generation time.
The intro ellipsis is intentionally silent. All other scene lines and two shoulder replies are voiced.

Model: https://huggingface.co/Aratako/Irodori-TTS-v4-Large
Terms: https://ai.google.dev/gemma/terms
Usage policy: https://ai.google.dev/gemma/prohibited_use_policy
