extends SceneTree
class PreviewGame extends "res://scripts/main.gd":
	func save_game() -> void:pass
	func read_save() -> Dictionary:return {}
	func save_preferences() -> void:pass
func _initialize() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(960,1000)
	var game=PreviewGame.new()
	game.size=Vector2(960,1000)
	root.add_child(game)
	await create_timer(3.0).timeout
	game.close_view=true
	game.layout()
	game.set_process(false)
	game.reduce_motion=false
	var destination=ProjectSettings.globalize_path("res://../builds/shoulder-preview")
	DirAccess.make_dir_recursive_absolute(destination)
	for pose in ["rest","contact","half","pressed"]:
		game.shoulder_visibility=0.0 if pose=="rest" else 1.0
		game.shoulder_pressure=1.0 if pose=="pressed" else .5 if pose=="half" else 0.0
		game.update_shoulder(0.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(destination+"/"+pose+".png")
	DirAccess.make_dir_recursive_absolute(destination+"/frames")
	for frame in range(96):
		game.shoulder_held=(frame>=12 and frame<38) or (frame>=52 and frame<76)
		game.update_shoulder(1.0/24.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(destination+"/frames/%03d.png" % frame)
	game.queue_free()
	await process_frame
	await create_timer(.2).timeout
	quit()
