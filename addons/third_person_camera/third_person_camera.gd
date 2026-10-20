extends Node3D

@onready var camera := %Camera3D

@export_category("Distance")
@export var min_distance := 1.0
@export var target_distance := 1.0
@export var max_distance := 5.0

@export_category("Inputs")
@export var allow_mouse := true
@export var left := ""
@export var right := ""
@export var up := ""
@export var down := ""
@export var zoom_in := ""
@export var zoom_out := ""

@export_category("Settings")
@export_flags_2d_physics var collision_mask := 1 :
	set(value):
		collision_mask = value
		if has_node("%SpringArm3D"):
			%SpringArm3D.collision_mask = collision_mask
@export var sensitivity_h := 2.0
@export var sensitivity_v := 2.0
@export var sensitivity_zoom := 1.0
@export var invert_h := false
@export var invert_v := false
@export var invert_zoom := false
@export var min_x_rotation := -80.0
@export var max_x_rotation := 30.0

func _ready() -> void:
	%SpringArm3D.collision_mask = collision_mask

func _process(delta: float) -> void:
	var cam_input := Vector2.ZERO
	if left and right:
		cam_input.x = Input.get_axis(left, right)
	if up and down:
		cam_input.y = Input.get_axis(down, up)
	if zoom_in and zoom_out:
		var zoom := Input.get_axis(zoom_in, zoom_out) * sensitivity_zoom
		if abs(zoom) > 0:
			var target_length : float = %SpringArm3D.spring_length
			if invert_zoom:
				zoom *= -1
			target_length = %SpringArm3D.spring_length + zoom * sensitivity_zoom
			target_distance = target_length
	
	rotation.y = lerp_angle(rotation.y, rotation.y + cam_input.x * (-1 if invert_h else 1), delta * sensitivity_h)
	rotation.x = lerp_angle(rotation.x, rotation.x + cam_input.y * (-1 if invert_v else 1), delta * sensitivity_v)
	var high := deg_to_rad(max_x_rotation)
	rotation.x = clampf(rotation.x, deg_to_rad(min_x_rotation), high)

	target_distance = clampf(target_distance, min_distance, max_distance)
	var tween := create_tween()
	tween.tween_property(%SpringArm3D, 'spring_length', target_distance, 0.2)

func _input(event: InputEvent) -> void:
	if not allow_mouse:
		return
	if event is InputEventMouseMotion:
		rotation.y += -1.0 * event.relative.x * 0.001 * sensitivity_h * (-1.0 if invert_h else 1.0)
		rotation.x += -1.0 * event.relative.y * 0.001 * sensitivity_v * (-1.0 if invert_v else 1.0)
		var high := deg_to_rad(max_x_rotation)
		rotation.x = clampf(rotation.x, deg_to_rad(min_x_rotation), high)
	elif event is InputEventMouseButton and event.pressed:
		var target_length : float = %SpringArm3D.spring_length
		var inc := 0.0
		match event.button_index:
			MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
				inc = 1.0
			MouseButton.MOUSE_BUTTON_WHEEL_UP:
				inc = -1.0
		if invert_zoom:
			inc *= -1
		target_length = %SpringArm3D.spring_length + inc * sensitivity_zoom
		target_distance = target_length
