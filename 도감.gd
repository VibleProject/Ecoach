extends Control

var characters = [
	"1 모찌찌", "2 세모모", "3 뭉게게", "4 나무무",
	"5 슝슝이", "6 클로로", "7 돌돌이", "8 별별이",
	"9 유유이", "10 워터터", "11 퐁퐁이", "12 햄스스",
	"13 푸푸리", "14 플로로", "15 룽룽이", "16 동동이",
	"17 쫀쪼니", "18 삐요요", "19 야야옹", "20 삼삼이",
	"21 사보보", "22 플플이", "23 뭉치치", "24 둥둥이"
]

var unlocked: Array:
	get: return Global.unlocked

var current_page: int = 0

@onready var page1 = $"1페이지"
@onready var page2 = $"2페이지"
@onready var popup = $팝업
@onready var popup_image = $팝업/TextureRect

func _ready():
	popup.visible = false
	call_deferred("update_page")

func update_page():
	page1.visible = (current_page == 0)
	page2.visible = (current_page == 1)
	for i in range(12):
		var card = page1.get_node("카드%d" % (i + 1))
		card.get_node("TextureRect").visible = !unlocked[i]
	for i in range(12):
		var card = page2.get_node("카드%d" % (i + 13))
		card.get_node("TextureRect").visible = !unlocked[i + 12]

func show_popup(char_index: int):
	var variant = randi() % 3 + 1
	var path = "res://collection/details/%s%d.png" % [characters[char_index], variant]
	popup_image.texture = load(path)
	popup.visible = true
	popup.move_to_front()

func _input(event):
	if popup.visible and event is InputEventMouseButton and event.pressed:
		popup.visible = false

func _on_page1_button_pressed():
	current_page = 0
	update_page()

func _on_page2_button_pressed():
	current_page = 1
	update_page()

# 1페이지 카드
func _on_카드1_texture_button_pressed():
	if unlocked[0]: show_popup(0)

func _on_카드2_texture_button_pressed():
	if unlocked[1]: show_popup(1)

func _on_카드3_texture_button_pressed():
	if unlocked[2]: show_popup(2)

func _on_카드4_texture_button_pressed():
	if unlocked[3]: show_popup(3)

func _on_카드5_texture_button_pressed():
	if unlocked[4]: show_popup(4)

func _on_카드6_texture_button_pressed():
	if unlocked[5]: show_popup(5)

func _on_카드7_texture_button_pressed():
	if unlocked[6]: show_popup(6)

func _on_카드8_texture_button_pressed():
	if unlocked[7]: show_popup(7)

func _on_카드9_texture_button_pressed():
	if unlocked[8]: show_popup(8)

func _on_카드10_texture_button_pressed():
	if unlocked[9]: show_popup(9)

func _on_카드11_texture_button_pressed():
	if unlocked[10]: show_popup(10)

func _on_카드12_texture_button_pressed():
	if unlocked[11]: show_popup(11)

# 2페이지 카드
func _on_카드13_texture_button_pressed():
	if unlocked[12]: show_popup(12)

func _on_카드14_texture_button_pressed():
	if unlocked[13]: show_popup(13)

func _on_카드15_texture_button_pressed():
	if unlocked[14]: show_popup(14)

func _on_카드16_texture_button_pressed():
	if unlocked[15]: show_popup(15)

func _on_카드17_texture_button_pressed():
	if unlocked[16]: show_popup(16)

func _on_카드18_texture_button_pressed():
	if unlocked[17]: show_popup(17)

func _on_카드19_texture_button_pressed():
	if unlocked[18]: show_popup(18)

func _on_카드20_texture_button_pressed():
	if unlocked[19]: show_popup(19)

func _on_카드21_texture_button_pressed():
	if unlocked[20]: show_popup(20)

func _on_카드22_texture_button_pressed():
	if unlocked[21]: show_popup(21)

func _on_카드23_texture_button_pressed():
	if unlocked[22]: show_popup(22)

func _on_카드24_texture_button_pressed():
	if unlocked[23]: show_popup(23)
	
	
func _on_x_버튼_pressed():
	get_tree().change_scene_to_file("res://MainHome.tscn")
