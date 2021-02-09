# Inventory for InventoryEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name InventoryInventory

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor: EditorPlugin
var _undo_redo: UndoRedo

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	for item in items:
		item.set_editor(_editor)
	_undo_redo = _editor.get_undo_redo()
# ***** EDITOR_PLUGIN_END *****

export (String) var uuid
export (String) var name
export (Array) var items
export (Resource) var selected
