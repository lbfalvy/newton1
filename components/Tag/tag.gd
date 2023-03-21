extends Control

@export var title = "";
@export var subtitle = "";
@export var target = NodePath("..");
@export var camera: Camera3D;
@export var subject: Node3D;
@export var offscreen_guide_radious = 400.0;
@export var color: Color:
	get: return color;
	set(new):
		color = new;
		propagate_color();
		
@onready var target_node: Node3D = get_node(target);
@onready var arrow: Polygon2D = get_node("Arrow");
@onready var marker: Control = get_node("Marker");
@onready var label: Label = get_node("Marker/Label");
var on_screen = false;
var display_position = Vector2.INF;

func _ready():
	propagate_color();

func _process(_delta):
	var real_pos = target_node.global_position
	if is_point_visible(real_pos): render_tag(real_pos)
	else: render_offscreen_guide(real_pos)

func is_point_visible(real_pos: Vector3) -> bool:
	if camera.is_position_behind(real_pos): return false;
	var point = camera.unproject_position(real_pos);
	return get_viewport_rect().has_point(point);

func render_offscreen_guide(real_pos: Vector3):
	var camspace_pos = camera.to_local(real_pos);
	var projected = Vector2(-camspace_pos.x, camspace_pos.y);
	arrow.visible = true;
	marker.visible = false;
	var pos = projected.normalized() * offscreen_guide_radious * -1;
	arrow.rotation = pos.angle() + (PI / 2);
	arrow.position = get_viewport().size / 2 + Vector2i(pos);

func render_tag(real_pos: Vector3):
	var screen_pos = camera.unproject_position(real_pos);
	marker.visible = true;
	arrow.visible = false;
	label.text = build_string();
	marker.position = screen_pos;

func build_string() -> String:
	var distance = subject.global_position.distance_to(target_node.global_position);
	var distance_str = distance_to_string(distance);
	var text = "⨯\n" + title + "\n";
	if subtitle != "": text += subtitle + "\n"
	return text + distance_str
	
func distance_to_string(distance: float) -> String:
	var unit: String;
	if distance > 1_000_000: distance /= 1_000_000; unit = " Mm";
	elif distance > 1000: distance /= 1000; unit = " km";
	else: unit = " m";
	return String.num(distance, 2).pad_decimals(2) + unit;

func propagate_color():
	if arrow: arrow.color = color;
	if label: label.add_theme_color_override("font_color", color);
