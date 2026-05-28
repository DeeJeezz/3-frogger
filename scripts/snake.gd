class_name Snake
extends Area2D

@export var variants: Array[AtlasTexture]

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite.texture = variants.pick_random()


func _on_area_entered(area: Area2D) -> void:
	var frogger: Frogger = area.get_parent()
	frogger.death()
