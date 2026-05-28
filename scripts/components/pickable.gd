@abstract
class_name Pickable
extends Area2D


func _ready() -> void:
	area_entered.connect(apply_effect)


@abstract func apply_effect(..._args) -> void
