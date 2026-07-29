extends Area2D

@export var inventory_trigger: Area2D
@export var items: Node2D
@export var dragLayer: CanvasLayer

const INITIAL_POS: Vector2 = Vector2(800.0, -200.0)
const FINAL_POS: Vector2 = Vector2(800.0, 0.0)

var _is_open: bool = false
var _tween: Tween
var _circle_match = {}

func _ready() -> void:
	self.position = INITIAL_POS
	inventory_trigger.mouse_entered.connect(_open)

	for item in items.get_children():
		for child in item.find_children("Draggable", "Node", true):
			if child is Draggable:
				child.drag_ended.connect(_on_item_drag_ended)
				child.drag_started.connect(_on_item_drag_started)

func _on_item_drag_started(area: Area2D) -> void:
	area.reparent(dragLayer)
func _on_item_drag_ended(_area: Area2D, drop_spot: SnappingSpot) -> void:
	if !drop_spot || !drop_spot.point:
		return
	var target_area = drop_spot.point
	var dragged_item = drop_spot.occupant
	if target_area and target_area.name.contains('Area') and _is_open and dragged_item:
		print(target_area.name)
		print(dragged_item.name)
		var matches = false
		if target_area.name.contains(dragged_item.name):
			matches = true
		_circle_match[target_area.name] = matches
		
		if _circle_match.size() != 6:
			print(_circle_match)
			_close()
			return
			
		_close()
		if (_circle_match.values.all(func(value): return value)):
			print("success")
		print("failure")

func _create_unique_tween():
	if _tween && _tween.is_valid():
		_tween.kill()
	_tween = create_tween()

func toggle_inventory() -> void:
	if !_is_open:
		_open()
		return
	_close()

func _open() -> void:
	_create_unique_tween()
	_tween.tween_property(self, "position", FINAL_POS, 1.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_is_open = true

func _close() -> void:
	_create_unique_tween()
	_tween.tween_property(self, "position", INITIAL_POS, 1.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_is_open = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()
		
	
