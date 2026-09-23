# # ---------- combat_manager.gd ----------
# used to deal combat damage to cards and player/vampire lord
extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
#func resolve_card_effect(card: CardData, target_lane: int) -> void:
	#match card.effect_type:
		#CardData.EffectType.DAMAGE:
			#combat_manager.deal_damage(card.value, target_lane, card.hits_multiple_lanes, card.lane_count)
			#if card.self_damage > 0:
				#player_manager.take_damage(card.self_damage)
		#CardData.EffectType.HEAL:
			#player_manager.heal(card.value)
		#CardData.EffectType.BLOCK_LANE:
			#board_manager.block_lane(target_lane)
		#CardData.EffectType.DISABLE_ENEMY:
			#vampire_lord_manager.disable(card.value)
		#CardData.EffectType.DRAW_CARD:
			#deck_manager.draw(card.value)
