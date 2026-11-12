extends Control
const State = preload("res://scripts/stage_state.gd")
const FONT = preload("res://assets/NotoSansJP-Medium.ttf")
const FACES = {"calm":preload("res://assets/full-calm.png"),"wary":preload("res://assets/full-wary.png"),"smile":preload("res://assets/full-smile.png")}
const BLOCK = preload("res://assets/full-block-v2.png")
const SWAT = preload("res://assets/full-swat.png")
const RECEIVE = preload("res://assets/full-receive.png")
const SURPRISE = preload("res://assets/full-surprise.png")
const CONFUSED = preload("res://assets/full-confused.png")
const BLINK = preload("res://assets/full-blink.png")
const HALF_BLINK = preload("res://assets/full-halfblink.png")
const GLANCE = preload("res://assets/full-glance.png")
const HAND = preload("res://assets/hand.png")
const POKE = preload("res://assets/poke.png")
const TRAIN_AUDIO = preload("res://assets/train-ambience.ogg")
const SAVE_PATH = "user://stage1-save.json"
var state = State.new()
var shell: Control
var stage: Control
var portrait: TextureRect
var hand: TextureRect
var bubble: Panel
var bubble_text: Label
var hint: Label
var name_label: Label
var relationship: Label
var meter: ProgressBar
var choices: VBoxContainer
var wallet: Button
var resume_button: Button
var reset_dialog: ConfirmationDialog
var game_menu: AcceptDialog
var inventory: AcceptDialog
var student_card: Panel
var card_toggle: Button
var card_pinned: bool = false
var settings: AcceptDialog
var ending: PanelContainer
var busy: bool = false
var serial: int = 0
var tween: Tween
var portrait_home: Vector2
var last_touch_ms: int = -5000
var quiet_timer: float = 0.0
var next_idle: float = 12.0
var idle_index: int = 0
var reduce_motion: bool = false
var save_note: Label
var has_save: bool = false
var close_view: bool = false
var view_button: Button
var face_overlay: TextureRect
var last_reaction_ms: int = -6000
var backdrop: Control
var body_top: TextureRect
var body_bottom: TextureRect
var eye_overlay: TextureRect
var blink_clock: float = 0.0
var next_blink: float = 4.0
var blink_elapsed: float = -1.0
var ambient_player: AudioStreamPlayer
var ambient_volume: float = 0.45
var ambient_muted: bool = false
var ambient_slider: HSlider
var ambient_toggle: CheckButton
var ambient_caption: Label
var audio_fade: Tween
var player_dialog: Panel
var player_speaker: Label
var player_text: Label
var player_turn: bool = false
const SETTINGS_PATH = "user://stage1-settings.cfg"

func _ready() -> void:
	var theme_resource = Theme.new()
	theme_resource.default_font = FONT
	theme_resource.default_font_size = 20
	theme = theme_resource
	for kind in ["normal","hover","pressed","focus"]:
		theme.set_stylebox(kind,"Button",box(Color("ffffff") if kind=="normal" else Color("e4e9e0"),Color("b5bcb1"),9))
	theme.set_color("font_color","Button",Color("30372f"))
	theme.set_color("font_hover_color","Button",Color("30372f"))
	theme.set_color("font_pressed_color","Button",Color("30372f"))
	var preferences = ConfigFile.new()
	if preferences.load(SETTINGS_PATH)==OK:
		card_pinned=bool(preferences.get_value("display","card_pinned",false))
		reduce_motion=bool(preferences.get_value("display","reduce_motion",false))
		ambient_volume=clampf(float(preferences.get_value("audio","train_volume",0.45)),0,1)
		ambient_muted=bool(preferences.get_value("audio","train_muted",false))
	build()
	start_ambience()
	resized.connect(layout)
	layout()
	var data = read_save()
	has_save = not data.is_empty()
	resume_button.visible = has_save
	show_scene(false)

