# Inventory data for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name InventoryData

# ***** EDITOR_PLUGIN *****
var _editor: EditorPlugin
var _undo_redo: UndoRedo

func editor() -> EditorPlugin:
	return _editor

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_undo_redo = _editor.get_undo_redo()

const UUID = preload("res://addons/inventory_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

# ***** INVENTORY SINGLE *****
export(bool) var inventory_single = true

func set_inventory_single(value: bool) -> void:
	var old_inventory_single = inventory_single
	if _undo_redo != null:
		_undo_redo.create_action("Inventory single")
		_undo_redo.add_do_method(self, "_set_inventory_single", value)
		_undo_redo.add_undo_method(self, "_set_inventory_single", old_inventory_single)
		_undo_redo.commit_action()
	else:
		_set_inventory_single(value)
	
func _set_inventory_single(value: bool) -> void:
	inventory_single = value
	emit_signal("inventory_single_changed", inventory_single)

# ***** INVENTORY *****
signal inventory_added(inventory)
signal inventory_removed(inventory)
signal inventory_selection_changed(inventory)
signal inventory_single_changed(value)

export(Array) var inventories = [_create_inventory()]
var _inventory_selected: InventoryInventory

func add_inventory(sendSignal = true) -> void:
	var inventory = _create_inventory()
	if _undo_redo != null:
		_undo_redo.create_action("Add inventory")
		_undo_redo.add_do_method(self, "_add_inventory", inventory)
		_undo_redo.add_undo_method(self, "_del_inventory", inventory)
		_undo_redo.commit_action()
	else:
		_add_inventory(inventory, sendSignal)

func _create_inventory() -> InventoryInventory:
	var inventory = InventoryInventory.new()
	inventory.uuid = UUID.v4()
	inventory.name = _next_inventory_name()
	inventory.items = []
	return inventory

func _next_inventory_name() -> String:
	var base_name = "Inventory"
	var value = -9223372036854775807
	var inventory_found = false
	if inventories:
		for inventory in inventories:
			var name = inventory.name
			if name.begins_with(base_name):
				inventory_found = true
				var behind = inventory.name.substr(base_name.length())
				var regex = RegEx.new()
				regex.compile("^[0-9]+$")
				var result = regex.search(behind)
				if result:
					var new_value = int(behind)
					if  value < new_value:
						value = new_value
	var next_name = base_name
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif inventory_found:
		next_name += "1"
	return next_name

func _add_inventory(inventory: InventoryInventory, sendSignal = true, position = inventories.size()) -> void:
	if not inventories:
		inventories = []
	inventories.insert(position, inventory)
	emit_signal("inventory_added", inventory)
	select_inventory(inventory)

func del_inventory(inventory) -> void:
	if _undo_redo != null:
		var index = inventories.find(inventory)
		_undo_redo.create_action("Del inventory")
		_undo_redo.add_do_method(self, "_del_inventory", inventory)
		_undo_redo.add_undo_method(self, "_add_inventory", inventory, false, index)
		_undo_redo.commit_action()
	else:
		_del_inventory(inventory)

func _del_inventory(inventory) -> void:
	var index = inventories.find(inventory)
	if index > -1:
		inventories.remove(index)
		emit_signal("inventory_removed", inventory)
		_inventory_selected = null
		var inventory_selected = selected_inventory()
		select_inventory(inventory_selected)

func selected_inventory() -> InventoryInventory:
	if not _inventory_selected and not inventories.empty():
		_inventory_selected = inventories[0]
	return _inventory_selected

func select_inventory(inventory: InventoryInventory) -> void:
	_inventory_selected = inventory
	emit_signal("inventory_selection_changed", _inventory_selected)

# ***** ITEM *****
signal item_added(item)
signal item_removed(item)
signal item_selection_changed(item)
signal item_icon_changed(item)

func emit_item_icon_changed(item: InventoryItem) -> void:
	emit_signal("item_icon_changed", item)

func add_item(sendSignal = true) -> void:
	var item = _create_item()
	if _undo_redo != null:
		_undo_redo.create_action("Add item")
		_undo_redo.add_do_method(self, "_add_item", item)
		_undo_redo.add_undo_method(self, "_del_item", item)
		_undo_redo.commit_action()
	else:
		_add_item(item, sendSignal)

func _create_item() -> InventoryItem:
	var item = InventoryItem.new()
	item.uuid = UUID.v4()
	item.type = _inventory_selected.uuid
	item.name = _next_item_name()
	return item

func _next_item_name(base_name = "Item") -> String:
	var value = -9223372036854775807
	var item_found = false
	if _inventory_selected.items:
		for item in _inventory_selected.items:
			var name = item.name
			if name.begins_with(base_name):
				item_found = true
				var behind = item.name.substr(base_name.length())
				var regex = RegEx.new()
				regex.compile("^[0-9]+$")
				var result = regex.search(behind)
				if result:
					var new_value = int(behind)
					if  value < new_value:
						value = new_value
	var next_name = base_name
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif item_found:
		next_name += "1"
	return next_name

func _add_item(item: InventoryItem, sendSignal = true, position = _inventory_selected.items.size(), select = true) -> void:
	if not _inventory_selected.items:
		_inventory_selected.items = []
	_inventory_selected.items.insert(position, item)
	emit_signal("item_added", item)
	if select:
		select_item(item)

func copy_item(item: InventoryItem) -> void:
	var new_item = _create_item()
	new_item.type = item.type
	new_item.name = _next_item_name()
	new_item.icon = item.icon
	new_item.properties = item.properties.duplicate()
	if _undo_redo != null:
		_undo_redo.create_action("Copy item")
		_undo_redo.add_do_method(self, "_add_item", new_item, true, _inventory_selected.items.size(), false)
		_undo_redo.add_undo_method(self, "_del_item", new_item)
		_undo_redo.commit_action()
	else:
		_add_item(new_item, true, _inventory_selected.items.size(), false)

func del_item(item) -> void:
	if _undo_redo != null:
		var index = _inventory_selected.items.find(item)
		_undo_redo.create_action("Del item")
		_undo_redo.add_do_method(self, "_del_item", item)
		_undo_redo.add_undo_method(self, "_add_item", item, false, index)
		_undo_redo.commit_action()
	else:
		_del_item(item)

func _del_item(item) -> void:
	var index = _inventory_selected.items.find(item)
	if index > -1:
		_inventory_selected.items.remove(index)
		emit_signal("item_removed", item)
		_inventory_selected.selected = null
		var item_selected = selected_item()
		select_item(item_selected)

func selected_item() -> InventoryItem:
	if not _inventory_selected.selected and not _inventory_selected.items.empty():
		_inventory_selected.selected = _inventory_selected.items[0]
	return _inventory_selected.selected

func select_item(item: InventoryItem) -> void:
	_inventory_selected.selected = item
	emit_signal("item_selection_changed", _inventory_selected.selected)

# ***** EDITOR SETTINGS *****
const BACKGROUND_COLOR_SELECTED = Color("#868991")

const PATH_TO_SAVE = "res://addons/inventory_editor/InventorySave.res"
const AUTHOR = "# @author Vladimir Petrenko\n"
const SETTINGS_INVENTORIES_SPLIT_OFFSET = "dialogue_editor/inventories_split_offset"
const SETTINGS_INVENTORIES_SPLIT_OFFSET_DEFAULT = 215
const SUPPORTED_IMAGE_RESOURCES = ["bmp", "jpg", "jpeg", "png", "svg", "svgz", "tres"]


func setting_inventories_split_offset() -> int:
	var offset = SETTINGS_INVENTORIES_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_INVENTORIES_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_INVENTORIES_SPLIT_OFFSET)
	return offset

