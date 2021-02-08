# InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends Control

var _editor: EditorPlugin
var _data:= InventoryData.new()

onready var _save_ui = $VBox/Margin/HBox/Save as Button
onready var _single_ui = $VBox/Margin/HBox/Single as CheckBox
onready var _inventories_ui = $VBox/Inventories

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_load_data()
	_data.set_editor(editor)
	_data_to_childs()
	_init_connections()
	_draw_view()

func _init_connections() -> void:
	if not _save_ui.is_connected("pressed", self, "save_data"):
		assert(_save_ui.connect("pressed", self, "save_data") == OK)
	if not _single_ui.is_connected("pressed", self, "_on_single_pressed"):
		assert(_single_ui.connect("pressed", self, "_on_single_pressed") == OK)
	if not _data.is_connected("inventory_added", self, "_on_inventory_added"):
		assert(_data.connect("inventory_added", self, "_on_inventory_added") == OK)
	if not _data.is_connected("inventory_removed", self, "_on_inventory_removed"):
		assert(_data.connect("inventory_removed", self, "_on_inventory_removed") == OK)

func save_data() -> void:
	_data.save()

func _on_single_pressed() -> void:
	_data.set_inventory_single(_single_ui.pressed)

func _on_inventory_added(inventory: InventoryInventory) -> void:
	_draw_view()

func _on_inventory_removed(inventory: InventoryInventory) -> void:
	_draw_view()

func _load_data() -> void:
	_data.init_data()

func _on_tab_changed(tab: int) -> void:
	_data_to_childs()

func _data_to_childs() -> void:
	_inventories_ui.set_data(_data)

func _draw_view() -> void:
	_check_single_inventory_view()

func _check_single_inventory_view() -> void:
	_single_ui.pressed = _data.inventory_single
	_single_ui.disabled = not (_data.inventories && _data.inventories.size() == 1)
