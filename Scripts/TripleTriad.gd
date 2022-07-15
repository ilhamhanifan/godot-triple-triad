extends Node2D
signal cardHover(cardname)
signal cardSelected(cardname)
signal endgame()

#var board_slot_scene = load()
var cardScene = load("res://Scenes/Card.tscn")
var boardSlotScene = load("res://Scenes/Board.tscn")
var EFFECT = preload("res://Scenes/Explosion.tscn")

var bluecard = preload("res://Assets/images/card_blue.png")
var redcard = preload("res://Assets/images/card_red.png")

#card locations
var player_hand_position = []
var comp_hand_position = []
	
# card selected
var selectedCard = null

# card on hands
var playerCards = []
var compCards = []

# board and open slots
var boardSlots = []
var boardSlotsCards = []

var isPlayerTurn
var turnCount

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	turnCount = 0
	
	for x in range(20,421,100):
		player_hand_position.append(Vector2(60,x))
		comp_hand_position.append(Vector2(620,x))
	
	for x in range(3):
		var slots = []
		var slotsOpen = []
		var stats = []
		for y in range(3):
			var boardSlot = boardSlotScene.instance()
			boardSlot.position = Vector2(220 + (x*120), 60 + (y*160))
			add_child(boardSlot)
			slots.append(boardSlot)
			slotsOpen.append(null)
		boardSlots.append(slots)
		boardSlotsCards.append(slotsOpen)
	
	for pos in player_hand_position:
		var card = cardScene.instance()
		card.position = pos
		add_child(card)
		card.get_node("Template").set_texture(bluecard)
		playerCards.append(card)

	for pos in comp_hand_position:
		var card = cardScene.instance()
		card.position = pos
		add_child(card)
		card.get_node("Template").set_texture(redcard)
		compCards.append(card)
		
	isPlayerTurn = randi() % 2 == 0
	if !isPlayerTurn:
		get_node("Status").text = 'COMPUTER GOES FIRST'
		compTurn()
	else:
		get_node("Status").text = 'PLAYER GOES FIRST'
		
func _input(event):
		
	if isPlayerTurn == true:
		checkGameEnd()
		playerTurn(event)
		#compTurn(event)
	else:
		pass

func playerTurn(event):
	if event is InputEventMouse:
		var hovered = false
		for card in playerCards:
			if card == selectedCard:
				emit_signal("cardSelected",card)
			else:
				if !hovered and card.get_node("Template").get_rect().has_point(card.get_node("Template").get_local_mouse_position()):
					if event is InputEventMouseButton and \
					event.button_index == BUTTON_LEFT and \
					event.pressed and \
					card.clickable == true:
						selectedCard = card
					else:
						emit_signal("cardHover",card)
					hovered=true
				else:
					card.scale = Vector2(1,1)

		for x in boardSlots.size():
			for y in boardSlots.size():
				if event is InputEventMouseButton \
					and event.button_index == BUTTON_LEFT \
					and event.pressed \
					and boardSlots[x][y].get_node("Template").get_rect().has_point(boardSlots[x][y].get_node("Template").get_local_mouse_position()) \
					and selectedCard != null \
					and boardSlotsCards[x][y] == null:
						selectedCard.position = boardSlots[x][y].position
						selectedCard.scale = Vector2(1,1)
						adjustCardLabel(selectedCard)
						trigEffect(selectedCard)
						for card in playerCards:
							if card == selectedCard:
								card.clickable = false
								playerCards.erase(card)
						boardSlotsCards[x][y] = selectedCard
						checkboard(selectedCard)
						selectedCard = null
						isPlayerTurn = !isPlayerTurn
						turnCount += 1
						checkGameEnd()
						compTurn()
	
func compTurn():
	if isPlayerTurn == null:
		return
	yield(get_tree().create_timer(0.8), "timeout")
	var index = randi() % compCards.size()
	selectedCard = compCards[index]
	selectedCard.scale = Vector2(1.2,1.2)
	yield(get_tree().create_timer(0.8), "timeout")
	
	var openSlots = getOpenSlots()
	
	if openSlots.size() > 0:
		index = randi() % openSlots.size()
		var moveto = openSlots[index]
		selectedCard.scale = Vector2(1,1)
		selectedCard.position = Vector2(220 + (moveto.x*120), 60 + (moveto.y*160))
		adjustCardLabel(selectedCard)
		trigEffect(selectedCard)
		compCards.erase(selectedCard)
		boardSlotsCards[moveto.x][moveto.y] = selectedCard
		checkboard(selectedCard)
		selectedCard = null
		isPlayerTurn = !isPlayerTurn
		turnCount += 1
	return

