# Item3D as custom type for InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends Area
class_name Item3D

var inside
var _inventoryManager
const InventoryManagerName = "InventoryManager"

export(String) var item_put # item_uuid 
export(String) var to_inventory # inventory_uuid
export(int) var quantity = 1

func _ready() -> void:
	if get_tree().get_root().has_node(InventoryManagerName):
		_inventoryManager = get_tree().get_root().get_node(InventoryManagerName)
	if not is_connected("body_entered", self, "_on_body_entered"):
		assert(connect("body_entered", self, "_on_body_entered") == OK)
	if not is_connected("body_exited", self, "_on_body_exited"):
		assert(connect("body_exited", self, "_on_body_exited") == OK)

func _on_body_entered(body: Node) -> void:
	for child in get_children():
		if body == child:
			return 
	inside = true
	_inventoryManager.add_item(to_inventory, item_put, quantity)

func _on_body_exited(body: Node) -> void:
	inside = false

func _process(delta: float) -> void:
	if Engine.editor_hint and item_put and not item_put.empty():
		if not has_node("InventoryItemTexture_" + item_put):
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
					scene.name = "InventoryItemTexture_" + item_db.uuid
					if scene:
						add_child(scene)
						scene.set_owner(get_tree().edited_scene_root)
				root.remove_child(manager)
				manager.queue_free()

func _remove_old_childs() -> void:
	for child in get_children():
		if child.name.begins_with("InventoryItemTexture_"):
			remove_child(child)
			child.queue_free()
