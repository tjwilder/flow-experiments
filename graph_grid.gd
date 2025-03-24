extends Node2D


var maxX = 1000.0
var maxY = 1000.0
var dimensions = [30, 20]
var dx = maxX / dimensions[0]
var dy = maxY / dimensions[1]
var flow_grid = []
var flow_add = []
var density_grid = []
var cell_grid = []

@onready var grid_cell = preload("res://grid_cell.tscn")

func cell_coord(pos: Vector2) -> Vector2i:
	return Vector2i(int(pos.x / dx), int(pos.y / dy))

func world_coord(cell_pos: Vector2i) -> Vector2:
	return Vector2(dx * cell_pos[0] + dx / 2, dy * cell_pos[1] + dy / 2)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#var root = get_window()
	#for i in range(dimensions[0]):
		#var row = []
		#var add_row = []
		#var densities = []
		#var cells = []
		#flow_grid.append(row)
		#flow_add.append(add_row)
		#density_grid.append(densities)
		#cell_grid.append(cells)
		#for j in range(dimensions[1]):
			#row.append(Vector2.ZERO)
			#add_row.append(Vector2.ZERO)
			#densities.append(0.0)
			#var cell = grid_cell.instantiate()
			#cell.position = world_coord(Vector2i(j, i))
			#cell.scale.x = dx
			#cell.scale.y = dy
			#self.add_child(cell)
			#cells.append(cell)

var graph_nexts = []
var points: PackedVector2Array = []
var root_nodes = []

var cur_root_node = -1
var mana_timer = 0
@export var mana_spawn_speed: float = 1
var targets = []
var cur_positions = []
var mana_age = []
var mana_size = []
var mana_density = []
var mana_temperature = []
var temperature_diffs = []
var mana_velocity = []
var to_delete = []
var to_merge = []
@export var speed = 1
@export var max_mana_age = 10

@export var temperature_speed_percentage = .10
@export var temperature_distance = 50
@export var temperature_drop_rate = .1
@export var temperature_easing_constant = 1 # SEE: https://byteatatime.dev/posts/easings/
@export var visualize_temp_range: bool = true
@export var visualize_temp_effect: bool = true

@export var circle_radius = 30
var start_pos = null
var end_pos = null
var mode = "NONE"
var selected_point = -1

var base_energy = 0.5 * circle_radius * speed**2 # originally 15

func spawn_particle_at(ind: int, target: int, prev_size: float=circle_radius, age: float=0, prev_density: float=1, prev_temperature: float=0):
	targets.append(target)
	cur_positions.append(points[ind])
	mana_age.append(age)
	mana_size.append(sqrt((prev_size**2) / graph_nexts[ind].size()))
	mana_density.append(prev_density)
	mana_temperature.append(prev_temperature)

