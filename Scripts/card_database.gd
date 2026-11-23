# # ---------- card_database.gd ----------
# draws from card_data to fill in card stats

class_name CardDatabase

const CARDS = {
	"BallAndChain": preload("res://Cards/ballandchain.tres"),
	"Bandage": preload("res://Cards/bandage.tres"),
	"Bloodbag": preload("res://Cards/bloodbag.tres"),
	"Bow": preload("res://Cards/bow.tres"),
	"Crossbow": preload("res://Cards/crossbow.tres"),
	"Dagger": preload("res://Cards/dagger.tres"),
	"Elixer": preload("res://Cards/elixer.tres"),
	"Molotov": preload("res://Cards/molotov.tres"),
	"Sword": preload("res://Cards/sword.tres"),
	"SmThrall": preload("res://Cards/smthrall.tres"),
	"MdThrall": preload("res://Cards/mdthrall.tres"),
	"LgThrall": preload("res://Cards/lgthrall.tres")
}

# returns a loaded .tres file of a card after matching it by name
static func get_card(card_name: String) -> CardData:
	# if card_name doesn't match database
	if not CARDS.has(card_name):
		push_error("Card not in database: " + card_name)
		return null
	return CARDS[card_name]
