extends Node2D
class_name BattleManager

var ArrowBullet = preload("res://scripts/bullets/Arrow.gd")

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
var lastOption = 0

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
var spearAtkPos = Vector4(280, 204,85, 81)

enum MenuMode {
	OPTION_MODE,
	NO_MODE,
	ITEM,
	ENEMY_TURN,
	ATTACK,
}
var menuOptions = []

class Item :
	var Health: int
	var Name: String
	var SName: String
	
	func _init(Health, Name, ShortName) -> void:
		self.Health = Health
		self.Name = Name
		self.SName = ShortName
	
var food = [
	Item.new(22, "Cinnamon Bunny",  "C. Bun"),
	Item.new(22, "Cinnamon Bunny",  "C. Bun"),
	Item.new(22, "Cinnamon Bunny",  "C. Bun"),
	Item.new(22, "Cinnamon Bunny",  "C. Bun"),
	
	Item.new(999, "Butterscotch Pie",  "Pie"),
	
	Item.new(45, "Snowman Piece",  "SnowPiece"),
	Item.new(45, "Snowman Piece",  "SnowPiece"),
	Item.new(45, "Snowman Piece",  "SnowPiece"),
]
var menuMode = MenuMode.OPTION_MODE
var textNode: Label
var option0Node: Label
var option1Node: Label
var option2Node: Label
var option3Node: Label

var defaultText = "* The wind is howling..."
var currentText = defaultText
var currentTextI = 0

var currentAttack = 0

enum SoulMode {
	GREEN,
	RED,
}
var soulMode = SoulMode.RED
var redSoulTexture = CompressedTexture2D.new()
var greenSoulTexture = CompressedTexture2D.new()
var greenSoulPartsNode: Node2D
var greenSoulShield: Line2D
var greenSoulPos = Vector2(320, 242)
var greenSoulProtectUp: Tween
var greenSoulProtectDown: Tween
var greenSoulProtectLeft: Tween
var greenSoulProtectRight: Tween
var greenSoulRotate = deg_to_rad(90)

var checkText = """* Undyne the Undying - ATK 99 DEF 99
* Heroine reformed by her own
  DETERMINATION to save Earth.
"""

var enemyMaxHealth = 23000
var enemyHealth = enemyMaxHealth
var enemyHealthBar: ProgressBar

var attackIndicBar: AnimatedSprite2D
var attackTargetAnimation: AnimationPlayer
@onready var attackIndicAnimations = $Box/AttackIndic/FadeOutAni
var moveIndic = true

var knifeAnimationNode: AnimatedSprite2D
var knifeSound: AudioStreamPlayer
var enemyHitSound: AudioStreamPlayer

var Bullets: Node

var arrowUpPos:  Vector2
var arrowLeftPos: Vector2
var arrowRightPos: Vector2
var arrowDownPos: Vector2



func setBoxPosInsta(trans: Vector4) -> void:
	boxNode.position = Vector2(trans.x, trans.y)
	boxNode.size = Vector2(trans.z, trans.w)

func setBoxPos(trans: Vector4) -> Signal:
	var tweenMoveX = get_tree().create_tween()
	tweenMoveX.tween_property(boxNode, "position", Vector2(trans.x, boxNode.position.y), 0.1).set_trans(Tween.TRANS_LINEAR)
	var tweenSizeX = get_tree().create_tween()
	tweenSizeX.tween_property(boxNode, "size", Vector2(trans.z, boxNode.size.y), 0.2).set_trans(Tween.TRANS_LINEAR)
	tweenSizeX.play()
	tweenMoveX.play()
	await get_tree().create_timer(0.2).timeout
	
	var tweenMoveY = get_tree().create_tween()
	tweenMoveY.tween_property(boxNode, "position", Vector2(boxNode.position.x, trans.y), 0.1).set_trans(Tween.TRANS_LINEAR)
	var tweenSizeY = get_tree().create_tween()
	tweenSizeY.tween_property(boxNode, "size", Vector2(boxNode.size.x, trans.w), 0.2).set_trans(Tween.TRANS_LINEAR)
	tweenSizeY.play()
	tweenMoveY.play()
	return get_tree().create_timer(0.2).timeout
	
