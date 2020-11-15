extends StaticBody2D

var value = 5

func _process(_delta):
	if value <= 0:
		self.queue_free()


func decrement_value(val=1):
#	$ColorRect.rect_scale -= $ColorRect.rect_scale/value
	$Label.rect_scale -= $Label.rect_scale/value
	value -= val