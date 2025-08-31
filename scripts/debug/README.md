# 调试脚本文件夹 (Debug Scripts)

此文件夹包含游戏中用于调试和测试的脚本文件。

## 文件结构

- `button_handler.gd` - 调试按钮和输入框事件处理脚本

## 脚本说明

### 按钮和输入框处理器 (ButtonHandler)

`button_handler.gd` 实现了按钮点击和输入框文本提交的事件处理器，用于调试场景中的交互功能。

#### 按钮点击功能

当按钮被点击时，会创建三张不同位置的打击卡牌并加载卡牌数据，然后将卡牌添加到根场景中。创建的卡牌支持点击特效测试。

```gdscript
func _on_button_pressed():
    # 打印一行文字
    print("按钮被点击了！")
    
    # 创建三张不同位置的卡牌
    create_card(Vector2(700, 540))
    create_card(Vector2(960, 540))
    create_card(Vector2(1220, 540))
    
    # 打印创建成功信息
    print("创建了三张打击卡牌！")
```

**基础卡牌创建**：
```gdscript
func create_card(position: Vector2):
    # 确保卡牌池已初始化
    CardUtil.initialize_card_pool(root_node)
    
    # 使用卡牌池创建卡牌
    var card_instance = CardUtil.create_card_from_pool(root_node, "strike", position)
    
    # 设置卡牌名称，使其区分
    card_count += 1
    card_instance.card_name = "打击 #" + str(card_count)
    
    # 更新显示
    card_instance.update_display()
```

**点击效果测试**：创建的打击卡牌包含点击特效，点击卡牌时会触发以下效果：
- 打印1-100之间的随机数
- 显示卡牌信息
- 将卡牌置于最上层
- 开始拖拽模式

#### 输入框文本提交功能

当在输入框中输入文本并按下回车键时，会触发文本提交事件。调试界面支持多种命令来测试不同的游戏功能。

#### 支持的调试命令

- `hello` - 显示问候信息
- `reboot` - 重启root节点，清除所有卡牌并重新初始化全局工具
- `slide` - 创建一张从屏幕左侧滑动到中央的卡牌，并添加轻微的上下浮动动画
- `random` - 创建一张打击卡牌并将其随机移动到非中心区域（避开中心区域）
- `random2` - 创建一张随机类型的卡牌（打击或防御）并将其随机移动到非中心区域
- `overlap` - 创建5张重叠的卡牌，用于测试层级管理功能
- `listall` - 扫描prefabs目录下所有卡牌预制件并生成实例，按每行17个卡牌的网格布局排列
- `log on` - 开启日志输出
- `log off` - 关闭日志输出
- `help` - 显示所有可用命令和当前日志状态

```gdscript
func _on_input_field_text_submitted(text: String):
    # 检查输入的文本并执行相应命令
    if text.to_lower() == "hello":
        GlobalUtil.log("你好，世界！", GlobalUtil.LogLevel.INFO)
        GlobalUtil.log("收到问候：" + text, GlobalUtil.LogLevel.INFO)
    elif text.to_lower() == "reboot":
        GlobalUtil.log("正在重启root节点...", GlobalUtil.LogLevel.INFO)
        reboot_root_node()
    elif text.to_lower() == "slide":
        GlobalUtil.log("创建滑动卡牌", GlobalUtil.LogLevel.INFO)
        create_sliding_card()
    elif text.to_lower() == "random":
        GlobalUtil.log("创建随机移动卡牌", GlobalUtil.LogLevel.INFO)
        create_random_move_card()
    elif text.to_lower() == "random2":
        GlobalUtil.log("创建随机类型卡牌", GlobalUtil.LogLevel.INFO)
        create_random_type_card()
    elif text.to_lower() == "overlap":
        GlobalUtil.log("创建重叠卡牌测试", GlobalUtil.LogLevel.INFO)
        create_overlapping_cards_test()
    elif text.to_lower() == "log off":
        GlobalUtil.set_log_enabled(false)
        GlobalUtil.log("日志输出已关闭", GlobalUtil.LogLevel.INFO)
    elif text.to_lower() == "log on":
        GlobalUtil.set_log_enabled(true)
        GlobalUtil.log("日志输出已开启", GlobalUtil.LogLevel.INFO)
    elif text.to_lower() == "help":
        show_help()
    else:
        GlobalUtil.log("未知命令：" + text + "，输入 'help' 查看可用命令", GlobalUtil.LogLevel.WARNING)
    
    # 清空输入框
    input_field.text = ""
```

#### 特殊功能方法

