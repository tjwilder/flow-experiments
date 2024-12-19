extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	pass
	#var prev_touched = body.get_meta("touched", [])
	#print(prev_touched);
	#if self.name in prev_touched:
		##print("Skipping")
		#return
	#if "collision_layer" not in child:
		#continue
	#if child.collision_layer & 2 != 0:
	#var root = get_window()
	#var rng = RandomNumberGenerator.new()
	#var rand = null
	#print("Bouncing " + body.name)
	#print(prev_touched);
	#prev_touched.append(self.name)
	#body.set_meta("touched", prev_touched)
	#body.apply_central_impulse(Vector2(0, -2000))
	#var obj = null;
	#for i in range(get_meta("multiplier") - 1):
		#obj = instancedObject.instantiate()
		#obj.set_meta("touched", [self])
		#obj.transform = body.transform
		#rand = rng.randf_range(-1.0, 1.0)
		#obj.transform[2][0] += rand
		#rand = rng.randf_range(-1.0, 1.0)
		#obj.transform[2][1] += rand
		#print(obj.transform)
		#root.add_child(obj)
	print(body.name)
