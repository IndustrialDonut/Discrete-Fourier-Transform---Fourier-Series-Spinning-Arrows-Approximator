extends Node2D

var arrow = preload("res://arrow.tscn")

var colors = [
	Color.red,
	Color.purple,
	Color.green,
	Color.yellow,
	Color.blue,
	Color.azure,
	Color.magenta,
	Color.aliceblue
]

var rcoeffs = [] #all real coefficients are zero lol
var icoeffs = [  #starts at n = -3
	-3.0,
	-2.5,
	12.5,
	0.0, 
	0.5,
	-2.5,    
	1.0,  
	-0.5
]

func _ready():
	var i = 0
	var last
	for c in icoeffs:
		
		var inst = arrow.instance()
		self.add_child(inst)
		
		inst.get_node("Sprite").scale.y *= c / 6.0
		inst.modulate = colors[i]
		inst.freq *= -3 + i
		inst.freq *= -1
		
		if i == 0:
			inst.global_position = $Sprite.global_position
		else:
			inst.point = last.get_node("Sprite/tip")
			
		last = inst
		

		i += 1
		
	last.is_last = true
