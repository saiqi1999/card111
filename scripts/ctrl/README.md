# 控制器系统

简化的控制器系统，遵循Godot最佳实践，只保留必要的功能。<mcreference link="https://docs.godotengine.org/en/3.2/getting_started/step_by_step/singletons_autoload.html" index="1">1</mcreference>

## 文件结构

- `camera_ctrl.gd` - 相机控制器，提供可拖拽和缩放的2D相机功能
- `prefabs/` - UI组件文件夹
  - `ctrl_400_300.gd` - 简化的信息面板，使用Autoload单例模式
- `README.md` - 本说明文件

## 信息面板 (Ctrl400x300)

`prefabs/ctrl_400_300.gd` 是一个简化的信息显示面板，使用Autoload单例模式。<mcreference link="https://www.reddit.com/r/godot/comments/zrxhor/what_are_appropriate_singletons/" index="2">2</mcreference>

#### 主要功能

- **Autoload单例**: 全局可访问，无需实例化
- **简单显示**: 提供基本的标题和描述显示
- **固定位置**: 锚定在屏幕左下角
- **响应式**: 自动适应窗口大小变化

#### 使用示例

```gdscript
# 显示信息面板
Ctrl400x300.show_ctrl()

# 设置显示内容
Ctrl400x300.set_ctrl_title_and_description("标题", "描述信息")

# 隐藏信息面板
Ctrl400x300.hide_ctrl()
```

## 相机控制器 (CameraCtrl)

`camera_ctrl.gd` 继承自 `Camera2D`，提供可拖拽和缩放的2D相机功能，服务于root节点进行观察。

#### 主要功能

- **鼠标左键拖拽**: 按住鼠标左键可拖拽移动相机视野
- **智能卡牌检测**: 当鼠标位置有卡牌时，自动避免相机拖拽，优先处理卡牌操作
- **滚轮缩放**: 使用鼠标滚轮进行相机缩放（放大/缩小）
- **缩放限制**: 限制相机缩放范围在0.5x到3.0x之间
- **平滑操作**: 提供流畅的拖拽和缩放体验
- **位置管理**: 自动管理相机位置和状态

#### 核心属性

- `is_dragging`: 是否正在拖拽状态
- `drag_start_position`: 拖拽开始时的鼠标位置
- `camera_start_position`: 拖拽开始时的相机位置
- `current_zoom`: 当前缩放级别

#### 主要方法

- `start_dragging(mouse_pos)`: 开始拖拽操作
- `stop_dragging()`: 停止拖拽操作
- `update_camera_position(current_mouse_pos)`: 更新相机位置（拖拽时）
- `is_mouse_over_card()`: 检查鼠标位置是否有卡牌
- `zoom_in()`: 相机放大
- `zoom_out()`: 相机缩小
- `reset_camera()`: 重置相机位置和缩放
- `set_camera_position(new_position)`: 设置相机位置
- `set_camera_zoom(new_zoom)`: 设置相机缩放
- `get_camera_zoom()`: 获取当前缩放值
- `get_camera_info()`: 获取相机信息（用于调试）

#### 操作方式

```gdscript
# 鼠标右键拖拽移动视野
# 在_input事件中处理
if event.button_index == MOUSE_BUTTON_RIGHT:
	if event.pressed:
		start_dragging(event.position)  # 开始拖拽
	else:
		stop_dragging()  # 结束拖拽

# 滚轮缩放
elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
	zoom_in()  # 放大
elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
	zoom_out()  # 缩小
```

#### 相机特性

- **自动激活**: 初始化时自动设置为当前活动相机
- **智能拖拽**: 拖拽速度根据当前缩放级别自动调整
- **边界安全**: 缩放操作有最小值和最大值限制
- **调试支持**: 提供详细的日志输出和状态信息
- **响应式**: 根据缩放级别调整拖拽灵敏度

#### 使用示例

```gdscript
# 获取相机实例（在root.tscn场景中）
var camera = $Camera2D as CameraCtrl

# 重置相机
camera.reset_camera()

# 设置特定位置
camera.set_camera_position(Vector2(100, 100))

# 设置特定缩放
camera.set_camera_zoom(1.5)

# 获取当前缩放
var current_zoom = camera.get_camera_zoom()

# 获取相机调试信息
var info = camera.get_camera_info()
print("相机位置: ", info.position)
print("相机缩放: ", info.zoom)
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
- **尺寸**: 固定400x300像素
- **定位方式**: 使用简单的position设置，避免复杂的锚点问题
- **固定尺寸**: 使用400x300像素固定尺寸

### 如何创建新的容器类型

1. **创建新的容器子类**：
```gdscript
# 例如：ctrl_custom.gd
extends Control
class_name CtrlCustom

# 控制器基本属性
var ctrl_name: String = "自定义容器"
var description: String = "自定义容器描述"
var ctrl_texture: Texture2D = null
var on_click: Callable = Callable()

# UI元素引用
var background_panel: Panel
var title_label: Label
var description_label: Label

func _init():
	ctrl_name = "自定义容器"
	description = "自定义容器描述"
	on_click = custom_click_effect

func custom_click_effect(ctrl_instance):
	# 定义自定义点击行为
	pass

# 需要实现的核心方法
func setup_ctrl_ui():
	# 创建UI元素的逻辑
	pass

func setup_ctrl_layout():
	# 设置布局的逻辑
	pass
```



## 使用方法

### 使用Autoload单例（推荐方式）

#### 通过卡牌交互显示控制器

```gdscript
# 鼠标进入卡牌时显示控制器
func _on_mouse_entered():
	# 使用Autoload访问ctrl_400_300单例
	# 设置控制器的标题和描述
	var card_title = card_name if card_name else "未知卡牌"
	var card_desc = description if description else "无描述"
	Ctrl400x300.set_ctrl_title_and_description(card_title, card_desc)
	
	# 显示控制器
	Ctrl400x300.show_ctrl()

# 鼠标离开卡牌时隐藏控制器
func _on_mouse_exited():
	# 使用Autoload访问ctrl_400_300单例并隐藏
	Ctrl400x300.hide_ctrl()
```

### Autoload配置

在`project.godot`中配置Autoload：

```ini
[autoload]

Ctrl400x300="*res://scripts/ctrl/prefabs/ctrl_400_300.gd"
```

#### 全局访问方式
```gdscript
# 在任何脚本中直接使用
Ctrl400x300.show_ctrl()  # 显示控制器
Ctrl400x300.hide_ctrl()  # 隐藏控制器
Ctrl400x300.set_ctrl_title_and_description("标题", "描述")  # 设置内容
```

### 容器特性
- 使用anchor系统固定在窗口左下角（不随相机移动）
- 固定尺寸（400x300像素，不随屏幕分辨率变化）
- 支持动态标题和描述
- Autoload单例模式（全局唯一实例）
- 自动添加到场景树（解决Autoload Control节点显示问题）
- 基于Control的原生UI交互
- 内存安全（Godot引擎自动管理生命周期）

## 系统架构

简化的UI控制器系统架构：

```
Autoload单例
├── Ctrl400x300 - 信息面板单例
│   ├── 基本显示功能
│   └── 响应式布局

独立组件
├── CameraCtrl - 相机控制器
│   ├── 拖拽和缩放功能
│   └── 卡牌检测逻辑
```

## 设计原则

遵循Godot最佳实践的简化设计：

1. **最小化复杂性**: 只保留必要功能，避免过度设计
2. **Autoload单例**: 使用官方推荐的单例模式
3. **全局访问**: 简单直接的API调用
4. **响应式布局**: 自动适应窗口变化