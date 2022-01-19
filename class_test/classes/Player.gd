extends KinematicBody2D
class_name Player

export (Texture) var sprite
export (Vector2) var sprite_size
var tex = TextureRect.new()

export(Vector2)var col_size=Vector2(16,16)
export(Vector2)var collision_position=Vector2(0,0)


var movement = Vector2.ZERO
export(float)var friction = 0.5
export(int)var gravity = 512
export(int)var jump_force = 256
export(int)var move_speed=256
export(int)var jump_on_air=1
export(int)var wall_bounce=128
var air_jumps_left = 1
export(String, FILE)var jump_sfx="res://GameSFX/Blops/Retro Blop 22.wav"
export(float)var sfx_speed = 1.0
var col = CollisionShape2D.new()
var tween = Tween.new()
func _ready():
	add_child(tween)
	col.shape = RectangleShape2D.new()
	col.shape.extents = col_size
	col.position = collision_position+sprite_size/2
	add_child(col)
	add_child(tex)
	tex.expand = true
	tex.texture = sprite
	tex.rect_min_size = sprite_size
	tex.rect_size = sprite_size
	
func _process(delta):
	var dir = Vector2.ZERO
	
	if is_on_floor():movement.y = 0
	
	if Input.is_action_pressed("left"):dir.x-=move_speed
	if Input.is_action_pressed("right"):dir.x+=move_speed
	
	if Input.is_action_just_pressed("jump") && (is_on_floor()||air_jumps_left>0||get_wall()!=0):
		play_sound(jump_sfx,sfx_speed)
		tween.interpolate_property(tex,"rect_scale",Vector2(1,0.75),Vector2(1,1),0.25,Tween.TRANS_CIRC)
		tween.interpolate_property(tex,"rect_position",Vector2(0,0-sprite_size.y/4),Vector2(0,0),0.25,Tween.TRANS_CIRC)
		tween.start()
		movement.y=-jump_force
		if dir.x!=0:movement.x=dir.x*0.5
		else:movement.x*=0.5
		if !is_on_floor()&&get_wall()!=0:movement.x = wall_bounce*get_wall()
		else:air_jumps_left-=int(!is_on_floor())
		
	if is_on_floor():air_jumps_left = jump_on_air
	
	dir.y+= gravity
	movement+=dir*delta
	movement.x-=movement.x*(friction+int(is_on_floor()&&(sign(dir.x)!=sign(movement.x)||dir.x==0))*10)*delta
	
# warning-ignore:return_value_discarded
	move_and_slide(movement,Vector2.UP)
func get_wall():
	return (
		int(get_world_2d().direct_space_state.intersect_ray(global_position+Vector2(2,sprite_size.y/2),global_position+Vector2(-4,sprite_size.y/2),[self]).size()!=0)-
		int(get_world_2d().direct_space_state.intersect_ray(global_position+Vector2(sprite_size.x-2,sprite_size.y/2),global_position+Vector2(sprite_size.x+4,sprite_size.y/2),[self]).size()!=0)
		)
func play_sound(sound,speed=1.0):
	var sfx = AudioStreamPlayer.new()
	add_child(sfx)
	sfx.stream = load(sound)
	sfx.pitch_scale=speed
	sfx.play()
	sfx.connect("finished",self,'remove_object',[sfx])
func remove_object(obj):
	if obj!=null:
		obj.queue_free()