func box(fill: Color, stroke: Color, radius: int = 12) -> StyleBoxFlat:
	var b = StyleBoxFlat.new()
	b.bg_color=fill
	b.border_color=stroke
	b.set_border_width_all(1)
	b.set_corner_radius_all(radius)
	b.content_margin_left=18
	b.content_margin_right=18
	b.content_margin_top=12
	b.content_margin_bottom=12
	return b

func label(text: String, font_size: int = 20) -> Label:
	var l = Label.new()
	l.text=text
	l.add_theme_font_size_override("font_size",font_size)
	l.add_theme_color_override("font_color",Color("384035"))
	return l

func button(text: String, callback: Callable) -> Button:
	var b = Button.new()
	b.text=text
	b.add_theme_font_size_override("font_size",18)
	b.custom_minimum_size=Vector2(0,52)
	b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	b.pressed.connect(callback)
	return b

func build() -> void:
	shell = Control.new()
	add_child(shell)
	name_label=label("夕方の電車",25)
	shell.add_child(name_label)
	name_label.hide()
	relationship=label("初対面",15)
	shell.add_child(relationship)
	meter=ProgressBar.new()
	meter.show_percentage=false
	meter.add_theme_stylebox_override("background",box(Color("e0e4dd"),Color.TRANSPARENT,4))
	meter.add_theme_stylebox_override("fill",box(Color("6b7b63"),Color.TRANSPARENT,4))
	shell.add_child(meter)
	var menu=button("メニュー",func(): game_menu.popup_centered(Vector2i(360,260)))
	menu.name="SettingsButton"
	shell.add_child(menu)
	resume_button=button("続きから",resume_game)

	stage=Control.new()
	stage.mouse_filter=Control.MOUSE_FILTER_IGNORE
	stage.clip_contents=true
	shell.add_child(stage)
	var bg = TextureRect.new()
	backdrop=bg
	bg.set_script(preload("res://scripts/train_backdrop.gd"))
	stage.add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait=TextureRect.new()
	portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE
	stage.add_child(portrait)
	body_top=TextureRect.new()
	body_bottom=TextureRect.new()
	for body_piece in [body_top,body_bottom]:
		body_piece.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		body_piece.stretch_mode=TextureRect.STRETCH_SCALE
		body_piece.mouse_filter=Control.MOUSE_FILTER_IGNORE
		portrait.add_child(body_piece)
	body_bottom.texture=atlas(FACES.calm,Rect2(0,.65,1,.35))
	set_pose(FACES.calm)
	face_overlay=TextureRect.new()
	face_overlay.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	face_overlay.stretch_mode=TextureRect.STRETCH_SCALE
	face_overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
	portrait.add_child(face_overlay)
	eye_overlay=TextureRect.new()
	eye_overlay.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	eye_overlay.stretch_mode=TextureRect.STRETCH_SCALE
	eye_overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
	eye_overlay.hide()
	portrait.add_child(eye_overlay)
	for part in ["head","cheek","shoulder"]:
		var zone = Button.new()
		zone.name=part
		zone.flat=true
		zone.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
		zone.tooltip_text={"head":"頭に手を伸ばす","cheek":"頬に手を伸ばす","shoulder":"肩に呼びかける"}[part]
		for style in ["normal","hover","pressed"]:
			zone.add_theme_stylebox_override(style,StyleBoxEmpty.new())
		zone.pressed.connect(func(): touch(part))
		stage.add_child(zone)
	hand=TextureRect.new()
	hand.texture=HAND
	hand.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	hand.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hand.mouse_filter=Control.MOUSE_FILTER_IGNORE
	hand.hide()
	stage.add_child(hand)
	wallet=button("",func(): perform("pass"))
	wallet.set_script(preload("res://scripts/wallet.gd"))
	for style in ["normal","hover","pressed"]:
		wallet.add_theme_stylebox_override(style,StyleBoxEmpty.new())
	wallet.add_theme_font_size_override("font_size",40)
	wallet.tooltip_text="落ちた定期入れを知らせる"
	wallet.rotation=-0.15
	stage.add_child(wallet)
	bubble=Panel.new()
	bubble.mouse_filter=Control.MOUSE_FILTER_IGNORE
	bubble.add_theme_stylebox_override("panel",box(Color("ffffff"),Color("636b60"),22))
	bubble_text=label("……。",21)
	bubble_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	bubble_text.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	bubble_text.vertical_alignment=VERTICAL_ALIGNMENT_TOP
	bubble.add_child(bubble_text)
	stage.add_child(bubble)
	hint=label("",17)
	hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	shell.add_child(hint)
	player_dialog=Panel.new()
	player_dialog.mouse_filter=Control.MOUSE_FILTER_IGNORE
	player_dialog.add_theme_stylebox_override("panel",box(Color("f3f4ef"),Color("9b9f95"),12))
	player_speaker=label("あなた",14)
	player_dialog.add_child(player_speaker)
	player_text=label("",20)
	player_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	player_dialog.add_child(player_text)
	player_dialog.hide()
	shell.add_child(player_dialog)
	choices=VBoxContainer.new()
	choices.add_theme_constant_override("separation",9)
	shell.add_child(choices)
	save_note=label("",12)
	shell.add_child(save_note)
	view_button=button("近くで見る",func():close_view=not close_view;view_button.text="全身を見る" if close_view else "近くで見る";layout())
	shell.add_child(view_button)
	ending=PanelContainer.new()
	ending.add_theme_stylebox_override("panel",box(Color("f9faf6"),Color("a7b19e"),14))
	ending.hide()
	shell.add_child(ending)
	reset_dialog=ConfirmationDialog.new()
	reset_dialog.title="最初から始める"
	reset_dialog.dialog_text="進行を上書きして、\n初対面からやり直しますか？"
	reset_dialog.dialog_autowrap=true
	reset_dialog.ok_button_text="最初から"
	reset_dialog.cancel_button_text="戻る"
	reset_dialog.confirmed.connect(new_game)
	add_child(reset_dialog)
	settings=AcceptDialog.new()
	settings.title="設定"
	settings.ok_button_text="閉じる"
	var settings_box = VBoxContainer.new()
	settings_box.custom_minimum_size.x=300
	settings_box.add_theme_constant_override("separation",16)
	var motion=CheckButton.new()
	motion.text="まばたき・手の動きを控える"
	motion.button_pressed=reduce_motion
	motion.toggled.connect(func(on):
		reduce_motion=on
		save_preferences())
	settings_box.add_child(motion)
	ambient_caption=label("電車の環境音  %d%%" % roundi(ambient_volume*100),17)
	ambient_caption.add_theme_color_override("font_color",Color("ededeb"))
	settings_box.add_child(ambient_caption)
	ambient_slider=HSlider.new()
	ambient_slider.min_value=0
	ambient_slider.max_value=100
	ambient_slider.step=1
	ambient_slider.value=ambient_volume*100
	ambient_slider.custom_minimum_size=Vector2(300,28)
	ambient_slider.value_changed.connect(func(value):
		ambient_volume=value/100.0
		update_ambience()
		save_preferences())
	settings_box.add_child(ambient_slider)
	ambient_toggle=CheckButton.new()
	ambient_toggle.text="環境音をミュート"
	ambient_toggle.button_pressed=ambient_muted
	ambient_toggle.toggled.connect(func(on):
		ambient_muted=on
		update_ambience()
		save_preferences())
	settings_box.add_child(ambient_toggle)
	settings_box.add_child(button("最初から始める",func(): settings.hide();confirm_restart()))
	settings.add_child(settings_box)
	add_child(settings)
	build_menu()
	for dialog_button in [game_menu.get_ok_button(),inventory.get_ok_button(),settings.get_ok_button(),reset_dialog.get_ok_button(),reset_dialog.get_cancel_button()]:
		for color_name in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
			dialog_button.add_theme_color_override(color_name,Color("30372f"))

