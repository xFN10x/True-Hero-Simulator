extends Sprite2D
class_name Arrow

enum Direction {
	UP = 180,
	DOWN = 0,
	LEFT = 90,
	RIGHT = -90
}
var currentDirection: Direction
var speed: int

func _init(dir: Direction = Direction.DOWN, speed: int = 1) -> void:
	currentDirection = dir
	speed = speed

func _ready() -> void:
	rotation_degrees = currentDirection
	
	$Area2D.area_shape_entered.connect(func (area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
		if area.name == "ShieldHB":
			queue_free()
		)

func _process(delta: float) -> void:
	
	match currentDirection:
		Direction.UP:
			position.y += -speed
		Direction.DOWN:
			position.y += speed
		Direction.RIGHT:
			position.x += -speed
		Direction.LEFT:
			position.x += speed
