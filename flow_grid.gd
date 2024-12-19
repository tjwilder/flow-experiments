extends Node


var maxX = 1000.0
var maxY = 1000.0
var dimensions = [20, 20]
var dx = maxX / dimensions[0]
var dy = maxY / dimensions[1]
var flow_grid = []
var flow_add = []
var density_grid = []
var cell_grid = []

@onready var grid_cell = preload("res://grid_cell.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var root = get_window()
	for i in range(dimensions[0]):
		var row = []
		flow_grid.append(row)
		var add_row = []
		flow_add.append(add_row)
		var densities = []
		density_grid.append(densities)
		var cells = []
		cell_grid.append(cells)
		for j in range(dimensions[1]):
			row.append(Vector2.ZERO)
			add_row.append(Vector2.ZERO)
			densities.append(0.0)
			var cell = grid_cell.instantiate()
			cell.position.x = dx * j + dx / 2
			cell.position.y = dy * i + dy / 2
			cell.scale.x = dx
			cell.scale.y = dy
			self.add_child(cell)
			cells.append(cell)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var root = get_window()
	
	for child in root.get_children():
		if child == self or "collision_layer" not in child:
			continue
		if child.collision_layer & 2 == 0:
			continue
		
		# Calculate the grid position of the ball
		var xPos = int(child.position.x / dx)
		var yPos = int(child.position.y / dy)
		#print(child.position.x, ": ", xPos, " ", yPos)
		
		# Calculate over-time density in the flow grid for now
		if xPos >= dimensions[0] or xPos < 0 or yPos >= dimensions[1] or yPos < 0:
			continue
		density_grid[yPos][xPos] += 1
		flow_add[yPos][xPos] += child.speed
	
	# Now that we've updated the grid, color it in
	for i in range(dimensions[0]):
		for j in range(dimensions[1]):
			flow_grid[i][j] = 0.99 * flow_grid[i][j] + .01*flow_add[i][j]
			flow_add[i][j] = Vector2.ZERO
			cell_grid[i][j].self_modulate.r = fmod(density_grid[i][j], 255.0) / 1000.0
			var pointer = cell_grid[i][j].get_child(0)
			pointer.rotation = flow_grid[i][j].angle() - PI/2
			var scale = log(flow_grid[i][j].length()) / 10.0
			pointer.scale = Vector2(scale/2.0, scale)
	
		
		
