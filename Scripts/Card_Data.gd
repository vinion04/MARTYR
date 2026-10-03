# # ---------- card_data.gd ----------
# extends resource because it is a container script
extends Resource
class_name CardData

enum CardArchetype {
	STANDARD_GEAR,
	RECKLESS_ARSENAL,
	COMBAT_MEDICINE,
	THRALL,
	CURSE
}

enum EffectType {
	DAMAGE,		# bow, dagger, brass knuckles, crossbow, sword, etc.
	HEAL,		# bandage, herbs, elixer, blood bag
	BLOCK_LANE,	# crucifix
	DISABLE_ENEMY,	# holy water
	DRAW_CARD,	# smoke bomb
	SHIELD,		# body armor
	SUMMON,		# place thrall
	CURSE_EFFECT	# curse (?)
}

# card data
@export_group("Card Stats")
@export var card_name: String
@export var description: String
@export var category: CardArchetype
@export var effect_type: EffectType
@export var art: Texture2D
@export var cost: int = 0	# resource cost to play
@export var attack: int = 0		# store damage
@export var health: int = 0		# store health
@export var self_damage: int = 0	# health cost to player
