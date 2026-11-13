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
 game.contact_click("shoulder",0)
 game.contact_click("arm_left",1)
 await create_timer(4).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../builds/two-hands-preview.png"))
 game.queue_free()
 await process_frame
 quit()
