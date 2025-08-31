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

### recipe_util.gd

配方管理工具类，作为Autoload单例运行，负责管理卡牌之间的合成配方：

#### 核心功能
- **配方注册**: 支持动态注册新的合成配方
- **自动检测**: 当卡牌形成堆叠时自动检查是否匹配配方
- **合成管理**: 管理合成进度和时间控制
- **回调处理**: 合成完成后自动调用参与卡牌的`after_recipe_done`方法

#### 默认配方
- **铁铲 + 土堆 → 初级花盆**: 合成时间5秒

#### 合成进度条管理
- **进度条显示**: 合成开始时自动显示进度条
- **实时更新**: 合成过程中实时更新进度条显示
- **位置同步**: 卡牌移动时进度条位置自动同步
- **自动隐藏**: 合成完成或取消时自动隐藏进度条
- **连续合成**: 支持连续合成，完成后自动检查是否可继续合成

#### 主要方法
- `register_recipe(ingredients, craft_time, result_type)`: 注册新配方
- `check_stack_for_recipe(stack_cards)`: 检查堆叠是否匹配配方
- `start_crafting(stack_cards, stack_id)`: 开始合成过程
- `get_active_crafting_info()`: 获取当前合成任务信息
- `cancel_crafting(stack_id)`: 取消指定堆叠的合成
- `_complete_crafting(task)`: 完成合成，调用参与卡牌的`after_recipe_done`方法
- `show_progress_bar_for_stack(stack_id)`: 显示指定堆叠的进度条
- `update_progress_bar_for_stack(stack_id, progress)`: 更新进度条进度
- `hide_progress_bar_for_stack(stack_id)`: 隐藏指定堆叠的进度条
- `update_progress_bar_position_for_stack(stack_id)`: 更新进度条位置

#### 使用方式
```gdscript
# 全局访问（Autoload单例）
RecipeUtil.register_recipe(["卡牌A", "卡牌B"], 3.0, "合成产物")
var crafting_info = RecipeUtil.get_active_crafting_info()
```

### recipe_constant.gd

配方常量管理单例，用于存储所有配方数据：

#### 主要功能
- **配方数据存储**: 以JSON格式存储配方数据
- **配方数据解析**: 解析和获取配方信息
- **动态添加**: 支持动态添加新配方
- **数据验证**: 配方数据格式验证

#### 配方数据格式
```json
{
  "ingredients": ["iron_shovel", "dirt_pile"],
  "products": ["primary_flower_pot"],
  "craft_time": 5.0
}
```

#### 主要方法
- `get_all_recipes()`: 获取所有配方数据
- `add_recipe(ingredients, products, craft_time)`: 添加新配方

### stack_util.gd

卡牌堆叠管理工具，使用Autoload单例模式，管理所有卡牌的堆叠逻辑：

#### 主要功能
- **堆叠状态管理**: 管理所有卡牌的堆叠状态
- **堆叠检测**: 自动检测和处理卡牌堆叠
- **连带拖拽**: 支持堆叠卡牌的连带拖拽
- **堆叠信息统计**: 提供堆叠信息的统计和显示
- **合成检查集成**: 与配方系统集成，自动检查合成
- **位置更新**: 自动更新堆叠中卡牌的位置

#### 核心数据结构
- `card_stacks: Dictionary`: 卡牌堆叠状态管理 {stack_id: [card1, card2, ...]}
- `card_to_stack: Dictionary`: 卡牌到堆叠的映射 {card_instance_id: stack_id}
- `stack_id_counter: int`: 堆叠ID计数器

#### 主要方法
- `cleanup_invalid_stacks()`: 清理无效的堆叠引用
- `get_cards_above(card)`: 获取卡牌上方的所有卡牌（用于连带拖拽）
- `is_in_stack(card)`: 检查卡牌是否在堆叠中
- `get_stack_info(card)`: 获取卡牌所在堆叠的统计信息
- `format_stack_info_for_display(card)`: 格式化堆叠信息用于显示
- `check_stack_for_crafting(stack_id)`: 检查堆叠是否匹配配方并开始合成
- `stack_card_on_target(source_card, target_card)`: 将卡牌堆叠到目标卡牌上
- `stack_cards_on_target(source_cards, target_card)`: 将卡牌组堆叠到目标卡牌上
- `update_stack_positions(stack_id)`: 更新堆叠中所有卡牌的位置
- `find_stackable_card_at_position(position, exclude_card)`: 在指定位置查找可堆叠的卡牌
- `try_stack_card(card, position)`: 检查并尝试堆叠卡牌
- `get_stack_size(stack_id)`: 获取堆叠大小
- `is_bottom_card(card, stack_id)`: 检查卡牌是否是堆叠底部卡牌
- `get_stack_cards(stack_id)`: 获取堆叠中的卡牌数组

#### 堆叠特性
- **自动堆叠**: 当卡牌拖拽到其他卡牌附近时自动堆叠
- **连带拖拽**: 拖拽堆叠中的卡牌时，上方的卡牌会一起移动
- **位置管理**: 自动管理堆叠中卡牌的相对位置和偏移
- **合成集成**: 堆叠形成时自动检查是否可以进行合成
- **信息显示**: 提供堆叠信息的格式化显示功能
- **无效清理**: 自动清理无效的堆叠引用和映射

#### 使用方式
```gdscript
# 检查卡牌是否在堆叠中
if StackUtil.is_in_stack(card):
    var stack_info = StackUtil.get_stack_info(card)
    print("堆叠信息: ", stack_info)

# 尝试堆叠卡牌
var success = StackUtil.try_stack_card(card, target_position)

# 获取卡牌上方的所有卡牌（用于连带拖拽）
var cards_above = StackUtil.get_cards_above(card)
```

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

#### 配方合成相关常量
- `DEFAULT_CRAFT_TIME`: 默认合成时间（5.0秒）
- `RECIPE_CHECK_INTERVAL`: 合成进度检查间隔（0.1秒）

#### 日志配置常量
- `DEFAULT_LOG_ENABLED`: 默认日志开关状态（true）

#### 容器层级常量
- `CTRL_Z_INDEX`: 控制器主体层级（10000000）
- `CTRL_TITLE_Z_INDEX`: 控制器标题层级（10000015）
- `CTRL_UI_Z_INDEX`: 控制器UI元素层级（10000020）

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