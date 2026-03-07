extends Sprite2D
class_name HomingSpear

var battleManager: BattleManager;
var soul: Node2D
var moving = false

var vel = 4

func remove() -> void:
	queue_free()

func _ready() -> void:
	if battleManager == null: 
		remove()
		return
	soul = battleManager.soulNode
	$Animations.play("spawn")
	await $Animations.animation_finished
	rotation = position.angle_to_point(soul.global_position) + deg_to_rad(90)
	moving = true
	$SndArrow.play()
	$Area.area_shape_entered.connect(func (area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
		if area.name == "OutOfBounds":
			remove()
		elif area.name == "SoulHB":
			battleManager.damage(randi_range(8, 14))
			remove()
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not moving: return
	vel += 0.25
	position += Vector2.from_angle(rotation - deg_to_rad(90)) * vel
