extends SceneTree
var failures: Array[String]=[]
func check(ok: bool, message: String) -> void:
 if not ok:failures.append(message)
func _initialize() -> void:call_deferred("run")
func click(game,view: int,part: String) -> void:
 var zone: Control=game.views[view].zones[part]
 var event=InputEventMouseButton.new()
 event.button_index=MOUSE_BUTTON_LEFT
 event.position=zone.size*.5
 event.pressed=true
 zone.gui_input.emit(event)
 event.pressed=false
 zone.gui_input.emit(event)
func run() -> void:
 root.size=Vector2i(960,1000)
 var game=load("res://scene_two.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game.set_process(false)
 check(game.trust==60,"High relationship scene")
 check(game.find_children("*","AudioStreamPlayer",true,false).is_empty(),"No dialogue audio")
 click(game,1,"cheek_right")
 check(game.cel_playing[0] and game.contacts[0]=="cheek_right","A normal click starts the drawn stroke")
 var position: Vector2=game.views[1].hands[0].position
 var frame_texture=game.views[1].hands[0].texture
 game.update_animation(.4)
 check(game.cel_progress[0]>0 and game.cel_progress[1]==0,"Only the clicked hand animates")
 check(game.expression_comfort>0 and game.expression_closed>0,"Facial expression responds to the stroke")
 for view in game.views:
  check(view.hands[0].material.get_shader_parameter("frame_position")==game.cel_progress[0]*6,"Both views show identical cel timing")
  check(view.portrait.texture==game.PORTRAIT,"Standing portrait is not replaced or translated")
  check(view.portrait.material.get_shader_parameter("closed")==game.expression_closed,"Expression is synchronized in both views")
 var phase: float=game.cel_progress[0]
 click(game,1,"cheek_right")
 check(game.cel_progress[0]==phase,"Rapid clicks cannot restart or stack a playing stroke")
 var motion=InputEventMouseMotion.new()
 motion.relative=Vector2(300,200)
 motion.position=Vector2(800,600)
 motion.button_mask=MOUSE_BUTTON_MASK_LEFT
 game._input(motion)
 game.views[1].zones.cheek_right.gui_input.emit(motion)
 check(game.views[1].hands[0].position==position and game.cel_progress[0]==phase,"Pointer drag cannot translate the hand or advance cels")
 game.update_animation(1)
 check(not game.cel_playing[0] and game.views[1].hands[0].visible,"One click finishes one stroke and leaves the hand attached")
 check(game.views[1].hands[0].position==position,"The hand sprite anchor stays fixed throughout")
 click(game,0,"cheek_left")
 check(game.contacts==["cheek_right","cheek_left"] and game.cel_playing[1],"Two independent hands remain available")
 click(game,1,"cheek_right")
 check(game.cel_playing[0] and game.cel_progress[0]==0,"Next click starts another complete stroke")
 click(game,0,"hand_right")
 check(game.contacts==["hand_right","cheek_left"] and not game.cel_playing[0],"Changing target cancels only that hand's animation")
 root.size=Vector2i(1440,1100)
 await process_frame
 game.layout()
 check(game.views[0].hands[1].material.get_shader_parameter("frame_position")==game.views[1].hands[1].material.get_shader_parameter("frame_position"),"Resize preserves synchronized animation")
 game.reset_button.pressed.emit()
 game.update_animation(1)
 check(game.contacts==["", ""] and game.cel_playing==[false,false] and game.expression_comfort==0,"Reset clears hands, animation and expression")
 check(ProjectSettings.get_setting("application/run/main_scene")=="res://title.tscn","Startup stays at scene selection")
 game.queue_free()
 await process_frame
 if failures.is_empty():print("PASS: click-driven cels, expression, no drag, independent hands, synchronized views, one-shot persistence, reset and startup")
 else:
  for message in failures:push_error(message)
 quit(0 if failures.is_empty() else 1)
