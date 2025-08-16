# 容器系统

容器系统用于在游戏中显示和管理各种容器，如背包、商店界面等。采用类似卡牌系统的架构设计。

## 文件结构

- `container_base.gd` - 容器抽象基类，定义容器的基本属性和数据结构
- `container_util.gd` - 容器工具类，负责容器的实例化、显示和管理
- `prefabs/` - 容器预制件文件夹
  - `container_400_300.gd` - 400x300尺寸的容器包
- `container.gd` - 通用容器类（Node2D版本，待重构）
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
   - 容器z_index设置为100，显示在卡牌上方
   - 确保容器纹理始终可见
   - 保持容器与卡牌的正确层级关系

## 容器预制件 (Prefabs)

### 400x300容器包 (Container400x300)

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

### 方法一：使用场景文件
```gdscript
# 加载容器场景（使用400x300容器）
var container_scene = preload("res://scenes/container.tscn")
var container_instance = container_scene.instantiate()
get_tree().current_scene.add_child(container_instance)
```

### 方法二：直接使用脚本
```gdscript
# 创建400x300容器
var container_class = preload("res://scripts/container/container_400_300.gd")
var container_instance = container_class.new()
get_tree().current_scene.add_child(container_instance)
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
├── Container400x300
├── 其他容器类型...
└── 只关注特有属性和行为
```

## 注意事项

1. **单例模式**: 系统确保场上只能存在一个容器实例
2. **自动清理**: 当创建新容器时，会自动移除已存在的容器
3. **智能点击**: 系统能智能识别点击目标，避免误操作
4. **召唤卡牌**: 容器会记住召唤它的卡牌，支持特殊交互逻辑
5. **透明背景**: 容器默认使用透明纹理，避免阻挡拖拽操作
6. **拖拽优化**: 容器设置为IGNORE模式，Area2D优先级为-1，确保卡牌拖拽优先
7. **输入处理**: 使用_unhandled_input处理容器点击，避免与卡牌拖拽冲突
8. **事件处理优化**: 重新组织事件处理优先级，优先检查卡牌和可拖拽元素，确保容器不会拦截卡牌事件
9. **层级显示**: 容器z_index设置为100，确保容器纹理显示在卡牌上方，提供更好的视觉效果
10. **类型安全**: 通过预加载和类型检查确保运行时安全
11. **Node2D继承**: 改用Node2D继承，提供更好的2D坐标系统和位置管理，减少UI相关的bug

## 扩展性

容器系统设计具有良好的扩展性：

- **新容器类型**: 通过继承ContainerBase轻松添加
- **数据驱动**: 容器属性和行为完全由数据定义
- **插件化**: 容器包可独立开发和测试
- **动态加载**: 支持运行时动态加载不同类型的容器
- **自定义交互**: 每个容器可定义独特的点击效果