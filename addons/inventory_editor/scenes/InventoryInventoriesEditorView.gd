# Inventories view for InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends VBoxContainer

var _data: InventoryData
var _split_viewport_size = 0

onready var _split_ui = $Split
onready var _inventories_ui = $Split/Inventories
onready var _inventory_items = $Split/InventoryItems

func set_data(data: InventoryData) -> void:
	_data = data
	_inventories_ui.set_data(data)
	_inventory_items.set_data(data)
	_init_connections()
	_draw_view()

func _init_connections() -> void:
	if not _split_ui.is_connected("dragged", self, "_on_split_dragged"):
		assert(_split_ui.connect("dragged", self, "_on_split_dragged") == OK)
	if not _data.is_connected("inventory_single_changed", self, "_on_inventory_single_changed"):
		assert(_data.connect("inventory_single_changed", self, "_on_inventory_single_changed") == OK)

func _on_inventory_single_changed(value: bool) -> void:
	_draw_view()

func _process(delta):
	if _split_viewport_size != rect_size.x:
		_split_viewport_size = rect_size.x
		_init_split_offset()

func _init_split_offset() -> void:
	var offset = InventoryData.SETTINGS_INVENTORIES_SPLIT_OFFSET_DEFAULT
	if _data:
		offset = _data.setting_inventories_split_offset()
	_split_ui.set_split_offset(-rect_size.x / 2 + offset)

func _on_split_dragged(offset: int) -> void:
	if _data != null:
		var value = -(-rect_size.x / 2 - offset)
		_data.setting_inventories_split_offset_put(value)

func _draw_view() -> void:
	_check_single_inventory_view()

func _check_single_inventory_view() -> void:
	if _data.inventory_single:
		_inventories_ui.hide()
	else:
		_inventories_ui.show()
