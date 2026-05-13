extends Node2D

const MAX_PARTICLES: int = 240
const MAX_TRAILS: int = 140
const MAX_RINGS: int = 18
const CURSOR_IDLE_SECONDS: float = 2.2
const HOLD_SECONDS: float = 1.0

const PALETTE: Array[Color] = [
	Color(0.25, 0.95, 1.0),
	Color(1.0, 0.36, 0.78),
	Color(1.0, 0.82, 0.20),
	Color(0.43, 1.0, 0.48),
	Color(0.66, 0.47, 1.0),
	Color(1.0, 0.52, 0.30)
]

var particles: Array[Dictionary] = []
var trails: Array[Dictionary] = []
var rings: Array[Dictionary] = []

var focus_pos: Vector2 = Vector2.ZERO
var focus_target: Vector2 = Vector2.ZERO
var focus_timer: float = 0.0
var idle_time: float = 0.0
var mouse_down: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var held_keys: Dictionary = {}
var time: float = 0.0
var density: float = 1.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var size: Vector2 = _screen_size()
	focus_pos = size * 0.5
	focus_target = _random_screen_point(0.18)
	last_mouse_pos = get_viewport().get_mouse_position()
	set_process_input(true)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		_handle_key(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)


func _process(delta: float) -> void:
	time += delta
	idle_time += delta
	_update_cursor()
	_update_density()
	_update_focus(delta)
	_update_holds()

	if mouse_down:
		_emit_trail(get_viewport().get_mouse_position(), 1.15)

	_update_effects(delta)
	queue_redraw()


func _draw() -> void:
	var size: Vector2 = _screen_size()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.018, 0.040))
	_draw_background(size)
	_draw_trails()
	_draw_particles()
	_draw_rings()


func _handle_key(event: InputEventKey) -> void:
	if event.pressed and event.ctrl_pressed and event.alt_pressed and event.keycode == KEY_Q:
		get_tree().quit()
		return

	var code: int = event.keycode
	if event.pressed:
		if not held_keys.has(code):
			held_keys[code] = {"age": 0.0, "fired": false}
			_emit_key_burst(code)
		elif not event.echo:
			_emit_key_burst(code)
	else:
		held_keys.erase(code)


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	idle_time = 0.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var speed: float = event.relative.length()
	var strength: float = clampf(speed / 38.0, 0.35, 1.6)
	last_mouse_pos = event.position
	_emit_trail(event.position, strength)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT and event.button_index != MOUSE_BUTTON_RIGHT:
		return

	idle_time = 0.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_down = event.pressed
	if event.pressed:
		_emit_click_burst(event.position)


func _update_cursor() -> void:
	if idle_time > CURSOR_IDLE_SECONDS:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _update_density() -> void:
	var fps: float = Engine.get_frames_per_second()
	if fps > 58:
		density = minf(1.0, density + 0.015)
	elif fps > 0 and fps < 42:
		density = maxf(0.45, density - 0.035)


func _update_focus(delta: float) -> void:
	focus_timer -= delta
	if focus_timer <= 0.0 or focus_pos.distance_to(focus_target) < 24.0:
		focus_target = _random_screen_point(0.16)
		focus_timer = rng.randf_range(3.0, 5.5)

	var sway: Vector2 = Vector2(sin(time * 0.7), cos(time * 0.53)) * 18.0
	focus_pos = focus_pos.lerp(focus_target + sway, 0.018)


func _update_holds() -> void:
	for code in held_keys.keys():
		var hold: Dictionary = held_keys[code]
		hold["age"] += get_process_delta_time()
		if hold["age"] >= HOLD_SECONDS and not hold["fired"]:
			hold["fired"] = true
			_emit_hold_bloom()
		held_keys[code] = hold


func _update_effects(delta: float) -> void:
	for item in particles:
		item["age"] += delta
		item["pos"] += item["vel"] * delta
		item["vel"] *= pow(0.18, delta)
		item["radius"] += item["grow"] * delta
	for item in trails:
		item["age"] += delta
		item["pos"] += item["vel"] * delta
	for item in rings:
		item["age"] += delta

	particles = particles.filter(func(item): return item["age"] < item["life"])
	trails = trails.filter(func(item): return item["age"] < item["life"])
	rings = rings.filter(func(item): return item["age"] < item["life"])
	_trim_oldest(particles, int(MAX_PARTICLES * density))
	_trim_oldest(trails, int(MAX_TRAILS * density))
	_trim_oldest(rings, MAX_RINGS)


func _emit_key_burst(code: int) -> void:
	var special: bool = code == KEY_SPACE or code == KEY_ENTER or code == KEY_BACKSPACE
	var pos: Vector2 = _keyboard_effect_position()
	var count: int = 10 if special else 6
	var base_radius: float = 16.0 if special else 10.0
	var power: float = 170.0 if special else 105.0

	for i in range(int(count * density)):
		_add_particle(pos + _random_unit() * rng.randf_range(0.0, 28.0), power, base_radius, 0.9)
	_add_ring(pos, 150.0 if special else 82.0, 0.78, _pick_color())


func _emit_click_burst(pos: Vector2) -> void:
	for i in range(int(14 * density)):
		_add_particle(pos, 190.0, 13.0, 0.82)
	_add_ring(pos, 125.0, 0.62, _pick_color())


