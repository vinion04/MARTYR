# # ---------- combat_manager.gd ----------
# used to deal combat damage to cards and player/vampire lord base health
extends Node

# ----- CONSTANTS -----
const LANE_DELAY = .5

# ----- VARIABLES -----
# board manager reference to pull slot info
var board_manager_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set ref
	board_manager_ref = $"../BoardManager"

# used to resolve combat in sections (player then vampire)
func resolve_all_lanes():
	await player_attack_phase()
	await vampire_attack_phase()

# player goes first, cards hit across from them
func player_attack_phase():
	for lane in board_manager_ref.player_slots.size():
		# get the cards from the lane
		var p_card = board_manager_ref.get_card_in(board_manager_ref.player_slots[lane])
		var v_card = board_manager_ref.get_card_in(board_manager_ref.vampire_slots[lane])
		# if there's no player card, move on
		if p_card == null:
			continue
		# store the damage of the player card
		var dmg = get_attack(p_card)
		# if there is a vampire card, take damage
		if v_card:
			v_card.take_damage(dmg)
			# debug
			print("lane ", lane, ": player card hits thrall for ", dmg)
			# remove vampire card if dead
			remove_if_dead(v_card)
		else:
			# IMPLEMENT VAMPIRE HEALTH DECREASE HERE
			print("lane ", lane, ": open lane, player card unopposed")
			# pause before next lane resolve
		await get_tree().create_timer(LANE_DELAY).timeout

# vampire goes second, thralls that survive hit back
func vampire_attack_phase():
	for lane in board_manager_ref.vampire_slots.size():
		# get the cards from the lane
		var p_card = board_manager_ref.get_card_in(board_manager_ref.player_slots[lane])
		var v_card = board_manager_ref.get_card_in(board_manager_ref.vampire_slots[lane])
		# if there's no vamp card, move on
		if v_card == null:
			continue
		# store the damage of the vamp card
		var dmg = get_attack(v_card)
		# if there is a player card, take damage
		if p_card:
			p_card.take_damage(dmg)
			# debug
			print("lane ", lane, ": thrall card hits player for ", dmg)
			# remove player card if dead
			remove_if_dead(p_card)
		else:
			# IMPLEMENT PLAYER HEALTH DECREASE HERE
			print("lane ", lane, ": open lane, thrall card unopposed")
			# pause before next action
		await get_tree().create_timer(LANE_DELAY).timeout
		

# gets attack value from card
func get_attack(card):
	# if the card is a player 'damage' card or thrall, return attack amount
	if card.data.effect_type == CardData.EffectType.DAMAGE or card.data.category == CardData.CardArchetype.THRALL:
		return card.data.attack
	# else, no damage
	return 0
	
# removes a card if health < 0
func remove_if_dead(card):
	if card.current_health <= 0:
		board_manager_ref.remove_card(card.current_slot)
		# deletes card node from game
		card.queue_free()
