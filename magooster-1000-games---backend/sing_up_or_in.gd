extends Node2D
func _ready():
	DisplayServer.window_set_title("magnus browser | home")
	update_check()
	#Lootlocker.logged_in.connect(logged_in)
	#Lootlocker._white_label_login()

func logged_in(data):
	print(data)

func update_check():
	var usrn = OS.get_environment("USERNAME")
	if not OS.get_executable_path().contains("documents"):
		if FileAccess.file_exists("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games"):
			OS.shell_open("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\app\\magooster1000backend.exe")
			get_tree().quit()
		else:
			$"ui/loading/load text".text = "[b][wave]Updating..."
			DirAccess.make_dir_absolute("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games")
			DirAccess.make_dir_absolute("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\app")
			DirAccess.make_dir_absolute("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\data")
	var http = HTTPRequest.new()
	add_child(http)
	http.request("https://github.com/mag10000/Magooster1000games/commits")
	http.request_completed.connect(update_p2)

func update_p2(result, response_code, headers, body):
	var usrn = OS.get_environment("USERNAME")
	var stuff = body.get_string_from_utf8()
	_save("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\data\\update.html",stuff)


func _save(path,stuff):
	pass

func _load(path):
	pass
