extends Node2D

@onready var status_sprite = $CanvasLayer/Control/StatusSprite
@onready var reward_label  = $CanvasLayer/Control/RewardLabel

@onready var detail_btn1   = $CanvasLayer/Control/HBoxContainer/DetailButton1
@onready var detail_btn2   = $CanvasLayer/Control/HBoxContainer/DetailButton2
@onready var detail_btn3   = $CanvasLayer/Control/HBoxContainer/DetailButton3

@onready var comment_label = $CanvasLayer/Control/CommentLabel
@onready var back_button = $CanvasLayer/BackButton

@onready var money_label = $Moneybar/MoneyLabel

const SUCCESS_TEXTURE = preload("res://templates/MissionSuccess.png")
const FAILED_TEXTURE  = preload("res://templates/MissionFailed.png")


const COLOR_GOOD = Color(0.18, 0.80, 0.44)
const COLOR_BAD  = Color(0.93, 0.24, 0.24)

const REWARD_BY_CATEGORY = {
	"bottle": 700,
	"outlet": 500,
	"receipt": 500,
	"shopping": 600,
	"tumbler": 800,
	"transit": 500
}

const BUTTON_NAMES = {
	"bottle":   ["라벨", "이물질", "병뚜껑"],
	"outlet":   ["콘센트", "플러그", "주변상태"],
	"receipt":  ["전자화면", "구매내역", "일시정보"],
	"shopping": ["장바구니", "내용물", "장소"],
	"tumbler":  ["텀블러", "음료상태", "장소"],
	"transit":  ["교통UI", "이용기록", "탑승일시"],
}


func _ready():

	back_button.pressed.connect(_on_back_button_pressed)

	await get_tree().process_frame

	update_ui(Global.last_result)


func update_ui(data: Dictionary):

	if data.is_empty():
		push_error("표시할 데이터가 없습니다.")
		return

	var is_success: bool = data.get("is_success", false)

	var category = Global.current_category
	var reward: int = REWARD_BY_CATEGORY.get(category, 0)

	# 성공 시
	if is_success:

		Global.money += reward

		Global.clear_mission(category)

		money_label.text = str(Global.money)
		
	money_label.text = str(Global.money)

	# 성공 / 실패 이미지
	status_sprite.texture = (
		SUCCESS_TEXTURE
		if is_success
		else FAILED_TEXTURE
	)

	# 보상 텍스트
	reward_label.text = (
		"+" + str(reward) + " 캐시 획득!"
		if is_success
		else "보상 없음"
	)

	var details = data.get("details", {})

	var cls_vals = [
		str(details.get("cls1", "")),
		str(details.get("cls2", "")),
		str(details.get("cls3", ""))
	]

	var cat = Global.current_category

	var names = BUTTON_NAMES.get(
		cat,
		["항목1", "항목2", "항목3"]
	)

	var btns = [
		detail_btn1,
		detail_btn2,
		detail_btn3
	]

	for i in 3:

		btns[i].text = names[i]

		_set_button_color(btns[i], cls_vals[i])

	comment_label.text = str(data.get("comment", ""))


func _set_button_color(btn: Button, cls_val: String):

	var is_pass = (
		"bg-good" in cls_val
		or "bg-normal" in cls_val
		or "적합" in cls_val
		or "보통" in cls_val
	)

	var color = (
		COLOR_GOOD
		if is_pass
		else COLOR_BAD
	)

	var style = StyleBoxFlat.new()

	style.bg_color = color

	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8

	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("disabled", style)


func _on_back_button_pressed():

	get_tree().change_scene_to_file("res://scene/StartScene.tscn")
	
