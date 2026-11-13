extends Control
@export var placeholder: bool=false
const FONT=preload("res://assets/NotoSansJP-Medium.ttf")
var content: VBoxContainer
var routes: Dictionary={"シーン1":"res://main.tscn","シーン2":"res://scene_two.tscn","シーン3":"res://scene_three.tscn"}
func _ready() -> void:
 var ui_theme=Theme.new()
 ui_theme.default_font=FONT
 ui_theme.default_font_size=22
 theme=ui_theme
 content=VBoxContainer.new()
 content.add_theme_constant_override("separation",22)
 add_child(content)
 var title=Label.new()
 title.text="シーン3" if placeholder else "夏希と、最初の約束。"
 title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 title.add_theme_font_size_override("font_size",32)
 title.add_theme_color_override("font_color",Color("384035"))
 title.custom_minimum_size.y=100
 content.add_child(title)
 if placeholder:
  var status=Label.new()
  status.text="準備中"
  status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  status.add_theme_color_override("font_color",Color("73796e"))
  content.add_child(status)
  add_choice("シーン選択","res://title.tscn")
 else:
  for caption in routes:
   add_choice(caption,routes[caption])
 resized.connect(layout)
 layout()
func add_choice(caption: String, path: String) -> void:
 var choice=Button.new()
 choice.name=caption
 choice.text=caption
 choice.custom_minimum_size.y=80
 choice.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 for state in ["normal","hover","pressed","focus"]:
  var style=StyleBoxFlat.new()
  style.bg_color=Color("e5e9e0") if state in ["hover","pressed"] else Color("ffffff")
  style.border_color=Color("6b7b63") if state=="focus" else Color("b7beb1")
  style.set_border_width_all(2 if state=="focus" else 1)
  style.set_corner_radius_all(14)
  choice.add_theme_stylebox_override(state,style)
 choice.add_theme_color_override("font_color",Color("384035"))
 choice.add_theme_color_override("font_hover_color",Color("384035"))
 choice.add_theme_color_override("font_pressed_color",Color("384035"))
 choice.pressed.connect(func():get_tree().change_scene_to_file(path))
 content.add_child(choice)
func layout() -> void:
 content.size=Vector2(minf(440,size.x-64),content.get_combined_minimum_size().y)
 content.position=(size-content.size)*.5
