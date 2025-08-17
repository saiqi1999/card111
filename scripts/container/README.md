# 容器系统

容器系统用于在游戏中显示和管理各种容器，如背包、商店界面等。采用类似卡牌系统的架构设计。

## 文件结构

- `container_base.gd` - 容器抽象基类，定义容器的基本属性和数据结构
- `container_util.gd` - 容器工具类，负责容器的实例化、显示和管理
- `prefabs/` - 容器预制件文件夹
  - `container_400_300.gd` - 400x300尺寸的容器包
  - `container_big.gd` - 大尺寸容器预制件，支持更丰富的UI交互
- `README.md` - 本说明文件

## 容器抽象基类 (ContainerBase)

`container_base.gd` 继承自 `Resource`，定义了容器的基本属性和数据结构，类似于 `CardPackBase`。

#### 基类属性

- `container_name`: 容器名称
- `description`: 容器描述
- `container_width`: 容器宽度
- `container_height`: 容器高度
- `container_texture`: 容器背景纹理
- `on_click`: 容器点击回调函数

#### 基类方法

- `_init(p_name, p_description)`: 初始化容器基本信息
- `set_container_data()`: 设置容器数据
- `get_container_data()`: 获取容器数据字典
- `get_container_size()`: 获取容器尺寸

## 容器工具类 (ContainerUtil)

`container_util.gd` 继承自 `Node2D`，负责容器的视觉表现和交互逻辑，类似于 `CardUtil`。

#### 工具类功能

1. **静态容器管理**
   - `current_container`: 静态变量，跟踪当前显示的容器实例
   - `remove_current_container()`: 移除当前容器的静态方法
   - `has_container()`: 检查是否存在容器的静态方法

2. **动态标题描述系统**
   - `set_title_and_description_ui()`: 动态设置容器标题和描述
   - `title_label` 和 `description_label`: UI标签组件
   - 支持从召唤卡牌获取标题和描述信息

3. **召唤者关联系统**
   - `set_summoner_card()`: 设置召唤此容器的卡牌引用
   - `summoner_card`: 召唤卡牌的引用
   - 智能检测召唤卡牌的点击事件

4. **生命周期管理**
   - 自动初始化UI组件（`setup_container()`）
   - 确保场景中只存在一个容器实例
   - 正确的事件处理顺序和初始化时机

2. **容器显示**
   - `setup_container()`: 设置容器的基本结构（背景、点击区域等）
   - `center_container()`: 将容器居中显示
   - `update_display()`: 更新容器显示

3. **容器数据加载**
   - `load_from_container_pack()`: 从容器包加载数据
   - `load_from_container_type()`: 通过类型字符串加载容器
   - `get_container_pack_by_type()`: 获取容器包实例

4. **智能点击检测**
   - 自动检测点击位置是否在容器内部
   - 检测是否点击了其他UI元素（如卡牌）
   - 特殊处理召唤卡牌的点击（允许拖动的同时移除容器）
   - 只有点击空白区域才会移除容器
   - 优化事件处理优先级，确保卡牌事件不被容器拦截

5. **容器层级管理**
   - 使用全局常量统一管理层级设置
   - 容器主体使用 `GlobalConstants.CONTAINER_Z_INDEX`
   - 容器标题使用 `GlobalConstants.CONTAINER_TITLE_Z_INDEX`
   - 容器UI元素使用 `GlobalConstants.CONTAINER_UI_Z_INDEX`
   - 确保容器纹理始终可见
   - 保持容器与卡牌的正确层级关系

## 容器预制件 (Prefabs)

### 标准容器 (Container400x300)

`prefabs/container_400_300.gd` 继承自 `ContainerBase`，定义400x300尺寸容器的特有属性。

#### 主要功能

- **尺寸设置**: 定义为400x300像素
- **纹理设置**: 使用专用的容器背景图片
- **点击效果**: 定义特有的点击回调函数
- **数据封装**: 将所有属性封装在容器包中

#### 实现示例

