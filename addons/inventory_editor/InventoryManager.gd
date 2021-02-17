# Service to manage game items
# Please add this script to Project -> Project Settings -> AutoLoad
# to use this service as singleton
# @author Vladimir Petrenko
extends Node

signal inventory_changed

var _inventoryData = InventoryData.new()
var _path_to_inventory = "user://inventory.tres"
var _inventory = InventoryItems.new()

func _ready() -> void:
	_inventoryData.init_data()
	load_inventory()

func load_inventory() -> void:
	var loaded_inventory = load(_path_to_inventory)
	if loaded_inventory:
		_inventory.items = loaded_inventory.items

func save_inventory() -> void:
	var state = ResourceSaver.save(_path_to_inventory, _inventory)
	if state != OK:
		printerr("Can't save inventory")

func get_items() -> Array:
	return _inventory.items

func get_item(index: int):
		return _inventory.items[index]

func item_exists(uuid: String):
	for item in _inventory.items:
		if item.uuid == uuid:
			return true
	return false

func get_item_by_uuid(uuid: String):
	for item in _inventory.items:
		if item.uuid == uuid:
			return item
	return null

func get_items_by_property_name(property_name: String) -> Array:
	var items_with_property = Array()
	for item in _inventory.items:
		for property in item.properties:
			if property.name == property_name:
				items_with_property.append(item)
	return items_with_property

#func add_item(uuid: String, quantity: int = 1) -> void:
#	if(quantity < 0):
#		printerr("Can't add negative number of items")
#		return
#
#	var existing_item = get_item_by_name(name)
#	if existing_item:
#		existing_item.quantity = min(existing_item.quantity + quantity, inventory_item_from_db.maxstacksize)
#	else:
#		var new_item = {
#			item_reference = inventory_item_from_db,
#			quantity = min(quantity, inventory_item_from_db.maxstacksize)
#		}
#		_inventory.items.append(new_item)
#	save_inventory()
#	emit_signal("inventory_changed", self)
#
#func remove_item(name: String, quantity: int = 1) -> void:
#	for i in range(_inventory.items.size()):
#		var item = _inventory.items[i]
#		if item.item_reference.name == name:
#			if item.quantity > quantity:
#				 item.quantity -= quantity
#			else:
#				_inventory.items.remove(i)
#			save_inventory()
#			emit_signal("inventory_changed", self)
#			return
