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
	'{"ingredients": ["iron_shovel", "dirt_pile"], "products": ["primary_flower_pot"], "craft_time": 5.0}'
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

func _ready():
	GlobalUtil.log("RecipeConstant 初始化完成，加载了 " + str(RECIPES.size()) + " 个配方", GlobalUtil.LogLevel.INFO)