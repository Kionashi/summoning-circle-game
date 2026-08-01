extends Sprite2D

@export var shelf: Area2D

func _ready() -> void:
	self.visible = false
	shelf.ritual_completed.connect(_on_ritual_ritual_completed)
	
func _on_ritual_ritual_completed(success: bool) -> void:
	if (success):
		print('success, on signal')
	else:
		print('fail, on signal')
