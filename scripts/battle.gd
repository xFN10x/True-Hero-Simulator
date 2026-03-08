extends Node2D
class_name BattleManager

static var paused = false

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

var soulNode: CharacterBody2D
var soulTexNode: Sprite2D

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

var boxNode: MarginContainer
# Box Positions Vec4(x,y, width, height)
var defaultPos = Vector4(32, 250, 575, 140)
var spearAtkPos = Vector4(277.5, 201.5, 85, 81)
var redAttack1AtkPos = Vector4(185, 190, 227, 200)
var redAttack2AtkPos = Vector4(285, 300, 75, 90)
var redAttack3AtkPos = Vector4(32, 90, 575, 300)

var page = 0

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
	
	func _to_string() -> String:
		return SName
	
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

var actualNoMode = false 

enum SoulMode {
	GREEN,
	RED,
}
var soulMode = SoulMode.RED
var redSoulTexture = CompressedTexture2D.new()
var redSoulTextureHurt = CompressedTexture2D.new()
var redSoulSplit = CompressedTexture2D.new()
var greenSoulTexture = CompressedTexture2D.new()
var greenSoulTextureHurt = CompressedTexture2D.new()
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
@onready var attackIndicAnimations = $Box/Box/AttackIndic/FadeOutAni
var moveIndic = true

var knifeAnimationNode: AnimatedSprite2D
var knifeSound: AudioStreamPlayer
var enemyHitSound: AudioStreamPlayer

var Bullets: Node

var arrowUpPos:  Vector2
var arrowLeftPos: Vector2
var arrowRightPos: Vector2
var arrowDownPos: Vector2

var canAttack := true

var maxIFrames := 20
var iframes := 0
var godmode := false

var groundSpearPoses = [
	Vector2(299, 345),
	Vector2(321, 345),
	Vector2(344, 345),
]

func setBoxHitBox(size: Vector2) -> void:
	var array = PackedVector2Array()
	var first = Vector2(5, 5)
	var second  = Vector2(size.x - 5, 5)
	var third = Vector2(size.x - 5, size.y - 5)
	var fourth = Vector2(5, size.y - 5)
	array.append(first)
	array.append(second)
	array.append(third)
	array.append(fourth)
	$Box/Box/Body/Shape.polygon = array

func setBoxPosInsta(trans: Vector4) -> void:
	setBoxHitBox(Vector2(trans.z, trans.w))
	boxNode.position = Vector2(trans.x, trans.y)
	boxNode.size = Vector2(trans.z, trans.w)

func setBoxPos(trans: Vector4) -> Signal:
	setBoxHitBox(Vector2(trans.z, trans.w))
	var tweenMoveX = get_tree().create_tween()
	tweenMoveX.tween_property(boxNode, "position", Vector2(trans.x, boxNode.position.y), 0.5).set_trans(Tween.TRANS_LINEAR)
	var tweenSizeX = get_tree().create_tween()
	tweenSizeX.tween_property(boxNode, "size", Vector2(trans.z, boxNode.size.y), 0.5).set_trans(Tween.TRANS_LINEAR)
	
	if trans.z != boxNode.size.x:
		tweenSizeX.play()
	if trans.x != boxNode.position.x:
		tweenMoveX.play()
		
	if tweenMoveX.is_running():
		await tweenMoveX.finished
	if tweenSizeX.is_running():
		await tweenSizeX.finished
		
	var tweenMoveY = get_tree().create_tween()
	tweenMoveY.tween_property(boxNode, "position", Vector2(boxNode.position.x, trans.y), 0.1).set_trans(Tween.TRANS_LINEAR)
	var tweenSizeY = get_tree().create_tween()
	tweenSizeY.tween_property(boxNode, "size", Vector2(boxNode.size.x, trans.w), 0.1).set_trans(Tween.TRANS_LINEAR)
	if trans.w != boxNode.size.y:
		tweenSizeY.play()
	if trans.y != boxNode.position.y:
		tweenMoveY.play()
	if tweenSizeY.is_running():
		await tweenSizeY.finished
	return tweenMoveY.finished
	
