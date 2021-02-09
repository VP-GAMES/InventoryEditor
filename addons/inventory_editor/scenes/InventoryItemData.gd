# Inventory item data UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _item: InventoryItem
var _data: InventoryData

onready var _data_ui = $MarginData
onready var _preview_ui = $MarginPreview
onready var _stacksize_ui = $MarginData/VBox/HBoxStack/Stacksize as LineEdit
onready var _put_ui = $MarginData/VBox/HBoxIcon/Put as TextureRect
onready var _icon_ui = $MarginData/VBox/HBoxIcon/Icon as LineEdit
onready var _add_ui = $MarginData/VBox/HBoxAdd/Add as Button
onready var _properties_ui = $MarginData/VBox/VBoxProperties as VBoxContainer
onready var _preview_texture_ui = $MarginPreview/VBox/Texture as TextureRect

const InventoryItemDataProperty = preload("res://addons/inventory_editor/scenes/InventoryItemDataProperty.tscn")

func set_data(data: InventoryData) -> void:
	_data = data
	_item = _data.selected_item()
	_init_connections()
	_init_connections_item()
	_draw_view()

func _init_connections() -> void:
	if not _data.is_connected("item_selection_changed", self, "_on_item_selection_changed"):
		assert(_data.connect("item_selection_changed", self, "_on_item_selection_changed") == OK)
	if not _stacksize_ui.is_connected("text_changed", self, "_on_stacksize_text_changed"):
		assert(_stacksize_ui.connect("text_changed", self, "_on_stacksize_text_changed") == OK)
	if not _add_ui.is_connected("pressed", self, "_on_add_pressed"):
		assert(_add_ui.connect("pressed", self, "_on_add_pressed") == OK)

func _on_item_selection_changed(item: InventoryItem) -> void:
	_item = _data.selected_item()
	_init_connections_item()
	_draw_view()

func _init_connections_item() -> void:
	if _item:
		if not _item.is_connected("icon_changed", self, "_on_icon_changed"):
			assert(_item.connect("icon_changed", self, "_on_icon_changed") == OK)
		if not _item.is_connected("property_added", self, "_on_property_added"):
			assert(_item.connect("property_added", self, "_on_property_added") == OK)
		if not _item.is_connected("property_removed", self, "_on_property_removed"):
			assert(_item.connect("property_removed", self, "_on_property_removed") == OK)

func _on_icon_changed() -> void:
	_draw_view_preview_texture_ui()

func _on_property_added() -> void:
	_draw_view_properties_ui()

func _on_property_removed() -> void:
	_draw_view_properties_ui()

func _on_stacksize_text_changed(new_text: String) -> void:
	_item.set_stacksize(int(new_text))

func _on_add_pressed() -> void:
	_item.add_property()
	_draw_view_properties_ui()

func _draw_view() -> void:
	check_view_visibility()
	if _item:
		_update_view_data()
		_draw_view_stacksize_ui()
		_draw_view_properties_ui()
		_draw_view_preview_texture_ui()

func check_view_visibility() -> void:
	if _item:
		_data_ui.show()
		_preview_ui.show()
	else:
		_data_ui.hide()
		_preview_ui.hide()

func _update_view_data() -> void:
	_put_ui.set_data(_item, _data)
	_icon_ui.set_data(_item, _data)

func _draw_view_stacksize_ui() -> void:
	_stacksize_ui.text = str(_item.stacksize)

func _draw_view_properties_ui() -> void:
	_clear_view_properties()
	_draw_view_properties()

func _draw_view_properties() -> void:
	for property in _item.properties:
		_draw_property(property)

func _draw_property(property) -> void:
	var property_ui = InventoryItemDataProperty.instance()
	_properties_ui.add_child(property_ui)
	property_ui.set_data(property, _item)

func _clear_view_properties() -> void:
	for property_ui in _properties_ui.get_children():
		_properties_ui.remove_child(property_ui)
		property_ui.queue_free()

func _draw_view_preview_texture_ui() -> void:
	var t = load("res://addons/inventory_editor/icons/Item.png")
	if _item and _item.icon and _data.resource_exists(_item.icon):
		t = load(_item.icon)
	_preview_texture_ui.texture = t