```gdscript
extends ContainerBase
class_name Container400x300

func _init():
	# 调用父类初始化
	super._init("400x300容器", "标准尺寸的容器，适用于大部分场景")
	
	# 设置容器特有属性
	container_width = 400.0
	container_height = 300.0
	container_texture = preload("res://assets/images/frame.jpg")
	on_click = container_400_300_click_effect

# 400x300容器的特有点击效果
func container_400_300_click_effect(container_instance):
	# 定义特有的点击行为
	pass
```

### 大容器 (ContainerBig)

`prefabs/container_big.gd` 继承自 `ContainerBase`，提供大尺寸容器预制件，支持更丰富的UI交互。

#### 主要功能

- **大尺寸界面**: 提供更大的显示区域
- **确认按钮**: 支持用户确认操作
- **卡槽系统**: 提供3个卡槽用于卡牌放置
- **统一层级管理**: 使用全局常量管理UI元素层级
- **智能交互**: 支持卡槽点击和确认按钮交互

#### 实现示例

```gdscript
extends ContainerBase
class_name ContainerBig

func _init():
	# 调用父类初始化
	super._init("大容器", "大尺寸容器，支持更丰富的UI交互")
	
	# 设置容器特有属性
	container_width = 800.0
	container_height = 600.0
	container_texture = preload("res://assets/images/big_container_frame.jpg")
	on_click = container_big_click_effect

# 大容器的特有点击效果
func container_big_click_effect(container_instance):
	# 定义大容器的特有点击行为
	pass
```

## 容器系统架构

### 设计理念

容器系统采用基类+子类的设计模式，便于扩展不同尺寸和类型的容器：

1. **基类统一接口** - `ContainerBase`提供统一的功能接口
2. **子类特化实现** - 各子类实现特定尺寸和样式
3. **易于扩展** - 新增容器类型只需继承基类并设置参数

### 如何创建新的容器类型

1. **创建新的容器子类**：
```gdscript
# 例如：container_600_400.gd
extends "res://scripts/container/container_base.gd"

func _ready():
    container_width = 600
    container_height = 400
    container_texture = preload("res://assets/images/your_texture.jpg")
    super._ready()
```

2. **在场景中使用**：
```gdscript
var container_class = preload("res://scripts/container/container_600_400.gd")
var container = container_class.new()
add_child(container)
```





## 使用方法

### 通过卡牌召唤容器（推荐方式）

#### 召唤标准容器

```gdscript
# 在卡牌点击效果中召唤标准容器
func want_slime_click_effect(card_instance):
    # 创建容器实例
    var container_instance = preload("res://scripts/container/container_util.gd").new()
    
    # 从容器类型加载数据
    container_instance.load_from_container_type("400x300")
    
    # 设置容器位置
    var container_position = Vector2(card_position.x - 220 - GlobalConstants.CARD_WIDTH, card_position.y)
    container_instance.global_position = container_position
    
    # 设置召唤卡牌引用
    container_instance.set_summoner_card(card_instance)
    
    # 添加到场景树（触发_ready方法初始化UI）
    card_instance.get_tree().current_scene.add_child(container_instance)
    
    # 等待一帧确保完全初始化
    await card_instance.get_tree().process_frame
    
    # 设置动态标题和描述
    var card_title = card_instance.card_name if card_instance.card_name else "默认标题"
    var card_desc = card_instance.description if card_instance.description else "默认描述"
    container_instance.set_title_and_description_ui(card_title, card_desc)
```

#### 召唤大容器

```gdscript
# 在卡牌点击效果中召唤大容器
func summon_big_container_click_effect(card_instance):
    # 创建大容器实例
    var container_instance = preload("res://scripts/container/container_util.gd").new()
    
    # 从容器类型加载数据
    container_instance.load_from_container_type("big")
    
    # 设置容器位置（大容器通常居中显示）
    container_instance.global_position = Vector2(0, 0)
    
    # 设置召唤卡牌引用
    container_instance.set_summoner_card(card_instance)
    
    # 添加到场景树
    card_instance.get_tree().current_scene.add_child(container_instance)
    
    # 等待一帧确保完全初始化
    await card_instance.get_tree().process_frame
    
    # 设置动态标题和描述
    var card_title = card_instance.card_name if card_instance.card_name else "大容器标题"
    var card_desc = card_instance.description if card_instance.description else "大容器描述"
    container_instance.set_title_and_description_ui(card_title, card_desc)
```

