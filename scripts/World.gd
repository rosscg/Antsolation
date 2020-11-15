extends Node2D

#const AntScene = preload("res://Ant.tscn")
#const FoodScene = preload("res://Food.tscn")
const NestScene = preload("res://scenes/Nest.tscn")
const TerrainScene = preload("res://scenes/Terrain.tscn")

var h = ProjectSettings.get_setting("display/window/size/height")
var w = ProjectSettings.get_setting("display/window/size/width")

var civ_stats_t1 = {"Nest Range" : 300, "Courtiers" : 2, "Ex. Food" : 0}
var civ_stats_t2 = {"Nest Range" : 300, "Courtiers" : 2, "Ex. Food" : 0}
var t1_stats_dict = {'Speed': 0, 'Vision': 0, 'Damage':0, 'Health':0,
					'Carrying':0, 'Lifespan':0, 'Scouting':0, 'Aggressive':0}
var t2_stats_dict = {'Speed': 0, 'Vision': 0, 'Damage':0, 'Health':0,
					'Carrying':0, 'Lifespan':0, 'Scouting':0, 'Aggressive':0}
# Black, Maroon:
const TEAM_COLS = {1: Color(0, 0, 0, 1), 2: Color(0.49, 0.19, 0.38, 1) }
var breeding_season = true
var ants_t1 = 0
var ants_t2 = 0 

export var speed_mod = 1

var responses = {}
var player_id
var team_2_id = 0



func _process(delta):
	
#		t1_stats_dict = get_parent().get_parent().get_parent().get_node('Control').stats
	ants_t1 = 0
	ants_t2 = 0
	for ant in get_node("Ants").get_children():
		if ant.team == 1:
			ants_t1 += 1
		elif ant.team == 2:
			ants_t2 += 1
			
	get_node('Team1AntsLabel').text = "Team One: " + str(ants_t1) + " ant" + ("s" if ants_t1>1 else "")
	get_node('Team2AntsLabel').text = "Team Two: " + str(ants_t2) + " ant" + ("s" if ants_t2>1 else "")
	
	$WinnerLabel.visible = true
	if ants_t1 > ants_t2:
		$WinnerLabel.rect_position = $Team1AntsLabel.rect_position
	elif ants_t2 > ants_t1:
		$WinnerLabel.rect_position = $Team2AntsLabel.rect_position
	else:
		$WinnerLabel.visible = false
		
		
func _ready():
	randomize()
	player_id = randi()%10000
	get_node('Team1AntsLabel2').text = 'Player: ' + str(player_id)
	get_parent().get_node('Control').get_node('ExportButton').text = 'Export Ants with ID: ' + str(player_id)
	$ColorRect.rect_size = Vector2(w,h)
	for i in range(2):
		spawn_nest(i)
	for _i in range(8):
		var obj = spawn_terrain()
#		if obj.type == 'tree':
#			spawn_terrain('tree', (get_random_direction()*200 + obj.position))
#			spawn_terrain('tree', (get_random_direction()*200 + obj.position))
	for _i in range(20):
		$Gardener.spawn_food()


func spawn_nest(i, position=null):
	var nest_instance = NestScene.instance()
	if not position:
		nest_instance.position = Vector2(w/4, h/4) * (1 + 2*i)
	else:
		nest_instance.position = position
	nest_instance.team = i + 1
	nest_instance.food = 80
	self.get_node("Nests").add_child(nest_instance)


func spawn_terrain(type=null, position=null):
	var terr_instance = TerrainScene.instance()
	terr_instance.init(type)
	if not position:
		position = get_random_position_untouched(50)
		# Keep away from nests
		while _get_closest_obj(position).get_parent().name == 'Nests' and \
			_get_closest_obj(position).position.distance_to(position) < 70:
			position = get_random_position_untouched(30)
		# Keep away from edges
	#	while position.x < 40 or position.x > w-40 or position.y < 100:
	#		position = get_random_position_untouched(30)
#	if terr_instance.type == 'tree':
#		spawn_terrain('tree', get_random_position(terr_instance.position, 30))
	terr_instance.position = position
	terr_instance.scale = Vector2(.7, .7)
	self.get_node("Terrain").add_child(terr_instance)
	return terr_instance


func _get_closest_obj(position_from):
	var closest = null
	var distance = INF
	var objects = get_node('Food').get_children() + \
					get_node('Nests').get_children() + \
					get_node('Terrain').get_children()
	for obj in objects:
		if position_from.distance_to(obj.position) < distance:
			closest = obj
			distance = position_from.distance_to(obj.position)
	return closest
	
	
func get_random_position_untouched(distance):
	var pos = get_random_position()
	while _get_closest_obj(pos).position.distance_to(pos) < distance:
		pos = get_random_position()
	return pos


func get_random_position(from_loc=null, distance=null):
	if from_loc and distance:
		var vec = Vector2(-1,-1)
		while vec.x < 0 or vec.x > w or vec.y < 0 or vec.y > w:
			vec = from_loc + (get_random_direction()*distance)
		return vec
	return Vector2(randi()%w,randi()%h)


func get_random_direction() -> Vector2:
	var x = rand_range (-1, 1)
	var y = rand_range (-1, 1)
	return Vector2(x,y)


func _on_Button2_button_up():
	speed_mod += 1

func _on_Button3_button_up():
	if speed_mod >= 2:
		speed_mod -= 1
