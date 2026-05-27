extends Node2D

@export var frogger: Frogger
@export var frogger_start_marker: Marker2D
@export var ground_layer: TileMapLayer


func _ready() -> void:
	frogger.position = frogger_start_marker.position
	#frogger.moved.connect(_on_frogger_moved)


#func _on_frogger_moved() -> void:
	#var local_position: Vector2 = ground_layer.to_local(frogger.global_position)
	#var tile_position: Vector2i = ground_layer.local_to_map(local_position)
	#var tile: TileData = ground_layer.get_cell_tile_data(tile_position)
#
	#if tile == null:
		#frogger.is_on_water = false
		#return
#
	#frogger.is_on_water = tile.get_custom_data(Constants.WATER_TILEMAP_LAYER_NAME) == true