func death() -> void:
	paused = true
	AudioServer.set_bus_mute(1, true)
	$BlackOut.visible = true
	$Soul/GreenSoul.visible = false
	soulTexNode.texture = redSoulTexture
	await get_tree().create_timer(0.6).timeout
	soulTexNode.texture = redSoulSplit
	$SndBreak1.play()
	await get_tree().create_timer(1).timeout
	soulTexNode.texture = null
	$SndBreak2.play()
	$Soul/CPUParticles2D.emitting = true
	await get_tree().create_timer(2).timeout
	$GlobalAnimations.play("death")
	
func canNavTo(optionArray: Array, selected: int) -> bool:
	return selected >= 0 && selected + (page * 4) < optionArray.size()

func showText(text: String) -> void:
	currentText = text
	currentTextI = 0

func selectOption() -> void:
	menuMode = 0

func restart() -> void:
	get_tree().reload_current_scene()
	_ready()
	paused = false
	AudioServer.set_bus_mute(1, false)

func spawnHomingArrow():
	var bullet: HomingSpear = preload("res://scripts/bullets/homing_spear.tscn").instantiate()
	bullet.battleManager = self
	bullet.position = NavigationServer2D.region_get_random_point($Box/Box/RandomSpearRegion.get_rid(), 1, true)
	Bullets.add_child(bullet)

var lastGroundArrow: int
func spawnGroundArrow():
	var bullet: GroundSpear = preload("res://scripts/bullets/ground_spear.tscn").instantiate()
	bullet.battleManager = self
	var rand = randi_range(0,2)
	if rand == lastGroundArrow:
		while rand == lastGroundArrow:
			rand = randi_range(0,2)
	bullet.position = groundSpearPoses[rand]
	Bullets.add_child(bullet)
	lastGroundArrow = rand
	
func spawn6Spears():
	var bullet: SixSpear = preload("res://scripts/bullets/6spear.tscn").instantiate()
	bullet.battleManager = self
	bullet.position = soulNode.position
	Bullets.add_child(bullet)

func spawnYellowArrow(speed: int, direction):
	var bullet: YellowArrow = preload("res://scripts/bullets/yellow_bullet.tscn").instantiate()
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

func heal(number: int) -> void:
	var fakeHealth = hp + number
	if fakeHealth > maxHp:
		hp = maxHp
	else:
		hp = fakeHealth

