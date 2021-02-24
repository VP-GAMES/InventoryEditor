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
	for type in types:
		type.set_editor(_editor)
	_undo_redo = _editor.get_undo_redo()

const UUID = preload("res://addons/inventory_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

# ***** TYPE *****
signal type_added(type)
signal type_removed(type)
signal type_selection_changed(type)
signal type_icon_changed(item)

func emit_type_icon_changed(type: InventoryType) -> void:
	emit_signal("type_icon_changed", type)

export(Array) var types = [_create_type()]
var _type_selected: InventoryType

func add_type(sendSignal = true) -> void:
	var type = _create_type()
	if _undo_redo != null:
		_undo_redo.create_action("Add type")
		_undo_redo.add_do_method(self, "_add_type", type)
		_undo_redo.add_undo_method(self, "_del_type", type)
		_undo_redo.commit_action()
	else:
		_add_type(type, sendSignal)

func _create_type() -> InventoryType:
	var type = InventoryType.new()
	type.set_editor(_editor)
	type.uuid = UUID.v4()
	type.name = _next_type_name()
	type.items = []
	return type

func _next_type_name() -> String:
	var base_name = "Type"
	var value = -9223372036854775807
	var type_found = false
	if types:
		for type in types:
			var name = type.name
			if name.begins_with(base_name):
				type_found = true
				var behind = type.name.substr(base_name.length())
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
	elif type_found:
		next_name += "1"
	return next_name

func _add_type(type: InventoryType, sendSignal = true, position = types.size()) -> void:
	if not types:
		types = []
	types.insert(position, type)
	emit_signal("type_added", type)
	select_type(type)

func del_type(type) -> void:
	if _undo_redo != null:
		var index = types.find(type)
		_undo_redo.create_action("Del type")
		_undo_redo.add_do_method(self, "_del_type", type)
		_undo_redo.add_undo_method(self, "_add_type", type, false, index)
		_undo_redo.commit_action()
	else:
		_del_type(type)

func _del_type(type) -> void:
	var index = types.find(type)
	if index > -1:
		types.remove(index)
		emit_signal("type_removed", type)
		_type_selected = null
		var type_selected = selected_type()
		select_type(type_selected)

func selected_type() -> InventoryType:
	if not _type_selected and not types.empty():
		_type_selected = types[0]
	return _type_selected

func select_type(type: InventoryType) -> void:
	_type_selected = type
	emit_signal("type_selection_changed", _type_selected)

# ***** ITEM *****
signal item_added(item)
signal item_removed(item)
signal item_selection_changed(item)
signal item_icon_changed(item)

func emit_item_icon_changed(item: InventoryItem) -> void:
	emit_signal("item_icon_changed", item)

func all_items() -> Array:
	var items = []
	for type in types:
		for item in type.items:
			items.append(item)
	return items

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
	item.set_editor(_editor)
	item.uuid = UUID.v4()
	item.type_uuid = _type_selected.uuid
	item.name = _next_item_name()
	return item

func _next_item_name(base_name = "Item") -> String:
	var value = -9223372036854775807
	var item_found = false
	if _type_selected.items:
		for item in _type_selected.items:
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

func _add_item(item: InventoryItem, sendSignal = true, position = _type_selected.items.size(), select = true) -> void:
	if not _type_selected.items:
		_type_selected.items = []
	_type_selected.items.insert(position, item)
	emit_signal("item_added", item)
	if select:
		select_item(item)

func copy_item(item: InventoryItem) -> void:
	var new_item = _create_item()
	new_item.name = _next_item_name()
	new_item.stacksize = item.stacksize
	new_item.icon = "" + item.icon
	new_item.properties = item.properties.duplicate(true)
	if _undo_redo != null:
		_undo_redo.create_action("Copy item")
		_undo_redo.add_do_method(self, "_add_item", new_item, true, _type_selected.items.size())
		_undo_redo.add_undo_method(self, "_del_item", new_item)
		_undo_redo.commit_action()
	else:
		_add_item(new_item, true, _type_selected.items.size())

func del_item(item) -> void:
	if _undo_redo != null:
		var index = _type_selected.items.find(item)
		_undo_redo.create_action("Del item")
		_undo_redo.add_do_method(self, "_del_item", item)
		_undo_redo.add_undo_method(self, "_add_item", item, false, index)
		_undo_redo.commit_action()
	else:
		_del_item(item)

func _del_item(item) -> void:
	var index = _type_selected.items.find(item)
	if index > -1:
		_type_selected.items.remove(index)
		emit_signal("item_removed", item)
		_type_selected.selected = null
		var item_selected = selected_item()
		select_item(item_selected)

func selected_item() -> InventoryItem:
	if not _type_selected.selected and not _type_selected.items.empty():
		_type_selected.selected = _type_selected.items[0]
	return _type_selected.selected

func select_item(item: InventoryItem) -> void:
	_type_selected.selected = item
	emit_signal("item_selection_changed", _type_selected.selected)

func get_item_by_uuid(uuid: String) -> InventoryItem:
	for type in types:
		for item in type.items:
			if item.uuid == uuid:
				return item
	return null

func get_type_by_uuid(uuid: String) -> InventoryItem:
	for type in types:
		if type.uuid == uuid:
			return type
	return null

# ***** EDITOR SETTINGS *****
const BACKGROUND_COLOR_SELECTED = Color("#868991")

const PATH_TO_SAVE = "res://addons/inventory_editor/InventorySave.res"
const AUTHOR = "# @author Vladimir Petrenko\n"
const SETTINGS_TYPES_SPLIT_OFFSET = "dialogue_editor/types_split_offset"
const SETTINGS_TYPES_SPLIT_OFFSET_DEFAULT = 215
const SETTINGS_ITEMS_SPLIT_OFFSET = "dialogue_editor/items_split_offset"
const SETTINGS_ITEMS_SPLIT_OFFSET_DEFAULT = 215
const SUPPORTED_IMAGE_RESOURCES = ["bmp", "jpg", "jpeg", "png", "svg", "svgz", "tres"]

func setting_types_split_offset() -> int:
	var offset = SETTINGS_TYPES_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_TYPES_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_TYPES_SPLIT_OFFSET)
	return offset

func setting_types_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_TYPES_SPLIT_OFFSET, offset)

func setting_items_split_offset() -> int:
	var offset = SETTINGS_ITEMS_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_ITEMS_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_ITEMS_SPLIT_OFFSET)
	return offset

func setting_items_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_ITEMS_SPLIT_OFFSET, offset)

# ***** LOAD SAVE *****
func init_data() -> void:
	var file = File.new()
	if file.file_exists(PATH_TO_SAVE):
		var resource = ResourceLoader.load(PATH_TO_SAVE) as InventoryData
		if resource.types and not resource.types.empty():
			types = resource.types

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
