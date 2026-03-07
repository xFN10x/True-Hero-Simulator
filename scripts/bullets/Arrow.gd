extends Sprite2D
class_name Arrow

var battleManager;
var canDamage = true

enum Direction {
	UP = 180,
	DOWN = 0,
	LEFT = -90,
	RIGHT = 90
}
static var CurrentArrows = []

var currentDirection: Direction
var speed: int
var isRed = false

func _init(dir: Direction = Direction.DOWN, speed: int = 1, manager = null) -> void:
	currentDirection = dir
	speed = speed
	battleManager = manager

func _ready() -> void:
	rotation_degrees = currentDirection
	CurrentArrows.append(self)
	$Area2D.body_entered.connect(func (other: Node2D):
		if other.name == "Soul":
			canDamage = false
			battleManager.damage(randi_range(8,14))
			remove()
		)
	$Area2D.area_shape_entered.connect(func (area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
		if not canDamage: return
		if area.name == "ShieldHB":
			canDamage = false
			$Ding.play()
			remove()
		)

func remove() -> void:
	position.x += 9999
	var index = CurrentArrows.find(self)
	if index == -1: return
	CurrentArrows.remove_at(index)
	if $Ding.playing:
		await $Ding.finished
	queue_free()

func _process(delta: float) -> void:
	if BattleManager.paused:
		return
	if not isRed && CurrentArrows.find(self) == 0:
		isRed = true
		region_rect.position.y = 1030
		
	match currentDirection:
		Direction.UP:
			position.y += -speed
		Direction.DOWN:
			position.y += speed
		Direction.RIGHT:
			position.x += -speed
		Direction.LEFT:
			position.x += speed