func damage(number: int) -> void:
	if  iframes > 0: return
	iframes = maxIFrames
	if (hp - number) <= 0:
		iframes = 100
		death();
		return
	if not godmode:
		hp -= number
	$SndHurt1.play()
	$Soul/GreenSoul.visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	redSoulTexture.load_path = "res://.godot/imported/red_soul_normal.png-4f89669b8b9113871863587930ef3923.ctex"
	greenSoulTexture.load_path = "res://.godot/imported/green_soul_normal.png-41e0ebc41d7a126f221b5f497a015d17.ctex"
	redSoulSplit.load_path = "res://.godot/imported/broken_sou;.png-25d08bafe0cf88cd027113c867e9e7c8.ctex"

	redSoulTextureHurt.load_path = "res://.godot/imported/red_soul_hurt.png-5d5a25d9159157f8d767869f2fec4428.ctex"
	greenSoulTextureHurt.load_path= "res://.godot/imported/green_soul_hurt.png-2055f311f0ed0817c57d6449da57be9e.ctex"
	
	musicNode = get_node("Music")
	menuMoveNode = get_node("MenuMove")
	menuSelectNode = get_node("MenuSelect")
	textSndNode = get_node("TextSnd")
	
	soulNode = get_node("Soul")
	soulTexNode = $Soul/SoulTex
	
	fightNode = get_node("Fight")
	actNode = get_node("Act")
	itemNode = get_node("Item")
	mercyNode = get_node("Mercy")
	
	undyneAnimationNode = get_node("Undyne/BodyAnimation")
	undyneEyeAnimationNode = get_node("Undyne/EyeGlintAnimation")
	undyneAnimationNode.play("undyne")
	undyneEyeAnimationNode.play("eye")
	$Undyne/OtherAnimations.play("undyne")
	
	textNode = get_node("Box/Box/MainText")
	
	option0Node = get_node("Box/Box/Options/0")
	option1Node = get_node("Box/Box/Options/1")
	option2Node = get_node("Box/Box/Options/2")
	option3Node = get_node("Box/Box/Options/3")
	
	hpBarNode = get_node("InfoBar/HPBar")
	hpTextNode = get_node("InfoBar/HPText")

	boxNode = get_node("Box")
	
	greenSoulPartsNode = get_node("Soul/GreenSoul")
	greenSoulShield = get_node("Soul/GreenSoul/Shield")
	
	enemyHealthBar = get_node("Box/Box/Options/0/HPBar")
	enemyHealthBar.max_value = enemyMaxHealth
	enemyHealthBar.value = enemyHealth
	enemyHealthBar.visible = false

	attackIndicBar = get_node("Box/Box/AttackIndic")
	attackIndicBar.play()
	attackTargetAnimation = get_node("Box/Target/TargetAnimation")

	knifeAnimationNode = get_node("Undyne/KnifeAnimation")
	knifeSound = get_node("Attack")
	enemyHitSound = get_node("Damage")

	Bullets = get_node("Bullets")

	arrowUpPos = Vector2(soulNode.position.x, -80)
	arrowLeftPos = Vector2(-16, soulNode.position.y)
	arrowRightPos = Vector2(640 + 16, soulNode.position.y)
	arrowDownPos = Vector2(soulNode.position.x, 640 - 80)

	$HealthBar/Bar.max_value = enemyMaxHealth
	$HealthBar/Bar.value = enemyMaxHealth

	setBoxPosInsta(defaultPos)
	musicNode.play()
	
	YellowArrow.DUPath = $"Box/D>U"
	YellowArrow.UDPath = $"Box/U>D"
	YellowArrow.RLPath = $"Box/R>L"
	YellowArrow.LRPath = $"Box/L>R"

func endAttack() -> void:
	actualNoMode = true
	menuMode = MenuMode.NO_MODE;
	for node in Bullets.get_children():
		node.remove()
	currentText = ""
	textNode.text = ""
	await setBoxPos(defaultPos)
	menuMode = MenuMode.OPTION_MODE;
	showText(defaultText)
	actualNoMode = false
	
var mainSoulMode

func redsoul(boxPos: Vector4i) -> void:
	soulMode = SoulMode.RED
	soulNode.position = Vector2(boxPos.x + (boxPos.z / 2), boxPos.y + (boxPos.w / 2))
	soulNode.visible = true
	mainSoulMode = SoulMode.RED

func greensoul() -> void:
	if paused: return
	$GlobalAnimations.play("fade")
	await setBoxPos(spearAtkPos)
	soulMode = SoulMode.GREEN
	soulNode.position = greenSoulPos
	soulNode.visible = true
	mainSoulMode = SoulMode.GREEN

var turn = 0

func changeSoul() -> void:
	if soulMode == SoulMode.GREEN:
		soulMode = SoulMode.RED
	else:
		soulMode = SoulMode.GREEN

func spearChange() -> void:
	$Undyne/OtherAnimations.play("spear_change")
	await $Undyne/OtherAnimations.animation_finished
	$Undyne/OtherAnimations.play("undyne")
	$Undyne/OtherAnimations.seek(undyneAnimationNode.current_animation_position)

