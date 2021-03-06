# Drag and drop UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
# This is a workaround for https://github.com/godotengine/godot/issues/30480
tool
extends TextureRect

var _item: InventoryItem
var _data: InventoryData

func set_data(item: InventoryItem, data: InventoryData) -> void:
	_item = item
	_data = data

func can_drop_data(position, data) -> bool:
	var resource_value = data["files"][0]
	var resource_extension = _data.file_extension(resource_value)
	for extension in _data.SUPPORTED_IMAGE_RESOURCES:
		if resource_extension == extension:
			return true
	return false

func drop_data(position, data) -> void:
	var path_value = data["files"][0]
	_item.set_icon(path_value)
	_data.emit_item_icon_changed(_item)
