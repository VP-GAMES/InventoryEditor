tool
extends TextureRect

var _inventoryManager
var _inventory_uuid
var _index: int
var _item
var _item_db: InventoryItem

func set_data(inventoryManager, inventory_uuid, index, item, item_db) -> void:
	_inventoryManager = inventoryManager
	_inventory_uuid = inventory_uuid
	_index = index
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
		"type": "InventoryItem",
		"index": _index,
		"item": _item,
		"item_db": _item_db
	} 
	return data

func can_drop_data(position: Vector2, data) -> bool:
	return data.has("type") and data["type"] == "InventoryItem"

func drop_data(position: Vector2, data) -> void:
	if _inventoryManager and data.has("index"):
		_inventoryManager.move_item(_inventory_uuid, data["index"], _inventory_uuid, _index)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			if _item_db and _item_db.properties and _item_db.properties.size() > 0:
				_create_properties_popup()

func _create_properties_popup() -> void:
	var popup = $Popup
	for property in _item_db.properties:
		popup.add_child(_create_properties_hbox(property))
	var transform =  get_global_transform_with_canvas()
	popup.popup(Rect2(transform.origin.x + rect_size.x + margin_left + margin_right, transform.origin.y, 100, 100))
	popup.set_as_minsize()


func _create_properties_hbox(property:Dictionary) -> HBoxContainer:
	var hBox = HBoxContainer.new()
	hBox.anchor_right = 1
	var labelName = Label.new()
	labelName.set_h_size_flags(SIZE_EXPAND_FILL)
	labelName.text = property.name
	var labelValue = Label.new()
	labelValue.set_h_size_flags(SIZE_EXPAND_FILL)
	labelValue.text = property.value
	hBox.add_child(labelName)
	hBox.add_child(labelValue)
	return hBox
