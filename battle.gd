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

var optionPoses = [
	Vector2(72.0, 286.0), Vector2(312, 286.0),
	Vector2(72.0, 318.0), Vector2(312, 318.0)
]

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

var hp = 56
var maxHp = 56
var hpBarNode: ProgressBar
var hpTextNode: Label

var boxNode: Panel
# Box Positions Vec4(x,y, width, height)
var defaultPos = Vector4(32, 250, 575, 140)
var spearAtkPos = Vector4(85, 81, 280, 204)

enum MenuMode {
	OPTION_MODE,
	NO_MODE,
	ACT,
	ITEM,
	MERCY,
	FIGHT,
	ENEMY_TURN,
}
var menuOptions = [
	"test", "test",
	"big test"
]
var menuMode = MenuMode.OPTION_MODE
var textNode: Label
var option0Node: Label
var option1Node: Label
var option2Node: Label
var option3Node: Label

var currentText = "* The wind is howling..."
var currentTextI = 0

var currentAttack = 0

enum SoulMode {
	GREEN,
	RED,
}
var soulMode = SoulMode.RED
var redSoulTexture = CompressedTexture2D.new()
var greenSoulTexture = CompressedTexture2D.new()

func setBoxPosInsta(trans: Vector4) -> void:
	boxNode.position = Vector2(trans.x, trans.y)
	boxNode.size = Vector2(trans.z, trans.w)

func setBoxPos(trans: Vector4) -> void:
	var tweenMove = get_tree().create_tween()
	tweenMove.tween_property(boxNode, "position", Vector2(trans.x, trans.y), 1)
	var tweenSize = get_tree().create_tween()
	tweenSize.tween_property(boxNode, "size", Vector2(trans.z, trans.w), 1)
	tweenSize.play()
	tweenMove.play()
	
func canNavTo(optionArray: Array, selected: int) -> bool:
	return selected >= 0 && selected < optionArray.size()

func showText(text: String) -> void:
	currentText = text
	currentTextI = 0
	optionPoses

func selectOption() -> void:
	menuMode = 0
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	redSoulTexture.load_path = "res://.godot/imported/red_soul_normal.png-4f89669b8b9113871863587930ef3923.ctex"
	greenSoulTexture.load_path = "res://.godot/imported/green_soul_normal.png-41e0ebc41d7a126f221b5f497a015d17.ctex"

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
	
	textNode = get_node("Box/MainText")
	
	option0Node = get_node("Box/Options/0")
	option1Node = get_node("Box/Options/1")
	option2Node = get_node("Box/Options/2")
	option3Node = get_node("Box/Options/3")
	
	hpBarNode = get_node("InfoBar/HPBar")
	hpTextNode = get_node("InfoBar/HPText")

	boxNode = get_node("Box")
	
	setBoxPosInsta(defaultPos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match soulMode:
		SoulMode.RED:
			soulNode.texture = redSoulTexture
		SoulMode.GREEN:
			soulNode.texture = greenSoulTexture
	hpBarNode.value = hp
	hpTextNode.text = "%s / %s" % [hp, maxHp]
	#print(selectedButton)
	if currentTextI < currentText.length() && (menuMode != MenuMode.ITEM):
		if menuMode == MenuMode.NO_MODE && Input.is_action_just_pressed("ui_select") :
			currentTextI = currentText.length()
				
		currentTextI += 1
		textNode.text = currentText.substr(0,currentTextI)
		if not textNode.text.substr(textNode.text.length()-1, 1) == " ":
			#print(textNode.text.substr(textNode.text.length()-1, 1))
			textSndNode.play()
	match menuMode:
		MenuMode.ENEMY_TURN:
			option0Node.visible = false
			option1Node.visible = false
			option2Node.visible = false
			option3Node.visible = false
			textNode.visible = false;
			soulNode.visible = false;
			match currentAttack:
				0:
					pass
					
		MenuMode.NO_MODE:
			option0Node.visible = false
			option1Node.visible = false
			option2Node.visible = false
			option3Node.visible = false
			textNode.visible = true;
			soulNode.visible = false;
			
			if currentTextI <= currentText.length() && Input.is_action_just_pressed("ui_select") :
				menuMode == MenuMode.ENEMY_TURN
		MenuMode.OPTION_MODE:
			option0Node.visible = false
			option1Node.visible = false
			option2Node.visible = false
			option3Node.visible = false
			textNode.visible = true;
			soulNode.visible = true;
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
						pass
					1:
						pass
					2:
						menuMode = MenuMode.ITEM
					3:
						pass
					
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
			pass
		MenuMode.ITEM:
			soulNode.visible = true;
			option0Node.visible = true
			if canNavTo(menuOptions, 0):
				option0Node.text = "*  " + menuOptions[0]
			else :
				option0Node.text = ""
			option1Node.visible = true
			if canNavTo(menuOptions, 1):
				option1Node.text = "*  " + menuOptions[1]
			else :
				option1Node.text = ""
			option2Node.visible = true
			if canNavTo(menuOptions, 2):
				option2Node.text = "*  " + menuOptions[2]
			else :
				option2Node.text = ""
			option3Node.visible = true
			if canNavTo(menuOptions, 3):
				option3Node.text = "*  " + menuOptions[3]
			else :
				option3Node.text = ""
			textNode.visible = false;
			if canNavTo(menuOptions, selectedButton + 1) && Input.is_action_just_pressed("ui_right") && (selectedButton != 1  && selectedButton != 3) :
				selectedButton += 1
				menuMoveNode.play()
				
			if canNavTo(menuOptions, selectedButton - 1) && Input.is_action_just_pressed("ui_left") && (selectedButton != 0 && selectedButton != 2) :
				selectedButton -= 1
				menuMoveNode.play()
				
			if canNavTo(menuOptions, selectedButton - 2) && Input.is_action_just_pressed("ui_up") && (selectedButton != 0 && selectedButton != 1) :
				selectedButton -= 2
				menuMoveNode.play()
				
			if canNavTo(menuOptions, selectedButton + 2) && Input.is_action_just_pressed("ui_down") && (selectedButton != 2 && selectedButton != 3) :
				selectedButton += 2
				menuMoveNode.play()
				
			if Input.is_action_just_pressed("ui_cancel") :
				selectedButton = 2
				menuMode = MenuMode.OPTION_MODE
				currentTextI = 0
			if Input.is_action_just_pressed("ui_select") :
				menuSelectNode.play()
				menuMode = MenuMode.NO_MODE
				showText("* Consumed the " + menuOptions[selectedButton])
				match selectedButton:
					0:
						
						pass
					1:
						pass
					2:
						pass
					3:
						pass
			soulNode.position = optionPoses[selectedButton]
			pass
				
