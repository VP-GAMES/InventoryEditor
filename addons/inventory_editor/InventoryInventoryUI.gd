# Inventory ItemControl as custom type for UI in InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends Control
class_name InventoryUI

const InventoryManagerName = "InventoryManager"
var _inventoryManager

export(String) var inventory # inventory_uuid

func set_inventory_manager(inv_uuid, manager) -> void:
	inventory = inv_uuid
	_inventoryManager = manager

func _ready() -> void:
	if get_tree().get_root().has_node(InventoryManagerName):
		_inventoryManager = get_tree().get_root().get_node(InventoryManagerName)
		if _inventoryManager:
			_set_inventory_manager_to_stacks(self)

func _set_manager_to_stacks(node: Node) -> void:
	pass
#	TODO
#	for child in node.get_children():
#		if child is 
