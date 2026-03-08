@tool
extends Node2D
class_name ShootingSpearSpawner

var battleManager;

static var angleCounter = 0

@export var spears = 6
@export var initRadius = 12
@export var spearScene: PackedScene
@export var angleOffset := 0
var angles := 0

func remove() -> void:
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match angleCounter:
		0:
			angleOffset = 0
		1:
			angleOffset = -45
		2:
			angleOffset = 45
			angleCounter = -1
	angleCounter += 1
	
	addSpears()
	
func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2(0,0), initRadius, Color.AQUA, false, 1)
		draw_circle(Vector2(0,0), 3, Color.AQUA, true)
		for i in range(spears):
			draw_circle(Vector2.from_angle(deg_to_rad((angles * i) + angleOffset)) * initRadius, 12, Color.GREEN if i == 0 else Color.RED)
		queue_redraw()
		
func addSpears() -> void:
	angles = 360 / spears
	if not is_inside_tree(): return
	for i in range(spears):
		var sp: ShootingSpear = spearScene.instantiate()
		sp.battleManager = battleManager
		sp.target = global_position
		sp.position = Vector2.from_angle(deg_to_rad((angles * i) + angleOffset)) * initRadius
		add_child(sp)
