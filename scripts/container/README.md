# 容器系统脚本

此文件夹包含与容器系统相关的所有脚本。

## 文件结构

- `container.gd` - 容器脚本，实现容器的显示、交互和管理功能

## 脚本说明

### 容器脚本 (Container)

`container.gd` 实现了一个可交互的容器系统，用于显示和管理游戏中的容器界面。

#### 主要功能

**容器显示**：
- 使用 `TextureRect` 显示容器背景图像
- 固定尺寸为 400x300 像素，使用拉伸模式适应图像
- 容器居中显示在屏幕上

**点击检测**：
- 使用 `Area2D` 和 `CollisionShape2D` 实现精确的点击检测
- 检测范围与视觉显示尺寸完全匹配（400x300）
- 点击容器外部区域会移除容器
- 点击容器内部区域不会触发移除

**交互逻辑**：
```gdscript
func _on_area_2d_input_event(viewport, event, shape_idx):
    # 处理容器内部点击事件
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        GlobalUtil.log("点击了容器内部，不移除容器", GlobalUtil.LogLevel.DEBUG)
        get_viewport().set_input_as_handled()

func _input(event):
    # 处理全局点击事件
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if not get_viewport().gui_get_focus_owner():
            GlobalUtil.log("点击了容器外部，移除容器", GlobalUtil.LogLevel.DEBUG)
            queue_free()
```

#### 技术实现

**节点结构**：
- `Container` (Control) - 根节点
  - `Background` (TextureRect) - 背景显示
  - `Area2D` - 点击检测区域
    - `CollisionShape2D` - 碰撞形状

**尺寸配置**：
- 背景位置：`Vector2(-200, -150)`
- 背景尺寸：`Vector2(400, 300)`
- 拉伸模式：`STRETCH_KEEP_ASPECT_CENTERED`
- 碰撞形状：矩形，尺寸与背景匹配

**日志集成**：
- 使用 `GlobalUtil.log()` 记录交互事件
- 支持不同日志级别的输出
- 便于调试和问题排查

#### 使用方法

**创建容器**：
```gdscript
# 实例化容器场景
var container_scene = preload("res://scenes/container.tscn")
var container_instance = container_scene.instantiate()

# 添加到场景树
get_tree().current_scene.add_child(container_instance)

# 容器会自动居中显示并处理交互
```

**容器特性**：
- 自动居中显示
- 点击外部自动关闭
- 点击内部保持显示
- 支持拖拽和其他交互（如果需要）

#### 全局常量系统集成

容器系统已集成全局常量系统，相关配置通过 `GlobalConstants` 管理：

- **容器尺寸**：可通过全局常量统一配置
- **位置计算**：使用屏幕中心等全局位置常量
- **日志配置**：遵循全局日志系统设置

#### 扩展说明

要扩展容器功能，可以考虑以下方向：

1. **动画效果**：添加容器出现和消失的动画
2. **内容管理**：在容器内部添加具体的UI元素
3. **多种容器**：创建不同类型和尺寸的容器
4. **拖拽功能**：允许用户拖拽移动容器
5. **键盘交互**：支持ESC键关闭容器

#### 注意事项

1. 容器的视觉尺寸必须与检测区域尺寸匹配
2. 使用 `queue_free()` 而非 `remove_child()` 来销毁容器
3. 确保在容器内部点击时调用 `get_viewport().set_input_as_handled()`
4. 容器脚本路径已从 `scripts/mobs` 移动到 `scripts/container`
5. 所有引用该脚本的文件都已更新路径

## 开发指南

### 添加新的容器类型

创建新的容器类型时，请遵循以下规范：

1. 继承现有的容器脚本或创建新的容器基类
2. 确保视觉显示与检测区域尺寸匹配
3. 使用 `GlobalUtil.log()` 记录重要事件
4. 遵循统一的命名规范
5. 添加适当的注释说明功能

### 代码风格

- 使用有意义的变量和函数名
- 为公共方法添加注释
- 使用 `GlobalConstants` 中的常量而非硬编码数值
- 遵循GDScript的代码规范