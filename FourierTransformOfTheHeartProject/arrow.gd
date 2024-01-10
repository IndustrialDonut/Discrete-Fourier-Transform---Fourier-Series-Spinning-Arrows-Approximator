extends Node2D

var redpoint = preload("res://redpoint.tscn")

var freq = 0.2

var point : Node2D

var is_last = false


func _process(delta):
	if point:
		self.global_position = point.global_position
	
	self.rotate(freq * delta)
	
	if is_last:
		var ins = redpoint.instance()
		
		get_tree().root.add_child(ins)
		ins.global_position = $Sprite/tip.global_position
		

