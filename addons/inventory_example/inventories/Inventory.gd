tool
extends Control

var _inventoryManager
const InventoryManagerName = "InventoryManager"

export(String) var inventory # inventory_uuid

onready var _grid_ui = $NinePatchRect/Margin/Grid as GridContainer

const Item = preload("res://addons/inventory_example/inventories/ItemUI.tscn")

func set_inventory_manager(inventory_uuid, manager) -> void:
	inventory = inventory_uuid
	_inventoryManager = manager

func _ready() -> void:
	if get_tree().get_root().has_node(InventoryManagerName):
		_inventoryManager = get_tree().get_root().get_node(InventoryManagerName)
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if _inventoryManager:
		if not _inventoryManager.is_connected("inventory_changed", self, "_on_inventory_changed"):
			_inventoryManager.connect("inventory_changed", self, "_on_inventory_changed")

func _on_inventory_changed(inventory_uuid: String) -> void:
	if inventory == inventory_uuid:
		_update_view()

func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	var children = _grid_ui.get_children()
	for child in children:
		_grid_ui.remove_child(child)
		child.queue_free()

func _draw_view() -> void:
	var inventory_db = _inventoryManager.get_inventory_db(inventory) as InventoryInventory
	var items = _inventoryManager.get_inventory_items(inventory)
	for index in range(inventory_db.stacks):
		var item = Item.instance()
		if items and items[index].has("item_uuid") and index < items.size():
			item.set_item(items[index], _inventoryManager.get_item_db(items[index].item_uuid))
		_grid_ui.add_child(item)
