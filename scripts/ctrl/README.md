# 控制器系统

控制器系统用于在游戏中显示和管理各种UI界面，如背包、商店界面等。采用Control+简化位置设置的UI实现方式。

## 文件结构

- `ctrl_base.gd` - 控制器抽象基类，继承自Control，定义控制器的基本属性和UI布局
- `ctrl_util.gd` - 控制器工具类，负责控制器的实例化、显示和管理
- `prefabs/` - 控制器预制件文件夹
  - `ctrl_400_300.gd` - 400x300尺寸的小控制器包
- `README.md` - 本说明文件

## 控制器抽象基类 (CtrlBase)

`ctrl_base.gd` 继承自 `Control`，定义了控制器的基本属性和UI布局。

#### 基类属性

- `ctrl_name`: 控制器名称
- `description`: 控制器描述
- `background_panel`: 背景面板引用
- `title_label`: 标题标签引用
- `description_label`: 描述标签引用
- `on_click`: 容器点击回调函数

#### 基类方法

- `_init(p_name, p_description)`: 初始化控制器基本信息
- `_ready()`: 初始化UI元素和布局
- `setup_ctrl_ui()`: 创建UI元素（背景面板、标题标签、描述标签）
- `setup_ctrl_layout()`: 设置控制器布局（左下角，占据三分之一屏幕，留100px边距）
- `set_ctrl_data()`: 设置控制器数据
- `get_ctrl_size()`: 获取控制器尺寸

## 控制器工具类 (CtrlUtil)

`ctrl_util.gd` 继承自 `Control`，负责控制器的管理和交互逻辑。

#### 工具类功能

1. **静态容器管理**
   - `current_ctrl`: 静态变量，跟踪当前显示的控制器实例
- `remove_current_ctrl()`: 移除当前控制器的静态方法
- `has_ctrl()`: 检查是否存在控制器的静态方法
- `get_current_ctrl()`: 获取当前控制器实例的静态方法

2. **容器实例管理**
   - `ctrl_instance`: 当前控制器实例引用
   - `load_from_ctrl_pack()`: 从控制器包加载数据
   - `load_from_ctrl_type()`: 通过类型字符串加载控制器
   - `set_ctrl_title_and_description()`: 设置控制器标题和描述

3. **控制器类型支持**
   - `get_ctrl_pack_by_type()`: 通过类型获取控制器包实例
   - 目前支持 "400x300" 小控制器类型

## 小控制器 (Ctrl400x300Pack)

`prefabs/ctrl_400_300.gd` 继承自 `CtrlBase`，提供400x300尺寸的小控制器预制件。

#### 主要功能

- **标准尺寸**: 400x300像素的显示区域
- **左下角布局**: 自动定位到屏幕左下角
- **响应式设计**: 占据屏幕三分之一的长宽，留有100px边距
- **动态标题描述**: 支持动态设置标题和描述文本

#### 实现示例

```gdscript
extends CtrlBase
class_name Ctrl400x300Pack

func _init():
	# 调用父类初始化
	super._init("400x300容器", "标准尺寸的小容器，位于左下角")
	
	# 设置点击回调
	on_click = ctrl_400_300_click_effect

# 400x300容器的特有点击效果
func ctrl_400_300_click_effect(ctrl_instance):
	# 定义特有的点击行为
	pass

# 设置容器布局（重写父类方法以支持特殊布局需求）
func setup_ctrl_layout():
	# 调用父类布局
	super.setup_ctrl_layout()
	# 可以在这里添加特殊的布局逻辑
```

## 容器系统架构

### 设计理念

控制器系统采用Control+简化位置设置的UI实现方式，具有以下特点：

1. **UI原生支持** - 基于Control节点，享受Godot原生UI系统的所有优势
2. **简化布局** - 使用简单的位置设置替代复杂的Anchor系统，避免显示问题
3. **响应式缩放** - 控制器尺寸根据屏幕分辨率动态调整
4. **层级管理** - 通过UI层级自然管理显示顺序
5. **易于扩展** - 新增控制器类型只需继承基类并设置参数

### 布局系统

控制器使用以下布局规则：
- **位置**: 左下角，距离边缘100像素
- **尺寸**: 占据屏幕四分之一的长宽
- **定位方式**: 使用简单的position设置，避免复杂的锚点问题
- **响应式**: 根据屏幕分辨率动态计算尺寸和位置

### 如何创建新的容器类型