**重启root节点功能**：
```gdscript
func reboot_root_node():
    # 获取root节点并清除所有卡牌
    var root = get_tree().get_root().get_node("Root")
    for child in root.get_children():
        if child.name != "Debug" and child.name != "Util":
            root.remove_child(child)
            child.queue_free()
    card_count = 0
    GlobalUtil.log("root节点已重启，所有卡牌已清除", GlobalUtil.LogLevel.INFO)
```

**滑动卡牌创建**：
```gdscript
func create_sliding_card():
    # 确保卡牌池已初始化
    CardUtil.initialize_card_pool(root_node)
    
    # 设置卡牌初始位置（屏幕左侧外）
    var start_position = Vector2(-200, 540)
    
    # 使用卡牌池创建卡牌
    var card_instance = CardUtil.create_card_from_pool(root_node, "strike", start_position)
    
    # 设置卡牌名称并更新显示
    card_instance.card_name = "滑动打击卡牌"
    card_instance.update_display()
    
    # 创建滑动动画
    CardUtil.move_card(card_instance, Vector2(960, 540), 2.0)
```

**随机移动卡牌创建**：
```gdscript
func create_random_move_card():
    # 确保卡牌池已初始化
    CardUtil.initialize_card_pool(root_node)
    
    # 设置卡牌初始位置（屏幕中央）
    var start_position = Vector2(960, 540)
    
    # 使用卡牌池创建卡牌
    var card_instance = CardUtil.create_card_from_pool(root_node, "strike", start_position)
    
    # 设置卡牌名称并更新显示
    card_instance.card_name = "随机移动打击卡牌"
    card_instance.update_display()
    
    # 随机移动卡牌
    var move_distance = CardUtil.random_move_card(card_instance)
    GlobalUtil.log("卡牌移动了：" + str(move_distance), GlobalUtil.LogLevel.INFO)
```

**重叠卡牌测试**：
```gdscript
func create_overlapping_cards_test():
    # 在同一位置创建多张卡牌，测试层级管理
    var base_position = Vector2(960, 540)
    
    # 确保卡牌池已初始化
    CardUtil.initialize_card_pool(root_node)
    
    # 创建5张重叠的卡牌
    for i in range(5):
        # 计算卡牌位置（稍微偏移以便观察层级）
        var offset = Vector2(i * 20, i * 15)  # 每张卡牌稍微偏移
        var target_position = base_position + offset
        
        # 使用卡牌池创建卡牌
        var card_instance = CardUtil.create_card_from_pool(root_node, "strike", target_position)
        
        # 设置卡牌名称
        card_count += 1
        card_instance.card_name = "重叠测试卡牌 #" + str(card_count)
        
        # 更新显示
        card_instance.update_display()
        
        GlobalUtil.log("创建重叠测试卡牌 #" + str(card_count) + " 完成", GlobalUtil.LogLevel.DEBUG)
```

**帮助信息显示**：
```gdscript
func show_help():
    # 显示所有可用命令和当前日志状态
    GlobalUtil.log("=== 可用命令 ===", GlobalUtil.LogLevel.INFO)
    GlobalUtil.log("hello - 显示问候信息", GlobalUtil.LogLevel.INFO)
    GlobalUtil.log("reboot - 重启并清除所有卡牌", GlobalUtil.LogLevel.INFO)
    GlobalUtil.log("slide - 创建滑动卡牌", GlobalUtil.LogLevel.INFO)
    GlobalUtil.log("random - 创建随机移动的打击卡牌", GlobalUtil.LogLevel.INFO)
    GlobalUtil.log("random2 - 创建随机移动的打击或防御卡牌", GlobalUtil.LogLevel.INFO)
    GlobalUtil.log("overlap - 创建5张重叠卡牌测试层级管理", GlobalUtil.LogLevel.INFO)
    GlobalUtil.log("listall - 生成所有卡牌预制件的网格布局", GlobalUtil.LogLevel.INFO)
    GlobalUtil.log("log on/off - 开启/关闭日志输出", GlobalUtil.LogLevel.INFO)
    GlobalUtil.log("help - 显示此帮助信息", GlobalUtil.LogLevel.INFO)
    var log_status = "开启" if GlobalUtil.is_log_enabled() else "关闭"
    GlobalUtil.log("当前日志状态：" + log_status, GlobalUtil.LogLevel.INFO)

    # 重新初始化全局工具
    var util_node = root.get_node("Util")
    if util_node and util_node.has_method("_ready"):
        util_node._ready()
        print("全局工具已重新初始化")
```

