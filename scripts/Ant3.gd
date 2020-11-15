extends KinematicBody2D

onready var world = self.get_parent().get_parent()

enum State {HUNGRY, MOVING, EATING, RETURNING, DROPOFF, ATTACKING, DEAD, NESTING}

var eat_range = 30
var queen = false

var nest_distance = 300
var rotation_speed = 5
var speed = 100
var vision_range = 100
var food_capacity = 5
var scout_range = 200
var lifespan = 40
var team = 1
var aggressiveness = 0.5
var health = 5
var damage = 1

var timer = 0
var velocity
var state
var target_obj
var busy
var current_food = 0
var age = 0

#var speed_mod = 3

func init(team=1, queen=false, position=Vector2(100,100)):
	self.queen = queen
	self.team = team
	self.position = position
	
func _ready():
	eat_range = 2+ $CollisionShape2D2.shape.radius + $CollisionShape2D2.shape.height/2
	$Wings.visible = queen
	$Body.color = world.TEAM_COLS[self.team]
	state = State.HUNGRY
	if queen:
		state = State.NESTING
	speed = speed * world.speed_mod
	rotation_speed = rotation_speed * world.speed_mod


func _physics_process(delta):
		
	if timer > 1.0 / world.speed_mod:
		age += 1
		timer -= 1
	else:
		timer += delta
	
	if age >= lifespan:
		state = State.DEAD

	if state == State.DEAD:
		if not busy:
			busy = true
			$Body.color = "757575"
			$Wings.visible = false
			$Legs.visible = false
			$Mandibles.visible = false
			$CollisionShape2D2.disabled = true
			self.team = -1
			var new_parent = get_parent().get_parent().get_node("Terrain")
			get_parent().remove_child(self)
			new_parent.add_child(self)
			yield(get_tree().create_timer(10/world.speed_mod), "timeout")
			$Body.color = "91646464"
			yield(get_tree().create_timer(10/world.speed_mod), "timeout")
			self.queue_free()
	
	if state == State.NESTING:
		var nest = _get_closest_nest()
		if self.position.distance_to(nest.position) > nest_distance and \
				self.position.x > 0 and self.position.x < world.w and \
				self.position.y > 0 and self.position.y < world.h:
			world.spawn_nest(self.team-1, self.position)
			self.queue_free()
		else:
			$Position2D.position = world.get_random_position(self.position, scout_range)
			var angle = self.position.direction_to($Position2D.position)
			while angle.dot(self.transform.x) < 0:
				$Position2D.position = world.get_random_position(self.position, scout_range)
				angle = self.position.direction_to($Position2D.position)
			target_obj = $Position2D
			_move_towards(delta, target_obj)
			
		
	if state == State.RETURNING:
		target_obj = _get_closest_nest()
		_move_towards(delta, target_obj)
	
	if not is_instance_valid(target_obj):
		target_obj = null
		state = State.HUNGRY
		
	if state == State.HUNGRY:
		var food = _get_closest_food()
		var enemy = _get_closest_enemy()
		if enemy and rand_range(0, 1) < self.aggressiveness:
			target_obj = enemy
			state = State.MOVING
		elif food:
			target_obj = food
			state = State.MOVING
		elif target_obj and position.distance_to(target_obj.position) > eat_range:
			_move_towards(delta, target_obj)
		else:
			$Position2D.position = world.get_random_position(self.position, scout_range)
			var angle = self.position.direction_to($Position2D.position)
			while angle.dot(self.transform.x) < 0:
				$Position2D.position = world.get_random_position(self.position, scout_range)
				angle = self.position.direction_to($Position2D.position)
			target_obj = $Position2D
			
			
	if state == State.MOVING:
		if target_obj:
			if position.distance_to(target_obj.position) < eat_range:
				if target_obj.get_parent().name == 'Ants':
					state = State.ATTACKING
				elif target_obj.get_parent().name == 'Food':
					state = State.EATING
				else:
					target_obj = null
			else:
				_move_towards(delta, target_obj)
		else:
			state = State.HUNGRY

	if state == State.EATING:
		if current_food >= food_capacity:
			state = State.RETURNING
		elif not busy:
			if target_obj:
				target_obj.decrement_value(1)
				self.current_food += 1
				if target_obj.value > 0:
					busy = true
					yield(get_tree().create_timer(2.0/world.speed_mod), "timeout")
					busy = false
				else:
					target_obj = null
			else:
				state = State.HUNGRY
		
	if state == State.ATTACKING:
		if target_obj:
			if not busy:
				if position.distance_to(target_obj.position) > eat_range:
					state = State.MOVING
				else:
					busy = true
					var delay = randf()/10
					var is_dead = target_obj.take_damage(damage)
					yield(get_tree().create_timer((0.5+delay)/world.speed_mod), "timeout")
					if is_dead:
						state = State.HUNGRY
						target_obj = null
					busy = false
		else:
			state = State.HUNGRY


func take_damage(val):
	health -= val
	if health <= 0:
		state = State.DEAD
		#self.queue_free()
		return true
	return false
	

func _get_closest_food():
	var closest = null
	var distance = vision_range
	for food in get_parent().get_parent().get_node('Food').get_children():
		if position.distance_to(food.position) < distance:
			closest = food
			distance = position.distance_to(food.position)
	return closest
	

func _get_closest_nest():
	var closest = null
	var distance = INF
	for nest in get_parent().get_parent().get_node('Nests').get_children():
		if nest.team == self.team and position.distance_to(nest.position) < distance:
			closest = nest
			distance = position.distance_to(nest.position)
	return closest
	

func _get_closest_enemy():
	var closest = null
	var distance = vision_range
	for ant in get_parent().get_parent().get_node('Ants').get_children():
		if ant.team != self.team and ant.team != -1 and \
			position.distance_to(ant.position) < distance:
			closest = ant
			distance = position.distance_to(ant.position)
	return closest
	
	
func _move_towards(delta, obj):
	if get_slide_count() == 0:
		if to_local(obj.position).angle() > PI/180*3:
			rotation += rotation_speed * delta
		elif to_local(obj.position).angle() < PI/180*3:
			rotation -= rotation_speed * delta
	else: # Move around obstruction
		rotation += rotation_speed * delta
	if position.distance_to(obj.position) > speed*delta:
		velocity = Vector2(1, 0).rotated(rotation) * speed
	else:
		velocity = Vector2(1, 0).rotated(rotation) * position.distance_to(target_obj.position)
	velocity = move_and_slide(velocity)
	
	
	
#func _move_wander(delta):
#	rotation += rotation_speed * delta * (randi()%3-1)
#	velocity = Vector2(1, 0).rotated(rotation) * speed
#	velocity = move_and_slide(velocity)


func set_dropoff(nest):
	if nest.team == self.team and not queen:
		self.state = State.DROPOFF
		while current_food > 0:
			nest.food += 1
			current_food -= 1
			yield(get_tree().create_timer(0.5/world.speed_mod), "timeout")
		self.state = State.HUNGRY
		