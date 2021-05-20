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
signal ingredient_added
signal ingredient_removed
signal ingredient_value_changed(ingredient)

export (String) var uuid
export (String) var name
export (String) var description
export (int) var stacksize = 1
export (String) var icon
export (String) var item
export (Array) var ingredients

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

func change_ingredient_value(ingredient, value, sendSignal = true) -> void:
	var old_value = ingredient.value
	if _undo_redo != null:
		_undo_redo.create_action("Change ingredient value")
		_undo_redo.add_do_method(self, "_change_ingredient_value", ingredient, value, sendSignal)
		_undo_redo.add_undo_method(self, "_change_ingredient_value", ingredient, old_value, true)
		_undo_redo.commit_action()
	else:
		_change_ingredient_value(ingredient, value, sendSignal)

func _change_ingredient_value(ingredient, value, sendSignal = true) -> void:
	ingredient.value = value
	if sendSignal:
		emit_signal("ingredient_value_changed", ingredient)

func add_ingredient() -> void:
	var ingredient = _create_ingredient()
	if _undo_redo != null:
		_undo_redo.create_action("Add ingredient")
		_undo_redo.add_do_method(self, "_add_ingredient", ingredient)
		_undo_redo.add_undo_method(self, "_del_ingredient", ingredient)
		_undo_redo.commit_action()
	else:
		_add_ingredient(ingredient)

func _create_ingredient() -> Dictionary:
	return {"uuid": UUID.v4(), "value": ""}

func _add_ingredient(ingredient, position = ingredients.size()) -> void:
	ingredients.insert(position, ingredient)
	emit_signal("ingredient_added")

func del_ingredient(ingredient) -> void:
	if _undo_redo != null:
		var index = ingredients.find(ingredient)
		_undo_redo.create_action("Del ingredient")
		_undo_redo.add_do_method(self, "_del_ingredient", ingredient)
		_undo_redo.add_undo_method(self, "_add_ingredient", ingredient, index)
		_undo_redo.commit_action()
	else:
		_del_ingredient(ingredient)

func _del_ingredient(ingredient) -> void:
		ingredients.erase(ingredient)
		emit_signal("ingredient_removed")
