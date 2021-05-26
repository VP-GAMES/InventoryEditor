# Example implementation for inventory item popup to demonstrate functionality of InventoryEditor : MIT License
# @author Vladimir Petrenko
extends Popup

var _localization_manager

onready var _label = $Label as RichTextLabel

func _ready() -> void:
	if not _localization_manager:
		_localization_manager = get_tree().get_root().get_node("LocalizationManager")

func update_item_data(item: InventoryItem) -> void:
	var text = item.description
	if _localization_manager:
		text = _localization_manager.tr(text)
	_label.bbcode_text = text
