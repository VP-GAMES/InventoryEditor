tool
extends TextureRect

var _item
var _item_db: InventoryItem

onready var _icon_ui = $Icon as TextureRect
onready var _quantity_ui = $Quantity as Label

func set_item(item, item_db) -> void:
	_item = item
	_item_db = item_db

func _ready() -> void:
	if _item and _item_db:
		if _item_db.icon:
			_icon_ui.texture = load(_item_db.icon)
		if _item.quantity:
			_quantity_ui.text = str(_item.quantity)
