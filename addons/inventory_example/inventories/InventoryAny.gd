extends Control

onready var _grid_ui = $NinePatchRect/Margin/Grid as GridContainer

const Item = preload("res://addons/inventory_example/inventories/ItemUI.tscn")

func _ready() -> void:
	update_view()

func update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	var children = _grid_ui.get_children()
	for child in children:
		_grid_ui.remove_child(child)
		child.queue_free()

func _draw_view() -> void:
	for index in range(16):
		var item = Item.instance()
		_grid_ui.add_child(item)