# https://jcoxeye.neocities.org/utu-guide
func attack() -> void:
	menuMode = MenuMode.ENEMY_TURN
	turn += 1
	"""
		await setBoxPos(spearAtkPos)
			soulMode = SoulMode.GREEN
			soulNode.position = greenSoulPos
			soulNode.visible = true
			$GlobalAnimations.play("fade")
			
			var dur2 = 0.25
			
			
			var dur3 = 0.15
			var spe = 27
			
			for i2 in range(4):
				for i in range(3):
					spawnArrow(spe, ArrowBullet.Direction.DOWN)
					await get_tree().create_timer(dur3).timeout
				await get_tree().create_timer(dur2).timeout
				spawnArrow(spe + 3, ArrowBullet.Direction.RIGHT)
				await get_tree().create_timer(dur2).timeout
				for i in range(3):
					spawnArrow(spe, ArrowBullet.Direction.DOWN)
					await get_tree().create_timer(dur3).timeout
				await get_tree().create_timer(dur2).timeout
				spawnArrow(spe + 3, ArrowBullet.Direction.LEFT)
				await get_tree().create_timer(dur2).timeout
			$GlobalAnimations.play_backwards("fade")
			await get_tree().create_timer(1).timeout
			
			endAttack()
	"""
	match turn:
		# test attack
		0:
			await setBoxPos(redAttack3AtkPos) 
			redsoul(redAttack3AtkPos)
		1:
			await greensoul()
			
			spawnArrow(5, ArrowBullet.Direction.DOWN)
			await get_tree().create_timer(0.7).timeout
			spawnArrow(5, ArrowBullet.Direction.DOWN)
			await get_tree().create_timer(0.7).timeout
			spawnArrow(5, ArrowBullet.Direction.DOWN)
			await get_tree().create_timer(1.5).timeout
			var dur2 = 0.3
			var spe = 15
			
			spawnArrow(spe, ArrowBullet.Direction.RIGHT)
			await get_tree().create_timer(dur2).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.UP)
			await get_tree().create_timer(dur2).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.LEFT)
			await get_tree().create_timer(dur2).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.DOWN)
			await get_tree().create_timer(dur2).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.LEFT)
			await get_tree().create_timer(dur2).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.UP)
			await get_tree().create_timer(dur2).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.RIGHT)
			await get_tree().create_timer(dur2).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.UP)
			await get_tree().create_timer(dur2).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.LEFT)
			await get_tree().create_timer(dur2).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.DOWN)
		2:
			await greensoul()
			await get_tree().create_timer(1).timeout
			
			var dur = 0.25
			var spe = 13
			spawnArrow(spe, ArrowBullet.Direction.RIGHT)
			await get_tree().create_timer(dur).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.LEFT)
			await get_tree().create_timer(dur).timeout
			
			for i in range(2):
				spawnArrow(spe, ArrowBullet.Direction.RIGHT)
				await get_tree().create_timer(dur - 0.1).timeout
			
			for i in range(2):
				spawnArrow(spe, ArrowBullet.Direction.LEFT)
				await get_tree().create_timer(dur).timeout
				
			spawnArrow(spe, ArrowBullet.Direction.RIGHT)
			await get_tree().create_timer(dur).timeout
			
			for i in range(2):
				spawnArrow(spe, ArrowBullet.Direction.LEFT)
				await get_tree().create_timer(dur - 0.1).timeout
			pass
			
			spawnArrow(spe, ArrowBullet.Direction.RIGHT)
			await get_tree().create_timer(dur).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.LEFT)
			await get_tree().create_timer(dur).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.RIGHT)
			await get_tree().create_timer(dur).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.LEFT)
			await get_tree().create_timer(dur).timeout
			
			spawnArrow(spe, ArrowBullet.Direction.RIGHT)
			await get_tree().create_timer(dur).timeout
		3:
			await greensoul()
			
			var spe = 3
			for i in range(18):
				var di = Arrow.Direction.values()[randi_range(0, Arrow.Direction.values().size() -1 )]
				spawnArrow(spe, di)
				await get_tree().create_timer(randf_range(0.3, 0.5)).timeout
			await get_tree().create_timer(spe * (spe /2)).timeout
			spearChange()
		4:
			redsoul(redAttack1AtkPos) 
			await setBoxPos(redAttack1AtkPos) 
			for i in range(3*8):
				spawnHomingArrow()
				await get_tree().create_timer(.33333).timeout
			await get_tree().create_timer(1).timeout
		5:
			await setBoxPos(redAttack2AtkPos) 
			redsoul(redAttack2AtkPos)
			for i in range(6*2):
				spawnGroundArrow()
				await get_tree().create_timer(.5).timeout
			spearChange()
			await get_tree().create_timer(2).timeout
		6:
			await greensoul()
			var vertSpeed = 8
			var horiSpeed = 15
			
			spawnArrow(vertSpeed, Arrow.Direction.DOWN)
			await get_tree().create_timer(.15).timeout
			spawnArrow(horiSpeed, Arrow.Direction.LEFT)
			await get_tree().create_timer(.4).timeout
			spawnArrow(vertSpeed, Arrow.Direction.UP)
			await get_tree().create_timer(.15).timeout
			spawnArrow(horiSpeed, Arrow.Direction.RIGHT)
			
			await get_tree().create_timer(.6).timeout
			spawnArrow(horiSpeed - 4, Arrow.Direction.LEFT)
			spawnArrow(vertSpeed - 4, Arrow.Direction.DOWN)
			await get_tree().create_timer(.3).timeout
			spawnArrow(horiSpeed - 4, Arrow.Direction.RIGHT)
			spawnArrow(vertSpeed - 4, Arrow.Direction.UP)
			await get_tree().create_timer(.3).timeout
			spawnArrow(horiSpeed - 6, Arrow.Direction.LEFT)
			await get_tree().create_timer(1).timeout
		7:
			await greensoul()
			var dur2 = 0.2
			var dur3 = 0.1
			var spe = 32
			
			spawnArrow(spe - 21, ArrowBullet.Direction.RIGHT)
			for i in range(4):
				spawnArrow(spe, ArrowBullet.Direction.DOWN)
				await get_tree().create_timer(dur3).timeout
			await get_tree().create_timer(dur2).timeout
			
			spawnArrow(spe - 21, ArrowBullet.Direction.LEFT)
			for i in range(4):
				spawnArrow(spe, ArrowBullet.Direction.DOWN)
				await get_tree().create_timer(dur3).timeout
			await get_tree().create_timer(dur2).timeout
			
			spawnArrow(spe - 18, ArrowBullet.Direction.RIGHT)
			for i in range(3):
				spawnArrow(spe, ArrowBullet.Direction.DOWN)
				await get_tree().create_timer(dur3).timeout
			await get_tree().create_timer(dur2).timeout
			
			spawnArrow(spe - 18, ArrowBullet.Direction.LEFT)
			for i in range(3):
				spawnArrow(spe, ArrowBullet.Direction.DOWN)
				await get_tree().create_timer(dur3).timeout
			await get_tree().create_timer(dur2).timeout
			
			for i in range(3):
				spawnArrow(spe, ArrowBullet.Direction.DOWN)
				await get_tree().create_timer(dur3).timeout
			await get_tree().create_timer(dur2).timeout
		8:
			await greensoul()
			var speed = 10
			for i in range(4):
				spawnArrow(speed, Arrow.Direction.LEFT)
				await get_tree().create_timer(.3).timeout
				spawnArrow(speed, Arrow.Direction.DOWN)
				await get_tree().create_timer(.3).timeout
				
			for i in range(4):
				spawnYellowArrow(speed, Arrow.Direction.LEFT)
				await get_tree().create_timer(.3).timeout
				spawnYellowArrow(speed, Arrow.Direction.DOWN)
				await get_tree().create_timer(.3).timeout
			await get_tree().create_timer(1).timeout
			spearChange()
			await get_tree().create_timer(2).timeout
		9, 10:
			await setBoxPos(redAttack3AtkPos) 
			redsoul(redAttack3AtkPos)
			for i in range(8):
				spawn6Spears()
				await get_tree().create_timer(1).timeout
			
			await get_tree().create_timer(1).timeout
		10:
			spearChange()
			await get_tree().create_timer(2).timeout
	await get_tree().create_timer(1).timeout
	if paused: return
	if mainSoulMode == SoulMode.GREEN: $GlobalAnimations.play_backwards("fade")
	endAttack()
	return

