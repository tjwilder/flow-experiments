extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var total = 0
var rate = 0.1

@onready var instancedObject = preload("res://Ball.tscn")
@onready var manualBall = preload("res://ManualBall.tscn")
@onready var rng = RandomNumberGenerator.new()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	total += delta
	var mouse_pos = get_global_mouse_position()
	#self.position = mouse_pos
	var count = self.get_meta("count", 0)
	if total > rate and count > 0:
		total -= rate
		var root = get_window()
		var obj = manualBall.instantiate()
		obj.position = self.position
		var rand = rng.randf_range(-PI, PI)
		var dist = rng.randf_range(0.2, 1)
		obj.position[0] += dist * sin(rand)
		obj.position[1] += dist * cos(rand)
		#print(rand, dist)
		obj.set_meta("touched", [])
		#obj.name = "Manual Ball"
		root.add_child(obj)
		self.set_meta("count", count - 1)
		
