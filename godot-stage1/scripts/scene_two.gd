extends Control
const Definitions=preload("res://scripts/main.gd")
const PORTRAIT=preload("res://assets/full-smile.png")
const HANDS=[preload("res://assets/hand-right-open-v2.png"),preload("res://assets/hand-right-flex-v2.png")]
const CHEEK_CELS=preload("res://assets/cheek-cels-v1.png")
const SOFT_FACE=preload("res://assets/cheek-expression-soft-v1.png")
const CLOSED_FACE=preload("res://assets/cheek-expression-closed-v1.png")
const FONT=preload("res://assets/NotoSansJP-Medium.ttf")
const FACE_CROP=Rect2(.25,0,.5,.25)
var trust: int=60
var contacts: Array[String]=["", ""]
var frames: Array[int]=[0,0]
var points: Array[Vector2]=[Vector2.ZERO,Vector2.ZERO]
var active_hand: int=0
var requested_hand: int=-1
const STROKE_DURATION=1.25
var cel_progress: Array[float]=[0.0,0.0]
var cel_playing: Array[bool]=[false,false]
var expression_comfort: float=0.0
var expression_closed: float=0.0
var views: Array[Dictionary]=[]
var selectors: Array[Button]=[]
var reset_button: Button
var scene_one: Button
var scene_two: Button
var background: TextureRect

func _ready() -> void:
 var theme_resource=Theme.new()
 theme_resource.default_font=FONT
 theme_resource.default_font_size=18
 theme=theme_resource
 background=TextureRect.new()
 background.texture=preload("res://assets/train-interior-v2.png")
 background.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 background.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
 background.modulate=Color(1,1,1,.28)
 background.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(background)
 scene_one=make_button("シーン選択",func():get_tree().change_scene_to_file("res://title.tscn"))
 scene_two=make_button("シーン2",func():pass)
 scene_two.disabled=true
 build_view(false)
 build_view(true)
 for side in range(2):
  var selector=make_button("左手" if side==0 else "右手",func():active_hand=side;requested_hand=side;refresh())
  selector.toggle_mode=true
  selectors.append(selector)
 reset_button=make_button("リセット",reset_contacts)
 resized.connect(layout)
 layout()

func make_button(caption: String, action: Callable) -> Button:
 var result=Button.new()
 result.text=caption
 result.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 result.pressed.connect(action)
 add_child(result)
 return result

func build_view(closeup: bool) -> void:
 var panel=Panel.new()
 var style=StyleBoxFlat.new()
 style.bg_color=Color("f8f8f5") if closeup else Color(1,1,1,0)
 style.border_color=Color("c0c5bd")
 style.set_border_width_all(1 if closeup else 0)
 panel.add_theme_stylebox_override("panel",style)
 panel.clip_contents=true
 add_child(panel)
 var canvas=Control.new()
 canvas.mouse_filter=Control.MOUSE_FILTER_IGNORE
 panel.add_child(canvas)
 var portrait=TextureRect.new()
 portrait.texture=PORTRAIT
 var face_material=ShaderMaterial.new()
 face_material.shader=preload("res://shaders/cheek_expression.gdshader")
 face_material.set_shader_parameter("relaxed_face",SOFT_FACE)
 face_material.set_shader_parameter("closed_face",CLOSED_FACE)
 portrait.material=face_material
 portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE
 canvas.add_child(portrait)
 var hands: Array[TextureRect]=[]
 for side in range(2):
  var hand=TextureRect.new()
  hand.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
  hand.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
  hand.mouse_filter=Control.MOUSE_FILTER_PASS
  hand.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
  hand.gui_input.connect(func(event: InputEvent):
   if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT] and contacts[side].begins_with("cheek_"):
    play_stroke(side)
    hand.accept_event())
  hand.flip_h=side==0
  var material=ShaderMaterial.new()
  material.shader=preload("res://shaders/cheek_cels.gdshader")
  hand.material=material
  canvas.add_child(hand)
  hands.append(hand)
 var zones: Dictionary={}
 for part in Definitions.CONTACT_ZONES:
  if closeup and part not in ["head","cheek_right","cheek_left"]:continue
  var zone=Control.new()
  zone.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
  zone.mouse_filter=Control.MOUSE_FILTER_STOP
  zone.gui_input.connect(func(event: InputEvent):zone_input(event,part,zone,canvas))
  canvas.add_child(zone)
  zones[part]=zone
 views.append({"panel":panel,"canvas":canvas,"portrait":portrait,"hands":hands,"zones":zones,"closeup":closeup})

