# Service to manage game items
# Please add this script to Project -> Project Settings -> AutoLoad
# to use this manager as singleton
# @author Vladimir Petrenko
extends Node

signal inventory_changed

var _inventoryData = InventoryData.new()

var _path_to_inventory = "user://inventory.tres"
var _data = InventoryItemsData.new()

func _ready() -> void:
	_inventoryData.init_data()
	load_data()

func load_data() -> void:
	var loaded_data = load(_path_to_inventory)
	if loaded_data:
		_data.items = loaded_data.items

func save_inventory() -> void:
	var state = ResourceSaver.save(_path_to_inventory, _data)
	if state != OK:
		printerr("Can't save inventory")

func item_collected(uuid: String) -> bool:
	for item in _data.items:
		if item.item_uuid == uuid:
			return true
	return false

func add_item(inventory_uuid: String, item_uuid: String, quantity: int = 1) -> void:
	if(quantity < 0):
		printerr("Can't add negative number of items")
		return
	var inventory_item = _inventoryData.get_item_by_uuid(item_uuid)
	if item_collected(item_uuid):
		pass # TODO go here

#func item_in_data(item_uuid: String) -> 


#func add_item(item_uuid: String, quantity: int = 1) -> void:
#	if(quantity < 0):
#		printerr("Can't add negative number of items")
#		return
#
#	var item = get_item_by_uuid(item_uuid)
#	if item:
#		item.quantity = min(item.quantity + quantity, item.stacksize)
#	else:
#		var new_item = {
#			item_reference = inventory_item_from_db,
#			quantity = min(quantity, inventory_item_from_db.maxstacksize)
#		}
#		_inventory.items.append(new_item)
#	save_inventory()
#	emit_signal("inventory_changed", self)

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
