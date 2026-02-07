extends Node

signal logged_in(data : Dictionary)

#General Variables

var session_id = ''
var game_key = 'dev_fd6dc9c433104330aaa8887cf587c419'
var game_version = '1.0.0.0'
var platform = ''
var score = 0
var player_name = 'Magnus'
var leaderboard_id = 'leaderboard-id'
var public_uid = ''

#Guest Login Variables

var player_identifier = ''

#White Label Variables

var email = 'magnus.knisely@gmail.com'
var password = 'v1cuppy#'
var token = ''
var domain_key = 'zk3x9evv'

var log_in_data = {}

#HTTP Request

var guest_login_http = HTTPRequest.new()
var white_label_auth_http = HTTPRequest.new()

var white_label_signup_http = HTTPRequest.new()
var white_label_login_http = HTTPRequest.new()

var leaderboard_http = HTTPRequest.new()
var submit_score_http = HTTPRequest.new()

var get_player_name_http = HTTPRequest.new()
var set_player_name_http = HTTPRequest.new()

#Errors

func _ready():
	
	add_child(set_player_name_http)
	add_child(get_player_name_http)
	
	add_child(submit_score_http)
	add_child(leaderboard_http)
	
	add_child(white_label_login_http)
	add_child(white_label_signup_http)
	
	add_child(white_label_auth_http)
	add_child(guest_login_http)
	
	guest_login_http.request_completed.connect(_guest_login_request_completed)
	white_label_auth_http.request_completed.connect(_white_label_auth_request_completed)
	
	white_label_login_http.request_completed.connect(_white_label_login_request_completed)
	white_label_signup_http.request_completed.connect(_white_label_signup_request_completed)
	
	leaderboard_http.request_completed.connect(_get_leaderboard_request_completed)
	submit_score_http.request_completed.connect(_submit_score_request_completed)
	
	get_player_name_http.request_completed.connect(_get_player_name_request_completed)
	set_player_name_http.request_completed.connect(_set_player_name_request_completed)

func _guest_login():
	if !FileAccess.file_exists('user://LootLockerGuest.data'):
		var new_file = FileAccess.open('user://LootLockerGuest.data', FileAccess.WRITE)
		new_file.store_string('')
		new_file.close()
	var file = FileAccess.open('user://LootLockerGuest.data', FileAccess.READ)
	#print(file.get_as_text())
	player_identifier = file.get_as_text()
	file.close()

	
	var headers = ['Content-Type: application/json']
	var data = {'game_key': game_key, 'game_version': game_version}
	
	
	if player_identifier.length() != 0:
		data = {'game_key': game_key, 'game_version': game_version, 'player_identifier': player_identifier}
	
	guest_login_http.request('https://api.lootlocker.io/game/v2/session/guest', headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	

func _guest_login_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if json.has('error'):
		push_error(json.message)
	else:
		var file = FileAccess.open('user://LootLockerGuest.data',FileAccess.WRITE)
		#print(json.player_identifier)
		file.store_string(json.player_identifier)
		file.close()
		session_id = json.session_token
		public_uid = json.public_uid
		
		print('Logged in as a guest')

var redirect = "set"
func _white_label_auth():
	var headers = ['Content-Type: application/json']
	var data = {'game_key': game_key, 'email': email, 'token': token, 'game_version': game_version}
	
	white_label_auth_http.request('https://api.lootlocker.io/game/v2/session/white-label', headers, HTTPClient.METHOD_POST, JSON.stringify(data))

func _white_label_auth_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if json.has('error'):
		push_error(json.message)
	else:
		session_id = json.session_token
		print('Authentication Succesful')
		if redirect == "set":
			_set_player_name()
		else:
			_get_player_name()
	

func _white_label_login():
	var headers = ['domain-key:' + domain_key, 'Content-Type: application/json','is-development: true']
	var data = {'email': email, 'password': password, 'remember': true}

	white_label_login_http.request('https://api.lootlocker.io/white-label-login/login', headers, HTTPClient.METHOD_POST, JSON.stringify(data))

func _white_label_login_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())

	if json.has('error'):
		push_error(json.message)
	else:
		token = json.session_token
		print('Succesfully logged in')
		if redirect != "OVERRIDE":
			redirect = "get"
		else:
			redirect = "set"
		log_in_data["email"] = json.email
		_white_label_auth()


func _white_label_signup():
	var headers = ['domain-key:' + domain_key, 'Content-Type: application/json', 'is-development: true' ]
	var data = {'email': email, 'password': password}
	

	white_label_signup_http.request('https://api.lootlocker.io/white-label-login/sign-up', headers, HTTPClient.METHOD_POST, JSON.stringify(data))

func _white_label_signup_request_completed(_result, response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if response_code == 200:
		print('Signup worked')
		redirect = "OVERRIDE"
		_white_label_login()
	elif  json.has('error'):
		push_error(json.message)
	else:
		push_error('Not an email')

func _get_player_name():
	var headers = ['x-session-token: ' + session_id, 'LL-version: 2021-03-01', 'Content-Type: application/json']
	get_player_name_http.request('https://api.lootlocker.io/game/player/name', headers, HTTPClient.METHOD_GET, '')

func _get_player_name_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if json.has('name'):
		player_name = json.name
		print('Pulled player name from lootlocker')
		print(player_name)
		log_in_data["display_name"] = player_name
		logged_in.emit(log_in_data)
	if json.has('error'):
		push_error(json.message)

func _set_player_name():
	print(session_id)
	var headers = ['x-session-token:' + session_id, 'LL-version: 2021-03-01', 'Content-Type: application/json']
	var data = {'name': player_name}

	set_player_name_http.request('https://api.lootlocker.io/game/player/name', headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))

func _set_player_name_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if json.has('error'):
		push_error(json.message)
	else:
		print(json)
		#print('Player name set to ' + json.name)

func _get_leaderboard():
	var headers = ['x-session-token:' + session_id]
	
	leaderboard_http.request('https://api.lootlocker.io/game/leaderboards/'+leaderboard_id+'/list?count=10', headers,HTTPClient.METHOD_GET, '')

func _get_leaderboard_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json.has('error'):
		push_error(json.message)
	else:
		print('LeaderBoard pulled form lootlocker:')
		print(json.items)


func _submit_score():
	var headers = ['x-session-token:' + session_id, 'Content-Type: application/json']
	var data = {'score': score}

	submit_score_http.request('https://api.lootlocker.io/game/leaderboards/' +session_id + '/submit', headers, HTTPClient.METHOD_POST, JSON.stringify(data))

func _submit_score_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if json.has('error'):
		push_error(json.message)
