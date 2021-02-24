# Inventory type data UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _type: InventoryType
var _data: InventoryData

onready var _data_ui = $MarginData
onready var _preview_ui = $MarginPreview
onready var _put_ui = $MarginData/VBox/HBoxIcon/Put as TextureRect
onready var _icon_ui = $MarginData/VBox/HBoxIcon/Icon as LineEdit
onready var _preview_texture_ui = $MarginPreview/VBox/Texture as TextureRect

func set_data(data: InventoryData) -> void:
	_data = data
	_type = _data.selected_type()
	_init_connections()
	_init_connections_type()
	_draw_view()

func _init_connections() -> void:
	if not _data.is_connected("type_selection_changed", self, "_on_type_selection_changed"):
		assert(_data.connect("type_selection_changed", self, "_on_type_selection_changed") == OK)

func _on_type_selection_changed(type: InventoryType) -> void:
	_type = _data.selected_type()
	_init_connections_type()
	_draw_view()

func _init_connections_type() -> void:
	if _type:
		if not _type.is_connected("icon_changed", self, "_on_icon_changed"):
			assert(_type.connect("icon_changed", self, "_on_icon_changed") == OK)

func _on_icon_changed() -> void:
	_draw_view_preview_texture_ui()

func _draw_view() -> void:
	check_view_visibility()
	if _type:
		_update_view_data()
		_draw_view_preview_texture_ui()

func check_view_visibility() -> void:
	if _type:
		_data_ui.show()
		_preview_ui.show()
	else:
		_data_ui.hide()
		_preview_ui.hide()

func _update_view_data() -> void:
	_put_ui.set_data(_type, _data)
	_icon_ui.set_data(_type, _data)

func _draw_view_preview_texture_ui() -> void:
	var t = load("res://addons/inventory_editor/icons/Inventory.png")
	if _type and _type.icon and _data.resource_exists(_type.icon):
		t = load(_type.icon)
	_preview_texture_ui.texture = t
