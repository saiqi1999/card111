# 脚本文件夹 (Scripts)

此文件夹包含游戏中使用的所有GDScript脚本文件(.gd)。

## 核心脚本

### `card.gd`
基础卡牌类，定义了卡牌的基本属性和行为：
- 信号：`card_played`, `target_selection_needed`, `card_hovered`, `card_clicked`
- 属性：名称、消耗、描述
- 方法：`play()`, `get_target_count()`, `request_target_selection()`
- 输入处理：`_input_event()`

### `combat_manager.gd`
战斗管理器，负责协调游戏中的战斗流程：
- 信号：`target_selection_requested`, `card_play_failed`, `card_played_successfully`
- 玩家能量管理
- 卡牌使用逻辑
- 目标选择系统
- 卡组管理（抽牌堆、弃牌堆、手牌）

### `mobs.gd`
怪物基类，定义了怪物的基本属性和行为：
- 信号：`health_changed`, `died`, `monster_clicked`
- 属性：名称、生命值、攻击力、防御力
- 方法：`take_damage()`, `die()`
- 输入处理：`_input_event()`

### `slime.gd`
史莱姆怪物类，继承自`mobs.gd`，添加了特定的行为：
- 特有属性：`is_jiggly`
- 重写方法：`take_damage()`, `die()`
- 与战斗管理器的交互

### `strike.gd`
打击卡牌类，继承自`card.gd`，实现了特定的攻击效果：
- 特有属性：`damage`
- 重写方法：`get_target_count()`, `play()`
- 目标选择和伤害计算

## 脚本继承结构

游戏使用脚本继承机制来组织代码：
- `card.gd` → `strike.gd`（基础卡牌 → 特定卡牌）
- `mobs.gd` → `slime.gd`（基础怪物 → 特定怪物）

这种结构允许轻松扩展游戏内容，同时保持代码的一致性和可维护性。

## 添加新脚本

### 添加新卡牌脚本
1. 创建新的GDScript文件，继承自`card.gd`
2. 定义特定的属性和方法
3. 重写`get_target_count()`和`play()`方法以实现卡牌效果

### 添加新怪物脚本
1. 创建新的GDScript文件，继承自`mobs.gd`
2. 定义特定的属性和行为
3. 根据需要重写`take_damage()`和`die()`方法

## 脚本通信

脚本之间通过以下方式通信：
- 信号（Signals）用于事件通知
- 直接方法调用用于即时交互
- 节点引用用于访问其他对象