func build_menu() -> void:
	game_menu=AcceptDialog.new()
	game_menu.title="メニュー"
	game_menu.ok_button_text="戻る"
	var menu_items=VBoxContainer.new()
	menu_items.add_theme_constant_override("separation",12)
	menu_items.add_child(resume_button)
	menu_items.add_child(button("所持品",func():game_menu.hide();inventory.popup_centered(Vector2i(360,220))))
	menu_items.add_child(button("設定",func():game_menu.hide();settings.popup_centered(Vector2i(440,400))))
	game_menu.add_child(menu_items)
	add_child(game_menu)
	inventory=AcceptDialog.new()
	inventory.title="所持品"
	inventory.ok_button_text="戻る"
	inventory.confirmed.connect(func():game_menu.popup_centered(Vector2i(360,260)))
	var items=VBoxContainer.new()
	items.add_theme_constant_override("separation",16)
	var item_name=label("学生証",22)
	item_name.add_theme_color_override("font_color",Color.WHITE)
	items.add_child(item_name)
	card_toggle=button("",func():set_card_pinned(not card_pinned);inventory.hide())
	items.add_child(card_toggle)
	inventory.add_child(items)
	add_child(inventory)
	student_card=Panel.new()
	student_card.add_theme_stylebox_override("panel",box(Color("f7f5ee"),Color("686c64"),8))
	student_card.z_index=10
	shell.add_child(student_card)
	var title=label("学生証",18)
	title.position=Vector2(14,10)
	student_card.add_child(title)
	var photo=TextureRect.new()
	photo.texture=atlas(FACES.calm,Rect2(.27,.02,.46,.24))
	photo.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	photo.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	photo.position=Vector2(14,44)
	photo.size=Vector2(64,86)
	student_card.add_child(photo)
	var details=label("日向 夏希\n大学生",16)
	details.position=Vector2(92,55)
	student_card.add_child(details)
	var store_card=button("×",func():set_card_pinned(false))
	for style_name in ["normal","hover","pressed","focus"]:
		var compact=box(Color("f7f5ee"),Color("b5bcb1"),5)
		compact.content_margin_left=3
		compact.content_margin_right=3
		compact.content_margin_top=0
		compact.content_margin_bottom=0
		store_card.add_theme_stylebox_override(style_name,compact)
	store_card.custom_minimum_size=Vector2(28,28)
	store_card.position=Vector2(190,8)
	store_card.size=Vector2(28,28)
	store_card.tooltip_text="所持品にしまう"
	student_card.add_child(store_card)
	refresh_card()

