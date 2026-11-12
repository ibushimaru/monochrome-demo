extends SceneTree

class TestGame extends "res://scripts/main.gd":
	func save_game() -> void:pass
	func read_save() -> Dictionary:return {}
	func save_preferences() -> void:pass

var failures: Array[String]=[]
func check(ok: bool, message: String) -> void:
	if not ok:failures.append(message)
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var game=TestGame.new()
	game.size=Vector2(960,1000)
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.reduce_motion=false
	game.busy=false
	var home=game.portrait.position
	var original_body=game.body_top.texture
	var original_face=game.face_overlay.texture
	var zone=game.stage.get_node("shoulder") as Button
	zone.button_down.emit()
	check(game.shoulder_held,"Shoulder press begins kneading")
	game.update_shoulder(.08)
	check(game.shoulder_pressure>0 and game.shoulder_pressure<.75,"Press passes through intermediate pose")
	game.update_shoulder(.2)
	check(is_equal_approx(game.shoulder_pressure,1.0),"Holding reaches compressed pose")
	check(game.portrait.position==home,"Kneading never translates the standing sprite")
	check(not game.hand.visible,"Old sliding hand is not used for shoulders")
	check(game.shoulder_hand.visible and game.shoulder_folds.visible,"Hand and fold overlays are independent visible layers")
	check(game.body_top.texture.atlas==original_body.atlas and game.body_top.texture.region==original_body.region,"Kneading does not swap the body illustration")
	check(game.face_overlay.texture==original_face or game.state.phase=="noticed","Only story reaction may change the face")
	var registered_anchor=game.portrait.size*Vector2(.755,.215)
	for frame in range(3):
		game.position_shoulder_hand(frame)
		var key=["contact","half","pressed"][frame]
		var info=game.KNEAD_REGISTRATION.data[key]
		var scale=game.shoulder_hand.size.x/float(info.size[0])
		var anchor=game.shoulder_hand.position+Vector2(info.wrist_anchor[0],info.wrist_anchor[1])*scale
		check(anchor.is_equal_approx(registered_anchor),"Hand pose keeps the wrist planted")
	var count=game.state.shoulder_count
	game.update_shoulder(2.0)
	check(game.state.shoulder_count==count,"Holding does not repeatedly advance the story or trigger voice")
	var release=InputEventMouseButton.new()
	release.button_index=MOUSE_BUTTON_LEFT
	release.pressed=false
	game._input(release)
	game.update_shoulder(.14)
	check(game.shoulder_pressure>0 and game.shoulder_pressure<1,"Release relaxes through intermediate pose")
	game.update_shoulder(.3)
	check(is_zero_approx(game.shoulder_visibility),"Release outside target removes hand and folds")
	game.shoulder_held=true
	game.update_shoulder(.3)
	game._notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not game.shoulder_held and is_zero_approx(game.shoulder_visibility),"Focus loss cancels kneading")
	game.state.phase="withdraw"
	game.begin_shoulder()
	check(not game.shoulder_held,"Kneading cannot replace an active refusal")
	game.state.phase="question"
	game.player_turn=true
	game.begin_shoulder()
	check(not game.shoulder_held,"Player speech cannot be interrupted by kneading")
	game.player_turn=false
	game.begin_shoulder()
	game.update_shoulder(.3)
	game.show_scene(false)
	check(not game.shoulder_held and is_zero_approx(game.shoulder_visibility),"Scene transition clears shoulder patch")
	game.close_view=true
	game.layout()
	var normalized=Rect2((zone.position-game.portrait_home)/game.portrait.size,zone.size/game.portrait.size)
	check(normalized.is_equal_approx(Rect2(.58,.19,.16,.095)),"Shoulder hit target follows close view")
	await create_timer(4.0).timeout
	game.queue_free()
	await process_frame
	await create_timer(.2).timeout
	if failures.is_empty():print("PASS: shoulder press/release, stationary portrait, global release, focus, dialogue cancellation and zoom")
	else:
		for failure in failures:push_error(failure)
	quit(0 if failures.is_empty() else 1)
