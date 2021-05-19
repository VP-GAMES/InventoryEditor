# Inventory recipe for InventoryEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name InventoryRecipe

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor: EditorPlugin
var _undo_redo: UndoRedo

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	if _editor:
		_undo_redo = _editor.get_undo_redo()
	
const UUID = preload("res://addons/inventory_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

signal name_changed(name)
signal description_changed(description)
signal stacksize_changed
signal icon_changed

export (String) var uuid
export (String) var name
export (String) var description
export (int) var stacksize = 1
export (String) var icon
export (String) var item_to_craft
export (Array) var items_for_craft

func change_name(new_name: String):
	name = new_name
	emit_signal("name_changed")

func change_description(new_description: String):
	description = new_description
	emit_signal("description_changed")

func set_stacksize(new_stacksize: int) -> void:
	stacksize = new_stacksize
	emit_signal("stacksize_changed")

func set_icon(new_icon_path: String) -> void:
	icon = new_icon_path
	emit_signal("icon_changed")
