# 卡包预制体文件夹 (Card Pack Prefabs)

此文件夹包含各种卡包的预制体脚本文件。每个卡包都继承自`CardPackBase`基类，并可以自定义卡牌的创建、交互和回收逻辑。

## 卡牌生命周期

### 1. 卡牌创建
- 通过`CardUtil.create_card_from_pool`创建卡牌，该方法会：
  1. 从卡牌池获取或创建新的卡牌实例
  2. 加载对应类型的卡包数据
  3. 调用卡包的`after_init`方法进行初始化
  4. 将卡牌移动到指定位置（带边界检查）

### 2. 卡牌回收
卡牌可以通过以下方式被回收：
1. **自动回收**：某些卡牌（如天气卡）会在创建时启动定时器，到时自动回收
2. **条件回收**：某些卡牌（如Basic Skill Pack）在达到特定条件后自动回收
3. **合成回收**：某些卡牌（如碎木头、土堆）在参与一定次数的合成后回收
4. **手动回收**：通过调用`CardUtil.remove(card_instance)`手动回收

回收时，卡牌会：
- 装饰器清理：调用装饰器管理器的destroy方法，清理所有装饰器
- 标签清理：调用clear_tags方法，清空所有卡牌标签
- 从堆叠中移除
- 注销全局注册
- 重置状态
- 返回到卡牌池中

## 特殊卡牌示例

### 天气卡牌（雨、风）
```gdscript
# 在初始化函数中设置 after_init 回调
func _init():
    # ... 其他初始化代码 ...
    after_init = weather_after_init

# 创建时自动启动回收定时器
func weather_after_init(card_instance):
    start_recycle_timer(card_instance)
```

### 资源卡牌（碎木头、土堆）
```gdscript
# 在初始化函数中设置 after_recipe_done 回调
func _init():
    # ... 其他初始化代码 ...
    after_recipe_done = resource_after_recipe_done

# 在合成3次后自动回收
func resource_after_recipe_done(card_instance, crafting_cards: Array):
    recipe_count += 1
    if recipe_count >= 3:
        CardUtil.remove(card_instance)
```

### 生成器卡牌（Basic Skill Pack）
```gdscript
# 生成指定数量的卡牌后自动回收
func basic_skill_pack_click_effect(card_instance):
    if generated_cards_count >= MAX_GENERATED_CARDS:
        CardUtil.remove(card_instance)
```

## 创建新卡牌类型

1. 创建新的卡包脚本文件，继承`CardPackBase`
2. 实现必要的初始化逻辑：
   - 设置卡牌基本信息（名称、描述、图片）
   - 设置卡牌类型标识符
   - 定义点击效果（可选）
3. 根据需要重写生命周期方法：
   - `after_init`：卡牌创建后的初始化逻辑
   - `after_recipe_done`：参与合成后的处理逻辑

### 收割系统卡牌（蓝莓丛）
```gdscript
# 在初始化函数中设置 after_recipe_done 回调和耐久度
func _init():
    # ... 其他初始化代码 ...
    after_recipe_done = blueberry_bush_after_recipe_done
    harvest_count = 0  # 收割计数器
    durability = 3     # 小蓝莓丛3次耐久，大蓝莓丛5次耐久

# 收割后的处理逻辑
func blueberry_bush_after_recipe_done(card_instance, crafting_cards: Array):
    harvest_count += 1
    durability -= 1
    
    # 必定产出蓝莓
    CardUtil.create_card_from_pool(root, "blueberry", target_position)
    
    # 第一次必出魔法气息，后续50%几率
    if harvest_count == 1 or randf() < 0.5:
        CardUtil.create_card_from_pool(root, "small_magic_aura", target_position)
    
    # 耐久度耗尽时回收卡牌
    if durability <= 0:
        CardUtil.remove(card_instance)
```

## 注意事项

1. **优先使用卡牌池**：创建和回收卡牌时应优先使用 `CardUtil` 提供的卡牌池方法
2. **调用父类方法**：重写生命周期方法时，务必调用父类的对应方法
3. **清理资源**：确保在卡牌回收时正确清理所有资源和引用，特别是装饰器管理器和标签系统
4. **使用 CardUtil**：移动卡牌时应使用 `CardUtil.move_card_to_position()` 方法
5. **装饰器管理**：避免手动管理装饰器生命周期，让CardUtil的remove方法自动处理
6. **耐久度机制**：对于有耐久度的卡牌，使用 `CardUtil.remove()` 而不是 `queue_free()` 进行回收
7. **收割系统**：收割类卡牌应实现计数器和耐久度机制，确保资源产出的平衡性