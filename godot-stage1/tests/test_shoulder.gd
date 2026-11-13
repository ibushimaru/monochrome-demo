extends SceneTree
class TestGame extends "res://scripts/main.gd":
 func save_game() -> void:pass
 func read_save() -> Dictionary:return {}
 func save_preferences() -> void:pass
var failures: Array[String]=[]
func check(ok: bool, message: String) -> void:
 if not ok:failures.append(message)
func _initialize() -> void:call_deferred("run")
func click_zone(game, part: String, mouse: int) -> void:
 var event=InputEventMouseButton.new()
 event.button_index=mouse
 event.pressed=true
 game.stage.get_node(part).gui_input.emit(event)
 event.pressed=false
 game.stage.get_node(part).gui_input.emit(event)
func run() -> void:
 var game=TestGame.new()
 game.size=Vector2(960,1000)
 root.add_child(game)
 await create_timer(4).timeout
 game.set_process(false)
 game.busy=false
 # Regression: two ordinary left clicks must leave both shoulders occupied.
 click_zone(game,"shoulder_right",MOUSE_BUTTON_LEFT)
 click_zone(game,"shoulder_left",MOUSE_BUTTON_LEFT)
 check(game.contacts==["shoulder_right","shoulder_left"],"Two normal clicks allocate left AND right hands to both shoulders")
 check(game.contact_sprites[0].visible and game.contact_sprites[1].visible,"Both shoulder hands are visible at once")
 var left_frame=game.contact_frames[0]
 click_zone(game,"shoulder_left",MOUSE_BUTTON_LEFT)
 check(game.contacts==["shoulder_right","shoulder_left"] and game.contact_frames[0]==left_frame and game.contact_frames[1]==1,"Reclick moves only the hand already on that shoulder")
 game.cancel_shoulder()
 var home=game.portrait.position
 click_zone(game,"shoulder_left",MOUSE_BUTTON_LEFT)
 click_zone(game,"arm_left",MOUSE_BUTTON_RIGHT)
 check(game.contacts==["shoulder_left","arm_left"],"Two independent hands occupy two targets")
 var positions=[game.contact_sprites[0].position,game.contact_sprites[1].position]
 var textures=[game.contact_sprites[0].texture,game.contact_sprites[1].texture]
 await create_timer(4).timeout
 check(game.contacts==["shoulder_left","arm_left"] and game.contact_sprites[0].visible and game.contact_sprites[1].visible,"Release and idle never remove either hand")
 check(game.contact_sprites[0].position==positions[0] and game.contact_sprites[1].position==positions[1],"Hands never move automatically")
 click_zone(game,"shoulder_left",MOUSE_BUTTON_LEFT)
 check(game.contact_sprites[0].texture!=textures[0] and game.contact_sprites[1].texture==textures[1],"Click articulates only selected hand")
 click_zone(game,"arm_left",MOUSE_BUTTON_LEFT)
 check(game.contacts==["shoulder_left","arm_left"],"Occupied target does not duplicate or steal a hand")
 click_zone(game,"arm_right",MOUSE_BUTTON_LEFT)
 check(game.contacts==["arm_right","arm_left"],"Moving one hand preserves the other")
 game.show_scene(false)
 check(game.contacts==["arm_right","arm_left"],"Dialogue refresh preserves contact")
 check(game.body_top.material==null and not game.shoulder_folds.visible,"Cloth overlay and deformation are disabled")
 game.close_view=true
 game.layout()
 check(game.contact_sprites[0].visible and game.contact_sprites[1].visible,"Zoom preserves both contacts")
 game.busy=false
 game.last_touch_ms=-10000
 click_zone(game,"head",MOUSE_BUTTON_LEFT)
 check(game.contacts==["","arm_left"],"Refusal releases only the rejected hand")
 game.reset_hands.pressed.emit()
 check(game.contacts==["",""] and not game.contact_sprites[0].visible and not game.contact_sprites[1].visible,"Reset releases both hands")
 for part in game.CONTACT_ZONES:
  check(game.stage.get_node(part).tooltip_text.is_empty(),"No touch tooltips")
 game.state.phase="question"
 game.busy=false
 click_zone(game,"hand_left",MOUSE_BUTTON_LEFT)
 click_zone(game,"waist_left",MOUSE_BUTTON_RIGHT)
 check(game.contacts==["hand_left","waist_left"],"Hand and waist use the same two-slot ownership")
 click_zone(game,"hand_right",MOUSE_BUTTON_LEFT)
 check(game.contacts==["hand_right","waist_left"],"Either character hand can be selected independently of waist")
 for pair in [["shoulder_right","shoulder_left"],["waist_right","waist_left"],["hand_right","hand_left"]]:
  check(game.CONTACT_POINTS[pair[0]].x<.5 and game.CONTACT_POINTS[pair[1]].x>.5,"Anatomical right/left maps to opposite screen sides")
  check(not game.CONTACT_ZONES[pair[0]].intersects(game.CONTACT_ZONES[pair[1]]),"Paired targets do not overlap")
 check(game.contact_sprites[0].flip_h and not game.contact_sprites[1].flip_h,"Left and right hands have opposite thumb silhouettes")
 await create_timer(12).timeout
 game.queue_free()
 await process_frame
 await create_timer(.2).timeout
 if failures.is_empty():print("PASS: two-hand ownership, click articulation, idle persistence, refusal, reset, zoom and no cloth effects")
 else:
  for failure in failures:push_error(failure)
 quit(0 if failures.is_empty() else 1)
