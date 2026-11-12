extends SceneTree

# Real scene controls/timers, with storage isolated from the player's save.
class TestGame extends "res://scripts/main.gd":
	var saves: int = 0
	var saved: Dictionary = {}
	func save_game() -> void:
		saves += 1
		saved = state.snapshot()
	func read_save() -> Dictionary:
		return saved.duplicate(true)

var game: TestGame
var failures: Array[String] = []
func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func settle() -> void:
	await create_timer(5.0).timeout
func check_stationary() -> void:
	var speed=Engine.time_scale
	Engine.time_scale=1
	var timer=create_timer(.8)
	var moved=false
	while timer.time_left>0:
		await process_frame
		moved=moved or not game.portrait.position.is_equal_approx(game.portrait_home)
	Engine.time_scale=speed
	check(not moved,"Portrait must stay fixed during reaction: "+game.state.phase)
func choose(index: int = 0) -> void:
	check(game.choices.get_child_count()>index, "Choice exists at "+game.state.phase)
	if game.choices.get_child_count()<=index:return
	game.choices.get_child(index).pressed.emit()
	await settle()
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	Engine.time_scale=30
	game=TestGame.new()
	game.size=Vector2(960,1000)
	root.add_child(game)
	await settle()
	check(game.wallet.visible and not game.busy, "Opening allows pass interaction")
	game.reduce_motion=false
	game.blink_clock=10
	game.update_blink(0.01)
	check(game.eye_overlay.visible, "Idle starts a blink")
	game.update_blink(.1)
	check(game.eye_overlay.texture.atlas==game.BLINK, "Blink reaches closed-eye frame")
	game.update_blink(.2)
	check(not game.eye_overlay.visible, "Blink restores expression")
	game.settings.popup_centered(Vector2i(440,400))
	await process_frame
	await process_frame
	check(game.settings.size.y<600, "Settings fits desktop window")
	game.settings.hide()
	game.wallet.pressed.emit()
	await settle()
	check(game.state.phase=="thanks" and not game.wallet.visible, "Pass triggers thanks")
	check(game.body_top.texture.atlas==game.RECEIVE, "Receiving pose shown")
	check(game.body_bottom.texture.atlas==game.FACES.calm, "Legs remain stable across poses")
	game.choices.get_child(0).pressed.emit()
	await check_stationary()
	await settle()
	for i in range(8): await choose()
	check(game.state.phase=="promise" and game.ending.visible, "Actual choice buttons complete Stage 1")
	check(game.saved.flags.get("stage2_unlocked",false), "Completion saved")
	game.new_game()
	await settle()
	game.touch("head")
	await check_stationary()
	await settle()
	check(game.state.phase=="withdraw", "Direct head target withdraws")
	var before=game.state.caution
	game.last_touch_ms=-5000
	game.touch("shoulder")
	check(game.state.caution==before and game.state.phase=="withdraw", "Shoulder cannot replace refusal")
	await choose()
	await choose()
	check(game.state.phase=="intro", "Refusal recovery returns to interrupted scene")
	game.last_touch_ms=-5000
	game.touch("shoulder")
	await settle()
	var saves=game.saves
	game.last_touch_ms=-5000
	game.touch("shoulder")
	check(game.saves==saves+1 and game.saved.shoulder_count==2, "Same-scene shoulder reaction persists")
	for i in range(2):
		game.last_touch_ms=-5000
		game.touch("head")
		await check_stationary()
		await settle()
	check(game.state.phase=="rejected" and game.ending.visible, "Repeated touch visibly ends ride")
	check(is_zero_approx(game.portrait.modulate.a), "Rejected character leaves carriage area")
	game.ending.get_child(0).get_child(1).pressed.emit()
	await settle()
	check(game.state.phase=="return_wary", "Ending button starts later ride")
	check(game.portrait.position.is_equal_approx(game.portrait_home) and is_equal_approx(game.portrait.modulate.a,1.0), "Later ride resets departure animation")
	for phase in game.State.STORY.data:
		game.state.phase=phase
		game.show_scene(false)
		await settle()
		var line_height=game.FONT.get_height(game.bubble_text.get_theme_font_size("font_size"))
		check(game.bubble_text.get_line_count()*line_height+24<=game.bubble.size.y+1,"Bubble contains all lines: "+phase)
		if game.choices.get_child_count()>0:
			var last=game.choices.get_child(game.choices.get_child_count()-1)
			check(game.choices.position.y+last.position.y+last.size.y<game.view_button.position.y,"Choices clear footer: "+phase)
	game.queue_free()
	await process_frame
	if failures.is_empty(): print("PASS: desktop UI route, fixed portrait through reactions, save/retry, expressions, dialogs and all scene layouts at 960x1000")
	else:
		for failure in failures:push_error(failure)
	quit(0 if failures.is_empty() else 1)
