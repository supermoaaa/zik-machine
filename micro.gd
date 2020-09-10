extends ColorRect


# Declare member variables here. Examples:

var bus_delay = "none"

func _ready():
	pass # Replace with function body.


func _on_ButtonMicro_toggled(button_pressed):
	if button_pressed == true:
		$AudioMicro.play()
	else:
		$AudioMicro.stop()


func _on_Vol_mic_Slider_value_changed(value):
	$AudioMicro.volume_db = value


func _on_Button_toggled(button_pressed):
	if button_pressed == true:
		$micro_effect_Panel.show()
	if button_pressed == false:
		$micro_effect_Panel.hide()



func _on_micro_effect_Panel_modal_closed():
	if $effect_bt.pressed == true:
		$effect_bt.pressed = false


func _on_Button_delay_on_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.set_bus_effect_enabled ( 1, 1, true )
		$micro_effect_Panel/Button_delay_on.text = "off"
	else:
		AudioServer.set_bus_effect_enabled ( 1, 1, false )
		$micro_effect_Panel/Button_delay_on.text = "on"


func _on_HSlider_value_changed(value):
		AudioServer.get_bus_effect(1, 1).set_tap1_delay_ms(value)


func _on_Check_feedback_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.get_bus_effect(1, 1).set_feedback_active(true)
		
	else:
		AudioServer.get_bus_effect(1, 1).set_feedback_active(false)


func _on_HSlider2_value_changed(value):
		AudioServer.get_bus_effect(1, 1).set_tap2_delay_ms(value)


func _on_HSlider3_value_changed(value):
	AudioServer.get_bus_effect(1, 1).set_feedback_delay_ms(value)


func _on_Button_phaser_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.set_bus_effect_enabled ( 1, 2, true )
		$micro_effect_Panel/Button_phaser.text = "off"
	else:
		AudioServer.set_bus_effect_enabled ( 1, 2, false )
		$micro_effect_Panel/Button_phaser.text = "on"


func _on_feed_phaser_scroll_value_changed(value):
	AudioServer.get_bus_effect(1, 2).set_feedback(value/10)

func _on_HSlider_deth_phaser_value_changed(value):
	AudioServer.get_bus_effect(1, 2).set_depth(value/10)
