extends HTTPRequest

var search_url = 'http://users.ox.ac.uk/cgi-bin/safeperl/sann5290/searchme.pl'


func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	var world = get_parent().get_node("World")
	get_parent().get_node("World").responses = response["vals"]
	
	var opp = get_parent().get_node('Control').get_node("ImportInput").text
	for resp in response["vals"]:
		if resp["player_id"] == int(opp):
			world.civ_stats_t2 = {"Nest Range" : resp["Nest Range"], "Courtiers" : resp["Courtiers"], "Ex. Food" : resp["Ex. Food"]}
			world.t2_stats_dict = {'Speed': resp["Speed"], 'Vision': resp["Vision"], 'Damage':resp["Damage"], 'Health':resp["Health"],
					'Carrying':resp["Carrying"], 'Lifespan':resp["Lifespan"], 'Scouting':resp["Scouting"], 'Aggressive':resp["Aggressive"]}
			world.team_2_id = resp["player_id"]
			world.get_node('Team2AntsLabel2').text = 'Player: ' + str(resp["player_id"])

func _on_Button5_button_up():
	self.connect("request_completed", self, "_http_request_completed")
	var error = self.request(search_url)
