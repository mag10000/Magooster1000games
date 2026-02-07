extends ColorRect
var usrn = OS.get_environment("USERNAME")
var method = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	Lootlocker.logged_in.connect(logged_in)
	Lootlocker.error.connect(error)

func logged_in(data):
	$VBoxContainer/linedits.show()
	var new_data = data
	new_data["pass"] = $VBoxContainer/linedits/pass.text
	$"../.."._save("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\data\\auto_login.dat",new_data)
	var pass_data = data
	pass_data["done"] = true
	$"../.."._save("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\data\\data.dat",pass_data)
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func error(text):
	$VBoxContainer/linedits.show()
	$VBoxContainer/linedits/RichTextLabel.text = text

func _on_login_pressed():
	method = "login"
	$VBoxContainer/linedits/usrnm.hide()
	$VBoxContainer/linedits.show()
	$VBoxContainer/login.hide()
	$VBoxContainer/signup.hide()


func _on_signup_pressed():
	method = "signup"
	$VBoxContainer/linedits.show()
	$VBoxContainer/login.hide()
	$VBoxContainer/signup.hide()


func _on_button_pressed():
	if method == "signup":
		Lootlocker.email = $VBoxContainer/linedits/mail.text
		Lootlocker.password = $VBoxContainer/linedits/pass.text
		Lootlocker.player_name = $VBoxContainer/linedits/usrnm.text
		$VBoxContainer/linedits.hide()
		Lootlocker._white_label_signup()
	if method == "login":
		Lootlocker.email = $VBoxContainer/linedits/mail.text
		Lootlocker.password = $VBoxContainer/linedits/pass.text
		$VBoxContainer/linedits.hide()
		Lootlocker._white_label_login()


func _on_visibility_changed():
	if visible:
		var json1 = JSON.new()
		var dat_data = json1.parse_string($"../.."._load("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\data\\data.dat"))
		if dat_data:
			if dat_data.has("game_name"):
				$RichTextLabel.text += dat_data["game_name"]
			else:
				$RichTextLabel.text = "[b]Sign in to 3rd party application"
		if FileAccess.file_exists("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\data\\auto_login.dat"):
			var data = $"../.."._load("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\data\\auto_login.dat")
			var json = JSON.new()
			data = json.parse_string(data)
			data["done"] = true
			data.erase("pass")
			$"../.."._save("C:\\Users\\" + usrn + "\\Documents\\Magooster1000_games\\data\\data.dat",data)
			get_tree().quit()
