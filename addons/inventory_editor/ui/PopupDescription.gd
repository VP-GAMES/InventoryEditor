# Example implementation for inventory item popup to demonstrate functionality of InventoryEditor : MIT License
# @author Vladimir Petrenko
extends Popup

var localization_editor

onready var _label = $Label as RichTextLabel

func _ready() -> void:
	if not localization_editor:
		localization_editor = get_tree().get_root().find_node("LocalizationEditor", true, false)

func update_item_data(item: InventoryItem) -> void:
	var text = item.description
	if localization_editor:
		text = localization_editor.tr(text)
	_label.bbcode_text = text
