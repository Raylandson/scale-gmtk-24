extends CanvasLayer

var player_offensive_index = 0
var current_upgrade: String
var indexes_list:Array = [0, 0, 0, 0]
var _timer = 0
var time_to_press = 0.5
var upgrades = [
	[
		# player ofensivo
		{
			'nome': 'Sword Damage +',
			'upgrade': 'upgrade_sword_damage',
			'water': 2,
			'wood': 2,
			'ore': 2
		},
		{
			'nome': 'Stronger Sword (lvl2)',
			'upgrade': 'upgrade_stronger_sword',
			'water': 2,
			'wood': 2,
			'ore': 2
		},
		{
			'nome': 'Sword Damage +',
			'upgrade': 'upgrade_sword_damage',
			'water': 2,
			'wood': 2,
			'ore': 2
		},
		{
			'nome': 'Berzek Sword (Max)',
			'upgrade': 'upgrade_berzerk_sword',
			'water': 2,
			'wood': 2,
			'ore': 2
		}
	],
	# plant defense
	[
		{
			'nome': 'Plant Life +',
			'upgrade': 'upgrade_plant_life',
			'water': 2,
			'wood': 2,
			'ore': 2
		},
		{
			'nome': 'Thornmail',
			'upgrade': 'upgrade_thornmail',
			'water': 2,
			'wood': 3,
			'ore': 0
		},
		{
			'nome': 'Plant Heal Faster',
			'upgrade': 'upgrade_plant_heal_faster',
			'water': 2,
			'wood': 3,
			'ore': 0
		},
		{
			'nome': 'Plant Slow Area (Slow nearby Enemies)',
			'upgrade': 'upgrade_slow_area',
			'water': 2,
			'wood': 3,
			'ore': 0
		},
		{
			'nome': 'Max level Reached',
			'upgrade': 'bosonaro',
			'water': 0,
			'wood': 0,
			'ore': 0
		}
	],
	# well upgrades
	[
		{
			'nome': 'well fill velocity +',
			'upgrade': 'upgrade_well_fill_velocity',
			'water': 0,
			'wood': 4,
			'ore': 5
		},
		{
			'nome': 'well max water +',
			'upgrade': 'upgrade_well_max_water',
			'water': 0,
			'wood': 3,
			'ore': 4
		},
		{
			'nome': 'well fill velocity (lvl 2) ++',
			'upgrade': 'upgrade_well_fill_velocity',
			'water': 0,
			'wood': 5,
			'ore': 5
		},
		{
			'nome': 'bucket max water +',
			'upgrade': 'upgrade_bucket_max_water',
			'water': 0,
			'wood': 2,
			'ore': 6
		},
		{
			'nome': 'Max level Reached',
			'upgrade': 'bosonaro',
			'water': 0,
			'wood': 0,
			'ore': 0
		},
	],
	[
		{
			'nome': 'Cut speed +',
			'upgrade': 'upgrade_cut_speed',
			'water': 0,
			'wood': 2,
			'ore': 5
		},
		{
			'nome': 'tree spawn_speed +',
			'upgrade': 'upgrade_tree_spawn_speed',
			'water': 2,
			'wood': 4,
			'ore': 0
		},
		{
			'nome': 'tree spawn_speed (lvl 2) ++',
			'upgrade': 'upgrade_tree_spawn_speed',
			'water': 4,
			'wood': 3,
			'ore': 0
		},
		{
			'nome': 'Max level Reached',
			'upgrade': 'bosonaro',
			'water': 0,
			'wood': 0,
			'ore': 0
		},
		
	]
]


func _input(event):
	if event.is_action_pressed("x"):
		get_tree().paused = false
		self.hide()
		


func self_show():
	if _timer >= time_to_press:
		get_tree().paused = true
		$"%Upgrade".grab_focus()
		self.show()
		_timer = 0


func upgrade_cut_speed() -> void:
	Globals.cut_speed_multi -= 0.2
	
	print("Cut speed upgraded!")

func upgrade_tree_spawn_speed() -> void:
	Globals.spawn_tree_multi -= 0.2
	print("Tree spawn speed upgraded!")



func upgrade_well_fill_velocity() -> void:
	Globals.well_fill_multiplier -= 0.15
	print("Well fill velocity upgraded!")

func upgrade_well_max_water() -> void:
	Globals.well_max_water += 2
	print("Well max water capacity increased!")

func upgrade_bucket_max_water() -> void:
	Globals.bucket_max_water += 2
	print("Bucket max water capacity increased!")


func upgrade_sword_damage() -> void:
	Globals.attack_level += 1
	print("Sword damage upgraded!")


func upgrade_stronger_sword() -> void:
	Globals.upgrade_sword_2.emit()
	print("Stronger sword acquired!")


func upgrade_berzerk_sword() -> void:
	Globals.upgrade_sword_berzek.emit()
	print("Berserk sword unlocked!")


func upgrade_plant_life() -> void:
	Globals.plant_max_life += 1
	print("Plant life increased!")


func upgrade_thornmail() -> void:
	Globals.upgrade_thornmail.emit()
	print("Thornmail equipped!")


func upgrade_plant_heal_faster() -> void:
	Globals.plant_heal_muilti += 0.15
	print("Plant heal rate increased!")


func upgrade_slow_area() -> void:
	Globals.upgrade_slow_area
	print("Slow area effect activated!")


func apply_upgrade() -> void:
	
	if has_method(current_upgrade):
		var dir = upgrades[current_index][indexes_list[current_index]]
		if Globals.ore >= dir['ore'] and Globals.water >= dir['water'] and\
		Globals.wood >= dir['wood']:
			Globals.dict_vars['ore'] -= dir['ore']
			Globals.dict_vars['water'] -= dir['water']
			Globals.dict_vars['wood'] -= dir['wood']
			Globals.update_vars()
			
			call(current_upgrade)
			if indexes_list[current_index] < upgrades[current_index].size() -1 :
				indexes_list[current_index] += 1
			update()
		
		else:
			print('camera shake aqui')
		#aí fecha aqui
	else:
		print("Upgrade não encontrado: ", current_upgrade)


func update() -> void:
	var dir = upgrades[current_index][indexes_list[current_index]]
	%WaterLabel.text = str(dir['water'])
	%WoodLabel.text = str(dir['wood'])
	%OreLabel.text = str(dir['ore'])
	%Upgrade.text = dir['nome']
	%LvlLabel.text = "lvl: " + str(indexes_list[current_index]+1)
	current_upgrade = dir['upgrade']


func _ready() -> void:
	Globals.show_upgrades.connect(self_show)
	update()

var current_index = 0

func next_upgrade() -> void:
	if current_index < upgrades.size() - 1:
		current_index += 1
	else:
		current_index = 0
	update()


func previous_upgrade() -> void:
	if current_index > 0:
		current_index -= 1
	else:
		current_index = upgrades.size() - 1
	update()


func _process(delta):
	_timer += delta
	pass
	#if Input.is_action_just_pressed("ui_accept"):
		#var current_upgrade = upgrades[0][player_offensive_index]
		##apply_upgrade(current_upgrade['upgrade'])  # Aplica o upgrade correspondente
		#player_offensive_index += 1
		#update()
