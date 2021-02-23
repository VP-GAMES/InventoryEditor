# Service to manage game items
# Please add this script to Project -> Project Settings -> AutoLoad
# to use this manager as singleton
# @author Vladimir Petrenko
tool
extends Node

signal inventory_changed

var _db = InventoryData.new()

var _path_to_inventory = "user://inventory.tres"
var _data = InventoryItemsData.new()

func _ready() -> void:
	_db.init_data()
	load_data()

func load_data() -> void:
	var file = File.new()
	if file.file_exists(_path_to_inventory):
		var loaded_data = load(_path_to_inventory)
		if loaded_data:
			_data.items = loaded_data.items

func save_inventory() -> void:
	var state = ResourceSaver.save(_path_to_inventory, _data)
	if state != OK:
		printerr("Can't save inventory")

func add_item(inventory_uuid: String, item_uuid: String, quantity: int = 1) -> void:
	if(quantity < 0):
		printerr("Can't add negative number of items")
		return
	var db_item = _db.get_item_by_uuid(item_uuid)
	if item_collected(inventory_uuid, item_uuid):
		for index in range(_data.items.size()):
			var item = _data.items[index]
			item.quantity = min(item.quantity + quantity, db_item.stacksize)
	else:
		var new_item = {
			inventory_uuid = inventory_uuid,
			item_uuid = db_item.uuid,
			quantity = min(quantity, db_item.stacksize)
		}
		_data.items.append(new_item)
	save_inventory()
	emit_signal("inventory_changed", self)

func remove_item(inventory_uuid: String, item_uuid: String, quantity: int = 1) -> void:
	if item_collected(inventory_uuid, item_uuid):
		for index in range(_data.items.size()):
			var item = _data.items[index]
			if item.inventory_uuid == inventory_uuid and item.item_uuid == item_uuid:
				if item.quantity > quantity:
					item.quantity -= quantity
				else:
					_data.items.remove(index)
				save_inventory()
				emit_signal("inventory_changed", self)

func item_collected(inventory_uuid: String, item_uuid: String) -> bool:
	for item in _data.items:
		if item.inventory_uuid == inventory_uuid and item.item_uuid == item_uuid:
			return true
	return false

func get_item(item_uuid: String) -> Dictionary:
	var item_collected
	for item in _data.items:
		if item.item_uuid == item_uuid:
			item_collected = item
			break
	return {
		inventory_uuid = item_collected.inventory_uuid if item_collected else null,
		item_uuid = item_uuid,
		quantity = item_collected.quantity if item_collected else 0,
		item = _db.get_item_by_uuid(item_uuid)
	}

func get_item_db(item_uuid: String) -> InventoryItem:
	return _db.get_item_by_uuid(item_uuid)

func get_inventory_items(inventory_uuid: String) -> Array:
	var items = []
	for item in _data.items:
		if item.inventory_uuid == inventory_uuid:
			items.append({
				inventory_uuid = inventory_uuid,
				item_uuid = item.item_uuid,
				quantity = item.quantity,
				item = _db.get_item_by_uuid(item.item_uuid)
			})
	return items

func get_inventory_db(inventory_uuid: String) -> InventoryInventory:
	return _db.get_inventory_by_uuid(inventory_uuid)
