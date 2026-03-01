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

var playerName = "chara"
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	musicNode = get_node("Music")
	musicNode.play()
	menuMoveNode = get_node("MenuMove")
	soulNode = get_node("Soul")
	
	fightNode = get_node("Fight")
	actNode = get_node("Act")
	itemNode = get_node("Item")
	mercyNode = get_node("Mercy")
	
	get_node("InfoBar/Name").text = playerName
	

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
			fightNode.region_rect = Rect2(8, fightVOffset + selectedVOffset, 110, 42)
			actNode.region_rect = Rect2(8, actVOffset, 110, 42)
			itemNode.region_rect = Rect2(8, itemVOffset, 110, 42)
			mercyNode.region_rect = Rect2(8, mercyVOffset, 110, 42)
		1:
			# ACT
			soulNode.global_position = Vector2(actXSoul, soulY)
			fightNode.region_rect = Rect2(8, fightVOffset, 110, 42)
			actNode.region_rect = Rect2(8, actVOffset + selectedVOffset, 110, 42)
			itemNode.region_rect = Rect2(8, itemVOffset, 110, 42)
			mercyNode.region_rect = Rect2(8, mercyVOffset, 110, 42)
		2:
			# ITEM
			soulNode.global_position = Vector2(itemXSoul, soulY)
			fightNode.region_rect = Rect2(8, fightVOffset, 110, 42)
			actNode.region_rect = Rect2(8, actVOffset, 110, 42)
			itemNode.region_rect = Rect2(8, itemVOffset + selectedVOffset, 110, 42)
			mercyNode.region_rect = Rect2(8, mercyVOffset, 110, 42)
		3:
			# MERCY
			soulNode.global_position = Vector2(mercyXSoul, soulY)
			fightNode.region_rect = Rect2(8, fightVOffset, 110, 42)
			actNode.region_rect = Rect2(8, actVOffset, 110, 42)
			itemNode.region_rect = Rect2(8, itemVOffset, 110, 42)
			mercyNode.region_rect = Rect2(8, mercyVOffset + selectedVOffset, 110, 42)
	
