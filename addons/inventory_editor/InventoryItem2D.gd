# Item2D as custom type for InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends Node2D
class_name Item2D

var inside 
var _inventoryManager
const InventoryManagerName = "InventoryManager"

export(String) var item_put # item_uuid 
export(String) var to_inventory # inventory_uuid
export(int) var quantity = 1

func _ready() -> void:
	if get_tree().get_root().has_node(InventoryManagerName):
		_inventoryManager = get_tree().get_root().get_node(InventoryManagerName)

func _process(delta: float) -> void:
	if Engine.editor_hint and item_put and not item_put.empty():
		if not has_node("InventoryItem_" + item_put):
			_remove_old_childs()
			if not get_tree().edited_scene_root.has_node(InventoryManagerName):
				var root = get_tree().edited_scene_root
				var manager = Node2D.new()
				manager.name = InventoryManagerName
				manager.set_script(load("res://addons/inventory_editor/InventoryManager.gd"))
				root.add_child(manager)
				manager.set_owner(get_tree().edited_scene_root)
				var item_db = manager.get_item_db(item_put)
				if item_db and not item_db.scene.empty():
					var scene = load(item_db.scene).instance()
					scene.name = "InventoryItem_" + item_db.uuid
					for child in scene.get_children():
						if child is Area2D:
							if not child.is_connected("body_entered", self, "_on_body_entered"):
								assert(child.connect("body_entered", self, "_on_body_entered") == OK)
							if not child.is_connected("body_exited", self, "_on_body_exited"):
								assert(child.connect("body_exited", self, "_on_body_exited") == OK)
							break
					if scene:
						add_child(scene)
						scene.set_owner(get_tree().edited_scene_root)
				root.remove_child(manager)
				manager.queue_free()

func _remove_old_childs() -> void:
	for child in get_children():
		if child.name.begins_with("InventoryItem_"):
			remove_child(child)
			child.queue_free()


func _on_body_entered(body: Node) -> void:
	inside = true
	_inventoryManager.add_item(to_inventory, item_put, quantity)

func _on_body_exited(body: Node) -> void:
	inside = false
