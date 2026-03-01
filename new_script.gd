extends Node

var selectedVOffset = 47
var fightVOffset = 111
var actVOffset = 9
var itemVOffset = 212
var mercyVOffset = 313

var soulY = 453
var fightXSoul = 48
var actXSoul = 201
var itemXSoul = 361
var mercyXSoul = 516

var fightNode: Sprite2D
var actNode: Sprite2D
var itemNode: Sprite2D
var mercyNode: Sprite2D

var selectedButton = 0;

var soulNode: Sprite2D
var musicNode: AudioStreamPlayer
var menuMoveNode: AudioStreamPlayer
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	musicNode = get_node("Music")
	musicNode.play()
	menuMoveNode = get_node("MenuMove")
	soulNode = get_node("Soul")
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right") && selectedButton != 3 :
		selectedButton += 1
		menuMoveNode.play()
		
	if Input.is_action_just_pressed("ui_left") && selectedButton != 0 :
		selectedButton -= 1
		menuMoveNode.play()
	
	match selectedButton:
		0:
			# FIGHT
			soulNode.global_position = Vector2(fightXSoul, soulY)
			
		1:
			# ACT
			soulNode.global_position = Vector2(actXSoul, soulY)
		2:
			# ITEM
			soulNode.global_position = Vector2(itemXSoul, soulY)
		3:
			# MERCY
			soulNode.global_position = Vector2(mercyXSoul, soulY)
	