func adjustCardLabel(card):
	card.get_node("Label_top").visible = false
	card.get_node("Label_right").visible = false
	card.get_node("Label_bottom").visible = false
	card.get_node("Label_left").visible = false
	
	card.get_node("Label_top2").visible = true
	card.get_node("Label_right2").visible = true
	card.get_node("Label_bottom2").visible = true
	card.get_node("Label_left2").visible = true
func getOpenSlots():
	var result = []
	for x in boardSlots.size():
		for y in boardSlots.size():
			if !boardSlotsCards[x][y]:
				result.append(Vector2(x,y))
	return result
	
func checkboard(card):
	for x in boardSlotsCards.size():
		for y in boardSlotsCards.size():
			if card == boardSlotsCards[x][y]:
				if y-1 >= 0:
					if boardSlotsCards[x][y-1] != null:
						if int(boardSlotsCards[x][y-1].get_node("Label_bottom").text) < int(boardSlotsCards[x][y].get_node("Label_top").text):
							if boardSlotsCards[x][y-1].get_node("Template").texture.resource_path != boardSlotsCards[x][y].get_node("Template").texture.resource_path:
								var color = boardSlotsCards[x][y-1].get_node("Template").texture.resource_path
								boardSlotsCards[x][y-1].get_node("Template").set_texture(flip(x,y-1,color))

				if x+1 < 3:
					if boardSlotsCards[x+1][y] != null:
						if int(boardSlotsCards[x+1][y].get_node("Label_left").text) < int(boardSlotsCards[x][y].get_node("Label_right").text):
							if boardSlotsCards[x+1][y].get_node("Template").texture.resource_path != boardSlotsCards[x][y].get_node("Template").texture.resource_path:
								var color = boardSlotsCards[x+1][y].get_node("Template").texture.resource_path
								boardSlotsCards[x+1][y].get_node("Template").set_texture(flip(x+1,y,color))
							
				if y+1 < 3:
					if boardSlotsCards[x][y+1] != null:
						if int(boardSlotsCards[x][y+1].get_node("Label_top").text) < int(boardSlotsCards[x][y].get_node("Label_bottom").text):
							if boardSlotsCards[x][y+1].get_node("Template").texture.resource_path != boardSlotsCards[x][y].get_node("Template").texture.resource_path:
								var color = boardSlotsCards[x][y+1].get_node("Template").texture.resource_path
								boardSlotsCards[x][y+1].get_node("Template").set_texture(flip(x,y+1,color))
				if x-1 >= 0:
					if boardSlotsCards[x-1][y] != null:
						if int(boardSlotsCards[x-1][y].get_node("Label_right").text) < int(boardSlotsCards[x][y].get_node("Label_left").text):
							if boardSlotsCards[x-1][y].get_node("Template").texture.resource_path != boardSlotsCards[x][y].get_node("Template").texture.resource_path:
								var color = boardSlotsCards[x-1][y].get_node("Template").texture.resource_path
								boardSlotsCards[x-1][y].get_node("Template").set_texture(flip(x-1,y,color))
								
func flip(x,y,color):
	if color == "res://Assets/images/card_red.png":
		return bluecard
	else:
		return redcard
		
func checkGameEnd():
	if turnCount == 9:
		emit_signal("endgame")
		isPlayerTurn = null
		return
		
func trigEffect(card):
	var effect = EFFECT.instance()
	add_child(effect)
	effect.global_position = card.position + Vector2(60,90)

func _on_TripleTriad_cardHover(card):
	if card.clickable == true:
		card.scale = Vector2(1.1,1.1)

func _on_TripleTriad_cardSelected(card):
	card.scale = Vector2(1.2,1.2)
		
func _on_TripleTriad_endgame():
	var scorePlayer = 0
	var scoreComputer = 0 
	for x in boardSlotsCards.size():
		for y in boardSlotsCards.size():
			var color = boardSlotsCards[x][y].get_node("Template").texture.resource_path
			if color == "res://Assets/images/card_blue.png":
				scorePlayer += 1
			else:
				scoreComputer += 1
	if scorePlayer > scoreComputer:
		get_node("Status").text = 'PLAYER WINS'
	elif scorePlayer < scoreComputer:
		get_node("Status").text = 'COMPUTER WINS'
	else:
		get_node("Status").text = 'MATCH DRAW'
		
func _on_restartButton_pressed():
	get_tree().change_scene("res://Scenes/TripleTriad.tscn")

func _on_menuButton_pressed():
	get_tree().change_scene("res://Scenes/Menu.tscn")

func _on_quitButton_pressed():
	get_tree().quit()