func graph_point_ind(pos: Vector2):
	# Loop from the end because later points are drawn on top
	for i in range(points.size() - 1, -1, -1):
		var point = points[i]
		if pos.distance_to(point) < circle_radius:
			return i
	return -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var root = get_window()
	mana_timer += delta
	if points.size() > 0:
		while mana_timer > mana_spawn_speed:
			mana_timer -= mana_spawn_speed
			
			var ind = root_nodes[cur_root_node]
			cur_root_node = (cur_root_node + 1) % root_nodes.size()
			if graph_nexts[ind].size() > 0:
				for target in graph_nexts[ind]:
					spawn_particle_at(ind, target)
			
		# Travel each position along the path
		mana_velocity = []
		temperature_diffs = []
		var i = 0
		while i < cur_positions.size():
			# Total dist to the target point
			var origin = cur_positions[i]
			var dist = points[targets[i]] - cur_positions[i]
			var dir = dist.normalized()
			var rem_dist = delta * speed * 100
			while rem_dist > dist.length():
				rem_dist -= dist.length()
				cur_positions[i] = points[targets[i]]
				if graph_nexts[targets[i]].size() == 0:
					to_delete.append(i)
					break
				var new_target = graph_nexts[targets[i]][0]
				if graph_nexts[targets[i]].size() > 1:
					# Spawn new mana particles in the remaining space
					for j in range(graph_nexts[targets[i]].size() - 1):
						var target = graph_nexts[targets[i]][j + 1]
						spawn_particle_at(targets[i], target, mana_size[i])
				mana_size[i] /= sqrt(graph_nexts[targets[i]].size())
				
				targets[i] = new_target
				dist = points[targets[i]] - cur_positions[i]
			dir = dist.normalized()
			cur_positions[i] += rem_dist * dir
			var total_movement = cur_positions[i] - origin
			mana_velocity.append(total_movement / delta)
			temperature_diffs.append(0)
			i = i + 1
			
		# Calculate tempearture differences and merges
		i = 0
		while i < cur_positions.size():
			mana_age[i] += delta
			if mana_age[i] > max_mana_age and i not in to_delete:
				to_delete.append(i)
			var temperature_diff = 0
			for j in range(cur_positions.size()):
				if i == j:
					continue
				var dist = cur_positions[j] - cur_positions[i]
				var direction_combo = (mana_velocity[i].normalized().dot(mana_velocity[j].normalized())) / ((100 * speed) ** 2)
				var distance = abs(dist.length() - temperature_distance)
				if (dist.length() < mana_size[i] + mana_size[j]) and (mana_size[i] > mana_size[j] or (i < j and mana_size[i] == mana_size[j])):
					# They must be moving towards the same point
					if targets[i] == targets[j]:
						#print(dist.normalized(), ": ", mana_velocity[j].normalized(), " - ", mana_velocity[i].normalized(), " :: ", dist.normalized().dot(mana_velocity[j].normalized()), ", ", (-dist.normalized()).dot(mana_velocity[i].normalized()))
						# merge the particles into the bigger one
						var already_merging = false
						for k in range(len(to_merge)):
							if to_merge[k].x == i or to_merge[k].y == i:
								already_merging = true
								break
						if not already_merging:
							to_merge.append(Vector2i(i, j))
							#print("merging " + str(i) + "," + str(j))
				var temperature_distance_effect = ease(max(1 - temperature_drop_rate*distance, 0), temperature_easing_constant)
				var temperature_stream_effect = 1 - abs(mana_velocity[i].normalized().dot(dist.normalized()))
				# account for numerical imprecision
				if temperature_stream_effect < .000001:
					temperature_stream_effect = 0
				var temperature_effect = temperature_distance_effect * direction_combo * (mana_size[j] / circle_radius) * temperature_stream_effect
				#if i == 0:
					#print(dist.length(), " ", direction_combo, " ", temperature_distance_effect, " ", temperature_stream_effect, " ", temperature_effect)
				temperature_diff = temperature_effect * delta
				var speed_drop = temperature_effect * delta * temperature_speed_percentage * mana_velocity[i]
				var energy_diff = 0.5 * mana_density[i] * mana_size[i] * (mana_velocity[i].length()**2 - (mana_velocity[i] - speed_drop).length()**2)
				mana_temperature[j] += energy_diff
				temperature_diffs[j] += energy_diff
				mana_velocity[i] -= speed_drop
				#print(mana_velocity[i].length())
			i = i + 1
		
		queue_redraw()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if mode == "NONE":
					mode = "PLACE"
					selected_point = graph_point_ind(event.position)
					if selected_point == -1:
						points.append(event.position)
						graph_nexts.append([])
						root_nodes.append(points.size() - 1)
					start_pos = event.position
				else:
					mode = "NONE"
					selected_point = -1
			else:
				if mode == "PLACE":
					var target_point = graph_point_ind(event.position)
					if target_point == -1:
						graph_nexts[selected_point].append(points.size())
						points.append(event.position)
						graph_nexts.append([])
					else:
						graph_nexts[selected_point].append(target_point)
					queue_redraw()
					
				mode = "NONE"
				selected_point = -1
		#	print(event.as_text())
		#if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if mode == "NONE":
					selected_point = graph_point_ind(event.position)
					if selected_point != -1:
						mode = "MOVE"
			else:
				if mode == "MOVE":
					selected_point = -1
					mode = "NONE"
				
	elif event is InputEventMouseMotion:
		if mode == "MOVE" and selected_point != -1:
			points[selected_point] = event.position
			queue_redraw()
			
