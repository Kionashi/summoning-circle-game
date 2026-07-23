extends Area2D

@export var inventory_trigger: Area2D
@export var items: Node2D

const INITIAL_POS: Vector2 = Vector2(839.0, -246.0)
const FINAL_POS: Vector2 = Vector2(818.0, 60.0)

var _is_open: bool = false
var _tween: Tween

func _ready() -> void:
	inventory_trigger.mouse_entered.connect(_open)

	for item in items.get_children():
		pass
		

func create_unique_tween():
	if _tween && _tween.is_valid():
		_tween.kill()
	_tween = create_tween()

func toggle_inventory() -> void:
	if !_is_open:
		_open()
		return
	_close()

func _open() -> void:
	create_unique_tween()
	_tween.tween_property(self, "position", FINAL_POS, 1.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_is_open = true

func _close() -> void:
	create_unique_tween()
	_tween.tween_property(self, "position", INITIAL_POS, 1.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_is_open = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()
		
	
