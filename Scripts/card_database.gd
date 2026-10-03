# # ---------- card_database.gd ----------
# draws from card_data to fill in card stats

class_name CardDatabase

const CARDS = {
	"Sword": preload("res://Cards/sword.tres"),
	"Crossbow": preload("res://Cards/crossbow.tres"),
	"Dagger": preload("res://Cards/dagger.tres")
}

# returns a loaded .tres file of a card after matching it by name
static func get_card(card_name: String) -> CardData:
	# if card_name doesn't match database
	if not CARDS.has(card_name):
		push_error("Card not in database: " + card_name)
		return null
	return CARDS[card_name]
