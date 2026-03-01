extends Node

var Legs
var LArm
var RArm
var Hair
var Body
var Torso
var Head

var tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Legs = get_node("Legs")
	LArm = get_node("LArm")
	RArm = get_node("RArm")
	Hair = get_node("Hair")
	Body = get_node("Body")
	Torso = get_node("Torso")
	Head = get_node("Head")
	
	tween = get_tree().get_twe


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Tween.new()
