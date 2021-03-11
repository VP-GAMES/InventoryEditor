extends Node2D

var inventoryManager

onready var _error_ui = $CanvasError as CanvasLayer

func _ready() -> void:
	if get_tree().get_root().has_node("InventoryManager"):
		_error_ui.queue_free()
		inventoryManager = get_tree().get_root().get_node("InventoryManager	")
