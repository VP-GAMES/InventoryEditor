# Inventory recipe data for InventoryEditor: MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _ingredient
var _recipe: InventoryRecipe

onready var _dropdown_ui = $Dropdown
onready var _quantity_ui = $Quantity
onready var _del_ui = $Del

func set_data(ingredient, recipe: InventoryRecipe) -> void:
	_ingredient = ingredient
	_recipe = recipe
	_init_connections()
	_draw_view()

func _init_connections() -> void:
	if not _quantity_ui.is_connected("text_changed", self, "_on_quantity_text_changed"):
		assert(_quantity_ui.connect("text_changed", self, "_on_quantity_text_changed") == OK)
	if not _del_ui.is_connected("pressed", self, "_on_del_pressed"):
		assert(_del_ui.connect("pressed", self, "_on_del_pressed") == OK)

func _on_quantity_text_changed(new_text: String) -> void:
	_recipe.change_ingredient_value(_ingredient, new_text, false)

func _on_del_pressed() -> void:
	_recipe.del_ingredient(_ingredient)

func _draw_view() -> void:
	_draw_view_quantity()

func _draw_view_quantity() -> void:
	_quantity_ui.text = str(_ingredient.quantity)
