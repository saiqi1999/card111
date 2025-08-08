# 全局工具系统

本目录包含游戏中使用的全局工具类和加载器。

## 文件说明

### util.gd

`util.gd` 是全局工具类，提供了一系列通用的工具方法：

- `debug_log(message)`: 输出调试信息
- `get_timestamp()`: 获取当前时间戳
- `random_int(min_value, max_value)`: 生成指定范围内的随机整数
- `calculate_distance(point1, point2)`: 计算两点之间的距离
- `format_time(seconds)`: 将秒数格式化为分:秒格式

### global_util_loader.gd

`global_util_loader.gd` 是全局工具加载器，负责初始化全局工具实例并将其注册为自动加载单例。

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
    # 输出调试信息
    GlobalUtil.debug_log("Hello World!")
    
    # 获取随机数
    var random_value = GlobalUtil.random_int(1, 10)
    GlobalUtil.debug_log("随机数: %d" % random_value)
    
    # 计算距离
    var distance = GlobalUtil.calculate_distance(Vector2(0, 0), Vector2(3, 4))
    GlobalUtil.debug_log("距离: %f" % distance)
```

## 注意事项

- 全局工具实例在Root场景加载时创建，在场景退出时销毁
- 如果需要添加新的全局工具方法，请在 `util.gd` 中添加
- 确保Root场景是游戏的第一个加载场景，以便全局工具能够正确初始化