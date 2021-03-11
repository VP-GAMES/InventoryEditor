extends Node2D

var inventoryManager

onready var _error_ui = $CanvasError as CanvasLayer
onready var _inventory = $CanvasInventory/Inventory
onready var _inventory_button_ui = $CanvasButton/TextureButton as TextureButton

func _ready() -> void:
	if get_tree().get_root().has_node("InventoryManager"):
		_error_ui.queue_free()
		inventoryManager = get_tree().get_root().get_node("InventoryManager")
		_inventory_button_ui.connect("pressed", self, "_on_inventory_button_pressed")

func _on_inventory_button_pressed() -> void:
	if _inventory.visible:
		_inventory.hide()
	else:
		_inventory.show()
