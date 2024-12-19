extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	pass
	#var root = get_window()
	#var count = root.get_meta("BallCount", 0)
	#count += 1
	#print(count)
	#root.set_meta("BallCount", count)
	#body.queue_free()
