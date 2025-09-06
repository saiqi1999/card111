# 配方常量管理
# 用于存储所有配方数据的单例
extends Node

# 配方数据数组，每个元素是一个JSON字符串
# JSON格式包含三个字段：
# - ingredients: Array[String] - 原料列表
# - products: Array[String] - 产出列表  
# - craft_time: float - 合成时长（秒）
var RECIPES: Array[String] = [
	# 铲子 + 土堆 = 基础花盆
	'{"ingredients": ["iron_shovel", "dirt_pile"], "products": ["primary_flower_pot"], "craft_time": 5.0}',
	# 木材 + 燧石 = 铁斧
	'{"ingredients": ["wood", "flint"], "products": ["iron_axe"], "craft_time": 3.0}',
	# 2木材 + 燧石 = 铲子
	'{"ingredients": ["wood", "wood", "flint"], "products": ["iron_shovel"], "craft_time": 3.5}',
	# 木材 + 3燧石 = 镰刀
	'{"ingredients": ["wood", "flint", "flint", "flint"], "products": ["sickle"], "craft_time": 4.5}',
	# 木材 + 2燧石 = 十字镐
	'{"ingredients": ["wood", "flint", "flint"], "products": ["pickaxe"], "craft_time": 4.0}',
	# 碎木堆 + 铁斧 = 木材
	'{"ingredients": ["wood_scraps", "iron_axe"], "products": ["wood"], "craft_time": 2.0}',
	# 石堆 + 十字镐 = 由回调函数处理生成
	'{"ingredients": ["stone_pile", "pickaxe"], "products": [], "craft_time": 2.0}',
	# 十字镐 + 奇怪石堆 = 未激活奥秘
	'{"ingredients": ["pickaxe", "strange_stone_pile"], "products": ["inactive_mystery"], "craft_time": 13.0}',
	# 镰刀 + 小蓝莓丛 = 由回调函数处理生成
	'{"ingredients": ["sickle", "small_blueberry_bush"], "products": [], "craft_time": 2.0}',
	# 镰刀 + 大蓝莓丛 = 由回调函数处理生成
	'{"ingredients": ["sickle", "large_blueberry_bush"], "products": [], "craft_time": 3.0}'
]

# 获取所有配方数据
func get_all_recipes() -> Array[Dictionary]:
	var recipes: Array[Dictionary] = []
	for recipe_json in RECIPES:
		var json = JSON.new()
		var parse_result = json.parse(recipe_json)
		if parse_result == OK:
			recipes.append(json.data)
		else:
			GlobalUtil.log("解析配方JSON失败: " + recipe_json, GlobalUtil.LogLevel.ERROR)
	return recipes

# 添加新配方
func add_recipe(ingredients: Array[String], products: Array[String], craft_time: float):
	var recipe_dict = {
		"ingredients": ingredients,
		"products": products,
		"craft_time": craft_time
	}
	var json_string = JSON.stringify(recipe_dict)
	RECIPES.append(json_string)
	GlobalUtil.log("添加新配方: " + json_string, GlobalUtil.LogLevel.INFO)

# 配方剩余次数映射
var recipe_remaining_times: Dictionary = {
	# 铁斧配方只能使用一次
	"[\"wood\",\"flint\"]" : 1,
	# 铲子配方只能使用一次
	"[\"wood\",\"wood\",\"flint\"]" : 1,
	# 镰刀配方只能使用一次
	"[\"wood\",\"flint\",\"flint\",\"flint\"]" : 1,
	# 十字镐配方只能使用一次
	"[\"wood\",\"flint\",\"flint\"]" : 1,
	# 十字镐 + 奇怪石堆配方只能使用一次
	"[\"pickaxe\",\"strange_stone_pile\"]" : 1
}

# 检查配方是否还有剩余次数
func check_recipe_remaining_times(ingredients: Array[String]) -> bool:
	# 生成与字典中完全相同格式的key
	var key = "[" + ",".join(ingredients.map(func(x): return "\"" + x + "\"")) + "]"
	
	if not recipe_remaining_times.has(key):
		GlobalUtil.log("配方 " + key + " 剩余使用次数: 无限使用", GlobalUtil.LogLevel.INFO)
		return true
	
	# 检查剩余次数
	if recipe_remaining_times[key] > 0:
		GlobalUtil.log("配方 " + key + " 剩余使用次数: " + str(recipe_remaining_times[key]), GlobalUtil.LogLevel.INFO)
		return true
	
	GlobalUtil.log("配方 " + key + " 已无剩余使用次数", GlobalUtil.LogLevel.INFO)
	return false

# 减少配方剩余次数
func decrease_recipe_remaining_times(ingredients: Array[String]):
	# 生成与字典中完全相同格式的key
	var key = "[" + ",".join(ingredients.map(func(x): return "\"" + x + "\"")) + "]"
	
	if recipe_remaining_times.has(key) and recipe_remaining_times[key] > 0:
		# 减少剩余次数
		recipe_remaining_times[key] -= 1
		GlobalUtil.log("配方 " + key + " 减少使用次数，剩余: " + str(recipe_remaining_times[key]), GlobalUtil.LogLevel.INFO)

func _ready():
	GlobalUtil.log("RecipeConstant 初始化完成，加载了 " + str(RECIPES.size()) + " 个配方", GlobalUtil.LogLevel.INFO)