# 调试脚本文件夹 (Debug Scripts)

此文件夹包含游戏中用于调试和测试的脚本文件。

## 文件结构

- `button_handler.gd` - 调试按钮和输入框事件处理脚本

## 脚本说明

### 按钮和输入框处理器 (ButtonHandler)

`button_handler.gd` 实现了按钮点击和输入框文本提交的事件处理器，用于调试场景中的交互功能。

#### 按钮点击功能

当按钮被点击时，会创建三张不同位置的卡牌并通过类型字符串加载打击卡牌数据，然后将卡牌添加到根场景中。

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

#### 输入框文本提交功能

当在输入框中输入文本并按下回车键时，会触发文本提交事件。特别地，当输入"hello"时，会打印特定的问候信息；当输入"reboot"时，会重启root节点，清除所有卡牌并重新初始化全局工具；当输入"slide"时，会创建一张从屏幕左侧滑动到中央的卡牌；当输入"random"时，会创建一张卡牌并将其随机移动到非中心区域。

```gdscript
func _on_input_field_text_submitted(text: String):
    # 检查输入的文本
    if text.to_lower() == "hello":
        # 打印一行信息
        print("你好，世界！")
        
        # 在控制台显示一条消息
        print("收到问候：" + text)
    elif text.to_lower() == "reboot":
        # 打印重启信息
        print("正在重启root节点...")
        
        # 调用重启方法
        reboot_root_node()
    elif text.to_lower() == "slide":
        # 打印滑动信息
        print("创建滑动卡牌...")
        
        # 调用滑动卡牌方法
        create_sliding_card()
    elif text.to_lower() == "random":
        # 打印随机移动信息
        print("创建随机移动卡牌...")
        
        # 调用随机移动卡牌方法
        create_random_move_card()
    else:
        # 打印其他输入
        print("收到输入：" + text)
    
    # 清空输入框
    input_field.text = ""
```

#### 重启root节点功能

提供了重启root节点的功能，清除所有卡牌并重新初始化全局工具。

```gdscript
func reboot_root_node():
    # 获取root节点
    var root = get_tree().get_root().get_node("Root")
    
    # 清除所有卡牌
    for child in root.get_children():
        # 跳过Debug和Util节点
        if child.name != "Debug" and child.name != "Util":
            # 移除子节点
            root.remove_child(child)
            # 释放资源
            child.queue_free()
    
    # 重置卡牌计数
    card_count = 0
    
    # 打印重启完成信息
    print("root节点已重启，所有卡牌已清除")
    
    # 重新初始化全局工具
    var util_node = root.get_node("Util")
    if util_node and util_node.has_method("_ready"):
        util_node._ready()
        print("全局工具已重新初始化")
```

#### 滑动卡牌功能

提供了创建一张从屏幕左侧滑动到中央的卡牌功能，使用Tween动画系统实现平滑移动效果。

```gdscript
func create_sliding_card():
    # 创建卡牌场景实例
    var card_instance = card_scene.instantiate()
    
    # 设置卡牌初始位置（屏幕左侧外）
    card_instance.position = Vector2(-200, 540)
    
    # 通过类型字符串加载卡牌
    card_instance.load_from_card_type("strike")
    
    # 设置卡牌名称
    card_count += 1
    card_instance.card_name = "滑动打击 #" + str(card_count)
    
    # 将卡牌添加到根场景
    root_node.add_child(card_instance)
    
    # 创建Tween动画
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_QUART)
    
    # 设置卡牌移动动画（从左到右）
    tween.tween_property(card_instance, "position", Vector2(960, 540), 1.5)
    
    # 添加第二段动画（轻微上下浮动）
    tween.tween_property(card_instance, "position", Vector2(960, 520), 0.5)
    tween.tween_property(card_instance, "position", Vector2(960, 540), 0.5)
    
    # 打印创建信息
    print("创建了一张从左向右滑动的打击卡牌！")
```

#### 随机移动卡牌功能

提供了创建一张卡牌并将其随机移动到非中心区域的功能，使用CardUtil.random_move_card方法实现随机移动效果。卡牌会移动到X和Y坐标在-200到200范围内，但避开-50到50的中心区域。

```gdscript
func create_random_move_card():
    # 创建卡牌场景实例
    var card_instance = card_scene.instantiate()
    
    # 设置卡牌初始位置（屏幕中央）
    card_instance.position = Vector2(960, 540)
    
    # 通过类型字符串加载卡牌
    card_instance.load_from_card_type("strike")
    
    # 设置卡牌名称
    card_count += 1
    card_instance.card_name = "随机移动打击 #" + str(card_count)
    
    # 将卡牌添加到根场景
    root_node.add_child(card_instance)
    
    # 使用CardUtil.random_move_card方法随机移动卡牌
    var move_distance = CardUtil.random_move_card(card_instance)
    
    # 打印创建和移动信息
    print("创建了一张随机移动的打击卡牌！")
    print("卡牌移动了：", move_distance)
```

## 开发指南

### 添加新的调试脚本

添加新的调试脚本时，请遵循以下规范：

1. 使用有意义的文件名，采用snake_case命名法
2. 在脚本开头添加类注释，说明脚本的调试用途
3. 为调试功能添加清晰的注释
4. 调试脚本应该尽量简单明了，专注于特定功能的测试
5. 避免在调试脚本中包含复杂的游戏逻辑

### 调试脚本的使用

调试脚本主要用于以下场景：

1. 测试游戏功能和交互
2. 验证UI元素的响应
3. 检查信号连接是否正常工作
4. 模拟游戏中的特定场景或状态