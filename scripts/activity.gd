class_name Activity extends Node

#"b_cd": 1, # cooldown
#"b_dmg": 10,
#"b_dur": 0.25, # duration # TODO NOT USED
#"anim": "punch", # animation
#"act": "punch" # ac

var id: int = -1
var node_name: String = ""
var friendly_name: String = ""
var base_dmg: float = 5.0
var base_cd: float = 1.0 # cooldown imposed before using another activity
var animation_use: String = ""
var animation_hit: String = ""
var processed: bool = false
var requester: int = -1
var source: String = "" # TODO: probably refactor to some other name

func _init(id_: int, node_name_: String, friendly_name_: String, base_dmg_: float, base_cd_: float, animation_use_: String, animation_hit_: String):
	id = id_
	node_name = node_name_
	friendly_name = friendly_name_
	base_dmg = base_dmg_
	base_cd = base_cd_
	animation_use = animation_use_
	animation_hit = animation_hit_
