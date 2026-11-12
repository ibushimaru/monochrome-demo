extends Control
var motion: float = 0.0
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
	motion = fmod(motion + delta * 12.0, 140.0)
	queue_redraw()
func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_rect(Rect2(0,0,w,h),Color("ecece8"))
	draw_rect(Rect2(0,h*.85,w,h*.15),Color("d7d8d2"))
	# Large carriage windows, seats, overhead rail, and passing scenery.
	for x in [-180.0, w-195.0]:
		draw_style_box(_box(Color("f7f7f3"),Color("a4a5a0")),Rect2(x,70,370,h*0.57))
		for i in range(5):
			var bx: float = x + i*90 - motion
			if bx > x and bx < x+325:
				draw_rect(Rect2(bx,h*0.35+sin(i)*12,45,h*0.2),Color("dedfda"))
		draw_line(Vector2(x, h*0.57),Vector2(x+370,h*0.57),Color("b4b5b0"),2)
		draw_style_box(_box(Color("c2c4bf"),Color("9a9d96")),Rect2(x,h*0.7,370,h*0.15))
	draw_line(Vector2(0,45),Vector2(w,45),Color("999e97"),3)
	for x in [50.0,w-50.0]:
		draw_line(Vector2(x,0),Vector2(x,130),Color("a2a69d"),3)
		draw_arc(Vector2(x,146),17,0,TAU,24,Color("91998f"),4,true)
	for x in [210.0,w-210.0]:
		draw_line(Vector2(x,50),Vector2(x,h*.85),Color("b9beb5"),3)
func _box(fill: Color, stroke: Color) -> StyleBoxFlat:
	var b = StyleBoxFlat.new()
	b.bg_color=fill
	b.border_color=stroke
	b.set_border_width_all(2)
	b.set_corner_radius_all(12)
	return b
