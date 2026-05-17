extends Control

var count_o2: int:
	get: return Global.count_o2
	set(value): Global.count_o2 = value
var count_water: int:
	get: return Global.count_water
	set(value): Global.count_water = value
var money: int:
	get: return Global.money
	set(value): Global.money = value

var char_names = [
	"모찌찌", "세모모", "뭉게게", "나무무",
	"슝슝이", "클로로", "돌돌이", "별별이",
	"유유이", "워터터", "퐁퐁이", "햄스스",
	"푸푸리", "플로로", "룽룽이", "동동이",
	"쫀쪼니", "삐요요", "야야옹", "삼삼이",
	"사보보", "플플이", "뭉치치", "둥둥이"
]

# 화 이미지 폴더의 실제 파일명 기준
var anger_char_names = [
	"모찌찌", "세모모", "뭉게게", "나무무",
	"슝슝이", "클로로", "돌돌이", "별별이",
	"유유이", "워터터", "퐁퐁이", "햄스스",
	"푸푸리", "플로로", "룽룽이", "동동이",
	"쫀쪼니", "삐요요", "야야옹", "삼삼이",
	"사보보", "플플이", "뭉치치", "둥둥이"
]

var session_feed_count: int = 0
const SESSION_FEED_MAX: int = 3
var _emotion_display_id: int = 0

# 눈물1단계 폴더 기준 (모모찌 표기)
var tear_char_names_1 = [
	"모찌찌", "세모모", "뭉게게", "나무무",
	"슝슝이", "클로로", "돌돌이", "별별이",
	"유유이", "워터터", "퐁퐁이", "햄스스",
	"푸푸리", "플로로", "룽룽이", "동동이",
	"쫀쪼니", "삐요요", "야야옹", "삼삼이",
	"사보보", "플플이", "뭉치치", "둥둥이"
]

# 웃음2단계 폴더 기준 (1단계와 달리 모모찌 표기)
var smile_char_names_2 = [
	"모찌찌", "세모모", "뭉게게", "나무무",
	"슝슝이", "클로로", "돌돌이", "별별이",
	"유유이", "워터터", "퐁퐁이", "햄스스",
	"푸푸리", "플로로", "룽룽이", "동동이",
	"쫀쪼니", "삐요요", "야야옹", "삼삼이",
	"사보보", "플플이", "뭉치치", "둥둥이"
]

var poop_scene = preload("res://Poop.tscn")

@onready var eco_bar = $환경수치바
@onready var eco_label = $TopUI/Environment/EnvironmentLabel
@onready var char_image = $캐릭터
@onready var msg_box = $메시지박스

var _char_base_pos: Vector2
var _char_base_scale: Vector2
var _is_dead: bool = false

# 죽음2단계 폴더 기준 (햄햄스 표기)
var death_char_names_2 = [
	"모찌찌", "세모모", "뭉게게", "나무무",
	"슝슝이", "클로로", "돌돌이", "별별이",
	"유유이", "워터터", "퐁퐁이", "햄스스",
	"푸푸리", "플로로", "룽룽이", "동동이",
	"쫀쪼니", "삐요요", "야야옹", "삼삼이",
	"사보보", "플플이", "뭉치치", "둥둥이"
]


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Global.save_data()
		get_tree().quit()

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	if not Global.has_character:
		Global.eco_score = 0.0
	_char_base_pos = char_image.position
	_char_base_scale = char_image.scale
	spawn_poop()
	update_character_image()
	start_bounce()
	_update_all_ui()
	_check_poop_death()

	var o2_icon = get_node_or_null("FoodButton/FoodPanel/O2Icon")
	if o2_icon:
		o2_icon.mouse_filter = Control.MOUSE_FILTER_STOP
		o2_icon.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				_on_o2_button_pressed()
		)

	var water_icon = get_node_or_null("FoodButton/FoodPanel/WaterIcon")
	if water_icon:
		water_icon.mouse_filter = Control.MOUSE_FILTER_STOP
		water_icon.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				_on_water_button_pressed()
		)