1. **创建新的容器子类**：
```gdscript
# 例如：ctrl_custom.gd
extends CtrlBase
class_name CtrlCustom

func _init():
	super._init("自定义容器", "自定义容器描述")
	on_click = custom_click_effect

func custom_click_effect(ctrl_instance):
	# 定义自定义点击行为
	pass
```

2. **在CtrlUtil中注册新类型**：
```gdscript
static func get_ctrl_pack_by_type(type: String) -> CtrlBase:
	match type:
		"400x300":
			return Ctrl400x300Pack.new()
		"custom":
		return CtrlCustom.new()
		_:
			GlobalUtil.log("未知的容器类型: " + type, GlobalUtil.LogLevel.ERROR)
			return null
```

## 使用方法

### 通过卡牌召唤容器（推荐方式）

#### 召唤小容器

```gdscript
# 在卡牌点击效果中召唤小容器
func want_slime_click_effect(card_instance):
	# 创建容器工具类实例
	var ctrl_instance = preload("res://scripts/ctrl/ctrl_util.gd").new()
	
	# 从容器类型加载容器数据
	ctrl_instance.load_from_ctrl_type("400x300")
	
	# 将容器添加到场景树中
	get_tree().current_scene.add_child(ctrl_instance)
	
	# 设置容器标题和描述
	var card_title = card_instance.card_name if card_instance.card_name else "召唤容器"
	var card_desc = card_instance.description if card_instance.description else "容器描述"
	ctrl_instance.set_ctrl_title_and_description(card_title, card_desc)
```

### 直接创建容器

#### 方法一：使用场景文件
```gdscript
# 加载容器场景
var ctrl_scene = preload("res://scenes/ctrl.tscn")
var ctrl_instance = ctrl_scene.instantiate()
get_tree().current_scene.add_child(ctrl_instance)

# 加载控制器类型
ctrl_instance.load_from_ctrl_type("400x300")
```

#### 方法二：直接使用脚本
```gdscript
# 创建400x300小容器
var ctrl_util = preload("res://scripts/ctrl/ctrl_util.gd").new()
get_tree().current_scene.add_child(ctrl_util)
ctrl_util.load_from_ctrl_type("400x300")
```

### 容器特性
- 自动布局到左下角
- 响应式尺寸（屏幕三分之一，留100px边距）
- 支持动态标题和描述
- 单例模式管理（场上只能存在一个容器）
- 基于Control的原生UI交互

## 系统架构

容器系统采用分层架构设计：

```
CtrlBase (Control)
├── 定义容器UI结构
├── 封装容器属性
├── 提供布局方法
└── 管理UI元素生命周期

CtrlUtil (Control)
├── 管理容器实例
├── 处理容器类型加载
├── 控制容器生命周期
└── 提供静态管理方法

Prefabs/
├── Ctrl400x300Pack (小控制器)
├── 其他容器类型...
└── 只关注特有属性和行为
```

## 重要特性

控制器系统具有以下重要特性：

1. **Control实现**: 使用Godot原生Control节点，享受完整的UI系统支持
2. **简化布局**: 使用简单的位置设置替代复杂的Anchor系统，避免显示问题
3. **响应式缩放**: 根据屏幕分辨率动态计算尺寸，适应不同屏幕尺寸
4. **单例管理**: 确保场上只能存在一个控制器实例，避免UI冲突
5. **自动布局**: 控制器自动定位到左下角，无需手动设置复杂的锚点
6. **动态内容**: 支持动态设置标题和描述，适应不同使用场景
7. **类型系统**: 通过类型字符串管理不同控制器类型，易于扩展
8. **生命周期管理**: 完善的创建、初始化和销毁流程
9. **UI层级**: 基于Control的自然层级管理，无需手动设置z_index

## 注意事项

1. **单例模式**: 系统确保场上只能存在一个容器实例
2. **自动清理**: 当创建新容器时，会自动移除已存在的容器
3. **响应式布局**: 容器会根据屏幕尺寸自动调整大小和位置
4. **UI原生**: 基于Control实现，享受Godot UI系统的所有特性

## 扩展性

控制器系统设计具有良好的扩展性：

- **新控制器类型**: 通过继承CtrlBase轻松添加
- **简化布局**: 基于简单位置设置的布局系统，易于理解和维护
- **响应式缩放**: 根据屏幕分辨率动态调整，适应不同屏幕
- **插件化**: 控制器包可独立开发和测试
- **动态加载**: 支持运行时动态加载不同类型的控制器
- **自定义交互**: 每个控制器可定义独特的点击效果
- **UI集成**: 与Godot UI系统完全集成，支持主题、样式等特性