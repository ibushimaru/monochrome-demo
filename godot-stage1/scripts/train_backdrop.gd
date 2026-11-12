extends TextureRect
const INTERIOR = preload("res://assets/train-interior-v2.png")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture = INTERIOR
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	# Static carriage and scenery: no scroll, parallax, or frame updates.
