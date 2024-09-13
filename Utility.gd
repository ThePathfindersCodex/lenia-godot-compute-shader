extends Node

func bell(x: float, m: float, ss: float) -> float:
	return exp(-((x - m) / ss) ** 2 / 2)

func bilinear_interpolation(x: float, y: float, grid: Array, old_width: int, old_height: int) -> float:
	var x1 = int(floor(x))
	var y1 = int(floor(y))
	var x2 = min(x1 + 1, old_width - 1)
	var y2 = min(y1 + 1, old_height - 1)
	
	var q11 = grid[y1 * old_width + x1]
	var q21 = grid[y1 * old_width + x2]
	var q12 = grid[y2 * old_width + x1]
	var q22 = grid[y2 * old_width + x2]
	
	var r1 
	var r2
	if x2 == x1:
		r1 = q11
		r2 = q12
	else:
		r1 = (x2 - x) * q11 + (x - x1) * q21
		r2 = (x2 - x) * q12 + (x - x1) * q22
	
	if y2 == y1:
		return r1
	return (y2 - y) * r1 + (y - y1) * r2

func calculate_offset(outer_grid_width: int, inner_grid_width: int) -> Vector2:
	var offset_x = int((outer_grid_width - inner_grid_width) / 2.0)
	var offset_y = int((outer_grid_width - inner_grid_width) / 2.0)
	return Vector2(offset_x, offset_y)