func refresh_card() -> void:
	student_card.visible=card_pinned
	card_toggle.text="左上からしまう" if card_pinned else "左上に配置する"

func set_card_pinned(pinned: bool) -> void:
	card_pinned=pinned
	refresh_card()
	save_preferences()

func layout() -> void:
	if not is_instance_valid(shell): return
	var w: float = minf(size.x,820)
	var h: float = size.y
	shell.position=Vector2((size.x-w)/2,0)
	shell.size=Vector2(w,h)
	name_label.position=Vector2(16,20)
	name_label.add_theme_font_size_override("font_size",19 if w<500 else 25)
	relationship.position=Vector2(w-258,20)
	meter.position=Vector2(w-258,49)
	meter.size=Vector2(130,6)
	shell.get_node("SettingsButton").position=Vector2(w-114,14)
	shell.get_node("SettingsButton").size=Vector2(104,44)
	student_card.position=Vector2(14,84)
	student_card.size=Vector2(230,148)
	var sh: float = maxf(200,h-402)
	stage.position=Vector2(0,75)
	stage.size=Vector2(w,sh)
	var ph: float = (sh-12)*(1.8 if close_view else 1.0)
	var pw: float = ph*0.5
	portrait.size=Vector2(pw,ph)
	portrait_home=Vector2((w-pw)/2-((44 if close_view else 22) if w<500 else 0),0)
	portrait.position=portrait_home
	# One display pixel of overlap avoids a filtering seam at fractional zoom.
	body_top.size=Vector2(pw,ph*.65+1)
	body_bottom.position=Vector2(0,ph*.65-1)
	body_bottom.size=Vector2(pw,ph*.35+1)
	face_overlay.position=Vector2(pw*.32,ph*.085)
	face_overlay.size=Vector2(pw*.33,ph*.10)
	eye_overlay.position=Vector2(pw*.39,ph*.105)
	eye_overlay.size=Vector2(pw*.20,ph*.027)
	var zones={"head":Rect2(.32,.025,.32,.075),"cheek":Rect2(.36,.10,.28,.075),"shoulder":Rect2(.22,.20,.55,.075)}
	for part in zones:
		var rect: Rect2 = zones[part]
		var zone: Control = stage.get_node(part)
		zone.position=portrait_home+rect.position*portrait.size
		zone.size=rect.size*portrait.size
	var bubble_width: float = 164 if w<500 else 235
	bubble_text.add_theme_font_size_override("font_size",17 if w<500 else 21)
	bubble.position=Vector2(minf(w-bubble_width-8,portrait_home.x+pw*.80),ph*.10)
	bubble.size=Vector2(bubble_width,0)
	fit_bubble()
	wallet.position=Vector2(maxf(24,(w-pw)/2-20),sh-65)
	wallet.size=Vector2(85,60)
	hint.position=Vector2(24,sh+90)
	hint.size=Vector2(w-48,60)
	player_dialog.position=Vector2(24,sh+84)
	player_dialog.size=Vector2(w-48,64)
	player_speaker.position=Vector2(14,21)
	player_speaker.size=Vector2(56,26)
	player_text.position=Vector2(78,16)
	player_text.size=Vector2(w-148,48)
	choices.position=Vector2(24,sh+155)
	choices.size=Vector2(w-48,170)
	save_note.position=Vector2(24,h-25)
	view_button.position=Vector2(w-180,h-56)
	view_button.size=Vector2(156,40)
	ending.position=Vector2(24,sh+155)
	ending.size=Vector2(w-48,160)