func layout() -> void:
 if views.size()!=2:return
 var margin: float=24
 var usable: float=size.x-margin*3
 var left_width: float=usable*.53
 var inset_width: float=minf(usable*.47,size.y*.55)
 background.position=Vector2(0,72)
 background.size=Vector2(size.x,size.y-150)
 scene_one.position=Vector2(margin,16)
 scene_two.position=Vector2(margin+132,16)
 scene_one.size=Vector2(120,44)
 scene_two.size=Vector2(120,44)
 var full=views[0]
 full.panel.position=Vector2(margin,82)
 full.panel.size=Vector2(left_width,size.y-170)
 var height: float=minf(full.panel.size.y,full.panel.size.x*2)
 full.canvas.size=Vector2(height*.5,height)
 full.canvas.position=Vector2((left_width-height*.5)*.5,0)
 var zoom=views[1]
 zoom.panel.position=Vector2(margin*2+left_width,126)
 zoom.panel.size=Vector2(inset_width,inset_width)
 zoom.canvas.size=Vector2(inset_width/FACE_CROP.size.x,inset_width/FACE_CROP.size.y)
 zoom.canvas.position=-FACE_CROP.position*zoom.canvas.size
 for view in views:
  view.portrait.size=view.canvas.size
  for part in view.zones:
   var bounds: Rect2=Definitions.CONTACT_ZONES[part]
   view.zones[part].position=bounds.position*view.canvas.size
   view.zones[part].size=bounds.size*view.canvas.size
 for side in range(2):
  selectors[side].position=Vector2(margin+side*180,size.y-64)
  selectors[side].size=Vector2(172,44)
 reset_button.position=Vector2(margin+368,size.y-64)
 reset_button.size=Vector2(112,44)
 refresh()

func zone_input(event: InputEvent, part: String, zone: Control, canvas: Control) -> void:
 if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
  contact(part,Definitions.CONTACT_POINTS[part],1 if event.button_index==MOUSE_BUTTON_RIGHT else requested_hand)
  requested_hand=-1
  zone.accept_event()

func contact(part: String, point: Vector2, side: int=-1) -> int:
 if side<0:
  side=contacts.find(part)
  if side<0:side=0 if part.ends_with("_right") else 1 if part.ends_with("_left") else active_hand
 if contacts[1-side]==part:return -1
 var same_target=contacts[side]==part
 if cel_playing[side] and same_target:return side
 frames[side]=1-frames[side] if same_target else 0
 contacts[side]=part
 points[side]=Definitions.CONTACT_POINTS[part]
 cel_playing[side]=false
 cel_progress[side]=0.0
 if part.begins_with("cheek_"):play_stroke(side)
 refresh()
 return side

func play_stroke(side: int) -> void:
 if cel_playing[side]:return
 cel_progress[side]=0.0
 cel_playing[side]=true
 refresh()

func update_animation(delta: float) -> void:
 var response: float=0.0
 var touching=false
 for side in range(2):
  if contacts[side].begins_with("cheek_"):
   touching=true
   if cel_playing[side]:
    cel_progress[side]=minf(1.0,cel_progress[side]+delta/STROKE_DURATION)
    response=maxf(response,sin(cel_progress[side]*PI))
    if cel_progress[side]>=1.0:cel_playing[side]=false
 expression_comfort=move_toward(expression_comfort,1.0 if touching else 0.0,delta*4.0)
 expression_closed=move_toward(expression_closed,response,delta*4.0)
 refresh()

func _process(delta: float) -> void:
 update_animation(delta)

func refresh() -> void:
 if selectors.size()!=2:return
 for side in range(2):
  selectors[side].set_pressed_no_signal(active_hand==side)
  selectors[side].text=("左手" if side==0 else "右手")+(" · "+Definitions.CONTACT_NAMES[contacts[side]] if contacts[side]!="" else "")
  for view in views:
   var hand: TextureRect=view.hands[side]
   hand.visible=contacts[side]!=""
   var stroking=contacts[side].begins_with("cheek_")
   if stroking:
    hand.texture=CHEEK_CELS
    hand.material.set_shader_parameter("frame_position",cel_progress[side]*6.0)
    hand.use_parent_material=false
    hand.flip_h=side==1
    hand.size=Vector2.ONE*view.canvas.size.y*.095
    hand.rotation=0.0
    var anchor=Vector2(.65 if side==0 else .35,.22)
    hand.position=points[side]*view.canvas.size-hand.size*anchor
   else:
    hand.texture=HANDS[frames[side]]
    hand.use_parent_material=true
    hand.flip_h=side==0
    hand.size=Vector2.ONE*view.canvas.size.y*.080
    hand.rotation=deg_to_rad(-12 if side==0 else 12)
    hand.position=points[side]*view.canvas.size-(hand.size*Vector2(.5,.54)).rotated(hand.rotation)
 for view in views:
  view.portrait.material.set_shader_parameter("comfort",expression_comfort)
  view.portrait.material.set_shader_parameter("closed",expression_closed)
 if is_instance_valid(reset_button):reset_button.disabled=contacts==["", ""]

func reset_contacts() -> void:
 contacts.assign(["", ""])
 frames.assign([0,0])
 cel_progress.assign([0.0,0.0])
 cel_playing.assign([false,false])
 requested_hand=-1
 refresh()

func _input(_event: InputEvent) -> void:
 # Hand motion is authored cels, never pointer translation.
 pass
