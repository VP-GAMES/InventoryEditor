tool
extends TextureRect


var _item
var _item_db: InventoryItem

func set_item(item, item_db) -> void:
	_item = item
	_item_db = item_db

func get_drag_data(position: Vector2):
	var drag_texture = TextureRect.new()
	drag_texture.expand = true
	drag_texture.rect_size = Vector2(100, 100)
	drag_texture.texture = texture

	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.rect_position = -0.5 * drag_texture.rect_size
	set_drag_preview(control)
	
	var data = {
		"item": _item,
		"item_db": _item_db
	} 
	return data


func can_drop_data(position: Vector2, data) -> bool:
	# Can drop data to this slot
	#return false
	return true

func drop_data(position: Vector2, data) -> void:
	# Drop to this item
	pass