func canNavTo(optionArray: Array, selected: int) -> bool:
	return selected >= 0 && selected < optionArray.size()

func showText(text: String) -> void:
	currentText = text
	currentTextI = 0

func selectOption() -> void:
	menuMode = 0

func spawnArrow(speed: int, direction):
	var bullet: Arrow = preload("res://scripts/bullets/bullet.tscn").instantiate()
	bullet.speed = speed
	bullet.battleManager = self
	bullet.currentDirection = direction
	match direction:
		ArrowBullet.Direction.UP:
			bullet.position = arrowDownPos
		ArrowBullet.Direction.DOWN:
			bullet.position = arrowUpPos
		ArrowBullet.Direction.RIGHT:
			bullet.position = arrowRightPos
		ArrowBullet.Direction.LEFT:
			bullet.position = arrowLeftPos
	Bullets.add_child(bullet)

func damage(number: int) -> void:
	hp -= number
	$SndHurt1.play()

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
	
	greenSoulPartsNode = get_node("Soul/GreenSoul")
	greenSoulShield = get_node("Soul/GreenSoul/Shield")
	
	enemyHealthBar = get_node("Box/Options/0/HPBar")
	enemyHealthBar.max_value = enemyMaxHealth
	enemyHealthBar.value = enemyHealth
	enemyHealthBar.visible = false

	attackIndicBar = get_node("Box/AttackIndic")
	attackIndicBar.play()
	attackTargetAnimation = get_node("Box/Target/TargetAnimation")

	knifeAnimationNode = get_node("Undyne/KnifeAnimation")
	knifeSound = get_node("Attack")
	enemyHitSound = get_node("Damage")

	Bullets = get_node("Bullets")

	arrowUpPos = Vector2(soulNode.position.x, -16)
	arrowLeftPos = Vector2(-16, soulNode.position.y)
	arrowRightPos = Vector2(640 + 16, soulNode.position.y)
	arrowDownPos = Vector2(soulNode.position.x, 480 + 16)

	setBoxPosInsta(defaultPos)

func endAttack() -> void:
	menuMode = MenuMode.OPTION_MODE;
	currentText = ""
	textNode.text = ""
	await setBoxPos(defaultPos)
	showText(defaultText)

var attacksHealthRange = {
	
}
func attackProceed() -> void:
	attackNoProceed(0)
	
func attackNoProceed(id) -> void:
	menuMode = MenuMode.ENEMY_TURN
	var dur = 0.3

	currentAttack = id
	match currentAttack:
		0:
			await setBoxPos(spearAtkPos)
			soulMode = SoulMode.GREEN
			soulNode.position = greenSoulPos
			soulNode.visible = true
			spawnArrow(5, ArrowBullet.Direction.DOWN)
			await get_tree().create_timer(0.5).timeout
			spawnArrow(5, ArrowBullet.Direction.DOWN)
			await get_tree().create_timer(0.5).timeout
			spawnArrow(5, ArrowBullet.Direction.DOWN)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.DOWN)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.UP)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.LEFT)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.RIGHT)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.DOWN)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.UP)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.LEFT)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.RIGHT)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.DOWN)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.UP)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.LEFT)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.RIGHT)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.DOWN)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.UP)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.LEFT)
			await get_tree().create_timer(0.1).timeout
			spawnArrow(5, ArrowBullet.Direction.RIGHT)
			for i in 100:
				await get_tree().create_timer(0.01).timeout
				spawnArrow(5, ArrowBullet.Direction.RIGHT)
			await get_tree().create_timer(1).timeout
			
			endAttack()
			
