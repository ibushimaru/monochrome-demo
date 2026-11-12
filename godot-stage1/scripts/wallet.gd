extends Button
func _draw() -> void:
	var card=StyleBoxFlat.new()
	card.bg_color=Color("777c72")
	card.border_color=Color("363e31")
	card.set_border_width_all(2)
	card.set_corner_radius_all(6)
	draw_style_box(card,Rect2(5,12,size.x-10,size.y-22))
	draw_rect(Rect2(14,20,size.x-28,size.y-38),Color("efeee7"))
	draw_line(Vector2(21,29),Vector2(size.x-21,29),Color("b4b9ae"),3)
	draw_circle(Vector2(size.x-10,13),5,Color("e9ece4"))
