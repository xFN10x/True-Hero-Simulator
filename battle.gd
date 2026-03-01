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
var menuSelectNode: AudioStreamPlayer
var textSndNode: AudioStreamPlayer

var undyneAnimationNode: AnimationPlayer
var undyneEyeAnimationNode: AnimationPlayer
enum MenuMode {
	OPTION_MODE,
	NO_MODE,
	ACT,
	ITEM,
	MERCY,
	FIGHT,
}
var menuMode = MenuMode.OPTION_MODE
var textNode: Label

var currentText = "*   The    wind    is    howling..."
var currentTextI = 0

func showText(text: String) -> void:
	currentText = text
	currentTextI = 0

func selectOption() -> void:
	menuMode = 0
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	musicNode = get_node("Music")
	musicNode.play()
	menuMoveNode = get_node("MenuMove")
	menuSelectNode = get_node("MenuSelect")
	textSndNode = get_node("TextSnd")
	
	soulNode = get_node("Soul")
	
	fightNode = get_node("Fight")
	actNode = get_node("Act")
	itemNode = get_node("Item")
	mercyNode = get_node("Mercy")
	
	undyneAnimationNode = get_node("Undyne/BodyAnimation")
	undyneEyeAnimationNode = get_node("Undyne/EyeGlintAnimation")
	undyneAnimationNode.play("undyne")
	undyneEyeAnimationNode.play("eye")
	
	textNode = get_node("Box/Label")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currentTextI < currentText.length():
		currentTextI += 1
		textNode.text = currentText.substr(0,currentTextI)
		if textNode.text.substr(textNode.text.length()) != " ":
			textSndNode.play()
		
	if menuMode == MenuMode.OPTION_MODE:
		if Input.is_action_just_pressed("ui_right") && selectedButton != 3 :
			selectedButton += 1
			menuMoveNode.play()
			
		if Input.is_action_just_pressed("ui_left") && selectedButton != 0 :
			selectedButton -= 1
			menuMoveNode.play()
			
		if Input.is_action_just_pressed("ui_select") :
			menuSelectNode.play()
		
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
		
