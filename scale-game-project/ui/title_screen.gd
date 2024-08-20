
extends Control

const MAIN = preload("res://maps/main.tscn")


func _ready():
	$VBoxContainer/Button.grab_focus()


func _on_button_pressed():
	get_tree().change_scene_to_file("res://maps/main.tscn")


func _on_button_2_pressed():
	$AnimationPlayer.play("credits")
	$Button4.grab_focus()
	


func _on_button_4_pressed():
	$AnimationPlayer.play("credits", -1, -1)
	$VBoxContainer/Button2.grab_focus()
