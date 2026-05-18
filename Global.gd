extends Node

var has_character: bool = false
var poop_count: int = 0
const POOP_MAX: int = 5
var money: int = 0
var count_o2: int = 0
var count_water: int = 0
var current_char_index: int = 0
var current_stage: int = 1
var eco_score: float = 0.0
var last_play_time: int = 0

var last_result: Dictionary = {}
var current_category: String = "bottle"

# 테스트용
# 60 = 1분
# 86400 = 24시간
const DAILY_RESET_SECONDS = 86400
const ALL_MISSIONS = ["bottle", "outlet", "receipt", "shopping", "tumbler", "transit"]

var daily_missions = []
var cleared_missions = []
var last_reset_time = 0

func check_daily_reset():
	var now = Time.get_unix_time_from_system()
	if last_reset_time == 0:
		reset_daily_missions()
		return
	if now - last_reset_time >= DAILY_RESET_SECONDS:
		reset_daily_missions()

func reset_daily_missions():
	last_reset_time = Time.get_unix_time_from_system()
	cleared_missions.clear()
	var temp = ALL_MISSIONS.duplicate()
	temp.shuffle()
	daily_missions = temp.slice(0, 4)
	print("일일 미션 리셋")
	print(daily_missions)

func is_mission_cleared(category: String) -> bool:
	return category in cleared_missions

func clear_mission(category: String):
	if category not in cleared_missions:
		cleared_missions.append(category)

func get_remaining_time() -> int:
	var now = Time.get_unix_time_from_system()
	var remaining = DAILY_RESET_SECONDS - int(now - last_reset_time)
	return max(0, remaining)

var unlocked: Array = [
	false, false, false, false, false, false,
	false, false, false, false, false, false,
	false, false, false, false, false, false,
	false, false, false, false, false, false
]

func unlock_character(index: int):
	if index >= 0 and index < unlocked.size():
		unlocked[index] = true

func get_max_eco_score() -> float:
	match current_stage:
		1: return 100.0
		2: return 150.0
		3: return 200.0
	return 100.0

# ── 저장/로드 ──────────────────────────────────
const SAVE_PATH = "user://save.json"

func _ready() -> void:
	load_data()

func save_data() -> void:
	var data = {
		"has_character": has_character,
		"current_char_index": current_char_index,
		"current_stage": current_stage,
		"eco_score": eco_score,
		"poop_count": poop_count,
		"money": money,
		"count_o2": count_o2,
		"count_water": count_water,
		"unlocked": unlocked,
		"last_reset_time": last_reset_time,
		"daily_missions": daily_missions,
		"cleared_missions": cleared_missions,
		"last_play_time": int(Time.get_unix_time_from_system())
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		return
	var data: Dictionary = json.get_data()

	has_character = data.get("has_character", false)
	current_char_index = data.get("current_char_index", 0)
	current_stage = data.get("current_stage", 1)
	eco_score = float(data.get("eco_score", 0.0))
	poop_count = data.get("poop_count", 0)
	money = data.get("money", 0)
	count_o2 = data.get("count_o2", 0)
	count_water = data.get("count_water", 0)
	unlocked = data.get("unlocked", unlocked)
	last_reset_time = data.get("last_reset_time", 0)
	daily_missions = data.get("daily_missions", [])
	cleared_missions = data.get("cleared_missions", [])
	last_play_time = data.get("last_play_time", 0)

	if has_character and last_play_time > 0:
		var now = int(Time.get_unix_time_from_system())
		var days_elapsed = int((now - last_play_time) / 86400)
		if days_elapsed > 0:
			eco_score = max(0.0, eco_score - 50.0 * days_elapsed)
		var hours_elapsed = int((now - last_play_time) / 3600)
		if hours_elapsed > 0:
			poop_count = min(POOP_MAX, poop_count + hours_elapsed)
