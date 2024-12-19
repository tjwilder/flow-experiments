extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var speed = Vector2(0, 0)
var push = 1000.0
var ballGravity = 2.1
var radius = 10
var size = Vector2(2*radius, 2*radius)
var touched = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var root = get_window()
	gravity = 1.0
	speed[1] += delta * gravity / 2
	
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	# Check in each direction instead of in the absolute stuff
	var dir = speed.normalized() * radius
	# TODO, it doesn't necessarily collide in the direction it's going, but almost always to one side
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + dir + delta*speed, 1<<8)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	#print(result)
	# Reflect speed by result normal
	# TODO: Maybe we could use bounce() built-in
	#print(result)
	if "normal" in result:
		#var normal = result.normal * sin(-body.rotation)
		speed = 0.99*speed.bounce(result.normal)
		
	self.position += delta * speed
	speed[1] += delta * gravity / 2
	var x = self.collision_layer
	
	for child in root.get_children():
		if child == self or "collision_layer" not in child:
			continue
		if child.collision_layer & 2 != 0:
			#print(child.name)
			var vec = child.global_position - self.global_position
			var direction = vec.normalized()
			var dist = vec.length()
			if dist < size[0]:
				continue
			var diff = ballGravity * direction / (dist*dist)
			diff[0] = min(max(diff[0], -1), 1)
			diff[1] = min(max(diff[1], -1), 1)
			speed += 1*diff
			
	for area in touched:
		var vec = area.global_position - self.global_position
		var direction = vec.normalized()
		var dist = vec.length()
		#print(dist)
		#var overlap = vec / size
		var diff = delta * direction * push / (dist)
		diff[0] = min(max(diff[0], -10), 10)
		diff[1] = min(max(diff[1], -10), 10)
		speed -= 1*diff


func _on_area_entered(area: Area2D) -> void:
	if "Sink" in area.name:
		print(area.name)
		self.queue_free()
	# TODO: check collissions with other manual balls
	if area.get_meta("touched", null) != null:
		touched.append(area)
	#print(area.name)
		#speed -= 
		#print(direction)


func _on_area_exited(area: Area2D) -> void:
	for i in range(len(touched)):
		if touched[i] == area:
			touched.remove_at(i)
			return
	
func _on_body_entered(body: Node2D) -> void:
	pass
	#if "Wall" in body.name:
		##print(body.name)
		#var vec = self.global_position - body.global_position
		#var space_state = get_world_2d().direct_space_state
		## use global coordinates, not local to node
		## Check in each direction instead of in the absolute stuff
		##for dir in [Vector2(-size[0]/2.0, 0.0), Vector2(size[0]/2.0, 0.0),
					##Vector2(0.0, -size[1]/2.0), Vector2(0.0, size[1]/2.0)]:
			##dir = Vector2(dir[0] * cos(body.rotation), dir[1] * sin(body.rotation))
		#var query = PhysicsRayQueryParameters2D.create(global_position, global_position + speed, 1<<8)
		#query.collide_with_areas = true
		#query.collide_with_bodies = true
		#var result = space_state.intersect_ray(query)
		##print(result)
		## Reflect speed by result normal
		## TODO: Maybe we could use bounce() built-in
		#print(result)
		#if "normal" in result:
			##var normal = result.normal * sin(-body.rotation)
			#speed = speed.bounce(result.normal)
			## Also push it slightly away from the wall
			##self.position += 5.0*result.normal
			##break
