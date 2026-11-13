extends SceneTree
var failures: Array[String]=[]
func check(ok: bool, message: String) -> void:
 if not ok:failures.append(message)
func _initialize() -> void:call_deferred("run")
func click(game, view: int, part: String) -> void:
 var zone: Control=game.views[view].zones[part]
 var event=InputEventMouseButton.new()
 event.button_index=MOUSE_BUTTON_LEFT
 event.position=zone.size*.5
 event.pressed=true
 zone.gui_input.emit(event)
 event.pressed=false
 zone.gui_input.emit(event)
func check_shared(game) -> void:
 for side in range(2):
  for view in game.views:
   var sprite: TextureRect=view.hands[side]
   var anchor=(sprite.position+(sprite.size*Vector2(.5,.54)).rotated(sprite.rotation))/view.canvas.size
   check(anchor.is_equal_approx(game.points[side]),"Both views share the exact normalized contact position")
   check(sprite.texture==game.HANDS[game.frames[side]],"Both views share hand pose")
func run() -> void:
 var game=load("res://scene_two.tscn").instantiate()
 root.size=Vector2i(960,1000)
 root.add_child(game)
 await process_frame
 check(game.trust>=60,"Scene two starts with high relationship")
 check(game.find_children("*","AudioStreamPlayer",true,false).is_empty(),"No dialogue audio")
 check(game.find_children("*","Label",true,false).is_empty(),"No dialogue or explanatory text")
 click(game,1,"cheek_right")
 click(game,1,"cheek_left")
 check(game.contacts==["cheek_right","cheek_left"],"Both cheeks can be touched directly in closeup without rejection")
 check_shared(game)
 var zone: Control=game.views[1].zones.cheek_right
 var down=InputEventMouseButton.new()
 down.button_index=MOUSE_BUTTON_LEFT
 down.pressed=true
 down.position=zone.size*.5
 zone.gui_input.emit(down)
 var motion=InputEventMouseMotion.new()
 motion.position=zone.size*.75
 motion.button_mask=MOUSE_BUTTON_MASK_LEFT
 var before: Vector2=game.points[0]
 zone.gui_input.emit(motion)
 check(game.points[0]!=before,"Dragging in closeup moves the touching hand")
 check_shared(game)
 down.pressed=false
 game._input(down)
 check(game.dragging_hand==-1 and game.contacts[0]=="cheek_right","Release stops drag but keeps contact")
 var point: Vector2=game.points[0]
 await create_timer(.5).timeout
 check(game.points[0]==point,"Hand never moves automatically")
 click(game,0,"hand_right")
 check(game.contacts==["hand_right","cheek_left"],"Full-body input uses same two hand slots as closeup")
 check_shared(game)
 root.size=Vector2i(1440,1100)
 await process_frame
 game.layout()
 check_shared(game)
 game.reset_button.pressed.emit()
 check(game.contacts==["", ""],"Reset clears both views")
 for view in game.views:
  check(not view.hands[0].visible and not view.hands[1].visible,"Reset hides both hand renderings")
 check(ProjectSettings.get_setting("application/run/main_scene")=="res://title.tscn","App starts at scene selection")
 game.queue_free()
 await process_frame
 await create_timer(.2).timeout
 if failures.is_empty():print("PASS: direct scene2, high relationship, silent UI, closeup click/drag, synchronized two-hand views, persistence, reset and resize")
 else:
  for message in failures:push_error(message)
 quit(0 if failures.is_empty() else 1)
