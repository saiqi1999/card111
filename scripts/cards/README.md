# 卡牌系统脚本

此文件夹包含与卡牌系统相关的所有脚本。

## 文件结构

- `card_pack_base.gd` - 卡包基类，定义了卡包的基本属性和方法
- `prefabs/` - 卡包预制体文件夹
  - `strike_card_pack.gd` - 打击卡包类，继承自卡包基类，使用strike.png作为图片
- `card_util.gd` - 卡牌工具脚本，用于显示卡牌的视觉表现和提供卡牌相关工具函数

## 使用说明

### 卡包基类 (CardPackBase)

卡包基类提供了卡牌数据管理功能，包括卡牌名称、描述、图像和个性化点击效果：

```gdscript
# 创建基础卡包
var basic_pack = CardPackBase.new("基础卡包", "包含基础卡牌的卡包")

# 设置卡牌数据
basic_pack.set_card_data("卡牌名称", "卡牌描述")

# 设置点击效果（可选）
basic_pack.on_click = my_click_function

# 获取卡牌数据（包含点击效果）
var card_data = basic_pack.get_card_data()
# card_data包含：name, description, image, on_click
```

### 打击卡包 (StrikeCardPack)

打击卡包是卡包基类的一个具体实现，专门用于管理打击类型的卡牌。它包含了打击卡牌的特殊点击效果：

```gdscript
# 推荐使用CardUtil获取打击卡包
var strike_pack = CardUtil.get_card_pack_by_type("strike")
# 打击卡包自动设置了点击特效：打印随机数（1-100）
```

**打击卡牌特效**：当点击打击卡牌时，会触发`strike_click_effect()`函数，打印一个1-100之间的随机数。

### 防御卡包 (DefendCardPack)

防御卡包是卡包基类的一个具体实现，专门用于管理防御类型的卡牌。它包含了防御卡牌的特殊点击效果：

```gdscript
# 推荐使用CardUtil获取防御卡包
var defend_pack = CardUtil.get_card_pack_by_type("defend")
# 防御卡包自动设置了点击特效：显示获得的护甲值
```

**防御卡牌特效**：当点击防御卡牌时，会触发`defend_click_effect()`函数，显示获得5点护甲的效果。

### 卡牌工具 (CardUtil)

卡牌工具脚本用于处理卡牌的视觉表现和提供卡牌相关工具函数，可以从卡包加载数据或通过类型字符串加载：

```gdscript
# 推荐方法：使用卡牌池系统创建卡牌
CardUtil.initialize_card_pool(root_node)  # 确保卡牌池已初始化
var card_instance = CardUtil.create_card_from_pool(root_node, "strike", Vector2(960, 540))
card_instance.card_name = "打击卡牌"
card_instance.update_display()

# 传统方法：直接实例化（不推荐，可能有拖拽延迟问题）
var card_instance_old = preload("res://scenes/card.tscn").instantiate()
card_instance_old.load_from_card_type("strike")
root_node.add_child(card_instance_old)

# 其他加载方式
var card_pack = CardUtil.get_card_pack_by_type("strike")
card_instance.load_from_card_pack(card_pack)
card_instance.set_card_data("卡牌名称", "卡牌描述", 卡牌图像)
```

#### 卡牌交互功能

**拖拽功能**：卡牌支持鼠标拖拽，具有以下特性：
- 鼠标左键按下开始拖拽，拖拽时卡牌半透明显示
- 使用全局鼠标跟踪，无论鼠标移动多快都能精确跟随
- 即使鼠标移出卡牌范围，拖拽状态仍然保持
- 鼠标释放结束拖拽，恢复正常透明度
- 拖拽开始时自动停止正在进行的Tween动画，避免冲突

**层级管理系统**：解决多张卡牌重叠时的交互问题：
- 自动注册和管理所有卡牌实例
- 只有最上层的卡牌响应鼠标点击
- 点击卡牌时自动将其置于最上层
- 支持失效卡牌的自动清理
- 每张卡牌都有唯一的层级标识

