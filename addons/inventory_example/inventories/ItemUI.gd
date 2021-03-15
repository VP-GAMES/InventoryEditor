# Example implementation for inventory item to demonstrate functionality of InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends TextureRect

var _inventoryManager
var _inventory_uuid
var _index: int
var _item
var _item_db: InventoryItem

onready var _icon_ui = $Icon as TextureRect
onready var _quantity_ui = $Quantity as Label

func set_data(inventoryManager, inventory_uuid, index, item = null, item_db = null) -> void:
	_inventoryManager = inventoryManager
	_inventory_uuid = inventory_uuid
	_index = index
	_item = item
	_item_db = item_db

func _ready() -> void:
	_icon_ui.set_data(_inventoryManager, _inventory_uuid, _index, _item, _item_db)
	if _item and _item_db:
		if _item_db.icon:
			_icon_ui.texture = load(_item_db.icon)
		if _item.quantity:
			_quantity_ui.text = str(_item.quantity)
