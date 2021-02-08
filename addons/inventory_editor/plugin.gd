# Plugin InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends EditorPlugin

const IconResource = preload("res://addons/inventory_editor/icons/Inventory.png")
const InventoryEditor = preload("res://addons/inventory_editor/InventoryEditor.tscn")

var _inventory_editor

func _enter_tree() -> void:
	_inventory_editor = InventoryEditor.instance()
	get_editor_interface().get_editor_viewport().add_child(_inventory_editor)
	_inventory_editor.set_editor(self)
	make_visible(false)

func _exit_tree() -> void:
	if _inventory_editor:
		_inventory_editor.queue_free()

func has_main_screen():
	return true

func make_visible(visible):
	if _inventory_editor:
		_inventory_editor.visible = visible

func get_plugin_name():
	return "Inventory"

func get_plugin_icon():
	return IconResource

func save_external_data():
	if _inventory_editor:
		_inventory_editor.save_data()
