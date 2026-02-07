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
	if stuff != _load("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\data\\update.html"):
		install_exe()
	_save("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\data\\update.html",stuff)

func install_exe():
	var usrn = OS.get_environment("USERNAME")
	_save("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\new_ver.zip","TEMPORARY")
	print("installing from github")
	$download_new_ver.download_file = "C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\new_ver.zip"#https://github.com/mag10000/Magooster1000games/archive/refs/heads/Mag-Branch.zip
	$download_new_ver.request("https://github.com/mag10000/Magooster1000games/archive/refs/heads/Mag-Branch.zip")

func _save(path,stuff):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(str(stuff))
	file.close()
	file = null


func _load(path):
	return FileAccess.get_file_as_string(path)


func _on_download_new_ver_request_completed(result, response_code, headers, body):
	extract_all_from_zip()

func extract_all_from_zip():
	var usrn = OS.get_environment("USERNAME")
	var reader = ZIPReader.new()
	reader.open("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\new_ver.zip")

	# Destination directory for the extracted files (this folder must exist before extraction).
	# Not all ZIP archives put everything in a single root folder,
	# which means several files/folders may be created in `root_dir` after extraction.
	var root_dir = DirAccess.open("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\app\\")

	var files = reader.get_files()
	for file_path in files:
		# If the current entry is a directory.
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue

		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)
