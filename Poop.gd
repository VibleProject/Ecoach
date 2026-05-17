extends TextureButton

var money: int:
	get: return Global.money
	set(value): Global.money = value

func _pressed():

	print("똥 클릭 성공!")

	var main = get_tree().current_scene

	main.money += 10

	Global.poop_count -= 1

	main.get_node(
		"TopUI/Cash/CashLabel"
	).text = str(main.money)

	main._change_eco(5.0)

	main.eco_label.text = str(int(Global.eco_score)) + "%"

	queue_free()