func _process(delta: float) -> void:
	if paused:
		return
	if Input.is_action_just_pressed("godmod"):
		if not godmode:
			godmode = true
			$MusOhyes.play()
		else:
			godmode = false
			$SndSaber3.play()
	if Input.is_action_just_pressed("kill") :
		damage(9999)
	if Input.is_action_just_pressed("skipturn") :
		turn += 1
	if Input.is_action_just_pressed("lastturn") :
		if not turn <= -1:
			turn -= 1
	if Input.is_action_just_pressed("song1"):
		musicNode.stream = AudioStreamMP3.load_from_file("res://audio/From_Now_On_Battle_2_KLICKAUD.mp3")
		musicNode.stop()
		musicNode.play()
	$Box/Box/TurnCounter.text = "Turn %s" % turn 
	iframes -= 1;
	greenSoulShield.rotation = lerp_angle(greenSoulShield.rotation, greenSoulRotate, 0.8)
	if iframes > 0:
		match soulMode:
			SoulMode.RED:
				soulTexNode.texture = redSoulTextureHurt
			SoulMode.GREEN:
				soulTexNode.texture = greenSoulTextureHurt
	else:
		match soulMode:
			SoulMode.RED:
				soulTexNode.texture = redSoulTexture
			SoulMode.GREEN:
				soulTexNode.texture = greenSoulTexture
	hpBarNode.value = hp
	hpTextNode.text = "%s / %s" % [hp, maxHp]
	#print(selectedButton)
	if currentTextI < currentText.length() && (menuMode == MenuMode.OPTION_MODE || menuMode == MenuMode.NO_MODE):
		if currentTextI != currentText.length() && menuMode == MenuMode.NO_MODE && Input.is_action_just_pressed("ui_cancel") :
			currentTextI = currentText.length()
				
		currentTextI += 1
		textNode.text = currentText.substr(0,currentTextI)
		if not textNode.text.substr(textNode.text.length()-1, 1) == " ":
			#print(textNode.text.substr(textNode.text.length()-1, 1))
			textSndNode.play()
	attackIndicBar.visible = menuMode == MenuMode.ATTACK
	$Box/Box/TurnCounter.visible = menuMode != MenuMode.ENEMY_TURN
	match menuMode:
		MenuMode.ATTACK:
			attackIndicBar.visible = true
			greenSoulPartsNode.visible = false;
			option0Node.visible = false
			option1Node.visible = false
			option2Node.visible = false
			option3Node.visible = false
			textNode.visible = false;
			#soulNode.visible = false;
			if moveIndic:
				attackIndicBar.position.x += 14
			if attackIndicBar.position.x >= 400 && canAttack:
				canAttack = false
				attackIndicAnimations.play("out")
				$Undyne/MissText.visible = true
				await get_tree().create_timer(0.8).timeout
				attackTargetAnimation.play_backwards()
				attackIndicAnimations.play("RESET")
				$Undyne/MissText.visible = false
				attack()
				return;
			
			if Input.is_action_just_pressed("ui_select") && canAttack :
				moveIndic = false
				canAttack = false
				knifeAnimationNode.visible = true
				knifeAnimationNode.play()
				knifeSound.play()
				var random = randi_range(-20, 20)
				var damage = 1800 + -abs((320 - attackIndicBar.position.x) * 5) + random
				if (Input.is_action_pressed("secret1")):
					damage += 10000
				$HealthBar/DamageNumbers.text = str(roundi(damage))
				enemyHealth -= damage
				var barTween = get_tree().create_tween()
				barTween.tween_property($HealthBar/Bar, "value", enemyHealth, 1).set_trans(Tween.TRANS_LINEAR)
				await get_tree().create_timer(0.8).timeout
				knifeAnimationNode.visible = false
				enemyHitSound.play()
				undyneAnimationNode.play("hurt")
				$Undyne/OtherAnimations.stop()
				$HealthBar.visible = true
				barTween.play()
				await get_tree().create_timer(.7).timeout
				undyneAnimationNode.play("undyne")
				$Undyne/OtherAnimations.play("undyne")
				await get_tree().create_timer(1).timeout
				$HealthBar.visible = false
				attackTargetAnimation.play_backwards()
				attackIndicBar.position.x = -99999
				attack()
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
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = true
					greenSoulRotate = deg_to_rad(270)
					await get_tree().create_timer(.06).timeout
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = false
				if Input.is_action_just_pressed("ui_up") :
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = true
					greenSoulRotate = deg_to_rad(90)
					await get_tree().create_timer(.06).timeout
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = false
				if Input.is_action_just_pressed("ui_left") :
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = true
					greenSoulRotate = deg_to_rad(0)
					await get_tree().create_timer(.06).timeout
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = false
				if Input.is_action_just_pressed("ui_right") :
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = true
					greenSoulRotate = deg_to_rad(180)
					await get_tree().create_timer(.06).timeout
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = false
			else:
				#greenSoulPartsNode.visible = false;
				var normal = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") 
				var incorrect = Vector2(sign(normal.x), sign(normal.y)) * 4
				soulNode.move_and_collide(incorrect)
		MenuMode.NO_MODE:
			greenSoulPartsNode.visible = false;
			option0Node.visible = false
			option1Node.visible = false
			option2Node.visible = false
			option3Node.visible = false
			textNode.visible = true;
			soulNode.visible = false;
			
			if not actualNoMode && currentTextI >= currentText.length() && Input.is_action_just_pressed("ui_select") :
				attack()
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
				page = 0
				match selectedButton:
					0:
						enemyHealthBar.visible = true
						menuOptions = [
							"Undyne the Undying"
						]
						menuMode = MenuMode.ITEM
					1:
						enemyHealthBar.visible = false
						menuOptions = [
							"Check"
						]
						menuMode = MenuMode.ITEM
					2:
						if food.is_empty(): return
						enemyHealthBar.visible = false
						menuOptions = food
						menuMode = MenuMode.ITEM
					3:
						enemyHealthBar.visible = false
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
			var offset = page * 4
			greenSoulPartsNode.visible = false;
			soulNode.visible = true;
			option0Node.visible = true
			if canNavTo(menuOptions, 0):
				option0Node.text = "*  " + str(menuOptions[0 + offset])
			else :
				option0Node.text = ""
			option1Node.visible = true
			if canNavTo(menuOptions, 1):
				option1Node.text = "*  " + str(menuOptions[1 + offset])
			else :
				option1Node.text = ""
			option2Node.visible = true
			if canNavTo(menuOptions, 2):
				option2Node.text = "*  " + str(menuOptions[2 + offset])
			else :
				option2Node.text = ""
			option3Node.visible = true
			if canNavTo(menuOptions, 3):
				option3Node.text = "*  " + str(menuOptions[3 + offset])
			else :
				option3Node.text = ""
			textNode.visible = false;
			if canNavTo(menuOptions, selectedButton + 1) && Input.is_action_just_pressed("ui_right") && ((selectedButton != 1  && selectedButton != 3) || menuOptions.size() > (4 + offset)) :
				if (selectedButton + 1 == 2) || (selectedButton + 1 == 4):
					selectedButton = 0
					page += 1;
					menuMoveNode.play()
					return
				selectedButton += 1
				menuMoveNode.play()
				
			if Input.is_action_just_pressed("ui_left") && (page > 0 || (canNavTo(menuOptions, selectedButton - 1) && (selectedButton != 2  && selectedButton != 0))) :
				if (selectedButton - 1 == -1) || (selectedButton - 1 == 1):
					selectedButton = 0
					page -= 1;
					menuMoveNode.play()
					return
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
				return
			if Input.is_action_just_pressed("ui_select") :
				menuSelectNode.play()
				menuMode = MenuMode.NO_MODE
				soulNode.visible = false
				if str(menuOptions[selectedButton + offset]) == "Check":
					showText(checkText)
				elif str(menuOptions[selectedButton + offset]) == "Spare":
					attack()
				elif str(menuOptions[selectedButton + offset]) == "Undyne the Undying":
					attackTargetAnimation.play("in")
					canAttack = false
					moveIndic = true
					attackIndicBar.position.x = -85.0
					menuMode = MenuMode.ATTACK
					await get_tree().create_timer(0.3).timeout
					canAttack = true
					enemyHealthBar.visible = false
				else:
					print(food)
					$SndHealC.play()
					heal(food[food.find(menuOptions[selectedButton + offset])].Health)
					showText("* You ate the " + menuOptions[selectedButton + offset].Name)
					page = 0
					food.remove_at(food.find(menuOptions[selectedButton + offset]))
					return
			soulNode.position = optionPoses[selectedButton]
			return
