# Inventory item for InventoryEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name InventoryItem

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor: EditorPlugin
var _undo_redo: UndoRedo

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_undo_redo = _editor.get_undo_redo()
	
const UUID = preload("res://addons/inventory_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

signal stacksize_changed
signal icon_changed
signal property_added
signal property_removed
signal property_changed(property)

export (String) var uuid
export (String) var type # uuid from InventoryInventory
export (String) var name
export (String) var icon
export (Array) var properties
export (int) var stacksize = 1

func set_stacksize(new_stacksize: int) -> void:
	stacksize = new_stacksize
	emit_signal("stacksize_changed")

func set_icon(new_icon_path: String) -> void:
	icon = new_icon_path
	emit_signal("icon_changed")

func set_property_value(property, value) -> void:
	property.value = value
	emit_signal("property_changed", property)

func add_property() -> void:
	var property = _create_property()
	if _undo_redo != null:
		_undo_redo.create_action("Add property")
		_undo_redo.add_do_method(self, "_add_property", property)
		_undo_redo.add_undo_method(self, "_del_property", property)
		_undo_redo.commit_action()
	else:
		_add_property(property)

func _create_property() -> Dictionary:
	return {"uuid": UUID.v4(), "name": _next_property_name(), "value": ""}

func _next_property_name() -> String:
	var base_name = "property"
	var value = -9223372036854775807
	var property_found = false
	if properties:
		for property in properties:
			var name = property.name
			if name.begins_with(base_name):
				property_found = true
				var behind = property.name.substr(base_name.length())
				var regex = RegEx.new()
				regex.compile("^[0-9]+$")
				var result = regex.search(behind)
				if result:
					var new_value = int(behind)
					if  value < new_value:
						value = new_value
	var next_name = base_name
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif property_found:
		next_name += "1"
	return next_name

func _add_property(property, position = properties.size()) -> void:
	properties.insert(position, property)
	emit_signal("property_added")

func del_property(property) -> void:
	if _undo_redo != null:
		var index = properties.find(property)
		_undo_redo.create_action("Del property")
		_undo_redo.add_do_method(self, "_del_property", property)
		_undo_redo.add_undo_method(self, "_add_property", property, index)
		_undo_redo.commit_action()
	else:
		_del_property(property)

func _del_property(property) -> void:
		properties.erase(property)
		emit_signal("property_removed")
