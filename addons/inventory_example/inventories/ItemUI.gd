tool
extends TextureRect

var _item

onready var _icon = $Icon
onready var _count = $Count

func set_item(item) -> void:
	_item = item
