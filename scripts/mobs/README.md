# 怪物系统脚本

此文件夹将包含与怪物系统相关的所有脚本。目前尚未实现。

## 计划文件结构

- `mob_base.gd` - 怪物基类，将定义怪物的基本属性和方法
- 具体怪物类型脚本，如 `slime.gd`、`goblin.gd` 等

## 设计思路

### 怪物基类 (MobBase)

怪物基类将提供以下功能：

- 基本属性：生命值、攻击力、防御力等
- 行为方法：攻击、受伤、死亡等
- 意图系统：预示下一回合的行动
- 状态系统：管理怪物的各种状态效果

```gdscript
# 示例代码（尚未实现）
extends Resource
class_name MobBase

var mob_name: String = "基础怪物"
var health: int = 10
var max_health: int = 10
var attack: int = 5
var defense: int = 0

func take_damage(amount: int) -> int:
    var actual_damage = max(1, amount - defense)
    health -= actual_damage
    if health <= 0:
        die()
    return actual_damage

func die():
    # 处理死亡逻辑
    pass

func get_intent() -> Dictionary:
    # 返回下一回合的意图
    return {"type": "attack", "value": attack}
```

### 具体怪物类

具体怪物类将继承自怪物基类，并根据需要重写方法：

```gdscript
# 示例代码（尚未实现）
extends "res://scripts/mobs/mob_base.gd"
class_name Slime

func _init():
    mob_name = "史莱姆"
    health = 15
    max_health = 15
    attack = 3
    defense = 1
    
func get_intent() -> Dictionary:
    # 史莱姆有50%几率攻击，50%几率防御
    var rand = randf()
    if rand < 0.5:
        return {"type": "attack", "value": attack}
    else:
        return {"type": "defend", "value": 5}
```

## 实现计划

1. 创建怪物基类，定义基本属性和方法
2. 实现几个简单的怪物类型
3. 将怪物系统与战斗系统集成
4. 添加怪物AI和行为模式
5. 实现怪物的视觉表现

## 注意事项

- 怪物系统将与卡牌系统交互，需要考虑接口设计
- 怪物的行为应该多样化，增加游戏的策略性
- 考虑使用状态模式管理怪物的不同行为状态