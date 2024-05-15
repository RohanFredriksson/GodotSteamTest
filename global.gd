extends Node

func _init() -> void:
	const steam_id = "480"
	OS.set_environment("SteamAppId", steam_id)
	OS.set_environment("SteamGameId", steam_id)

func _ready() -> void:
	
	var initialize_response = Steam.steamInitEx()
	#print("Did Steam initialize?: %s " % initialize_response)
	
	if initialize_response['status'] > 0:
		print("Failed to initialize Steam, shutting down: %s" % initialize_response)
		self.get_tree().quit()

	var is_on_steam_deck: bool = Steam.isSteamRunningOnSteamDeck()
	var is_online: bool = Steam.loggedOn()
	var is_owned: bool = Steam.isSubscribed()
	#var steam_id: int = Steam.getSteamID() THIS DOESNT WORK
	var steam_username: String = Steam.getPersonaName()
	
	if is_owned == false:
		print("User does not own this game")
		self.get_tree().quit()

func _process(_delta: float) -> void:
	Steam.run_callbacks()
