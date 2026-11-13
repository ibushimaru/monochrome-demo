夏希と、最初の約束。 — Windows / Godot Stage 1

主な配布対象は Windows x86_64。Macでも同じプロジェクトを制作・試遊できる。
Godot 4.6.2 / GL Compatibility。MacアプリはApple Silicon・Intel両対応。
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

Mac 出力（同じプロジェクト）:
  godot --headless --path godot-stage1 --export-release macOS ../builds/macos/NatsukiStage1.zip
Mac の保存先は通常 ~/Library/Application Support/Godot/app_userdata/夏希と、最初の約束。/

Godot ライセンスと第三者表示: GODOT-LICENSES.txt
Noto Sans JP: assets/OFL.txt。Medium は可変フォントから wght=450 を固定。
イラストには画像生成を使用。素材・プロンプトは ASSET-NOTES.txt / EXPRESSION-PROMPTS.txt。
電車の走行環境音を48秒ループで再生。「設定」で音量・ミュートを保存する。
走行音は rucisko の車内実録音（CC0）を編集。AUDIO-CREDITS.txt に出典を記載。
行動ボタンを選ぶと「あなた」の台詞／無言の動作が表示され、その後に夏希が応答する。
フォント・制作情報は設定画面に表示せず、配布物のテキストにまとめる。
背景は assets/train-interior-v2.png の静止画。横スクロール・パララックスは使わない。

夏希の既存台詞に、選択した03の声を基準に生成した音声を追加。
夏希の返答表示時に再生し、再生時間に合わせて選択肢を表示します。
「設定」のボイス音量・ミュートは電車の環境音と別に調整できます。

左右の手は独立した接触先を持ちます。通常クリックでは画面左の部位にプレイヤーの左手、画面右の部位に右手を配置します。接触中の部位を再クリックするとその手だけ形を切り替えます。画面下で手を明示的に選ぶと、次のクリックだけ指定した手を使います。
右クリックは右手のショートカットです。ボタンを離しても接触は維持し、拒否・リセット・別の接触先への移動で解除します。
接触先は頭・左右の頬・左右の肩・左右の腕・左右の手・左右の腰。左右の部位名は夏希本人を基準とし、操作する左手・右手はプレイヤー基準。シワの重ね描きと肩の変形は停止しています。

シーン2の操作試作
起動時はシーン選択を表示。シーン2は好感度60の操作試作。会話・音声・拒否はなく、シーン1の進行保存には書き込みません。
全身と顔のアップは同じ左右の手を表示します。両方の画面でクリックでき、同じ連続絵と表情を表示します。終了しても接触は残ります。
左上のシーン選択から切り替えます。シーン3は選択できますが、内容は未実装の準備中画面です。

頬の連続絵試作: 頬か添えた手をクリックすると、六枚の手の絵で一回の撫で動作を再生します。表情は目を細めてから穏やかな笑顔へ戻ります。再生中の連打は動作を再スタートさせません。終了後も手は残り、次のクリックで再生します。ドラッグによる移動はありません。
