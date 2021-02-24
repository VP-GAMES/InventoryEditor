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

var item_db_uuid

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
	if item_db_uuid != item_put and item_put and not item_put.empty() and Engine.editor_hint:
		if not get_tree().edited_scene_root.has_node(InventoryManagerName):
			var root = get_tree().edited_scene_root
			var manager = Spatial.new()
			manager.name = InventoryManagerName
			manager.set_script(load("res://addons/inventory_editor/InventoryManager.gd"))
			root.add_child(manager)
			manager.set_owner(get_tree().edited_scene_root)
			var item_db = manager.get_item_db(item_put)
			remove_old_childs()
			if item_db and not item_db.scene.empty():
				var scene = load(item_db.scene).instance()
				scene.name = item_db.name
				scene.set_meta("item_uuid", item_put)
				if scene:
					add_child(scene)
					scene.set_owner(get_tree().edited_scene_root)
			item_db_uuid = item_put
			root.remove_child(manager)
			manager.queue_free()

func remove_old_childs() -> void:
	for child in get_children():
		if child.has_meta("item_uuid"):
			if child.get_meta("item_uuid") != item_put:
				remove_child(child)
				child.queue_free()
