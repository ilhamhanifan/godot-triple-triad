extends Control

var EFFECT = preload("res://Scenes/Explosion.tscn")

func _ready():
	pass 
	
func _on_playButton_pressed():
	get_tree().change_scene("res://Scenes/TripleTriad.tscn")

func _on_aboutUsButton_pressed():
	get_tree().change_scene("res://Scenes/AboutUs.tscn")

func _on_quitButton_pressed():
	get_tree().quit()

func _on_GoBack_pressed():
	get_tree().change_scene("res://Scenes/Menu.tscn")

func _on_Play_Game_pressed():
	get_tree().change_scene("res://Scenes/TripleTriad.tscn")
