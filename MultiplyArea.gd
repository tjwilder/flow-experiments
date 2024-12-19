extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@onready var instancedObject = preload("res://Ball.tscn")
@onready var manualBall = preload("res://ManualBall.tscn")

func _on_body_entered(body: Node2D) -> void:
	var prev_touched = body.get_meta("touched")
	print(prev_touched);
	if self in prev_touched: 
		print("Skipping")
		return
	var root = get_window()
	var rng = RandomNumberGenerator.new()
	var rand = null
	prev_touched.append(self)
	print("Multiplying " + body.name)
	body.set_meta("touched", prev_touched)
	var obj = null;
	for i in range(get_meta("multiplier") - 1):
		var touched = []
		for touch in prev_touched:
			touched.append(touch)
		obj = instancedObject.instantiate()
		obj.set_meta("touched", touched)
		obj.transform = body.transform
		rand = rng.randf_range(-1.0, 1.0)
		obj.transform[2][0] += rand
		rand = rng.randf_range(-1.0, 1.0)
		obj.transform[2][1] += rand
		print(obj.transform)
		root.add_child(obj)


func _on_area_entered(area: Area2D) -> void:
	var prev_touched = area.get_meta("touched")
	print(prev_touched);
	if self in prev_touched: 
		print("Skipping")
		return
	var root = get_window()
	var rng = RandomNumberGenerator.new()
	var rand = null
	prev_touched.append(self)
	#print("Multiplying " + area.name)
	area.set_meta("touched", prev_touched)
	var obj = null;
	for i in range(get_meta("multiplier") - 1):
		var touched = []
		for touch in prev_touched:
			touched.append(touch)
		obj = manualBall.instantiate()
		obj.set_meta("touched", touched)
		obj.transform = area.transform
		rand = rng.randf_range(-1.0, 1.0)
		obj.transform[2][0] += rand
		rand = rng.randf_range(-1.0, 1.0)
		obj.transform[2][1] += rand
		#print(obj.transform)
		root.add_child(obj)
