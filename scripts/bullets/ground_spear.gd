extends Sprite2D
class_name GroundSpear

var battleManager: BattleManager

func remove() -> void:
	queue_free()

func _ready() -> void:
	$Spear/Area.body_entered.connect(func (other: Node2D):
		if other.name == "Soul":
			battleManager.damage(randi_range(8,14))
		)
	$Animation.play("spearrise")