func _process(delta: float) -> void:
	#print(menuMode)
	greenSoulShield.rotation = lerp_angle(greenSoulShield.rotation, greenSoulRotate, 0.8)
	match soulMode:
		SoulMode.RED:
			soulNode.texture = redSoulTexture
		SoulMode.GREEN:
			soulNode.texture = greenSoulTexture
	hpBarNode.value = hp
	hpTextNode.text = "%s / %s" % [hp, maxHp]
	#print(selectedButton)
	if currentTextI < currentText.length() && (menuMode != MenuMode.ITEM):
		if currentTextI != currentText.length() && menuMode == MenuMode.NO_MODE && Input.is_action_just_pressed("ui_cancel") :
			currentTextI = currentText.length()
				
		currentTextI += 1
		textNode.text = currentText.substr(0,currentTextI)
		if not textNode.text.substr(textNode.text.length()-1, 1) == " ":
			#print(textNode.text.substr(textNode.text.length()-1, 1))
			textSndNode.play()
	match menuMode:
		MenuMode.ATTACK:
			greenSoulPartsNode.visible = false;
			option0Node.visible = false
			option1Node.visible = false
			option2Node.visible = false
			option3Node.visible = false
			textNode.visible = false;
			soulNode.visible = false;
			if moveIndic:
				attackIndicBar.position.x += 14
			if attackIndicBar.position.x >= 480:
				attackIndicAnimations.play("out")
				await get_tree().create_timer(1).timeout
				attackProceed()
				return;
			
			if Input.is_action_just_pressed("ui_select") && moveIndic :
				moveIndic = false
				knifeAnimationNode.visible = true
				knifeAnimationNode.play()
				knifeSound.play()
				await get_tree().create_timer(0.9).timeout
				knifeAnimationNode.visible = false
				enemyHitSound.play()
				undyneAnimationNode.play("hurt")
				await get_tree().create_timer(1).timeout
				undyneAnimationNode.play("undyne")
				await get_tree().create_timer(1).timeout
				attackTargetAnimation.play_backwards()
				attackIndicBar.position.x = -99999
				await get_tree().create_timer(0.5).timeout
				attackProceed()
				return
			
		MenuMode.ENEMY_TURN:
			option0Node.visible = false
			option1Node.visible = false
			option2Node.visible = false
			option3Node.visible = false
			textNode.visible = false;
			if (soulMode == SoulMode.GREEN):
				greenSoulPartsNode.visible = true;
				var dur = 0.1
				if Input.is_action_just_pressed("ui_down") :
					greenSoulRotate = deg_to_rad(270)
				if Input.is_action_just_pressed("ui_up") :
					greenSoulRotate = deg_to_rad(90)
				if Input.is_action_just_pressed("ui_left") :
					greenSoulRotate = deg_to_rad(0)
				if Input.is_action_just_pressed("ui_right") :
					greenSoulRotate = deg_to_rad(180)
		MenuMode.NO_MODE:
			greenSoulPartsNode.visible = false;
			option0Node.visible = false
			option1Node.visible = false
			option2Node.visible = false
			option3Node.visible = false
			textNode.visible = true;
			soulNode.visible = false;
			
			if currentTextI >= currentText.length() && Input.is_action_just_pressed("ui_select") :
				attackNoProceed(0)
		MenuMode.OPTION_MODE:
			greenSoulPartsNode.visible = false;
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
				lastOption = selectedButton
				match selectedButton:
					0:
						enemyHealthBar.visible = true
						menuOptions = [
							"Undyne the Undying"
						]
						menuMode = MenuMode.ITEM
					1:
						menuOptions = [
							"Check"
						]
						menuMode = MenuMode.ITEM
					2:
						menuOptions = [
							food[0].SName,
							food[1].SName,
							food[2].SName,
							food[3].SName,
						]
						menuMode = MenuMode.ITEM
					3:
						menuOptions = [
							"Spare"
						]
						menuMode = MenuMode.ITEM
				selectedButton = 0
				soulNode.position = Vector2(999,999)
				return
					
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
			greenSoulPartsNode.visible = false;
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
				menuMode = MenuMode.OPTION_MODE
				selectedButton = lastOption
				currentTextI = 0
			if Input.is_action_just_pressed("ui_select") :
				menuSelectNode.play()
				menuMode = MenuMode.NO_MODE
				soulNode.visible = false
				if menuOptions[selectedButton] == "Check":
					showText(checkText)
				elif menuOptions[selectedButton] == "Spare":
					attackNoProceed(0)
				elif menuOptions[selectedButton] == "Undyne the Undying":
					attackTargetAnimation.play("in")
					moveIndic = true
					attackIndicBar.position.x = -85.0
					menuMode = MenuMode.ATTACK
				else:
					showText("* Consumed the " + menuOptions[selectedButton])
			soulNode.position = optionPoses[selectedButton]
			return
