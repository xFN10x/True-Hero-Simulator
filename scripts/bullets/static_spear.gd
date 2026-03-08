extends Area2D
class_name StaticSpear

var battleManager: BattleManager;
var soul: Node2D

func remove() -> void:
	queue_free()

func _ready() -> void:
	if battleManager != null: 
		soul = battleManager.soulNode
	body_shape_entered.connect(func (body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int):
		if body.name == "Soul":
			battleManager.damage(randi_range(8,14))
		)