**全卡牌预制件展示功能**：
```gdscript
func create_all_prefab_cards():
    # 扫描prefabs目录下的所有.gd文件并生成卡牌实例
    GlobalUtil.log("开始扫描prefabs目录...", GlobalUtil.LogLevel.INFO)
    
    # 确保卡牌池已初始化
    CardUtil.initialize_card_pool(root_node)
    
    var prefabs_dir = "res://scripts/cards/prefabs/"
    var dir = DirAccess.open(prefabs_dir)
    
    if dir == null:
        GlobalUtil.log("无法打开prefabs目录: " + prefabs_dir, GlobalUtil.LogLevel.ERROR)
        return
    
    # 获取所有.gd文件
    var gd_files = []
    dir.list_dir_begin()
    var current_file = dir.get_next()
    
    while current_file != "":
        if current_file.ends_with(".gd") and not current_file.ends_with(".uid"):
            gd_files.append(current_file)
        current_file = dir.get_next()
    
    dir.list_dir_end()
    
    # 按文件名排序
    gd_files.sort()
    
    GlobalUtil.log("找到 " + str(gd_files.size()) + " 个卡牌预制件文件", GlobalUtil.LogLevel.INFO)
    
    # 计算网格布局参数
    var cards_per_row = 17
    var card_width = GlobalConstants.CARD_WIDTH
    var card_height = GlobalConstants.CARD_HEIGHT
    var spacing_x = card_width + 10  # 卡牌间距
    var spacing_y = card_height + 10
    
    # 计算起始位置（居中显示）
    var total_width = cards_per_row * spacing_x - 10
    var start_x = (GlobalConstants.SCREEN_WIDTH - total_width) / 2
    var start_y = 100  # 从屏幕顶部开始
    
    # 生成卡牌实例
    for i in range(gd_files.size()):
        var file_name = gd_files[i]
        var card_type = file_name.replace("_card_pack.gd", "")
        
        # 计算卡牌位置
        var row = i / cards_per_row
        var col = i % cards_per_row
        var position = Vector2(
            start_x + col * spacing_x,
            start_y + row * spacing_y
        )
        
        # 创建卡牌实例
        var card_instance = CardUtil.create_card_from_pool(root_node, card_type, position)
        if card_instance:
            GlobalUtil.log("创建卡牌: " + card_type + " 位置: " + str(position), GlobalUtil.LogLevel.DEBUG)
        else:
            GlobalUtil.log("创建卡牌失败: " + card_type, GlobalUtil.LogLevel.WARNING)
    
    GlobalUtil.log("所有卡牌预制件已生成完成，共 " + str(gd_files.size()) + " 张卡牌", GlobalUtil.LogLevel.INFO)
```

#### 滑动卡牌功能

提供了创建一张从屏幕左侧滑动到中央的卡牌功能，使用Tween动画系统实现平滑移动效果。支持与拖拽功能的冲突处理。

```gdscript
func create_sliding_card():
    # 确保卡牌池已初始化
    CardUtil.initialize_card_pool(root_node)
    
    # 设置卡牌初始位置（屏幕左侧外）
    var start_position = Vector2(-200, 540)
    
    # 使用卡牌池创建卡牌
    var card_instance = CardUtil.create_card_from_pool(root_node, "strike", start_position)
    
    # 设置卡牌名称并更新显示
    card_instance.card_name = "滑动打击卡牌"
    card_instance.update_display()
    
    # 创建滑动动画
    CardUtil.move_card(card_instance, Vector2(960, 540), 2.0)
```

**特性**：
- 卡牌从屏幕左侧滑入到中央位置
- 包含轻微的上下浮动效果
- 支持拖拽功能，拖拽时会自动停止滑动动画
- 动画完成后自动清除Tween引用

#### 随机移动卡牌功能

提供了创建一张卡牌并将其随机移动到非中心区域的功能，使用CardUtil.random_move_card方法实现随机移动效果。支持与拖拽功能的冲突处理。

```gdscript
func create_random_move_card():
    # 确保卡牌池已初始化
    CardUtil.initialize_card_pool(root_node)
    
    # 设置卡牌初始位置（屏幕中央）
    var start_position = Vector2(960, 540)
    
    # 使用卡牌池创建卡牌
    var card_instance = CardUtil.create_card_from_pool(root_node, "strike", start_position)
    
    # 设置卡牌名称
    card_count += 1
    card_instance.card_name = "随机移动打击 #" + str(card_count)
    
    # 更新显示
    card_instance.update_display()
    
    # 使用CardUtil.random_move_card方法随机移动卡牌
    var move_distance = CardUtil.random_move_card(card_instance)
    
    # 打印创建和移动信息
    GlobalUtil.log("创建了一张随机移动的打击卡牌！", GlobalUtil.LogLevel.INFO)
    GlobalUtil.log("卡牌移动了：" + str(move_distance), GlobalUtil.LogLevel.INFO)
```

