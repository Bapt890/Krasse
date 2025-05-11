extends Area2D

enum Faction {PLAYER, ENEMY} # Système de factions ( à déplacer en global )

@export var faction : Faction = Faction.ENEMY

func _ready():
	update_visual()
	
func update_visual(): #Fonction qui change la couleur de la base en fonction de la faction
	match faction:
		Faction.PLAYER:
			$Sprite2D.modulate = Color(0.2, 0.6, 1.0) #Bleu
			if $Label:
				$Label.text="Allié"
		Faction.ENEMY:
			$Sprite2D.modulate = Color(1.0, 0.2, 0.2) #Rouge
			if $Label:
				$Label.text="Ennemi"
				
func _input_event(_viewport, event, _shape_idx): #Fonction créant un popup sur clic gauche d'un batiment
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if faction == Faction.PLAYER: # Popup seulement sur une base alliée
			BoutiquePanel.position = Vector2(500, 500) #Position du popup
			BoutiquePanel.popup()