func start_ambience() -> void:
	ambient_player=AudioStreamPlayer.new()
	var stream=TRAIN_AUDIO.duplicate() as AudioStreamOggVorbis
	stream.loop=true
	ambient_player.stream=stream
	add_child(ambient_player)
	ambient_player.volume_db=-60
	ambient_player.play()
	ambient_player.stream_paused=ambient_muted or ambient_volume<=0
	audio_fade=create_tween()
	audio_fade.tween_property(ambient_player,"volume_db",linear_to_db(maxf(ambient_volume,.001)),1.2)

func update_ambience() -> void:
	ambient_caption.text="電車の環境音  %d%%" % roundi(ambient_volume*100)
	if not is_instance_valid(ambient_player):return
	if audio_fade and audio_fade.is_valid():audio_fade.kill()
	ambient_player.volume_db=linear_to_db(maxf(ambient_volume,.001))
	ambient_player.stream_paused=ambient_muted or ambient_volume<=0

func save_preferences() -> void:
	var preferences=ConfigFile.new()
	preferences.set_value("display","card_pinned",card_pinned)
	preferences.set_value("display","reduce_motion",reduce_motion)
	preferences.set_value("audio","train_volume",ambient_volume)
	preferences.set_value("audio","train_muted",ambient_muted)
	preferences.save(SETTINGS_PATH)

func _exit_tree() -> void:
	if is_instance_valid(ambient_player):
		ambient_player.stop()
		ambient_player.stream=null

func perform(action: String) -> void:
	if busy: return
	var next_state=State.new()
	if not next_state.restore(state.snapshot()) or not next_state.act(action):return
	var line: String=state.scene().get("direct_actions",{}).get(action,"")
	for option in state.scene().get("choices",[]):
		if option[0]==action and option.size()>2:line=option[2]
	resume_button.hide()
	quiet_timer=0
	busy=true
	serial+=1
	var ticket: int=serial
	for child in choices.get_children():child.queue_free()
	if not line.is_empty():
		player_turn=true
		bubble.modulate.a=0
		hint.hide()
		player_text.text=line
		player_dialog.show()
		await get_tree().create_timer(clampf(line.length()*.06,1.3,2.8)+.25).timeout
		if ticket!=serial:return
	player_turn=false
	state=next_state
	show_scene(true,not line.is_empty())

