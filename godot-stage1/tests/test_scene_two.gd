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
 click(game,1,"cheek_right")
 var inner: Vector2=game.views[1].hands[0].position
 var poses: Array[int]=[]
 var peak: Vector2
 for i in range(5):
  if i>0:game._process(game.STROKE_DURATION/4)
  poses.append(int(game.views[1].hands[0].material.get_shader_parameter("pose_index")))
  if i==2:
   peak=game.views[1].hands[0].position
   check(game.points[0].is_equal_approx(game.stroke_point("cheek_right",1)),"Fingers reach the ear-side endpoint")
  for view in game.views:
   var hand: TextureRect=view.hands[0]
   var anchor=(hand.position+(hand.size*Vector2(.5,.54)).rotated(hand.rotation))/view.canvas.size
   check(anchor.is_equal_approx(game.points[0]),"Both views share moving contact point")
 check(poses==[0,1,2,1,0],"Exactly inner-middle-outer-middle-inner drawn poses")
 check(inner.distance_to(peak)>20,"Hand actually slides along the cheek, not only finger morphing")
 check(game.views[1].hands[0].position.is_equal_approx(inner),"Returns to initial contact without leaving cheek")
 check(not game.stroke_playing[0] and game.contacts[0]=="cheek_right","One click completes one round trip and leaves hand attached")
 var expression: float=game.expression_closed
 click(game,1,"cheek_right")
 game._process(.8)
 check(game.expression_closed==expression,"Expression does not reopen/reclose every stroke")
 var progress: float=game.stroke_progress[0]
 var motion=InputEventMouseMotion.new()
 motion.relative=Vector2(300,-200)
 motion.button_mask=MOUSE_BUTTON_MASK_LEFT
 game._input(motion)
 game.views[1].zones.cheek_right.gui_input.emit(motion)
 check(game.stroke_progress[0]==progress,"Pointer drag does not drive the animation")
 click(game,1,"cheek_right")
 check(game.stroke_progress[0]==progress,"Repeated clicks do not interrupt a running stroke")
 click(game,0,"cheek_left")
 check(game.contacts==["cheek_right","cheek_left"] and game.stroke_playing[1],"Both hands work independently")
 click(game,0,"hand_right")
 check(not game.stroke_playing[0] and game.stroke_playing[1],"Changing location cancels only that hand")
 game.reset_button.pressed.emit()
 game._process(1)
 check(game.contacts==["", ""] and game.stroke_playing==[false,false] and game.expression_comfort==0,"Reset clears contact, motion and expression")
 check(ProjectSettings.get_setting("application/run/main_scene")=="res://title.tscn","Scene selection remains startup")
 game.queue_free()
 await process_frame
 if failures.is_empty():print("PASS: three-pose round trip, real cheek travel, retained contact, no drag, stable expression, independent hands, reset and startup")
 else:
  for message in failures:push_error(message)
 quit(0 if failures.is_empty() else 1)
