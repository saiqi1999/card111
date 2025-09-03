# 卡牌装饰器系统

## 概述

卡牌装饰器系统使用装饰器设计模式为卡牌实例动态添加额外的行为和属性。通过标签系统，可以灵活地管理卡牌的特殊状态和功能。

## 设计原理

### 装饰器模式
- **CardDecoratorBase**: 装饰器基类，定义了装饰器的基本接口
- **FixedDecorator**: 具体装饰器实现，为卡牌添加"fixed"标签，防止拖动
- **CardDecoratorManager**: 装饰器管理器，统一管理单个卡牌的所有装饰器

### 标签系统
- 标签存储在 `CardPackBase.tags` 数组中
- 标签作为卡牌包的可继承字段，所有基于该卡包的卡牌实例共享标签状态
- 装饰器通过标签来标识和管理自己的状态

## 文件结构

```
scripts/cards/
├── card_pack_base.gd          # 卡包基类，包含标签系统
├── card_util.gd               # 卡牌工具类，集成装饰器管理
├── card_decorator_base.gd     # 装饰器基类
├── card_decorator_manager.gd  # 装饰器管理器
└── decorators/
    ├── README.md              # 本文件
    └── fixed_decorator.gd     # 固定装饰器实现
```

## 核心组件

### 1. CardPackBase (卡包基类)

**新增字段:**
```gdscript
var tags: Array[String] = []  # 卡牌标签数组
```

**标签管理方法:**
- `add_tag(tag: String)`: 添加标签
- `remove_tag(tag: String)`: 移除标签
- `has_tag(tag: String) -> bool`: 检查标签是否存在
- `get_tags() -> Array[String]`: 获取所有标签
- `clear_tags()`: 清空所有标签

### 2. CardDecoratorBase (装饰器基类)

**核心属性:**
- `card_instance: Node2D`: 被装饰的卡牌实例引用
- `decorator_tag: String`: 装饰器的标签名称

**核心方法:**
- `apply_decorator()`: 应用装饰器效果（子类重写）
- `remove_decorator()`: 移除装饰器效果（子类重写）
- `is_active() -> bool`: 检查装饰器是否激活
- `destroy()`: 销毁装饰器

### 3. FixedDecorator (固定装饰器)

**功能:**
- 为卡牌添加"fixed"标签
- 禁用卡牌的拖拽功能
- 保持点击功能正常工作

**实现原理:**
- 禁用 `ClickArea` 的 `input_pickable` 属性
- 设置 `CardBackground` 的 `mouse_filter` 为 `IGNORE`
- 在拖拽检测中提前返回，阻止拖拽行为

### 4. CardDecoratorManager (装饰器管理器)

**功能:**
- 统一管理单个卡牌的所有装饰器
- 提供装饰器的添加、移除、查询功能
- 防止重复添加相同标签的装饰器
- 支持根据卡牌已有标签自动初始化装饰器
- 提供完整的资源清理机制

**核心方法:**
- `add_decorator(decorator_class, tag)`: 添加装饰器
- `remove_decorator(tag) -> bool`: 移除装饰器
- `has_decorator(tag) -> bool`: 检查装饰器是否存在
- `clear_all_decorators()`: 清空所有装饰器
- `initialize_from_tags()`: 根据卡牌标签自动初始化装饰器
- `get_all_decorator_tags() -> Array[String]`: 获取所有装饰器标签

## 使用方法

### 基本使用

```gdscript
# 获取卡牌实例
var card = get_card_instance()

# 添加固定装饰器
card.add_fixed_decorator()

# 检查卡牌是否被固定
if card.is_fixed():
    print("卡牌已被固定，无法拖动")

# 移除固定装饰器
card.remove_fixed_decorator()
```

### 高级使用

```gdscript
# 直接操作标签系统
card.card_pack.add_tag("special")
card.card_pack.add_tag("rare")

# 检查标签
if card.card_pack.has_tag("special"):
    print("这是一张特殊卡牌")

# 获取所有标签
var all_tags = card.card_pack.get_tags()
print("卡牌标签: ", all_tags)

# 使用装饰器管理器
var manager = card.decorator_manager
var all_decorator_tags = manager.get_all_decorator_tags()
print("装饰器标签: ", all_decorator_tags)
```

### 静态方法

```gdscript
# 检查任意卡牌是否被固定
if CardUtil.is_card_fixed(some_card):
    print("卡牌被固定")

# 或者使用装饰器类的静态方法
if FixedDecorator.is_card_fixed(some_card):
    print("卡牌被固定")
```

## 扩展指南

### 创建自定义装饰器

1. **继承装饰器基类:**
```gdscript
extends "res://scripts/cards/card_decorator_base.gd"
class_name CustomDecorator

func _init(p_card_instance: Node2D):
    super._init(p_card_instance, "custom_tag")

func apply_decorator():
    # 实现装饰器效果
    pass

func remove_decorator():
    # 移除装饰器效果
    pass
```

2. **在管理器中注册:**
```gdscript
# 在 CardDecoratorManager.add_decorator() 中添加新的装饰器类型
if decorator_class == CustomDecorator:
    decorator_instance = CustomDecorator.new(card_instance)
    tag = "custom_tag"
```

3. **添加便捷方法:**
```gdscript
# 在 CardUtil 中添加便捷方法
func add_custom_decorator():
    if decorator_manager:
        return decorator_manager.add_decorator(CustomDecorator)
    return null
```

## 设计优势

### 1. 灵活性
- 可以在运行时动态添加或移除卡牌行为
- 不需要修改原有卡牌类的代码
- 支持根据现有标签自动恢复装饰器状态

### 2. 可扩展性
- 新增装饰器类型只需继承 `CardDecoratorBase`
- 装饰器之间相互独立，不会产生耦合

### 3. 解耦性
- 装饰器逻辑与卡牌核心逻辑分离
- 便于单独测试和维护

### 4. 一致性
- 所有装饰器都遵循相同的接口规范
- 统一的生命周期管理
- 完整的资源清理机制

### 5. 性能
- 使用对象池模式减少内存分配
- 标签系统提供快速的状态查询
- 智能的装饰器初始化和清理

## 注意事项

1. **标签唯一性**: 每个装饰器应使用唯一的标签名称
2. **生命周期管理**: 确保在卡牌销毁时正确清理装饰器
3. **状态同步**: 装饰器状态与标签状态保持同步
4. **性能考虑**: 避免频繁添加和移除装饰器
5. **错误处理**: 检查卡牌实例和管理器的有效性

## 测试

使用 `test_decorator_system.gd` 脚本可以测试装饰器系统的各项功能:

```gdscript
# 运行测试
var test_script = preload("res://scripts/test_decorator_system.gd")
var test_instance = test_script.new()
get_tree().current_scene.add_child(test_instance)
```

测试内容包括:
- 装饰器管理器初始化
- 固定装饰器的添加和移除
- 标签系统的基本操作
- 拖拽功能的禁用和恢复