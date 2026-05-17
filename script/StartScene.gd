extends Node2D

@onready var bottle_button   = $CanvasLayer/Control/BottleButton
@onready var outlet_button   = $CanvasLayer/Control/OutletButton
@onready var receipt_button  = $CanvasLayer/Control/ReceiptButton
@onready var shopping_button = $CanvasLayer/Control/ShoppingButton
@onready var tumbler_button  = $CanvasLayer/Control/TumblerButton
@onready var transit_button  = $CanvasLayer/Control/TransitButton

@onready var money_label = $Moneybar/MoneyLabel
@onready var timer_label = $TimerLabel


# 버튼 안 Sprite2D
@onready var bottle_sprite   = $CanvasLayer/Control/BottleButton/Bottle
@onready var outlet_sprite   = $CanvasLayer/Control/OutletButton/Outlet
@onready var receipt_sprite  = $CanvasLayer/Control/ReceiptButton/Receipt
@onready var shopping_sprite = $CanvasLayer/Control/ShoppingButton/Shopping
@onready var tumbler_sprite  = $CanvasLayer/Control/TumblerButton/Tumbler
@onready var transit_sprite  = $CanvasLayer/Control/TransitButton/Transit


const BUTTON_POSITIONS = [
	Vector2(-643, 180),
	Vector2(-643, 360),
	Vector2(-643, 540),
	Vector2(-643, 720),
]


# 클리어 이미지
const CLEAR_IMAGES = {
	"bottle": preload("res://templates/BottleClear.png"),
	"outlet": preload("res://templates/OutletClear.png"),
	"receipt": preload("res://templates/ReceiptClear.png"),
	"shopping": preload("res://templates/ShoppingClear.png"),
	"tumbler": preload("res://templates/TumblerClear.png"),
	"transit": preload("res://templates/TransitClear.png")
}


func _ready():

	money_label.text = str(Global.money)

	bottle_button.pressed.connect(_on_mission_selected.bind("bottle"))
	outlet_button.pressed.connect(_on_mission_selected.bind("outlet"))
	receipt_button.pressed.connect(_on_mission_selected.bind("receipt"))
	shopping_button.pressed.connect(_on_mission_selected.bind("shopping"))
	tumbler_button.pressed.connect(_on_mission_selected.bind("tumbler"))
	transit_button.pressed.connect(_on_mission_selected.bind("transit"))

	Global.check_daily_reset()

	var button_map = {
		"bottle": bottle_button,
		"outlet": outlet_button,
		"receipt": receipt_button,
		"shopping": shopping_button,
		"tumbler": tumbler_button,
		"transit": transit_button
	}

	var sprite_map = {
		"bottle": bottle_sprite,
		"outlet": outlet_sprite,
		"receipt": receipt_sprite,
		"shopping": shopping_sprite,
		"tumbler": tumbler_sprite,
		"transit": transit_sprite
	}

	# 전부 숨기기
	for btn in button_map.values():

		btn.visible = false
		btn.disabled = true

	# daily 미션만 표시
	for i in range(Global.daily_missions.size()):

		var category = Global.daily_missions[i]

		var btn = button_map[category]

		btn.visible = true
		btn.position = BUTTON_POSITIONS[i]

		# 클리어 여부
		if Global.is_mission_cleared(category):

			btn.disabled = true

			# 이미지 변경
			sprite_map[category].texture = CLEAR_IMAGES[category]

		else:

			btn.disabled = false


func _process(delta):

	var remaining = Global.get_remaining_time()

	var hours = remaining / 3600
	var minutes = (remaining % 3600) / 60
	var seconds = remaining % 60

	timer_label.text = (
		"리셋까지 "
		+ "%02d:%02d:%02d" % [hours, minutes, seconds]
	)


func _on_mission_selected(category: String):

	if Global.is_mission_cleared(category):
		return

	Global.current_category = category

	get_tree().change_scene_to_file("res://scene/UploadScene.tscn")


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://MainHome.tscn")
