# 调试脚本文件夹 (Debug Scripts)

此文件夹包含游戏中用于调试和测试的脚本文件。

## 文件结构

- `button_handler.gd` - 调试按钮事件处理脚本

## 脚本说明

### 按钮处理器 (ButtonHandler)

`button_handler.gd` 实现了一个按钮点击事件处理器，用于调试场景中的按钮交互。当按钮被点击时，会创建一个卡牌场景并通过类型字符串加载打击卡牌数据，然后将卡牌添加到根场景中。

```gdscript
func _on_button_pressed():
    # 打印一行文字
    print("按钮被点击了！")
    
    # 创建卡牌场景实例
    var card_instance = card_scene.instantiate()
    
    # 设置卡牌位置在屏幕中央
    card_instance.position = Vector2(960, 540)
    
    # 通过类型字符串加载卡牌
    card_instance.load_from_card_type("strike")
    
    # 将卡牌添加到根场景
    root_node.add_child(card_instance)
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