extends Sprite2D
class_name ShootingSpear

var battleManager: BattleManager;
var soul: Node2D
var moving = false
var target: Vector2

func remove() -> void:
	queue_free()

func _ready() -> void:
	if battleManager != null: 
		soul = battleManager.soulNode
		$Area.body_entered.connect(func (other: Node2D):
			if other.name == "Soul":
				battleManager.damage(randi_range(8,14))
				remove()
			)
	#$Animations.play("spawn")
	look_at(target)
	$Area/HomingSpear.disabled = true
	var tween1 = create_tween()
	tween1.parallel().tween_property(self,"rotation_degrees", rotation_degrees + 360, 0.56666)
	tween1.parallel().tween_property(self, "self_modulate", Color.WHITE, 0.56666)
	tween1.play()
	await tween1.finished
	$Area/HomingSpear.disabled = false
	moving = true

var timer = 0
func _process(delta: float) -> void:
	if timer >= 15:
		$Area/HomingSpear.disabled = true
		var tween1 = create_tween()
		tween1.parallel().tween_property(self, "self_modulate", Color.TRANSPARENT, 0.56666)
		tween1.play()
		tween1.finished.connect( func ():
			remove()
			)
	if moving:
		timer += 1
		position += Vector2.from_angle(rotation) * 12
