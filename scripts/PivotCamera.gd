extends Camera3D

@export var target: Node3D;
@export var pan_sensitivity = 0.01;
@export var zoom_sensitivity = 1.1;
@export var roll_sensitivity = 2;

var is_moving = false;
var relpos: Vector3;
var rot_velocity = 0;

func enable():
	assert(Input.mouse_mode != Input.MOUSE_MODE_CAPTURED,
		"Cannot enable camera controller while something else holds the mouse"
	);
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	is_moving = true;

func disable():
	assert(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED,
		"Mouse capture already broken"
	);
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	is_moving = false;

func toggle():
	if is_moving: disable();
	else: enable();

func rotate_around(axis: Vector3, angle: float):
	relpos = relpos.rotated(axis, angle);
	self.global_rotate(axis, angle);

# Called when the node enters the scene tree for the first time.
func _ready():
	relpos = global_position - target.global_position;
	enable();

func _input(event: InputEvent):
	if event is InputEventKey:
		print_debug("Key press received for {0}".format([event.keycode]))
		if event.keycode == KEY_SHIFT:
			if not event.is_pressed(): toggle();
			elif not event.is_echo(): toggle();
		elif event.keycode == KEY_CAPSLOCK:
			if event.is_pressed() and not event.is_echo(): toggle();
	if !is_moving: return;
	if event is InputEventMouseMotion:
		var rel = event.relative * pan_sensitivity;
		rotate_around(global_transform.basis.y, -rel.x);
		rotate_around(global_transform.basis.x, -rel.y);
	elif event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			relpos /= zoom_sensitivity;
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			relpos *= zoom_sensitivity;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var roll = 0;
	if Input.is_key_label_pressed(KEY_Q): roll += 1;
	if Input.is_key_label_pressed(KEY_E): roll -= 1;
	roll *= roll_sensitivity * delta;
	rotate_around(global_transform.basis.z, roll);
	global_position = target.global_position + relpos;
