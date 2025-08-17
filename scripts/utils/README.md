# 全局工具系统

本目录包含游戏中使用的全局工具类和加载器，提供日志管理、通用工具方法和全局常量配置。

## 文件说明

### util.gd

`util.gd` 是全局工具类，提供了一系列通用的工具方法和统一的日志管理系统：

#### 日志管理功能
- `log(message, level)`: 统一的日志输出接口，支持日志级别控制
- `set_log_enabled(enabled)`: 动态开启/关闭日志输出
- `is_log_enabled()`: 检查当前日志状态
- `LogLevel` 枚举: 支持DEBUG、INFO、WARNING、ERROR四个级别

#### 通用工具方法
- `debug_log(message)`: 输出调试信息（已更新为调用log方法）
- `get_timestamp()`: 获取当前时间戳
- `random_int(min_value, max_value)`: 生成指定范围内的随机整数
- `calculate_distance(point1, point2)`: 计算两点之间的距离
- `format_time(seconds)`: 将秒数格式化为分:秒格式

### global_constants.gd

全局常量类，定义了游戏中使用的所有常量配置：

#### 卡牌池相关常量
- `CARD_POOL_SIZE`: 卡牌池大小（默认5）
- `CARD_POOL_HIDDEN_POSITION`: 卡牌池隐藏位置

#### 卡牌尺寸和透明度常量
- `CARD_WIDTH`: 卡牌宽度（200像素）
- `CARD_HEIGHT`: 卡牌高度（300像素）
- `CARD_DRAG_ALPHA`: 拖拽时的透明度（0.5）
- `CARD_NORMAL_ALPHA`: 卡牌正常透明度（1.0）

#### 动画相关常量
- `DEFAULT_MOVE_DURATION`: 默认移动动画时长（1.0秒）
- `SLIDE_DURATION`: 滑动动画时长（2.0秒）

#### 随机移动相关常量
- `RANDOM_MOVE_RANGE`: 随机移动范围（200像素）
- `CENTER_AVOID_RANGE`: 中心避让范围（50像素）

#### 屏幕位置常量
- `SCREEN_CENTER`: 屏幕中心位置（960, 540）
- `SCREEN_LEFT_OUTSIDE`: 屏幕左侧外部位置（-200, 540）

#### 日志配置常量
- `DEFAULT_LOG_ENABLED`: 默认日志开关状态（true）

#### 容器层级常量
- `CONTAINER_Z_INDEX`: 容器主体层级（10000000）
- `CONTAINER_TITLE_Z_INDEX`: 容器标题层级（10000015）
- `CONTAINER_UI_Z_INDEX`: 容器UI元素层级（10000020）

### global_util_loader.gd

`global_util_loader.gd` 是全局工具加载器，负责初始化全局工具实例和全局常量，并将其注册为自动加载单例。

## 使用方法

### 在Root场景中添加全局工具加载器

1. 打开Godot编辑器，加载项目
2. 打开root.tscn场景
3. 在场景树中右键点击Root节点，选择"添加子节点"
4. 添加一个新的Node节点，命名为"GlobalUtilLoader"
5. 选择新创建的GlobalUtilLoader节点，在检查器面板中点击"脚本"旁边的下拉菜单
6. 选择"加载"，然后导航到 `res://scripts/utils/global_util_loader.gd`
7. 保存场景

### 在代码中使用全局工具

一旦全局工具加载器被添加到Root场景并且游戏运行，你可以在任何脚本中通过以下方式访问全局工具：

```gdscript
# 使用全局工具的示例
func _ready():
    # 使用新的日志系统
    GlobalUtil.log("Hello World!", GlobalUtil.LogLevel.INFO)
    
    # 不同级别的日志输出
    GlobalUtil.log("调试信息", GlobalUtil.LogLevel.DEBUG)
    GlobalUtil.log("一般信息", GlobalUtil.LogLevel.INFO)
    GlobalUtil.log("警告信息", GlobalUtil.LogLevel.WARNING)
    GlobalUtil.log("错误信息", GlobalUtil.LogLevel.ERROR)
    
    # 控制日志开关
    GlobalUtil.set_log_enabled(false)  # 关闭日志
    GlobalUtil.log("这条信息不会显示", GlobalUtil.LogLevel.INFO)
    GlobalUtil.set_log_enabled(true)   # 开启日志
    
    # 检查日志状态
    if GlobalUtil.is_log_enabled():
        GlobalUtil.log("日志已开启", GlobalUtil.LogLevel.INFO)
    
    # 使用其他工具方法
    var random_value = GlobalUtil.random_int(1, 10)
    GlobalUtil.log("随机数: %d" % random_value, GlobalUtil.LogLevel.DEBUG)
    
    var distance = GlobalUtil.calculate_distance(Vector2(0, 0), Vector2(3, 4))
    GlobalUtil.log("距离: %f" % distance, GlobalUtil.LogLevel.DEBUG)
```

### 日志系统特性

- **性能优化**: 关闭日志时可显著提升游戏性能
- **级别控制**: 支持不同级别的日志输出，便于调试和发布
- **动态控制**: 运行时可通过命令或代码动态开启/关闭
- **统一管理**: 所有日志输出通过统一接口管理，便于维护

## 注意事项

- 全局工具实例在Root场景加载时创建，在场景退出时销毁
- 如果需要添加新的全局工具方法，请在 `util.gd` 中添加
- 确保Root场景是游戏的第一个加载场景，以便全局工具能够正确初始化