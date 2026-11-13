extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(960,1000)
 var game=load("res://scene_two.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game.contact("cheek_right",Vector2(.425,.145))
 game.contact("cheek_left",Vector2(.565,.145))
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../builds/scene2-preview.png"))
 game.queue_free()
 await process_frame
 quit()
