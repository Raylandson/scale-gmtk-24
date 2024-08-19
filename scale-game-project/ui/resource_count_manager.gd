extends CanvasLayer

func _ready():
	pass
	
func _process(delta):
	$"%WoodLabel".text = str(Globals.wood)
	$"%OreLabel".text = str(Globals.ore)
	$"%Water".text = str(Globals.water)
