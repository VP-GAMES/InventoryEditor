tool
extends Control

export(String) var inventory_uuid # inventory_uuid

var _inventoryManager
const InventoryManagerName = "InventoryManager"

onready var _grid_ui = $NinePatchRect/Margin/Grid as GridContainer

const Item = preload("res://addons/inventory_example/inventories/ItemUI.tscn")

func set_inventory_manager(inv_uuid, manager) -> void:
	inventory_uuid = inv_uuid
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

func _on_inventory_changed(inv_uuid: String) -> void:
	if inventory_uuid == inv_uuid:
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
	var inventory_db = _inventoryManager.get_inventory_db(inventory_uuid) as InventoryInventory
	if inventory_db:
		var items = _inventoryManager.get_inventory_items(inventory_uuid)
		for index in range(inventory_db.stacks):
			var item_ui = Item.instance()
			var item
			var item_db
			if items and items[index].has("item_uuid"):
				item = items[index]
				item_db = _inventoryManager.get_item_db(items[index].item_uuid)
			item_ui.set_data(_inventoryManager, inventory_uuid,  index, item, item_db)
			_grid_ui.add_child(item_ui)
