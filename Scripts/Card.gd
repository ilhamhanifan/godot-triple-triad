extends Node2D

var clickable = true

func _ready():
	$Label_top.text = str(randi() % 9 + 1)
	$Label_right.text = str(randi() % 9 + 1)
	$Label_bottom.text = str(randi() % 9 + 1)
	$Label_left2.text = str(randi() % 9 + 1)
	$Label_top2.text = $Label_top.text
	$Label_right2.text = $Label_right.text
	$Label_bottom2.text = $Label_bottom.text
	$Label_left2.text = $Label_left.text


func _process(_delta):
	pass