### 方法一：使用场景文件
```gdscript
# 加载标准容器场景（使用400x300容器）
var container_scene = preload("res://scenes/container.tscn")
var container_instance = container_scene.instantiate()
get_tree().current_scene.add_child(container_instance)

# 加载大容器场景
var big_container_scene = preload("res://scenes/container_big.tscn")
var big_container_instance = big_container_scene.instantiate()
get_tree().current_scene.add_child(big_container_instance)
```

### 方法二：直接使用脚本
```gdscript
# 创建400x300标准容器
var container_class = preload("res://scripts/container/container_400_300.gd")
var container_instance = container_class.new()
get_tree().current_scene.add_child(container_instance)

# 创建大容器
var big_container_class = preload("res://scripts/container/container_big.gd")
var big_container_instance = big_container_class.new()
get_tree().current_scene.add_child(big_container_instance)
```

### 容器特性
- 自动居中显示
- 点击外部自动关闭
- 点击内部保持显示
- 支持拖拽和其他交互（如果需要）
- 容器会自动居中显示并处理交互

## 系统架构

容器系统采用分层架构设计：

```
ContainerBase (Resource)
├── 定义容器数据结构
├── 封装容器属性
└── 提供数据访问接口

ContainerUtil (Node2D)
├── 管理容器显示
├── 处理用户交互
├── 控制容器生命周期
└── 提供静态管理方法

Prefabs/
├── Container400x300 (标准容器)
├── ContainerBig (大容器)
├── 其他容器类型...
└── 只关注特有属性和行为
```

## 重要修复

容器系统经过多次优化，解决了以下关键问题：

1. **点击检测冲突**: 通过调整事件处理优先级，确保卡牌拖拽不被容器拦截
2. **层级显示问题**: 使用全局常量统一管理层级，确保正确的视觉层级
3. **拖拽延迟**: 优化Area2D设置，减少拖拽响应延迟
4. **事件传播**: 正确处理事件传播，避免误触发
5. **透明背景**: 容器默认使用透明纹理，避免阻挡拖拽操作
6. **拖拽优化**: 容器设置为IGNORE模式，Area2D优先级为-1，确保卡牌拖拽优先
7. **输入处理**: 使用_input处理容器点击，通过Area2D的input_event处理容器内部点击
8. **事件处理优化**: 重新组织事件处理优先级，优先检查卡牌和可拖拽元素，确保容器不会拦截卡牌事件
9. **层级显示**: 使用全局常量管理容器层级，确保容器纹理显示在正确位置，提供更好的视觉效果
10. **类型安全**: 通过预加载和类型检查确保运行时安全
11. **Node2D继承**: 改用Node2D继承，提供更好的2D坐标系统和位置管理，减少UI相关的bug
12. **标题描述显示修复**: 修复容器显示默认文字问题，确保正确显示召唤者卡牌的名称和描述
13. **初始化顺序修复**: 调整容器添加到场景树的时机，确保UI组件在设置标题描述前完全初始化
14. **生命周期管理**: 完善容器的创建、初始化和销毁流程，避免状态不一致问题
15. **大容器UI元素显示修复**: 修复大容器中确认按钮和卡槽z_index被重置导致不显示的问题，将z_index设置移到add_child()之后
16. **统一层级管理优化**: 使用GlobalConstants统一管理所有容器相关的层级常量，提高代码一致性和可维护性

## 注意事项

1. **单例模式**: 系统确保场上只能存在一个容器实例
2. **自动清理**: 当创建新容器时，会自动移除已存在的容器
3. **智能点击**: 系统能智能识别点击目标，避免误操作
4. **召唤卡牌**: 容器会记住召唤它的卡牌，支持特殊交互逻辑

## 扩展性

容器系统设计具有良好的扩展性：

- **新容器类型**: 通过继承ContainerBase轻松添加
- **数据驱动**: 容器属性和行为完全由数据定义
- **插件化**: 容器包可独立开发和测试
- **动态加载**: 支持运行时动态加载不同类型的容器
- **自定义交互**: 每个容器可定义独特的点击效果