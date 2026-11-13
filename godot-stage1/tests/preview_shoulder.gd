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
 await create_timer(4).timeout
 game.close_view=true
 game.layout()
 game.contact_click("shoulder_right")
 game.contact_click("shoulder_left")
 await create_timer(4).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../builds/two-hands-preview.png"))
 for pair in [["waist_right","waist_left"],["hand_right","hand_left"]]:
  game.cancel_shoulder()
  game.contact_click(pair[0],0)
  game.contact_click(pair[1],1)
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../builds/"+pair[0]+"-preview.png"))
 game.queue_free()
 await process_frame
 quit()
