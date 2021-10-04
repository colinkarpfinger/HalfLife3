extends RichTextLabel
var savegame = File.new() #file
var save_path = "user://savegame.save" #place of the file
var save_data = {"highscore": 0} #variable to store data

var score = 0
var highScore = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if not savegame.file_exists(save_path):
		create_save()
	else:
		highScore = read_savegame()
		updateText()


func incrementScore():
	score += 1
	if score > highScore:
		highScore = score
	updateText()
	

func resetScore():
	save(highScore)
	score = 0
	updateText()
	
func updateText():
	text = "Score :" + str(score) + " High Score: " + str(highScore)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func save(high_score):    
   save_data["highscore"] = high_score #data to save
   savegame.open(save_path, File.WRITE) #open file to write
   savegame.store_var(save_data) #store the data
   savegame.close() # close the file

func create_save():
   savegame.open(save_path, File.WRITE)
   savegame.store_var(save_data)
   savegame.close()

func read_savegame():
   savegame.open(save_path, File.READ) #open the file
   save_data = savegame.get_var() #get the value
   savegame.close() #close the file
   return save_data["highscore"] #return the value