**特性**：
- 卡牌随机移动到非中心区域（X和Y坐标在-200到200范围内，但避开-50到50的中心区域）
- 使用CardUtil.move_card方法实现平滑移动动画
- 支持拖拽功能，拖拽时会自动停止随机移动动画
- 返回移动距离向量供调试使用

#### 随机类型卡牌功能

提供了创建一张随机类型（打击或防御）的卡牌并将其随机移动到非中心区域的功能，使用CardUtil.random_move_card方法实现随机移动效果。

```gdscript
func create_random_type_card():
    # 确保卡牌池已初始化
    CardUtil.initialize_card_pool(root_node)
    
    # 随机选择卡牌类型
    var card_types = ["strike", "defend"]
    var random_type = card_types[randi() % card_types.size()]
    
    # 设置卡牌初始位置（屏幕中央）
    var start_position = Vector2(960, 540)
    
    # 使用卡牌池创建卡牌
    var card_instance = CardUtil.create_card_from_pool(root_node, random_type, start_position)
    
    # 设置卡牌名称
    card_count += 1
    var type_name = "打击" if random_type == "strike" else "防御"
    card_instance.card_name = "随机" + type_name + " #" + str(card_count)
    
    # 更新显示
    card_instance.update_display()
    
    # 随机移动卡牌
    var move_distance = CardUtil.random_move_card(card_instance)
    
    # 打印创建和移动信息
    GlobalUtil.log("创建了一张随机移动的" + type_name + "卡牌！", GlobalUtil.LogLevel.INFO)
    GlobalUtil.log("卡牌移动了：" + str(move_distance), GlobalUtil.LogLevel.INFO)
```

**特性**：
- 随机选择打击或防御卡牌类型
- 卡牌随机移动到非中心区域
- 支持拖拽功能，拖拽时会自动停止随机移动动画
- 根据卡牌类型设置相应的名称和特效

## 卡牌池系统

为了解决 `overlap` 命令生成的卡牌首次拖动无响应的问题，我们实现了卡牌池系统：

### 问题原因
- 卡牌的 `Area2D` 组件需要时间完全初始化
- 输入检测系统在卡牌创建后立即可能还未完全准备就绪
- 等待机制会影响游戏体验

### 解决方案
- 预加载5张空白卡牌到隐藏位置，保持输入检测组件就绪
- 需要生成卡牌时从池中获取预加载的卡牌
- 使用 `goto_card` 方法将卡牌瞬移到目标位置
- 卡牌使用完毕后可返回池中重复使用

### 优化效果
- 消除了卡牌首次拖拽的延迟问题
- 避免了等待机制对游戏体验的影响
- 提高了卡牌创建的性能
- 实现了卡牌资源的重复利用

## 全局常量系统集成

调试系统已完全集成全局常量系统，所有硬编码的位置和数值都已替换为`GlobalConstants`中的常量：

### 替换的常量

- **屏幕位置**：
  - `Vector2(960, 540)` → `GlobalConstants.SCREEN_CENTER`
  - `Vector2(-200, 540)` → `GlobalConstants.SCREEN_LEFT_OUTSIDE`

- **动画时长**：
  - 滑动动画使用 `GlobalConstants.SLIDE_DURATION`
  - 移动动画使用 `GlobalConstants.DEFAULT_MOVE_DURATION`

### 优势

- **统一配置**：所有位置和时长参数集中管理
- **易于调整**：修改屏幕布局只需更改常量值
- **类型安全**：避免硬编码错误
- **代码可读性**：常量名称更具语义化

## 开发指南

### 添加新的调试脚本

添加新的调试脚本时，请遵循以下规范：

1. 使用有意义的文件名，采用snake_case命名法
2. 在脚本开头添加类注释，说明脚本的调试用途
3. 为调试功能添加清晰的注释
4. 调试脚本应该尽量简单明了，专注于特定功能的测试
5. 避免在调试脚本中包含复杂的游戏逻辑
6. 使用 `GlobalConstants` 中的常量而非硬编码数值

### 调试脚本的使用

调试脚本主要用于以下场景：

1. 测试游戏功能和交互
2. 验证UI元素的响应
3. 检查信号连接是否正常工作
4. 模拟游戏中的特定场景或状态