**个性化点击效果**：每张卡牌支持自定义点击效果：
- 通过卡包的`on_click`属性设置点击回调函数
- 点击卡牌时自动触发对应的特效函数，并传递卡牌实例作为参数
- 打击卡牌示例：点击时打印卡牌实例ID和1-100的随机数
- 支持任意自定义的点击逻辑，可获取卡牌实例的完整信息

**移动动画功能**：

```gdscript
# 移动卡牌到指定位置（通用方法）
var tween = CardUtil.move_card(card_instance, Vector2(500, 300), 1.5)

# 随机移动卡牌到非中心区域
var move_distance = CardUtil.random_move_card(card_instance)
print("卡牌移动了：", move_distance)
```

- `move_card(card_instance, target_position, duration)` - 通用的卡牌移动方法
  - 自动停止之前的动画
  - 使用Tween实现平滑移动
  - 返回Tween实例供进一步操作
- `random_move_card(card_instance)` - 随机移动到非中心区域
  - 移动范围：X和Y坐标在-200到200范围内，但避开-50到50的中心区域
  - 返回移动的距离向量

#### 工具方法

```gdscript
# 通过类型字符串获取卡包实例
var strike_pack = CardUtil.get_card_pack_by_type("strike")

# 设置卡牌数据（包括点击效果）
card_instance.set_card_data("卡牌名称", "卡牌描述", 图像资源, 点击回调函数)

# 点击效果函数示例（接收卡牌实例作为参数）
func custom_click_effect(card_instance):
    print("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 被点击了！")
    # 可以访问卡牌的所有属性和方法
    print("卡牌名称:" + card_instance.card_name)

# 层级管理相关方法
CardUtil.register_card(card_instance)  # 注册卡牌到层级管理系统
CardUtil.unregister_card(card_instance)  # 从层级管理系统移除卡牌
CardUtil.bring_to_front(card_instance)  # 将卡牌置于最上层
var is_top = CardUtil.is_top_card_at_position(card_instance, mouse_position)  # 检查是否为最上层卡牌
CardUtil.cleanup_invalid_cards()  # 清理失效的卡牌引用
```

#### 卡牌尺寸

卡牌现在使用固定尺寸，不再由图片大小决定。所有尺寸常量都通过`GlobalConstants`类统一管理：

- 卡牌宽度：200像素（`GlobalConstants.CARD_WIDTH`）
- 卡牌高度：300像素（`GlobalConstants.CARD_HEIGHT`）

卡牌图像会自动缩放以适应这个固定尺寸，同时保持图像的原始宽高比。卡牌背景是一个带有圆角和边框的面板，确保所有卡牌具有一致的外观。

```gdscript
# 卡牌固定尺寸（使用全局常量）
const CARD_WIDTH: float = GlobalConstants.CARD_WIDTH  # 卡牌宽度
const CARD_HEIGHT: float = GlobalConstants.CARD_HEIGHT  # 卡牌高度
```

#### 全局常量系统集成

卡牌系统已完全集成全局常量系统，所有硬编码的数值都已替换为`GlobalConstants`中的常量：

- **卡牌尺寸**：`CARD_WIDTH`、`CARD_HEIGHT`
- **透明度设置**：`CARD_DRAG_ALPHA`（拖拽时）、`CARD_NORMAL_ALPHA`（正常状态）
- **动画时长**：`DEFAULT_MOVE_DURATION`（默认移动）、`SLIDE_DURATION`（滑动动画）
- **随机移动**：`RANDOM_MOVE_RANGE`（移动范围）、`CENTER_AVOID_RANGE`（中心避让）
- **卡牌池配置**：`CARD_POOL_SIZE`（池大小）、`CARD_POOL_HIDDEN_POSITION`（隐藏位置）

这种设计提供了以下优势：
- 统一的配置管理
- 类型安全的常量定义
- 易于维护和修改
- 避免硬编码错误

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