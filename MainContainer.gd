extends Node2D
var redpoint = preload("res://redpoint.tscn")
var click_points : PoolVector2Array
var points : PoolVector2Array
var arrows : PoolVector2Array
var ks : PoolIntArray

var is_running := false

onready var active_cam : Camera2D = $Camera2D

var more_or_less = 0

var arrow = preload("res://Arrow/newArrow.tscn")

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


func _process(delta):
	if Input.is_action_pressed("in"):
		active_cam.zoom -= Vector2(delta, delta)
	if Input.is_action_pressed("out"):
		active_cam.zoom += Vector2(delta, delta)
	
	if Input.is_action_just_pressed("fire") and not is_running:

		# Godot screen coordinates for get_viewport() get mouse position totally different
		# from getting the mouse position IN THE WORLD.
		# I should have known that though to be honest, and I even had that earlier suspicion about the camera.
		# Just wasn't quite on the money. Anyway, good on you for figuring out 
		# all of the algorithm pretty much in its entirety on paper and in Mathematica
		# before getting to the hardcore troubleshooting which had to be pure Godot 
		# related things. That was actually rather easy in the end once all other possibilities were
		# ruled out from extensive external testing. Good!
		click_points.append(get_global_mouse_position() - $Sprite.global_position)
		
		var ins = redpoint.instance()
		add_child(ins)
		ins.global_position = get_global_mouse_position()
		ins.modulate = Color.lightgreen
	
	#test_plot(delta)

func run_DFT(kmod = 0) -> void:
	var last = null
	
	for k in range(0, floor(click_points.size()/2) + kmod): # works since forced to be even, don't need -1 at the end since noninclusive
		var cx = xdft_sub(k)
		var cy = ydft_sub(k)
		
		var ar = cx.x
		var br = cx.y
		var ai = cy.x
		var bi = cy.y
		
		# allegedly atan2 automatically accounts for the sign of the x argument, to determine the quadrant. Need not add PI and do if shit
		var phi = atan2(ai + br, ar - bi) #if (ar - bi) > 0 else atan2(ai + br, ar - bi) + PI
		var mag = sqrt((ar - bi)*(ar - bi) + (ai + br)*(ai + br)) / 2.0
		
		var inst = arrow.instance()
		spawn_sub(phi, mag, k, inst, last)
		last = inst
		
		var vec = Vector2(1,0).rotated(phi) * mag
		arrows.append(vec)
		ks.append(k)

		if k != 0:
			cx = xdft_sub(-k)
			cy = ydft_sub(-k)
		
			ar = cx.x
			br = cx.y
			ai = cy.x
			bi = cy.y
		
			phi = atan2(ai + br, ar - bi)
			mag = sqrt((ar - bi)*(ar - bi) + (ai + br)*(ai + br)) / 2.0
			
			inst = arrow.instance()
			spawn_sub(phi, mag, -k, inst, last)
			last = inst
			
			vec = Vector2(1,0).rotated(phi) * mag
			arrows.append(vec)
			ks.append(-k)
		
	last.is_last = true
	

func xdft_sub(k) -> Vector2: # returns vector 2 because x is real and y is imaginary
	var sum = Vector2()
	for n in range(points.size()):
		
		sum.x += points[n].x * cos(TAU * k * n / points.size())
		
		sum.y += points[n].x * sin(TAU * k * n / points.size())
		
	return 2 * sum / points.size() # scales properly


func ydft_sub(k) -> Vector2: # returns vector 2 because x is real and y is imaginary
	var sum = Vector2()
	for n in range(points.size()):
		
		sum.x += points[n].y * cos(TAU * k * n / points.size())
		
		sum.y += points[n].y * sin(TAU * k * n / points.size())
		
	return 2 * sum / points.size() # scales properly


func spawn_sub(phi : float, mag : float, k : int, inst, last):
	$container.add_child(inst)
	
	if mag < 0:
		print("WARN: magnitude in spawning of vector is negative, this should never be the case")
	
	inst.get_node("Sprite").scale.y *= (mag/800.0) # simply setting the magnitude of the vector
	inst.rotation = phi + PI/2.0 # should be now adjusting the phase I hope

	inst.modulate = colors[abs(k % colors.size())]
	inst.freq = -k #/2.0

	if k == 0:
		inst.global_position = $Sprite.global_position
	else:
		inst.point = last.get_node("Sprite/tip")


func test_plot(delta) -> void:
	if arrows.size() > 1:
		var tot : Vector2 = $Sprite.global_position
		for i in range(arrows.size()):
			arrows[i] = arrows[i].rotated(ks[i] * delta)
			tot += arrows[i]
			if ks[i] == 0:
				var ins = redpoint.instance()
				add_child(ins)
				ins.global_position = arrows[i]
		
		# plot total point here
		#var ins = redpoint.instance()
		#add_child(ins)
		#ins.global_position = tot


func _on_Start_pressed():
	if is_running:
		return
	
	for p in range(click_points.size() - 1):
		var temp = click_points[p+1] - click_points[p]
		var length = temp.length()
		
		var num_new = floor(length / 50.0) # for every 50 pixes between two points, add a new point
		# effectively, make the new maximum distance between points 50 pixels
		
		for i in num_new:
			var frac = float(i)/float(num_new)
			
			points.append(temp * frac + click_points[p])
	
	if points.size() > 0:
		run_DFT()
		is_running = true


func _on_SwitchView_pressed():
	_switch_view()


func _switch_view():
	for child in $container.get_children():
		if "is_last" in child:
			if child.is_last:
				if not child.find_node("Camera2D").current:
					child.find_node("Camera2D").make_current()
					active_cam = child.find_node("Camera2D")
				else:
					$Camera2D.make_current()
					active_cam = $Camera2D


func _on_Decrease_pressed():
	_change_arrow_count(-1)


func _on_Increase_pressed():
	_change_arrow_count(1)


func _change_arrow_count(difference):
	for nd in $container.get_children():
		nd.queue_free()
	
	more_or_less += difference
	run_DFT(more_or_less)


func _on_Reset_pressed():
	is_running = false
	for x in $container.get_children():
		x.queue_free()
		
	click_points = []
	points = []