func start_bounce():
	var tween = create_tween().set_loops()
	tween.tween_property(char_image, "position:y", _char_base_pos.y - 20, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(char_image, "position:y", _char_base_pos.y, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# ── 캐릭터 이미지 ──────────────────────────────
func update_character_image():
	if not Global.has_character:
		char_image.visible = false
		return
	char_image.visible = true
	if _is_dead:
		char_image.texture = load(_get_death_char_path())
	elif Global.eco_score > 0 and Global.eco_score <= 10:
		char_image.texture = load(_get_tear_char_path())
	elif Global.eco_score >= Global.get_max_eco_score() - 20:
		char_image.texture = load(_get_smile_char_path())
	else:
		char_image.texture = load(_get_char_path())
	char_image.position = _char_base_pos
	char_image.scale = _char_base_scale

func _get_char_path(suffix: String = "") -> String:
	if Global.current_stage == 1:
		return "res://알%s.png" % suffix
	var name = char_names[Global.current_char_index]
	var img_stage = Global.current_stage - 1
	return "res://%d단계/%s_%d단계%s.png" % [img_stage, name, img_stage, suffix]

func _get_death_char_path() -> String:
	if Global.current_stage == 1:
		return "res://죽음1단계/알1단계죽음.png"
	if Global.current_stage == 2:
		return "res://죽음1단계/%s1단계죽음.png" % char_names[Global.current_char_index]
	return "res://죽음2단계/%s2단계죽음.png" % death_char_names_2[Global.current_char_index]

func show_death_image():
	_is_dead = true
	char_image.texture = load(_get_death_char_path())

func _check_poop_death() -> void:
	if not Global.has_character or _is_dead:
		return
	if Global.poop_count >= 3:
		show_death_image()
		update_eco_bar()

func _get_tear_char_path() -> String:
	if Global.current_stage == 1:
		return "res://눈물1단계/알1단계눈물.png"
	if Global.current_stage == 2:
		return "res://눈물1단계/%s1단계눈물.png" % tear_char_names_1[Global.current_char_index]
	return "res://눈물2단계/%s2단계눈물.png" % char_names[Global.current_char_index]

func _get_anger_char_path() -> String:
	var img_stage = max(1, Global.current_stage - 1)
	if Global.current_stage == 1:
		return "res://화%d단계/알%d단계화.png" % [img_stage, img_stage]
	var name = anger_char_names[Global.current_char_index]
	return "res://화%d단계/%s%d단계화.png" % [img_stage, name, img_stage]

func show_anger_image() -> void:
	if not Global.has_character:
		return
	_emotion_display_id += 1
	var my_id = _emotion_display_id
	char_image.texture = load(_get_anger_char_path())
	get_tree().create_timer(2.0).timeout.connect(func():
		if _emotion_display_id == my_id:
			update_character_image()
	)

func _get_smile_char_path() -> String:
	if Global.current_stage == 1:
		return "res://웃음1단계/알1단계.png"
	if Global.current_stage == 2:
		return "res://웃음1단계/%s1단계.png" % char_names[Global.current_char_index]
	return "res://웃음2단계/%s2단계.png" % smile_char_names_2[Global.current_char_index]

func show_smile_image() -> void:
	if not Global.has_character:
		return
	_emotion_display_id += 1
	var my_id = _emotion_display_id
	char_image.texture = load(_get_smile_char_path())
	get_tree().create_timer(2.0).timeout.connect(func():
		if _emotion_display_id == my_id:
			update_character_image()
	)

# ── 똥 ────────────────────────────────────────
func spawn_poop():
	for child in $PoopContainer.get_children():
		child.queue_free()
	if not Global.has_character:
		return
	for i in range(Global.poop_count):
		var poop = poop_scene.instantiate()
		poop.scale = Vector2(0.2, 0.2)
		poop.position = Vector2(
			randi() % 450 + 120,
			randi() % 250 + 550
		)
		$PoopContainer.add_child(poop)

# ── 환경수치 변경 ──────────────────────────────
func _change_eco(amount: float) -> void:
	if not Global.has_character:
		return
	var prev = Global.eco_score
	Global.eco_score = clamp(
		Global.eco_score + amount,
		0.0,
		Global.get_max_eco_score()
	)
	if prev > 0 and Global.eco_score == 0:
		show_death_image()
		update_eco_bar()
		return
	if amount > 0 and Global.eco_score >= Global.get_max_eco_score():
		advance_stage()
		return
	# 눈물/기쁨 구간 진입·이탈 시 즉시 이미지 갱신
	var max_eco = Global.get_max_eco_score()
	var in_cry = Global.eco_score > 0 and Global.eco_score <= 10
	var was_cry = prev > 0 and prev <= 10
	var in_happy = Global.eco_score >= max_eco - 20
	var was_happy = prev >= max_eco - 20
	if in_cry != was_cry or in_happy != was_happy:
		_emotion_display_id += 1
		update_character_image()
	update_eco_bar()

# ── 먹이기 ────────────────────────────────────
func _on_mission_done(type: String) -> void:
	if session_feed_count >= SESSION_FEED_MAX:
		show_anger_image()
		return
	match type:
		"water":
			if Global.count_water <= 0:
				return
			Global.count_water -= 1
			session_feed_count += 1
			_change_eco(15.0)
		"oxygen":
			if Global.count_o2 <= 0:
				return
			Global.count_o2 -= 1
			session_feed_count += 1
			_change_eco(50.0)
	show_smile_image()
	_update_food_panel_ui()

func _on_o2_button_pressed():
	_on_mission_done("oxygen")

func _on_water_button_pressed():
	_on_mission_done("water")

# ── 성장 ──────────────────────────────────────
func advance_stage():
	if Global.current_stage < 3:
		if Global.current_stage == 1:
			var locked = []
			for i in range(Global.unlocked.size()):
				if not Global.unlocked[i]:
					locked.append(i)
			if locked.size() > 0:
				Global.current_char_index = locked[randi_range(0, locked.size() - 1)]
		Global.current_stage += 1
		Global.eco_score = 0.0
		update_eco_bar()
		update_character_image()
	elif Global.current_stage == 3:
		graduate()

func graduate():
	Global.current_stage = 4
	Global.unlock_character(Global.current_char_index)
	Global.has_character = false
	Global.eco_score = 0.0
	update_eco_bar()
	update_character_image()
	msg_box.visible = true

# ── UI 업데이트 ────────────────────────────────
func _update_all_ui():
	update_eco_bar()
	_update_cash_ui()
	_update_food_panel_ui()

func update_eco_bar():
	eco_bar.max_value = Global.get_max_eco_score()
	var tween = create_tween()
	tween.tween_property(eco_bar, "value", Global.eco_score, 0.3)
	eco_label.text = str(int(Global.eco_score)) + "%"

func _update_cash_ui():
	$TopUI/Cash/CashLabel.text = str(money)

func _update_food_panel_ui():
	$FoodButton/FoodPanel/O2Label.text = str(count_o2) + "개"
	$FoodButton/FoodPanel/WaterLabel.text = str(count_water) + "개"

# ── 입력 ──────────────────────────────────────
func _input(event):
	if _is_dead and event is InputEventMouseButton and event.pressed:
		_is_dead = false
		Global.has_character = false
		Global.eco_score = 0.0
		Global.poop_count = 0
		_emotion_display_id += 1
		update_character_image()
		update_eco_bar()
		spawn_poop()
		return
	if msg_box.visible and event is InputEventMouseButton and event.pressed:
		msg_box.visible = false
		return


# ── 버튼 핸들러 ───────────────────────────────
func _on_texture_button_pressed():
	Global.save_data()
	get_tree().change_scene_to_file("res://store.tscn")

func _on_texture_button_2_pressed() -> void:
	pass

func _on_texture_button_3_pressed():
	Global.save_data()
	get_tree().change_scene_to_file("res://도감.tscn")

func _on_house_button_pressed() -> void:
	Global.save_data()
	get_tree().change_scene_to_file("res://scene/StartScene.tscn")

func _on_house_button_mouse_entered() -> void:
	pass

func _on_house_button_mouse_exited() -> void:
	pass

func _on_tree_button_hidden() -> void:
	pass

func _on_food_button_pressed() -> void:
	if $FoodButton/FoodPanel.visible:
		$FoodButton/FoodPanel.hide()
	else:
		session_feed_count = 0
		$FoodButton/FoodPanel.show()

func _on_tree_button_pressed():
	Global.save_data()
	get_tree().change_scene_to_file("res://main_menu.tscn")
