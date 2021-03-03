tool
extends TextureRect

func get_drag_data(position: Vector2):
	var drag_texture = TextureRect.new()
	drag_texture.expand = true
	drag_texture.rect_size = Vector2(100, 100)
	drag_texture.texture = load("res://addons/inventory_example/textures/weapons/SwordDestroyer.png")

	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.rect_position = -0.5 * drag_texture.rect_size
	set_drag_preview(control)
	
	var data = {} 
	return data


func can_drop_data(position: Vector2, data) -> bool:
	# Can drop data to this slot
	#return false
	return true

func drop_data(position: Vector2, data) -> void:
	# Drop to this item
	pass