func touch(part: String) -> void:
	if player_turn:return
	if state.ended(): return
	var now: int = Time.get_ticks_msec()
	if now-last_touch_ms<900: return
	if busy and not state.phase in ["withdraw","block","recover"]: return
	last_touch_ms=now
	var previous: String = state.phase
	if not state.act(part): return
	if part=="shoulder" and state.phase==previous:
		resume_button.hide()
		save_game()
		animate_touch(part,state.last_gesture)
		if now-last_reaction_ms>6500:
			last_reaction_ms=now
			bubble_text.text="聞こえてるよ。" if state.caution>0 else "どうしたの？"
			bubble.modulate.a=1
		return
	resume_button.hide()
	quiet_timer=0
	show_scene()
	animate_touch(part,state.last_gesture)

func show_scene(write: bool = true, keep_player: bool = false) -> void:
	player_turn=false
	player_dialog.visible=keep_player
	hint.hide()
	if tween and tween.is_valid():tween.kill()
	portrait.position=portrait_home
	hand.hide()
	serial+=1
	var ticket: int = serial
	busy=true
	var scene: Dictionary=state.scene()
	set_pose(SWAT if state.phase=="rejected" else BLOCK if state.phase=="block" else RECEIVE if state.phase=="thanks" else FACES.calm)
	eye_overlay.hide()
	blink_elapsed=-1
	blink_clock=0
	face_overlay.visible=state.phase not in ["block","rejected"]
	set_face(scene.face)
	if state.phase=="arrival":
		face_overlay.texture=atlas(GLANCE,Rect2(.32,.085,.33,.10))
	portrait.modulate=Color.WHITE
	name_label.text="日向 夏希" if state.flags.get("name",false) else "夕方の電車"
	relationship.text=("次の約束" if state.phase=="promise" else "打ち解けてきた" if state.trust>=45 else "顔見知り" if state.trust>=15 else "初対面")+"  "+str(state.trust)
	meter.value=state.trust
	hint.text=""
	wallet.visible=state.phase in ["intro","noticed"]
	for child in choices.get_children():
		child.queue_free()
	ending.hide()
	bubble.modulate.a=0
	bubble_text.text=scene.line
	bubble_text.visible_characters=-1
	fit_bubble()
	if write: save_game()
	await get_tree().create_timer(0.55).timeout
	if ticket!=serial:return
	create_tween().tween_property(bubble,"modulate:a",1.0,.2)
	# The line stays intact; clicks never advance a typewriter or interrupt it.
	await get_tree().create_timer(maxf(1.6,scene.line.length()*.055) if state.phase!="recover" else 3.0).timeout
	if ticket!=serial:return
	busy=false
	if state.phase=="thanks":set_face("smile")
	if state.phase=="arrival":set_face(scene.face)
	if state.ended():
		show_ending()
	else:
		for option in scene.get("choices",[]):
			var action: String=option[0]
			choices.add_child(button(option[1],func():perform(action)))

func fit_bubble() -> void:
	var font_size: int=bubble_text.get_theme_font_size("font_size")
	var text_width: float=bubble.size.x-28
	bubble_text.size.x=text_width
	var text_height: float=FONT.get_height(font_size)*maxi(1,bubble_text.get_line_count())
	bubble.size.y=maxf(48,text_height+24)
	bubble_text.position=Vector2(14,12)
	bubble_text.size=Vector2(text_width,bubble.size.y-24)

func atlas(source: Texture2D, area: Rect2) -> AtlasTexture:
	var result=AtlasTexture.new()
	result.atlas=source
	result.region=Rect2(area.position*source.get_size(),area.size*source.get_size())
	return result

func set_pose(source: Texture2D) -> void:
	body_top.texture=atlas(source,Rect2(0,0,1,.65))

