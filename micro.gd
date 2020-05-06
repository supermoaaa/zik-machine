extends ColorRect


# Declare member variables here. Examples:
# var a = 2
var bus_delay = "none"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


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
