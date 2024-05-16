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
	
	Steam.getPersonaName()
	
	if is_owned == false:
		print("User does not own this game")
		self.get_tree().quit()
	
	print("is_on_steam_deck: " + str(is_on_steam_deck))
	print("is_online: " + str(is_online))
	print("is_owned: " + str(is_owned))
	print("steam_id: " + str(steam_id))
	print("steam_username: " + str(steam_username))
	
	# Multiplayer signals.
	multiplayer.peer_connected.connect(self._on_peer_connected)
	multiplayer.peer_disconnected.connect(self._on_peer_disconnected)

func _host() -> void:
	
	var peer = SteamMultiplayerPeer.new()
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_FRIENDS_ONLY, 4)
	multiplayer.multiplayer_peer = peer

func _connect() -> void:
	
	var friends = self._get_friends_in_lobbies()
	if friends.is_empty(): return
	
	# For now just use the first lobby id in the list.
	# Ideally you would pick which friend you would like to join.
	var lobby_id = friends[friends.keys()[0]]
	
	var peer = SteamMultiplayerPeer.new()
	peer.connect_lobby(lobby_id)
	multiplayer.multiplayer_peer = peer
	
func _get_friends_in_lobbies() -> Dictionary:

	var results = {}
	
	# For all friends
	for i in range(0, Steam.getFriendCount()):
		
		# Get the current game info for the player.
		var steam_id = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		var game_info = Steam.getFriendGamePlayed(steam_id)
		if game_info.is_empty(): continue
	
		# Find game and lobby info.
		var app_id = game_info['id']
		var lobby = game_info['lobby']
		
		# See if they are in the current game and have a lobby.
		if app_id != Steam.getAppID() or lobby is String: continue
		results[steam_id] = lobby
	
	return results

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func _on_peer_connected(id):
	
	print(str(multiplayer.get_unique_id()) + ": PEER CONNECTED: " + str(id))
	var steam_id = multiplayer.multiplayer_peer.get_steam64_from_peer_id(id)

	if multiplayer.get_unique_id() == 1:
		self.load_map.rpc_id(id)
	
func _on_peer_disconnected(id):
	
	print(str(multiplayer.get_unique_id()) + ": PEER DISCONNECTED: " + str(id))
	var steam_id = multiplayer.multiplayer_peer.get_steam64_from_peer_id(id)

@rpc("authority", "call_local", "reliable", 0)
func load_map():
	print(str(multiplayer.get_unique_id()) + ": LOAD MAP")
