extends EditorProperty
class_name InventoryInspectorEditorItem

const Dropdown = preload("res://addons/inventory_editor/ui_extensions/dropdown/Dropdown.tscn")

var updating = false
var dropdown = Dropdown.instance()
var _data: InventoryData

func set_data(data: InventoryData) -> void:
	_data = data
	
