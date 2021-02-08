# Inventory item for InventoryEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name InventoryItem

signal stacksize_changed
signal icon_changed

export (String) var uuid
export (String) var type # uuid from InventoryInventory
export (String) var name
export (String) var icon
export (Dictionary) var properties
export (int) var stacksize = 1

func set_stacksize(new_stacksize: int) -> void:
	stacksize = new_stacksize
	emit_signal("stacksize_changed")

func set_icon(new_icon_path: String) -> void:
	icon = new_icon_path
	emit_signal("icon_changed")
