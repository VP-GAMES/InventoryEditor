extends EditorInspectorPlugin

func can_handle(object):
	return object is Item2D or object is Item3D 

func parse_property(object, type, path, hint, hint_text, usage):
	if type == TYPE_STRING:
		match path:
			"inventory_uuid":
				add_property_editor(path, InventoryInspectorEditorInventory.new())
				return true
			"item_uuid":
				add_property_editor(path, InventoryInspectorEditorItem.new())
				return true
	return false
