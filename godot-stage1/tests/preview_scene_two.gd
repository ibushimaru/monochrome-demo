extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(960,1000)
 var game=load("res://scene_two.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game.set_process(false)
 var output=ProjectSettings.globalize_path("res://../builds/cheek-cels-preview")
 DirAccess.make_dir_recursive_absolute(output)
 for frame in range(120):
  if frame==12 or frame==65:game.contact("cheek_right",Vector2.ZERO)
  game.update_animation(1.0/30.0)
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(output+"/%03d.png" % frame)
 game.queue_free()
 await process_frame
 quit()
