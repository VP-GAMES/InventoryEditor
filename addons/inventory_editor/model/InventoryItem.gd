# Inventory item for InventoryEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name InventoryItem

export (String) var uuid
export (String) var type # uuid from InventoryInventory
export (String) var name
export (Texture) var icon
export (Dictionary) var properties
export (int) var stacksize = 1
