class_name FreeLookCamera3D extends Camera3D

@export_group("Controls")
@export var move_down_key: Key = Key.KEY_Q
@export var move_up_key: Key = Key.KEY_E
@export var move_forward_key: Key = Key.KEY_W
@export var move_back_key: Key = Key.KEY_S
@export var move_left_key: Key = Key.KEY_A
@export var move_right_key: Key = Key.KEY_D

@export_group("Settings")
@export var sensitivity: float = 0.002
@export var speed: float = 5.0
@export var zoom_speed: float

const MIN_PITCH = deg_to_rad(-89)
const MAX_PITCH = deg_to_rad(89)

var target_position: Vector3
var yaw: float
var pitch: float

func _ready() -> void:
	target_position = global_position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		# event.relative содержит "сырое" движение мыши за этот кадр
		# Оно не сглажено и реагирует мгновенно
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		
		pitch = clampf(pitch, MIN_PITCH, MAX_PITCH)
		
		# Принудительно обновляем трансформацию сразу после ввода, 
		# чтобы не ждать следующего кадра _process (уменьшает задержку)
		_update_camera_transform()

func _process(delta: float) -> void:
	_handle_movement_input(delta)
	_update_camera_transform()

func _handle_movement_input(delta: float):
	var local_up: Vector3 = global_transform.basis.y.normalized()
	var local_forward: Vector3 = - global_transform.basis.z.normalized()
	var local_right: Vector3 = global_transform.basis.x.normalized()

	var vertical := Vector3()
	var horizontal := Vector3()

	if Input.is_key_pressed(move_up_key):
		vertical += local_up * speed * delta
	
	if Input.is_key_pressed(move_down_key):
		vertical -= local_up * speed * delta
	
	if Input.is_key_pressed(move_forward_key):
		horizontal += local_forward * speed * delta

	if Input.is_key_pressed(move_back_key):
		horizontal -= local_forward * speed * delta

	if Input.is_key_pressed(move_right_key):
		horizontal += local_right * speed * delta

	if Input.is_key_pressed(move_left_key):
		horizontal -= local_right * speed * delta
	
	target_position += vertical + horizontal

func _handle_mouse_input():
	var mouse_relative := Input.get_last_mouse_velocity()

	yaw -= mouse_relative.x * sensitivity * 0.01
	pitch -= mouse_relative.y * sensitivity * 0.01

	pitch = clampf(pitch, MIN_PITCH, MAX_PITCH)

func _update_camera_transform():
	global_transform.origin = target_position

	# Создаем базис из углов yaw и pitch
	# Сначала поворачиваем вокруг Y (yaw), потом вокруг X (pitch)
	var bas = Basis()
	bas = bas.rotated(Vector3.UP, yaw)
	bas = bas.rotated(bas.x, pitch) # Важно: вращаем вокруг локальной оси X после первого поворота
	
	global_transform.basis = bas
