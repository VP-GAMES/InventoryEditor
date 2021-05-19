extends Popup

onready var _label = $Label as RichTextLabel

func update_item_data(item: InventoryItem) -> void:
	_label.bbcode_text = item.description
