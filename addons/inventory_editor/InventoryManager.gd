# Service to manage game inventories and items
# Please add this script to Project -> Project Settings -> AutoLoad
# to use this manager as singleton
# @author Vladimir Petrenko
tool
extends Node

signal type_changed

var _db = InventoryData.new()

var _path_to_type = "user://type.tres"
var _data = InventoryItemsData.new()

func _ready() -> void:
	_db.init_data()
	load_data()

func load_data() -> void:
	var file = File.new()
	if file.file_exists(_path_to_type):
		var loaded_data = load(_path_to_type)
		if loaded_data:
			_data.items = loaded_data.items

func save_type() -> void:
	var state = ResourceSaver.save(_path_to_type, _data)
	if state != OK:
		printerr("Can't save type")

func add_item(type_uuid: String, item_uuid: String, quantity: int = 1) -> void:
	if(quantity < 0):
		printerr("Can't add negative number of items")
		return
	var db_item = _db.get_item_by_uuid(item_uuid)
	if item_collected(type_uuid, item_uuid):
		for index in range(_data.items.size()):
			var item = _data.items[index]
			item.quantity = min(item.quantity + quantity, db_item.stacksize)
	else:
		var type_db = get_type_db(type_uuid)
		if get_type_items(type_uuid).size() < type_db.stacks:
			var new_item = {
				type_uuid = type_uuid,
				item_uuid = db_item.uuid,
				quantity = min(quantity, db_item.stacksize)
			}
			_data.items.append(new_item)
	save_type()
	emit_signal("type_changed", self)

func remove_item(type_uuid: String, item_uuid: String, quantity: int = 1) -> void:
	if item_collected(type_uuid, item_uuid):
		for index in range(_data.items.size()):
			var item = _data.items[index]
			if item.type_uuid == type_uuid and item.item_uuid == item_uuid:
				if item.quantity > quantity:
					item.quantity -= quantity
				else:
					_data.items.remove(index)
				save_type()
				emit_signal("type_changed", self)

func item_collected(type_uuid: String, item_uuid: String) -> bool:
	for item in _data.items:
		if item.type_uuid == type_uuid and item.item_uuid == item_uuid:
			return true
	return false

func get_item(item_uuid: String) -> Dictionary:
	var item_collected
	for item in _data.items:
		if item.item_uuid == item_uuid:
			item_collected = item
			break
	return {
		type_uuid = item_collected.type_uuid if item_collected else null,
		item_uuid = item_uuid,
		quantity = item_collected.quantity if item_collected else 0,
		item = _db.get_item_by_uuid(item_uuid)
	}

func get_item_db(item_uuid: String) -> InventoryItem:
	return _db.get_item_by_uuid(item_uuid)

func get_type_items(type_uuid: String) -> Array:
	var items = []
	for item in _data.items:
		if item.type_uuid == type_uuid:
			items.append({
				type_uuid = type_uuid,
				item_uuid = item.item_uuid,
				quantity = item.quantity,
				item = _db.get_item_by_uuid(item.item_uuid)
			})
	return items

func get_type_db(type_uuid: String) -> InventoryType:
	return _db.get_type_by_uuid(type_uuid)
