# 卡牌系统脚本

此文件夹包含与卡牌系统相关的所有脚本。

## 文件结构

- `card_pack_base.gd` - 卡包基类，定义了卡包的基本属性和方法
- `strike_card_pack.gd` - 打击卡包类，继承自卡包基类，使用strike.png作为图片

## 使用说明

### 卡包基类 (CardPackBase)

卡包基类提供了管理卡牌集合的基本功能：

```gdscript
# 创建基础卡包
var basic_pack = CardPackBase.new("基础卡包", "包含基础卡牌的卡包")

# 添加卡牌
basic_pack.add_card(some_card)

# 获取所有卡牌
var all_cards = basic_pack.get_all_cards()

# 洗牌
basic_pack.shuffle()

# 获取随机卡牌
var random_card = basic_pack.get_random_card()
```

### 打击卡包 (StrikeCardPack)

打击卡包是卡包基类的一个具体实现，专门用于管理打击类型的卡牌：

```gdscript
# 创建打击卡包
var strike_pack = StrikeCardPack.new()


## 扩展说明

要创建新的卡包类型，只需继承CardPackBase并根据需要重写方法：

```gdscript
extends "res://scripts/cards/card_pack_base.gd"
class_name NewCardPack

func _init():
    super._init("新卡包", "新卡包的描述")
    # 覆盖父类的变量值
    pack_image = preload("res://path/to/new_image.png")
    # 添加特定初始化逻辑

# 添加特定方法
func special_method():
    # 实现特定功能
    pass
```

### 注意事项

1. 继承时使用脚本路径：`extends "res://scripts/cards/card_pack_base.gd"`
2. 不要在子类中重新声明父类已有的变量（如 `pack_image`），而是在 `_init()` 函数中覆盖它们的值
3. 始终使用 `super._init()` 调用父类的初始化函数