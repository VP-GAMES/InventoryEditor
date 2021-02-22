extends EditorInspectorPlugin

var _data: InventoryData

func set_data(data: InventoryData) -> void:
	_data = data

func can_handle(object):
	return object is Item2D or object is Item3D 

func parse_property(object, type, path, hint, hint_text, usage):
	if type == TYPE_STRING:
		match path:
			"to_inventory":
				var inspectorEditorInventory = InventoryInspectorEditorInventory.new()
				inspectorEditorInventory.set_data(_data)
				add_property_editor(path, inspectorEditorInventory)
				return true
			"item_put":
				var inspectorEditorItem = InventoryInspectorEditorItem.new()
				inspectorEditorItem.set_data(_data)
				add_property_editor(path, inspectorEditorItem)
				return true
	return false
