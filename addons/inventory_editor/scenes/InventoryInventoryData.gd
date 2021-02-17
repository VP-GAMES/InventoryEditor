# Inventory inventory data UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _inventory: InventoryInventory
var _data: InventoryData

onready var _data_ui = $MarginData
onready var _preview_ui = $MarginPreview
onready var _stacks_ui = $MarginData/VBox/HBoxStacks/Stacks as LineEdit
onready var _put_ui = $MarginData/VBox/HBoxIcon/Put as TextureRect
onready var _icon_ui = $MarginData/VBox/HBoxIcon/Icon as LineEdit
onready var _any_ui = $MarginData/VBox/HBoxAny/Any as CheckButton
onready var _preview_texture_ui = $MarginPreview/VBox/Texture as TextureRect

func set_data(data: InventoryData) -> void:
	_data = data
	_inventory = _data.selected_inventory()
	_init_connections()
	_init_connections_inventory()
	_draw_view()

func _init_connections() -> void:
	if not _data.is_connected("inventory_selection_changed", self, "_on_inventory_selection_changed"):
		assert(_data.connect("inventory_selection_changed", self, "_on_inventory_selection_changed") == OK)
	if not _stacks_ui.is_connected("text_changed", self, "_on_stacks_text_changed"):
		assert(_stacks_ui.connect("text_changed", self, "_on_stacks_text_changed") == OK)
	if not _any_ui.is_connected("pressed", self, "_on_any_ui_pressed"):
		assert(_any_ui.connect("pressed", self, "_on_any_ui_pressed") == OK)

func _on_inventory_selection_changed(inventory: InventoryInventory) -> void:
	_inventory = _data.selected_inventory()
	_init_connections_inventory()
	_draw_view()

func _init_connections_inventory() -> void:
	if _inventory:
		if not _inventory.is_connected("icon_changed", self, "_on_icon_changed"):
			assert(_inventory.connect("icon_changed", self, "_on_icon_changed") == OK)

func _on_icon_changed() -> void:
	_draw_view_preview_texture_ui()

func _on_stacks_text_changed(new_text: String) -> void:
	_inventory.set_stacks(int(new_text))

func _on_any_ui_pressed() -> void:
	_inventory.set_any(_any_ui.pressed)

func _draw_view() -> void:
	check_view_visibility()
	if _inventory:
		_update_view_data()
		_draw_view_stacks_ui()
		_draw_view_any_ui()
		_draw_view_preview_texture_ui()

func check_view_visibility() -> void:
	if _inventory:
		_data_ui.show()
		_preview_ui.show()
	else:
		_data_ui.hide()
		_preview_ui.hide()

func _update_view_data() -> void:
	_put_ui.set_data(_inventory, _data)
	_icon_ui.set_data(_inventory, _data)

func _draw_view_stacks_ui() -> void:
	_stacks_ui.text = str(_inventory.stacks)

func _draw_view_any_ui() -> void:
	_any_ui.pressed = _inventory.any

func _draw_view_preview_texture_ui() -> void:
	var t = load("res://addons/inventory_editor/icons/Inventory.png")
	if _inventory and _inventory.icon and _data.resource_exists(_inventory.icon):
		t = load(_inventory.icon)
	_preview_texture_ui.texture = t