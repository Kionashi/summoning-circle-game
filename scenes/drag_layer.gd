extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_item_drag_ended(_area: Area2D, drop_spot: SnappingSpot) -> void:
	print('drag ended (on the drag layer)')
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
