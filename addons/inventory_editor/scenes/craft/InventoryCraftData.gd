# Inventory recipe data UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends VBoxContainer

var _recipe: InventoryRecipe
var _data: InventoryData
var localization_editor

onready var _stacksize_ui = $HBoxStack/Stacksize as LineEdit
