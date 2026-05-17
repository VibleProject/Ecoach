extends Control

var money: int:
	get: return Global.money
	set(value): Global.money = value

var count_o2: int:
	get: return Global.count_o2
	set(value): Global.count_o2 = value
var count_water: int:
	get: return Global.count_water
	set(value): Global.count_water = value
var has_character: bool:
	get: return Global.has_character
	set(value): Global.has_character = value

const price_o2 = 500
const price_water = 100

@onready var money_label = $Control/Label
@onready var o2_label = $"산소 개수/o2_label"
@onready var water_label = $"물 개수/water_label"
@onready var egg_button = $알버튼

func _ready():
	update_display()
	egg_button.visible = !has_character

func update_display():
	money_label.text = str(money)
	o2_label.text = str(count_o2)
	water_label.text = str(count_water)

func _on_알버튼_pressed():
	if !has_character:
		has_character = true
		Global.current_stage = 1
		Global.eco_score = 0
		egg_button.visible = !has_character

func _on_산소_texture_button_pressed():
	if money >= price_o2:
		money -= price_o2
		count_o2 += 1
		update_display()

func _on_물_texture_button_pressed():
	if money >= price_water:
		money -= price_water
		count_water += 1
		update_display()

func _on_x_버튼_pressed():
	get_tree().change_scene_to_file("res://MainHome.tscn")
