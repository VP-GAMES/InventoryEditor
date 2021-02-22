# Item2D as custom type for InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends Area2D
class_name Item2D

var inside
var _inventoryManager
const InventoryManagerName = "InventoryManager"

export(String) var inventory_to_put # inventory_uuid
export(String) var item # item_uuid 
export(int) var quantity = 1

func _ready() -> void:
	if get_tree().get_root().has_node(InventoryManagerName):
		_inventoryManager = get_tree().get_root().get_node(InventoryManagerName)
	if not is_connected("body_entered", self, "_on_body_entered"):
		assert(connect("body_entered", self, "_on_body_entered") == OK)
	if not is_connected("body_exited", self, "_on_body_exited"):
		assert(connect("body_exited", self, "_on_body_exited") == OK)

func _on_body_entered(body: Node) -> void:
	inside = true
	_inventoryManager.add_item(inventory_to_put, item, quantity)

func _on_body_exited(body: Node) -> void:
	inside = false
