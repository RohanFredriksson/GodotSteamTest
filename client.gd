extends Node

func _init() -> void:
	const steam_id = "480"
	OS.set_environment("SteamAppId", steam_id)
	OS.set_environment("SteamGameId", steam_id)
	
func _ready() -> void:
	
	# Steam initialisation
	var initialize_response = Steam.steamInitEx()
	
	if initialize_response['status'] > 0:
		print("Failed to initialize Steam, shutting down: %s" % initialize_response)
		self.get_tree().quit()

	var is_on_steam_deck: bool = Steam.isSteamRunningOnSteamDeck()
	var is_online: bool = Steam.loggedOn()
	var is_owned: bool = Steam.isSubscribed()
	var steam_id: int = Steam.getSteamID()
	var steam_username: String = Steam.getPersonaName()
	
	if is_owned == false:
		print("User does not own this game")
		self.get_tree().quit()
	
	# Multiplayer signals.
	multiplayer.peer_connected.connect(self._on_peer_connected)
	multiplayer.peer_disconnected.connect(self._on_peer_disconnected)
	
	# For now lets just host the server.
	self._host()

func _host() -> void:
	var peer = SteamMultiplayerPeer.new()
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_FRIENDS_ONLY, 4)
	multiplayer.multiplayer_peer = peer

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func _on_peer_connected(id):
	print(str(multiplayer.get_unique_id()) + ": PEER CONNECTED: " + str(id))
	
func _on_peer_disconnected(id):
	print(str(multiplayer.get_unique_id()) + ": PEER DISCONNECTED: " + str(id))
