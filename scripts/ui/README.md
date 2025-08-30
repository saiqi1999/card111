# UI组件系统

本目录包含游戏中使用的各种可复用UI组件，提供丰富的用户界面功能。

## 文件说明

### crafting_progress_bar.gd

`crafting_progress_bar.gd` 是合成进度条UI组件，继承自Control节点，为合成系统提供可视化的进度显示功能。

#### 核心功能
- **自定义UI组件**: 基于Control节点的独立进度条组件
- **实时进度显示**: 支持0.0-1.0范围的进度值显示
- **自定义样式**: 可配置进度条颜色、高度和背景样式
- **动态位置调整**: 支持相对于卡牌堆叠的位置自动调整
- **生命周期管理**: 自动管理显示、隐藏和销毁流程

#### 样式配置
- `bar_height`: 进度条高度（默认4.0像素）
- `bar_color`: 进度条颜色（默认白色）
- `background_color`: 背景颜色（默认半透明灰色）

#### 位置调整
- **智能定位**: 进度条位置相对于卡牌堆叠自动计算
- **偏移设置**: 向左移动半个卡牌宽度，向上移动半个卡牌高度
- **动态更新**: 卡牌移动时进度条位置自动同步

#### 主要方法
- `show_progress_bar(card_width)`: 显示进度条并设置宽度
- `hide_progress_bar()`: 隐藏进度条并重置进度
- `update_progress(new_progress)`: 更新进度值（0.0-1.0）
- `set_position_below_stack(stack_position, stack_height)`: 设置进度条位置
- `_draw()`: 自定义绘制方法，绘制背景和进度条
- `_on_complete_delay_finished(timer)`: 完成延迟后自动隐藏

#### 使用示例
```gdscript
# 创建进度条实例
var progress_bar_script = preload("res://scripts/ui/crafting_progress_bar.gd")
var progress_bar = Control.new()
progress_bar.set_script(progress_bar_script)

# 添加到场景树
parent_node.add_child(progress_bar)

# 设置位置和显示
progress_bar.set_position_below_stack(stack_position, stack_height)
progress_bar.show_progress_bar(card_width)

# 更新进度
progress_bar.update_progress(0.5)  # 50%进度

# 隐藏进度条
progress_bar.hide_progress_bar()
```

#### 自动化功能
- **完成检测**: 当进度达到100%时，自动延迟0.2秒后隐藏
- **重绘优化**: 只在需要时触发重绘，提升性能
- **内存管理**: 自动清理定时器资源，避免内存泄漏

## 设计原则

### 可复用性
- 组件设计独立，不依赖特定的游戏逻辑
- 支持多种使用场景和自定义配置
- 提供清晰的API接口，易于集成

### 性能优化
- 使用Godot原生绘制系统，性能优异
- 智能重绘机制，避免不必要的渲染
- 轻量级设计，内存占用最小

### 用户体验
- 平滑的动画效果和视觉反馈
- 智能的位置调整和布局适应
- 直观的进度显示和状态管理

## 扩展指南

### 添加新UI组件

1. 在`ui/`目录下创建新的脚本文件
2. 继承合适的Godot UI节点（Control、Panel等）
3. 实现必要的接口方法和属性
4. 添加详细的注释和使用示例
5. 更新本README文件，添加组件说明

### 组件命名规范

- 使用snake_case命名法
- 文件名应清晰描述组件功能
- 类名使用PascalCase，与文件名对应

### 代码规范

- 遵循Godot的GDScript编码规范
- 添加中文注释说明功能和用法
- 提供完整的错误处理和边界检查
- 使用类型标注提高代码可读性

## 注意事项

- UI组件应保持独立性，避免与游戏逻辑强耦合
- 使用Godot的信号系统进行事件通信
- 注意内存管理，及时清理不再使用的资源
- 测试组件在不同屏幕分辨率下的表现