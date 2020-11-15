extends HTTPRequest

var logger_url = 'http://users.ox.ac.uk/cgi-bin/safeperl/sann5290/test.pl'

func _on_Button4_button_up():
	self.send_data({'one':'1'})


func send_data(message=null):
	var jstr = JSON.print(message)
	var dict = {'message': jstr}
	_make_post_request(logger_url, dict, false)


func _make_post_request(url, data_to_send, use_ssl):
	var query = _format_request(data_to_send)
	print(query)
	var headers = ["Content-Type: application/x-www-form-urlencoded", 'Content-Length: '+ str(query.length())]
	var _result = self.request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)
	print(_result)


# Format dict to valid form query
func _format_request(query_dict):
	var string = ''
	for i in query_dict:
		if query_dict[i]:
			string += i + '='
			string += query_dict[i]
			string += '&'
	string.erase(string.length() - 1, 1)
	return string


func _on_ExportButton_button_up():
	var world = get_parent().get_node("World")
	var data = {}
	data['player_id'] = world.player_id
	for key in world.civ_stats_t1:
		data[key] = world.civ_stats_t1[key]
	for key in world.t1_stats_dict:
		data[key] = world.t1_stats_dict[key]
	self.send_data(data)
