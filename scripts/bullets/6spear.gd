@tool
extends Node2D
class_name SixSpear

var battleManager;

static var turnCounter = 0

@export var spears = 6
@export var drawWireframe = false
@export var initRadius = 12
@export var spearScene: PackedScene
var angles := 0
@export var angleOffset = 0

func remove() -> void:
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	addSpears()
	if turnCounter == 0:
		$Animation.play("main")
		turnCounter += 1
	else:
		$Animation.play("alt")
		turnCounter = 0
	
func addSpears() -> void:
	angles = 360 / spears
	print("clearing")
	if not is_inside_tree(): return
	print(spearScene)
	print("clearing 2")
	for n in get_children():
		if not n is StaticSpear: continue
		remove_child(n)
		n.queue_free()
	for i in range(spears):
		var sp = spearScene.instantiate()
		sp.battleManager = battleManager
		add_child(sp)

func _draw() -> void:
	if drawWireframe:
		draw_circle(Vector2(0,0), initRadius, Color.AQUA, false, 1)
		draw_circle(Vector2(0,0), 3, Color.AQUA, true)
		for i in range(spears):
			draw_circle(Vector2.from_angle(deg_to_rad(angles * i) + angleOffset) * initRadius, 12, Color.RED)
		queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var chilren = get_children()
	for v in chilren:
		if v is StaticSpear:
			var i = chilren.find(v)
			v.position = Vector2.from_angle(deg_to_rad((angles * i) + angleOffset)) * initRadius
			v.look_at(global_position)