func set_face(face: String) -> void:
	var source: Texture2D=SURPRISE if face=="surprise" else CONFUSED if face=="confused" else FACES.get(face,FACES.calm)
	face_overlay.texture=atlas(source,Rect2(.32,.085,.33,.10))

func update_blink(delta: float) -> void:
	if reduce_motion or state.ended() or not face_overlay.visible:
		eye_overlay.hide()
		blink_elapsed=-1
		return
	if blink_elapsed>=0:
		blink_elapsed+=delta
		if blink_elapsed>.22:
			eye_overlay.hide()
			blink_elapsed=-1
			next_blink=randf_range(4,7)
		else:
			eye_overlay.texture=atlas(BLINK if blink_elapsed>.06 and blink_elapsed<.16 else HALF_BLINK,Rect2(.39,.105,.20,.027))
	else:
		blink_clock+=delta
		if blink_clock>next_blink:
			blink_clock=0
			blink_elapsed=0
			eye_overlay.texture=atlas(HALF_BLINK,Rect2(.39,.105,.20,.027))
			eye_overlay.show()

func animate_touch(part: String, gesture: String) -> void:
	if tween and tween.is_valid():tween.kill()
	portrait.position=portrait_home
	hand.texture=POKE if part=="cheek" else HAND
	hand.size=Vector2(portrait.size.x*.28,portrait.size.x*.12)
	hand.position=portrait_home+portrait.size*Vector2(.50,.04 if part=="head" else .12 if part=="cheek" else .22)
	hand.modulate=Color.WHITE
	hand.show()
	tween=create_tween()
	if gesture in ["withdraw","block","swat"]:
		tween.tween_property(hand,"modulate:a",0.0,.18)
	else:
		tween.tween_interval(.5)
		tween.tween_property(hand,"modulate:a",0.0,.2)
	tween.tween_callback(hand.hide)

func show_ending() -> void:
	if state.phase=="rejected":portrait.modulate.a=0
	for child in ending.get_children():child.queue_free()
	var content=VBoxContainer.new()
	content.add_theme_constant_override("separation",10)
	var title=label("次の約束ができた。" if state.phase=="promise" else "今日の乗車を終えた。",24)
	content.add_child(title)
	if state.phase=="promise":
		var detail=label("第1ステージ完了。第2ステージへ進む約束を保存しました。",15)
		detail.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		content.add_child(detail)
		content.add_child(button("もう一度、初対面から",confirm_restart))
	else:
		content.add_child(button("後日、同じ電車に乗る",func():perform("new_ride")))
	ending.add_child(content)
	ending.show()

func _process(delta: float) -> void:
	update_blink(delta)
	if busy or state.ended():return
	quiet_timer+=delta
	if quiet_timer>next_idle:
		quiet_timer=0
		next_idle=18
		idle_index+=1


func save_game() -> void:
	var file=FileAccess.open(SAVE_PATH+".tmp",FileAccess.WRITE)
	if file==null:
		save_note.text="保存できませんでした。保存先の空き容量・書き込み権限を確認してください。"
		return
	file.store_string(JSON.stringify(state.snapshot()))
	file.close()
	var error=DirAccess.rename_absolute(SAVE_PATH+".tmp",SAVE_PATH)
	save_note.text="この端末に保存済み" if error==OK else "保存に失敗しました"

func read_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):return {}
	var parsed=JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if not parsed is Dictionary:return {}
	var test=State.new()
	return parsed if test.restore(parsed) else {}

func resume_game() -> void:
	var data=read_save()
	if state.restore(data):
		resume_button.hide()
		game_menu.hide()
		show_scene(false)

func new_game() -> void:
	serial+=1
	if tween and tween.is_valid():tween.kill()
	hand.hide()
	state=State.new()
	resume_button.hide()
	portrait.position=portrait_home
	show_scene()

func confirm_restart() -> void:
	reset_dialog.popup_centered(Vector2i(mini(500,int(size.x)-24),200))