func setting_inventories_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_INVENTORIES_SPLIT_OFFSET, offset)

# ***** LOAD SAVE *****
func init_data() -> void:
	var file = File.new()
	if file.file_exists(PATH_TO_SAVE):
		var resource = ResourceLoader.load(PATH_TO_SAVE) as InventoryData
		if resource.inventories and not resource.inventories.empty():
			inventories = resource.inventories
		inventory_single = resource.inventory_single
		if not resource.inventory_single:
			resource.inventory_single = false

func save() -> void:
	ResourceSaver.save(PATH_TO_SAVE, self)

# ***** UTILS *****
func filename(value: String) -> String:
	var index = value.find_last("/")
	return value.substr(index + 1)

func filename_only(value: String) -> String:
	var first = value.find_last("/")
	var second = value.find_last(".")
	return value.substr(first + 1, second - first - 1)

func file_path(value: String) -> String:
	var index = value.find_last("/")
	return value.substr(0, index)

func file_extension(value: String):
	var index = value.find_last(".")
	if index == -1:
		return null
	return value.substr(index + 1)

func resource_exists(resource_path) -> bool:
	var file = File.new()
	return file.file_exists(resource_path)

func resize_texture(t: Texture, size: Vector2):
	var itex = t
	if itex:
		var texture = t.get_data()
		if size.x > 0 && size.y > 0:
			texture.resize(size.x, size.y)
		itex = ImageTexture.new()
		itex.create_from_image(texture)
	return itex
