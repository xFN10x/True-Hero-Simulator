extends Node

var Legs: Sprite2D
var LArm: Sprite2D
var RArm: Sprite2D
var Hair: Sprite2D
var Body: Sprite2D
var Torso: Sprite2D
var Head: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Legs = get_node("Legs")
	LArm = get_node("LArm")
	RArm = get_node("RArm")
	Hair = get_node("Hair")
	Body = get_node("Body")
	Torso = get_node("Torso")
	Head = get_node("Head")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
