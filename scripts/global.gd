extends Node

var fullscreen = false

var resMode = 0
var resModes = [
	Vector2(640, 480),
	Vector2(1920, 1080)
]

var fpsMode = 0
var fpsModes = [
	30,
	60,
	120,
	144,
	0
]
var fpsNode: Label

func _ready() -> void:
	fpsNode = get_node("FPSCounter")

func setFpsMode(mode) -> void: 
	fpsNode.visible = true
	Engine.max_fps = fpsModes[mode]


func _process(delta: float) -> void:
	fpsNode.text = "%s / %s" % [round(Engine.get_frames_per_second()), fpsModes[fpsMode]]
	if Input.is_action_just_pressed("toggle_fps"):
		fpsMode += 1
		if fpsMode >= 5:
			fpsMode = 0
		setFpsMode(fpsMode)
	if Input.is_action_just_pressed("fullscreen"):
		if not fullscreen :
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
