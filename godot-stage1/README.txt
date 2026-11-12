夏希と、最初の約束。 — Godot Stage 1

Godot 4.6.2 / GL Compatibility / Web (single-thread)
project.godot を Godot で開き、F6 または F5 で実行。

最初は関係値 0。足元の定期入れを知らせ、会話し、次の電車で会う約束をする。
頭・頬・肩は立ち絵上で直接操作。会話には待ち時間があり、連打で進行しない。
頭・頬への接触は身を引く→手で遮る→払いのけて退去。謝って会話に戻れる。
通常の別れ／断られた場合は後日の乗車へ。信頼と獲得済み報酬は引き継ぐ。
約束には信頼 60 以上・警戒 1 以下・名前と乗車時間の情報が必要。
第2ステージは未実装。約束時に stage2_unlocked を保存する。

データ: data/story.json（台詞・表情・選択肢）
遷移: scripts/stage_state.gd（信頼・警戒・条件・保存形式）
画面: scripts/main.gd（タップ範囲・待ち時間・演出・設定）
保存: user://stage1-save.json（ブラウザでは端末内。別ブラウザ・別URLとは非共有）
設定: user://stage1-settings.cfg

確認:
  godot --headless --path godot-stage1 --script res://tests/test_stage.gd
  godot --headless --path godot-stage1 --script res://tests/test_ui.gd
Web 出力（リポジトリのルートから）:
  godot --headless --path godot-stage1 --editor --import --quit
  godot --headless --path godot-stage1 --export-release Web ../stage1/index.html
stage1/ を HTTP(S) で配信。file:// では起動しない。

Godot ランタイムのライセンスと第三者表示: GODOT-LICENSES.txt
Noto Sans JP: assets/OFL.txt。配布する Medium は可変フォントから wght=450 を固定したもの。
イラストには画像生成を使用。未使用の旧候補は配信対象から除外。
音声・効果音はこのステージには未収録。
