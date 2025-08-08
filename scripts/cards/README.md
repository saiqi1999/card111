# 卡牌系统脚本

此文件夹包含与卡牌系统相关的所有脚本。

## 文件结构

- `card_pack_base.gd` - 卡包基类，定义了卡包的基本属性和方法
- `strike_card_pack.gd` - 打击卡包类，继承自卡包基类，使用strike.png作为图片
- `card_util.gd` - 卡牌工具脚本，用于显示卡牌的视觉表现和提供卡牌相关工具函数

## 使用说明

### 卡包基类 (CardPackBase)

卡包基类提供了卡牌数据管理功能：

```gdscript
# 创建基础卡包
var basic_pack = CardPackBase.new("基础卡包", "包含基础卡牌的卡包")

# 设置卡牌数据
basic_pack.set_card_data("卡牌名称", "卡牌描述")

# 获取卡牌数据
var card_data = basic_pack.get_card_data()
```

### 打击卡包 (StrikeCardPack)

打击卡包是卡包基类的一个具体实现，专门用于管理打击类型的卡牌：

```gdscript
# 创建打击卡包
var strike_pack = StrikeCardPack.new()
```

### 卡牌工具 (CardUtil)

卡牌工具脚本用于处理卡牌的视觉表现和提供卡牌相关工具函数，可以从卡包加载数据或通过类型字符串加载：

```gdscript
# 获取卡牌场景实例
var card_instance = preload("res://scenes/card.tscn").instantiate()

# 方法1：通过类型字符串加载卡牌（推荐）
card_instance.load_from_card_type("strike")

# 方法2：创建卡包实例并加载
var card_pack = CardUtil.get_card_pack_by_type("strike")
card_instance.load_from_card_pack(card_pack)

# 方法3：直接设置卡牌数据
card_instance.set_card_data("卡牌名称", "卡牌描述", 卡牌图像)
```

卡牌工具还提供了通过类型字符串获取卡包实例的静态方法：

```gdscript
# 通过类型字符串获取卡包实例
var strike_pack = CardUtil.get_card_pack_by_type("strike")
```

卡牌工具还提供了随机移动卡牌到非中心区域的静态方法：

```gdscript
# 随机移动卡牌到非中心区域
var move_distance = CardUtil.random_move_card(card_instance)
print("卡牌移动了：", move_distance)
```

这个方法会将卡牌实例随机移动到一个非中心区域（x和y坐标在-200到200范围内，但不在-50到50范围内），并使用Tween动画实现平滑移动效果。方法返回移动的距离向量，可用于后续处理。

#### 卡牌尺寸

卡牌现在使用固定尺寸，不再由图片大小决定：

- 卡牌宽度：200像素
- 卡牌高度：300像素

卡牌图像会自动缩放以适应这个固定尺寸，同时保持图像的原始宽高比。卡牌背景是一个带有圆角和边框的面板，确保所有卡牌具有一致的外观。

```gdscript
# 卡牌固定尺寸常量
const CARD_WIDTH: float = 200.0  # 卡牌宽度
const CARD_HEIGHT: float = 300.0  # 卡牌高度
```

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