func draw_temperature(point: Vector2, ind: int):
	var max_rings = 1000
	var main_red = Color.RED
	main_red.a = 0.5
	var red = Color.RED
	red.a = 0.0
	if visualize_temp_range:
		#print(temperature_distance * (1 + temperature_drop_rate))
		#draw_circle(point, temperature_distance, Color.RED, false)
		for i in range(max_rings / 2):
			var distance = i
			var temperature_distance_effect = ease(max(1 - temperature_drop_rate*distance, 0), temperature_easing_constant)
			#var temperature_distance_effect = max(1.0 - temperature_drop_rate*distance, 0)
			if temperature_distance_effect < 0.0001:
				break
			var color = lerp(red, main_red, temperature_distance_effect)
			#print(temperature_distance_effect)
			draw_circle(point, temperature_distance + distance, color, false)
			draw_circle(point, temperature_distance - distance, color, false)
	if visualize_temp_effect:
		if ind < temperature_diffs.size():
			#if ind == 0:
				#print(temperature_diffs[ind])
			var temp_point = Vector2(point.x, point.y - 50000*temperature_diffs[ind])
			draw_line(point, temp_point, Color.WHITE)

func _draw():
	if start_pos == null:
		return
	while to_merge.size() > 0:
		var i = to_merge[0].x
		var j = to_merge[0].y
		var weight = mana_size[i]**2 * mana_density[i] / (mana_size[i]**2 * mana_density[i] + mana_size[j]**2 * mana_density[j])
		var collision_angle_factor = (cur_positions[i] - points[targets[i]]).normalized().dot((cur_positions[j] - points[targets[j]]).normalized())
		mana_age[i] = weight * mana_age[i] + (1 - weight) * mana_age[j]
		var new_mass = (mana_size[i]**2 * mana_density[i]) + mana_size[j]**2 * mana_density[j]
		# Scale [-1, 1] to [1, 0]
		var density_factor = (-collision_angle_factor + 1) / 2
		var max_size = sqrt(mana_size[i]**2 + mana_size[j]**2)
		print(max_size, ": ", mana_size[i], ", ", mana_size[j])
		var min_density = new_mass / (max_size**2)
		var max_density = max(min_density, 0.9 * new_mass / max(mana_size[i], mana_size[j])**2)
		assert(max_density > min_density, "Min and max density are both " + str(min_density))
		#var min_density = weight * mana_density[i] + (1 - weight) * mana_density[j]
		mana_density[i] = lerp(min_density, max_density, density_factor)
		mana_size[i] = sqrt(new_mass / mana_density[i])
		print("::", min_density, ": ", max_density, ", ", mana_density[i], " -- ", mana_size[i])
		mana_temperature[i] = weight * mana_temperature[i] + (1 - weight) * mana_temperature[j]
		to_merge.remove_at(0)
		to_delete.append(j)
	#draw_line(start_pos, get_viewport().get_mouse_position(), Color.GREEN, 1)
	if cur_positions.size() > 0:
		draw_temperature(cur_positions[0], 0)
	for i in range(points.size()):
		var point = points[i]
		draw_circle(point, circle_radius, Color.RED)
		for target in graph_nexts[i]:
			draw_line(point, points[target], Color.GREEN, 1)
			# TODO: maybe draw arrows for directional?
	for i in range(cur_positions.size()):
		#var color = lerp(Color.WHITE, Color.BLACK, mana_age[i] / max_mana_age)
		var temp = (mana_temperature[i] / base_energy)
		var color = lerp(Color.WHITE, Color.RED, temp)
		if temp < 0:
			color = lerp(Color.BLUE, Color.WHITE, -temp)
		#if i == 0:
			#print(color)
		draw_circle(cur_positions[i], mana_size[i], color)
		draw_circle(cur_positions[i], 5, Color.WHITE)
		draw_temperature(cur_positions[i], i)
	while to_delete.size() > 0:
		cur_positions.remove_at(to_delete[0])
		targets.remove_at(to_delete[0])
		mana_age.remove_at(to_delete[0])
		mana_size.remove_at(to_delete[0])
		mana_density.remove_at(to_delete[0])
		mana_temperature.remove_at(to_delete[0])
		to_delete.remove_at(0)
