夏希と、最初の約束。 — Windows / Godot Stage 1

開発対象は Windows x86_64。Godot 4.6.2 / GL Compatibility。
ゲーム本体はこの Godot プロジェクトだけを更新する。
旧ブラウザ専用デモと stage1/ の Web 出力は過去の版として残し、今後は更新しない。
ブラウザのイベント設計ツールはゲーム本体とは別の設計用ツール。
iPhone 向けの調整・確認・Web への書き出しは行わない。

project.godot を Godot 4.6.2 で開き、F5 で実行。
Windows 配布物は builds/windows/ 内の exe と pck を同じ場所に置いて起動する。

初対面の関係値0から、定期入れを知らせ、会話して次の電車で会う約束をする。
頭・頬・肩は立ち絵上を直接クリック。台詞には待ち時間があり連打で進めない。
拒否は困惑表情→遮る腕→払う腕。謝って会話に戻る分岐と、後日の再会がある。
約束には信頼60以上、警戒1以下、名前と乗車時間の情報が必要。
第2ステージは未実装。約束時に stage2_unlocked を保存する。

演出方針:
立ち絵全体を平行移動・拡縮・回転して芝居を代用しない。
立ち絵位置は固定し、表情・目・腕・姿勢の差分を切り替える。
専用差分のない会釈や身を引く動作は実装しない。
退去は会話終了時の表示切替。画面外へスライドさせない。
プレイヤーの手は別素材として動く。「近くで見る」は表示倍率の手動切替。

データ: data/story.json
遷移: scripts/stage_state.gd
画面: scripts/main.gd
保存: user://stage1-save.json / 設定: user://stage1-settings.cfg
Windows の保存先は通常 %APPDATA%/Godot/app_userdata/夏希と、最初の約束。/
旧ブラウザ版の保存とは共有しない。

確認（リポジトリのルートから）:
  godot --headless --path godot-stage1 --script res://tests/test_stage.gd
  godot --headless --path godot-stage1 --script res://tests/test_ui.gd
Windows 出力:
  godot --headless --path godot-stage1 --editor --import --quit
  godot --headless --path godot-stage1 --export-release Windows ../builds/windows/NatsukiStage1.exe

Godot ライセンスと第三者表示: GODOT-LICENSES.txt
Noto Sans JP: assets/OFL.txt。Medium は可変フォントから wght=450 を固定。
イラストには画像生成を使用。素材・プロンプトは ASSET-NOTES.txt / EXPRESSION-PROMPTS.txt。
音声・効果音は未収録。
