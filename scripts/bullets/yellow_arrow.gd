extends Sprite2D
class_name YellowArrow

var battleManager;
var canDamage = true
var onPath = false
var inverted = false

static var UDPath: Path2D
static var DUPath: Path2D
static var RLPath: Path2D
static var LRPath: Path2D

var following: PathFollow2D

static func reverseDir(dir: Arrow.Direction) -> Arrow.Direction:
	match dir:
		Arrow.Direction.UP:
			return Arrow.Direction.DOWN
		Arrow.Direction.DOWN:
			return Arrow.Direction.UP
		Arrow.Direction.LEFT:
			return Arrow.Direction.RIGHT
	return Arrow.Direction.LEFT

var currentDirection: Arrow.Direction
var speed: int

func _init(dir: Arrow.Direction = Arrow.Direction.DOWN, speed: int = 1, manager = null) -> void:
	currentDirection = dir
	speed = speed
	battleManager = manager

func _ready() -> void:
	rotation_degrees = reverseDir(currentDirection)
	$Area2D/arrow.disabled = true
	$Area2D.body_entered.connect(func (other: Node2D):
		if other.name == "Soul":
			canDamage = false
			battleManager.damage(randi_range(8,14))
			remove()
		)
	$Area2D.area_shape_entered.connect(func (area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
		if not canDamage: return
		if area.name == "ShieldHB":
			canDamage = false
			$Ding.play()
			remove()
		)

func remove() -> void:
	position.x += 9999
	if $Ding.playing:
		await $Ding.finished
	queue_free()

func _process(delta: float) -> void:
	if BattleManager.paused:
		return
	if onPath:
		following.progress += speed * 3
		if following.progress_ratio >= 1:
			$Area2D/arrow.disabled = false
			inverted = true
			onPath = false
			following.queue_free()
	else:
		match (reverseDir(currentDirection) if inverted else currentDirection) :
			Arrow.Direction.UP:
				if !inverted && position.y <= (DUPath.curve.get_point_position(0).y + DUPath.global_position.y):
					onPath = true
					following = PathFollow2D.new()
					var followingRemote = RemoteTransform2D.new()
					followingRemote.update_rotation = false
					followingRemote.update_scale = false
					following.add_child(followingRemote)
					following.loop = false
					DUPath.add_child(following)
					followingRemote.remote_path = get_path()
				position.y += -speed
			Arrow.Direction.DOWN:
				if !inverted && position.y >= (UDPath.curve.get_point_position(0).y + UDPath.global_position.y):
					onPath = true
					following = PathFollow2D.new()
					var followingRemote = RemoteTransform2D.new()
					followingRemote.update_rotation = false
					followingRemote.update_scale = false
					following.add_child(followingRemote)
					following.loop = false
					UDPath.add_child(following)
					followingRemote.remote_path = get_path()
				position.y += speed
			Arrow.Direction.RIGHT:
				if !inverted && position.x <= (LRPath.curve.get_point_position(0).x + LRPath.global_position.x):
					onPath = true
					following = PathFollow2D.new()
					var followingRemote = RemoteTransform2D.new()
					followingRemote.update_rotation = false
					followingRemote.update_scale = false
					following.add_child(followingRemote)
					following.loop = false
					LRPath.add_child(following)
					followingRemote.remote_path = get_path()
				position.x += -speed
			Arrow.Direction.LEFT:
				if !inverted && position.x >= (LRPath.curve.get_point_position(0).x + LRPath.global_position.x):
					onPath = true
					following = PathFollow2D.new()
					var followingRemote = RemoteTransform2D.new()
					followingRemote.update_rotation = false
					followingRemote.update_scale = false
					following.add_child(followingRemote)
					following.loop = false
					LRPath.add_child(following)
					followingRemote.remote_path = get_path()
				position.x += speed
