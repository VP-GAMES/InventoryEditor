# Inventory item data UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _item: InventoryItem
var _data: InventoryData

onready var _stacksize_ui = $MarginData/VBox/HBoxStack/Stacksize as LineEdit
onready var _put_ui = $MarginData/VBox/HBoxIcon/Put as TextureRect
onready var _icon_ui = $MarginData/VBox/HBoxIcon/Icon as LineEdit
onready var _add_ui = $MarginData/VBox/HBoxAdd/Add as Button

func set_data(data: InventoryData) -> void:
	_data = data
	_item = _data.selected_item()
	_init_connections()
	_draw_view()

func _init_connections() -> void:
	if not _data.is_connected("item_selection_changed", self, "_on_item_selection_changed"):
		assert(_data.connect("item_selection_changed", self, "_on_item_selection_changed") == OK)
	if not _stacksize_ui.is_connected("text_changed", self, "_on_stacksize_text_changed"):
		assert(_stacksize_ui.connect("text_changed", self, "_on_stacksize_text_changed") == OK)

func _on_item_selection_changed(item: InventoryItem) -> void:
	_item = _data.selected_item()
	_draw_view()

func _on_stacksize_text_changed(new_text: String) -> void:
	_item.set_stacksize(int(new_text))

func _draw_view() -> void:
	_update_view_data()
	_draw_view_stacksize_ui()

func _update_view_data() -> void:
	_put_ui.set_data(_item, _data)
	_icon_ui.set_data(_item, _data)

func _draw_view_stacksize_ui() -> void:
	_stacksize_ui.text = str(_item.stacksize)
