# Service to manage game inventories and items
# Please add this script to Project -> Project Settings -> AutoLoad
# to use this manager as singleton
# @author Vladimir Petrenko
tool
extends Node

signal inventory_changed(inventory_uuid)

var _db = InventoryData.new()

var _path_to_type = "user://type.tres"
var _data = InventoryInventories.new()

func ready(db: InventoryData) -> void:
	_db = db
	_init_db()

func _ready() -> void:
	_db.init_data()
	load_data()

func _init_db() -> void:
	if not _db.is_connected("inventory_stacks_changed", self, "_on_inventory_stacks_changed"):
		_db.connect("inventory_stacks_changed", self, "_on_inventory_stacks_changed")

func _on_inventory_stacks_changed(inventory) -> void:
	emit_signal("inventory_changed", inventory.uuid)

func load_data() -> void:
	var file = File.new()
	if file.file_exists(_path_to_type):
		var loaded_data = load(_path_to_type)
		if loaded_data:
			_data.inventories = loaded_data.inventories

func save() -> void:
	var state = ResourceSaver.save(_path_to_type, _data)
	if state != OK:
		printerr("Can't save inventories data")

func get_inventory_items(inventory_uuid: String) -> Array:
	var items
	if _data.inventories.has(inventory_uuid):
		items = _data.inventories[inventory_uuid]
	return items

func add_item(inventory_uuid: String, item_uuid: String, quantity: int = 1) -> int:
	var remainder = 0 
	if(quantity < 0):
		printerr("Can't add negative number of items")
		return remainder
	var db_item = _db.get_item_by_uuid(item_uuid)
	if _data.inventories.has(inventory_uuid):
		var items = _data.inventories[inventory_uuid]
		var item
		for index in range(items.size()):
			if items[index].has("item_uuid") and items[index].item_uuid == item_uuid:
				item = items[index]
				break
		if item:
			if item.quantity + quantity > db_item.stacksize:
				remainder = item.quantity + quantity - db_item.stacksize
			var quantity_calc = min(item.quantity + quantity, db_item.stacksize)
			item.quantity = quantity_calc
		else:
			if quantity > db_item.stacksize:
				remainder = quantity - db_item.stacksize
			var quantity_calc = min(quantity, db_item.stacksize)
			var inventory_db = get_inventory_db(inventory_uuid) as InventoryInventory
			for index in range(inventory_db.stacks):
				if not items[index].has("item_uuid"):
					items[index] = {"item_uuid": item_uuid, "quantity": quantity_calc}
					break
	else:
		var inventory_db = get_inventory_db(inventory_uuid) as InventoryInventory
		var items = []
		for index in range(inventory_db.stacks):
			items.append({})
		_data.inventories[inventory_uuid] = items
		if quantity > db_item.stacksize:
			remainder = quantity - db_item.stacksize
		var quantity_calc = min(quantity, db_item.stacksize)
		_data.inventories[inventory_uuid][0] = {"item_uuid": item_uuid, "quantity": quantity_calc}
	save()
	emit_signal("inventory_changed", inventory_uuid)
	return remainder

func get_item_db(item_uuid: String) -> InventoryItem:
	return _db.get_item_by_uuid(item_uuid)

func get_type_db(type_uuid: String) -> InventoryType:
	return _db.get_type_by_uuid(type_uuid)

func get_inventory_db(inventory_uuid: String) -> InventoryInventory:
	return _db.get_inventory_by_uuid(inventory_uuid)

func remove_item(inventory_uuid: String, item_uuid: String, quantity: int = 1) -> void:
	if(quantity < 0):
		printerr("Can't remove negative number of items")
	if _data.inventories.has(inventory_uuid) and _data.inventories[inventory_uuid].size() > 0:
		var items = _data.inventories[inventory_uuid]
		for index in range(items.size()):
			var item = items[index]
			if item.has("item_uuid") and item.item_uuid == item_uuid:
				if item.quantity > quantity:
					item.quantity -= quantity
				else:
					items[index] = {}
				save()
				emit_signal("inventory_changed", inventory_uuid)

#
#func item_collected(inventory_uuid: String, item_uuid: String) -> bool:
#	var items = _data.inventories[]
#	for item in _data.items:
#		if item.type_uuid == type_uuid and item.item_uuid == item_uuid:
#			return true
#	return false
#
#func get_item(item_uuid: String) -> Dictionary:
#	var item_collected
#	for item in _data.items:
#		if item.item_uuid == item_uuid:
#			item_collected = item
#			break
#	return {
#		type_uuid = item_collected.type_uuid if item_collected else null,
#		item_uuid = item_uuid,
#		quantity = item_collected.quantity if item_collected else 0,
#		item = _db.get_item_by_uuid(item_uuid)
#	}
#
#
#func get_type_items(type_uuid: String) -> Array:
#	var items = []
#	for item in _data.items:
#		if item.type_uuid == type_uuid:
#			items.append({
#				type_uuid = type_uuid,
#				item_uuid = item.item_uuid,
#				quantity = item.quantity,
#				item = _db.get_item_by_uuid(item.item_uuid)
#			})
#	return items
#
