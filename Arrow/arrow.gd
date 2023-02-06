extends Node2D

var redpoint = preload("res://redpoint.tscn")

var freq = 0.7

var point : Node2D #= get_parent().get_node("arrow/Sprite/tip")

var is_last = false


func _process(delta):
	#print(self.rotation)
	if point:
		self.global_position = point.global_position
	
	self.rotate(freq * delta)
	
	if is_last:
		var ins = redpoint.instance()

		get_tree().root.add_child(ins)
		ins.global_position = $Sprite/tip.global_position
		

