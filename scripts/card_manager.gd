# res://scripts/card_manager.gd
extends Node

# 卡牌管理器信号
signal card_drawn(card)
signal card_played(card)
signal card_discarded(card)

# 卡牌集合
var deck = [] # 牌库
var hand = [] # 手牌
var discard_pile = [] # 弃牌堆

# 卡牌场景引用
@export var card_scene: PackedScene

# 卡牌容器引用
@export var hand_container: Node

# 游戏参数
@export var max_hand_size: int = 7
@export var starting_hand_size: int = 5

func _ready() -> void:
	print("Card Manager initialized")

# 初始化牌库
func initialize_deck(cards_data: Array) -> void:
	deck.clear()
	for card_data in cards_data:
		add_card_to_deck(card_data)
	
	# 洗牌
	shuffle_deck()
	print("Deck initialized with ", deck.size(), " cards")

# 向牌库添加卡牌
func add_card_to_deck(card_data: Dictionary) -> void:
	deck.append(card_data)

# 洗牌
func shuffle_deck() -> void:
	deck.shuffle()
	print("Deck shuffled")

# 抽牌
func draw_card() -> Node:
	if deck.size() == 0:
		# 如果牌库为空，将弃牌堆洗入牌库
		if discard_pile.size() == 0:
			print("No cards left to draw")
			return null
		else:
			reshuffle_discard_pile()
	
	if hand.size() >= max_hand_size:
		print("Hand is full")
		return null
	
	# 从牌库顶部抽一张牌
	var card_data = deck.pop_front()
	
	# 创建卡牌实例
	var card_instance = create_card_instance(card_data)
	
	# 添加到手牌
	hand.append(card_instance)
	
	# 将卡牌添加到手牌容器
	if hand_container:
		hand_container.add_child(card_instance)
		# 排列手牌
		arrange_hand()
	
	# 发出信号
	card_drawn.emit(card_instance)
	
	return card_instance

# 创建卡牌实例
func create_card_instance(card_data: Dictionary) -> Node:
	if not card_scene:
		push_error("Card scene not set")
		return null
	
	# 检查是否有自定义脚本
	var card_instance
	if card_data.has("script") and ResourceLoader.exists(card_data["script"]):
		# 加载自定义卡牌脚本
		var card_script = load(card_data["script"])
		# 实例化卡牌场景
		card_instance = card_scene.instantiate()
		# 设置脚本
		card_instance.set_script(card_script)
		# 自定义卡牌会在_ready中设置自己的属性
	else:
		# 实例化普通卡牌场景
		card_instance = card_scene.instantiate()
		
		# 设置卡牌属性
		if card_data.has("name"):
			card_instance.card_name = card_data["name"]
		if card_data.has("cost"):
			card_instance.cost = card_data["cost"]
		if card_data.has("description"):
			card_instance.description = card_data["description"]
		if card_data.has("image") and card_data["image"] is Texture2D:
			card_instance.card_image = card_data["image"]
	
	# 连接卡牌信号
	card_instance.card_played.connect(_on_card_played)

	
	return card_instance

# 排列手牌
func arrange_hand() -> void:
	if not hand_container or hand.is_empty():
		return
	
	var card_width = 220 # 卡牌宽度加间距
	var hand_width = hand.size() * card_width
	var start_x = -hand_width / 2 + card_width / 2
	
	for i in range(hand.size()):
		var card = hand[i]
		var target_position = Vector2(start_x + i * card_width, 0)
		# 可以添加动画效果
		card.position = target_position

# 将弃牌堆洗入牌库
func reshuffle_discard_pile() -> void:
	print("Reshuffling discard pile into deck")
	deck = discard_pile.duplicate()
	discard_pile.clear()
	shuffle_deck()

# 弃牌
func discard_card(card: Node) -> void:
	# 从手牌中移除
	var index = hand.find(card)
	if index != -1:
		hand.remove_at(index)
		
		# 从UI中移除
		if card.get_parent():
			card.get_parent().remove_child(card)
		
		# 添加到弃牌堆
		discard_pile.append(card)
		
		# 发出信号
		card_discarded.emit(card)
		
		# 重新排列手牌
		arrange_hand()

# 打出卡牌
func play_card(card: Node) -> void:
	# 从手牌中移除
	var index = hand.find(card)
	if index != -1:
		hand.remove_at(index)
		
		# 应用卡牌效果
		card.play_card()
		
		# 从UI中移除
		if card.get_parent():
			card.get_parent().remove_child(card)
		
		# 添加到弃牌堆
		discard_pile.append(card)
		
		# 发出信号
		card_played.emit(card)
		
		# 重新排列手牌
		arrange_hand()

# 抽指定数量的卡牌
func draw_cards(count: int) -> void:
	for i in range(count):
		draw_card()

# 抽初始手牌
func draw_starting_hand() -> void:
	for i in range(starting_hand_size):
		draw_card()

# 卡牌被打出的信号处理
func _on_card_played(card: Node) -> void:
	play_card(card)

# 弃掉所有手牌
func discard_hand() -> void:
	while not hand.is_empty():
		var card = hand[0]
		discard_card(card)