func _emit_trail(pos: Vector2, strength: float) -> void:
	if rng.randf() > density:
		return
	var color: Color = _pick_color()
	trails.append({
		"pos": pos + _random_unit() * rng.randf_range(0.0, 8.0),
		"vel": -_random_unit() * rng.randf_range(6.0, 20.0),
		"age": 0.0,
		"life": rng.randf_range(0.35, 0.7),
		"radius": rng.randf_range(5.0, 13.0) * strength,
		"color": color
	})
	_trim_oldest(trails, int(MAX_TRAILS * density))


func _emit_hold_bloom() -> void:
	var size: Vector2 = _screen_size()
	var pos: Vector2 = focus_pos.lerp(_random_screen_point(0.12), 0.35)
	_add_ring(pos, maxf(size.x, size.y) * 0.62, 1.25, Color(0.9, 0.9, 1.0))
	for i in range(int(34 * density)):
		_add_particle(pos, 270.0, 18.0, 1.15)


func _add_particle(pos: Vector2, power: float, base_radius: float, life: float) -> void:
	var color: Color = _pick_color()
	var dir: Vector2 = _random_unit()
	particles.append({
		"pos": pos,
		"vel": dir * rng.randf_range(power * 0.25, power),
		"age": 0.0,
		"life": rng.randf_range(life * 0.65, life * 1.2),
		"radius": rng.randf_range(base_radius * 0.45, base_radius),
		"grow": rng.randf_range(-5.0, 8.0),
		"color": color
	})
	_trim_oldest(particles, int(MAX_PARTICLES * density))


func _add_ring(pos: Vector2, max_radius: float, life: float, color: Color) -> void:
	rings.append({
		"pos": pos,
		"age": 0.0,
		"life": life,
		"max_radius": max_radius,
		"color": color
	})
	_trim_oldest(rings, MAX_RINGS)


func _draw_background(size: Vector2) -> void:
	var center: Vector2 = size * 0.5
	for i in range(4):
		var color: Color = PALETTE[i]
		var alpha: float = 0.06 + 0.025 * sin(time * 0.7 + i)
		var radius: float = size.y * (0.34 + i * 0.12)
		var pos: Vector2 = center + Vector2(
			sin(time * (0.18 + i * 0.035) + i * 1.7),
			cos(time * (0.14 + i * 0.04) + i)
		) * Vector2(size.x * 0.28, size.y * 0.18)
		draw_circle(pos, radius, _with_alpha(color, alpha))

	for band in range(3):
		var points: PackedVector2Array = PackedVector2Array()
		var y_base: float = size.y * (0.22 + band * 0.23)
		for step in range(10):
			var x: float = size.x * step / 9.0
			var y: float = y_base + sin(time * 0.55 + step * 0.75 + band * 1.8) * 34.0
			points.append(Vector2(x, y))
		draw_polyline(points, _with_alpha(PALETTE[(band + 2) % PALETTE.size()], 0.16), 7.0, true)


func _draw_trails() -> void:
	for item in trails:
		var pos: Vector2 = item["pos"]
		var radius: float = item["radius"]
		var color: Color = item["color"]
		var t: float = float(item["age"]) / float(item["life"])
		var alpha: float = (1.0 - t) * 0.42
		draw_circle(pos, radius * (1.0 + t), _with_alpha(color, alpha * 0.35))
		draw_circle(pos, radius * 0.42, _with_alpha(color.lightened(0.35), alpha))


func _draw_particles() -> void:
	for item in particles:
		var pos: Vector2 = item["pos"]
		var color: Color = item["color"]
		var t: float = float(item["age"]) / float(item["life"])
		var alpha: float = (1.0 - t) * 0.62
		var radius: float = maxf(1.0, float(item["radius"]) * (1.0 - t * 0.35))
		draw_circle(pos, radius * 2.6, _with_alpha(color, alpha * 0.16))
		draw_circle(pos, radius, _with_alpha(color.lightened(0.3), alpha))


func _draw_rings() -> void:
	for item in rings:
		var pos: Vector2 = item["pos"]
		var color: Color = item["color"]
		var t: float = float(item["age"]) / float(item["life"])
		var radius: float = float(item["max_radius"]) * _ease_out_cubic(t)
		var alpha: float = (1.0 - t) * 0.55
		draw_arc(pos, radius, 0.0, TAU, 72, _with_alpha(color, alpha), maxf(2.0, 9.0 * (1.0 - t)), true)


func _keyboard_effect_position() -> Vector2:
	if rng.randf() < 0.18:
		return _random_screen_point(0.08)
	return focus_pos + Vector2(rng.randf_range(-90.0, 90.0), rng.randf_range(-65.0, 65.0))


func _random_screen_point(margin_ratio: float) -> Vector2:
	var size: Vector2 = _screen_size()
	var margin: float = minf(size.x, size.y) * margin_ratio
	return Vector2(
		rng.randf_range(margin, maxf(margin, size.x - margin)),
		rng.randf_range(margin, maxf(margin, size.y - margin))
	)


func _screen_size() -> Vector2:
	return get_viewport_rect().size


func _random_unit() -> Vector2:
	var angle: float = rng.randf_range(0.0, TAU)
	return Vector2(cos(angle), sin(angle))


func _pick_color() -> Color:
	return PALETTE[rng.randi_range(0, PALETTE.size() - 1)]


func _with_alpha(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, clampf(alpha, 0.0, 1.0))


func _ease_out_cubic(value: float) -> float:
	return 1.0 - pow(1.0 - clampf(value, 0.0, 1.0), 3.0)


func _trim_oldest(list: Array, limit: int) -> void:
	while list.size() > limit:
		list.pop_front()
