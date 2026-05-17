extends Node2D

const SERVER_URL = "https://vible-django.onrender.com/analyze/api/verify/"


@onready var upload_button = $CanvasLayer/Control/UploadButton
@onready var upload_sprite = $CanvasLayer/Control/UploadButton/Upload

@onready var back_button = $CanvasLayer/Control/BackButton

@onready var mission_sprite = $MissionSprite

@onready var http_request = $AnalyzeRequest
@onready var image_dialog = $ImageDialog

@onready var warning_sprite = $WarningSprite

@onready var money_label = $Moneybar/MoneyLabel

const TITLES = {
	"bottle":   "페트병 분리배출 인증",
	"outlet":   "콘센트 안전 점검",
	"receipt":  "전자영수증 인증",
	"shopping": "장바구니 사용 인증",
	"tumbler":  "텀블러 사용 인증",
	"transit":  "대중교통 이용 인증",
}


const MISSION_IMAGES = {
	"bottle": preload("res://templates/Bottle.png"),
	"outlet": preload("res://templates/Outlet.png"),
	"receipt": preload("res://templates/Receipt.png"),
	"shopping": preload("res://templates/Shopping.png"),
	"tumbler": preload("res://templates/Tumbler.png"),
	"transit": preload("res://templates/Transit.png"),
}


const WARNING_IMAGES = {
	"bottle": preload("res://templates/BottleWarning.png"),
	"outlet": preload("res://templates/OutletWarning.png"),
	"receipt": preload("res://templates/ReceiptWarning.png"),
	"shopping": preload("res://templates/ShoppingWarning.png"),
	"tumbler": preload("res://templates/TumblerWarning.png"),
	"transit": preload("res://templates/TransitWarning.png"),
}


# 업로드 스프라이트 이미지
const UPLOAD_NORMAL = preload("res://templates/Upload.png")
const UPLOAD_LOADING = preload("res://templates/Uploading.png")

func _ready():
	money_label.text = str(Global.money)

	upload_button.pressed.connect(_on_upload_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

	http_request.request_completed.connect(_on_request_completed)
	image_dialog.file_selected.connect(_on_file_selected)

	var cat = Global.current_category

	warning_sprite.texture = WARNING_IMAGES.get(cat)

	mission_sprite.texture = MISSION_IMAGES.get(cat)

	# 기본 업로드 이미지
	upload_sprite.texture = UPLOAD_NORMAL
	


func _on_upload_button_pressed():

	image_dialog.popup_centered_clamped(Vector2i(800, 600))


func _on_file_selected(path: String):

	upload_button.disabled = true

	# 업로드중 이미지 변경
	upload_sprite.texture = UPLOAD_LOADING

	send_image_to_django(path, Global.current_category)


func send_image_to_django(image_path: String, category: String):

	if not FileAccess.file_exists(image_path):

		upload_button.disabled = false
		upload_sprite.texture = UPLOAD_NORMAL
		return

	var file = FileAccess.open(image_path, FileAccess.READ)
	var image_buffer = file.get_buffer(file.get_length())

	var boundary = "---------------------------GodotBoundary"
	var body = PackedByteArray()

	body.append_array(("--" + boundary + "\r\n").to_utf8_buffer())
	body.append_array(("Content-Disposition: form-data; name=\"category\"\r\n\r\n").to_utf8_buffer())
	body.append_array((category + "\r\n").to_utf8_buffer())

	body.append_array(("--" + boundary + "\r\n").to_utf8_buffer())
	body.append_array(("Content-Disposition: form-data; name=\"image\"; filename=\"upload.jpg\"\r\n").to_utf8_buffer())
	body.append_array(("Content-Type: image/jpeg\r\n\r\n").to_utf8_buffer())

	body.append_array(image_buffer)

	body.append_array(("\r\n--" + boundary + "--\r\n").to_utf8_buffer())

	var headers = [
		"Content-Type: multipart/form-data; boundary=" + boundary
	]

	http_request.request_raw(
		SERVER_URL,
		headers,
		HTTPClient.METHOD_POST,
		body
	)


func _on_request_completed(_result, response_code, _headers, body):

	upload_button.disabled = false

	# 원래 업로드 이미지로 복구
	upload_sprite.texture = UPLOAD_NORMAL

	if response_code == 200:

		var json = JSON.new()

		if json.parse(body.get_string_from_utf8()) == OK:

			Global.last_result = json.get_data()

			# 한 프레임 기다린 뒤 씬 변경
			await get_tree().process_frame

			call_deferred("_go_to_result")

		else:
			push_error("JSON 파싱 실패")

	else:
		push_error("서버 오류: " + str(response_code))


func _go_to_result():

	get_tree().change_scene_to_file("res://scene/ResultScene.tscn")


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scene/StartScene.tscn")

# 이거 메인 씬으로 연결해줘
func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://scene/StartScene.tscn") # << 여기
