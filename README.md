# 卡牌游戏项目 (Card Game Project)

## 项目结构

```
/
├── scripts/
│   ├── cards/           # 卡牌系统
│   │   ├── prefabs/    # 卡牌预制体
│   │   └── ...
│   ├── utils/          # 工具类
│   │   ├── area_util.gd    # 区域管理工具
│   │   ├── camera_ctrl.gd  # 相机控制
│   │   ├── card_util.gd    # 卡牌工具
│   │   └── ...
│   └── ...
└── README.md           # 本文档
```

## 核心系统

### 1. 卡牌系统

卡牌系统由以下核心组件构成：

1. **CardPackBase**：卡包基类，定义卡牌基本属性和行为，包含标签系统
2. **CardUtil**：卡牌工具类，提供卡牌管理和交互功能，包含完整的资源清理机制
3. **卡牌预制体**：各类卡牌的具体实现
4. **装饰器系统**：使用装饰器模式为卡牌动态添加行为和标签，支持完整的生命周期管理

#### 装饰器系统

装饰器系统基于装饰器设计模式，为卡牌提供动态行为扩展：

- **CardDecoratorBase**：装饰器基类，定义装饰器生命周期方法
- **FixedDecorator**：固定装饰器，禁用卡牌拖拽功能
- **CardDecoratorManager**：装饰器管理器，统一管理卡牌装饰器，支持自动初始化和完整清理

装饰器系统与标签系统深度集成，通过标签状态管理装饰器的生命周期，确保资源的正确分配和回收。

**使用示例：**
```gdscript
# 添加固定装饰器，防止卡牌被拖动
card.add_fixed_decorator()

# 检查卡牌是否被固定
if card.is_fixed():
    print("卡牌已被固定")

# 移除固定装饰器
card.remove_fixed_decorator()
```

详细信息请参考 [卡牌系统文档](scripts/cards/README.md) 和 [装饰器系统文档](scripts/cards/decorators/README.md)

### 2. 区域管理系统

区域管理系统负责控制游戏中各个元素的移动范围，主要包括：

1. **相机移动范围**
   - 定义相机可移动的边界区域
   - 通过`CAMERA_MOVE_BOUNDS_MIN`和`CAMERA_MOVE_BOUNDS_SIZE`控制
   - 确保相机始终在有效范围内移动

2. **卡牌移动范围**
   - 限制卡牌的活动区域
   - 通过`CARD_MOVE_BOUNDS_MIN`和`CARD_MOVE_BOUNDS_SIZE`控制
   - 应用于所有卡牌移动操作：
     * 拖拽移动
     * 随机移动
     * 瞬间移动

3. **遮罩层系统**
   - 使用 5x5 网格管理遮罩层，覆盖从 (-2,-2) 到 (2,2) 的区域
   - 通过`FOG_GRID_MIN`和`FOG_GRID_SIZE`控制遮罩层位置和大小
   - 初始状态：
     * (0,0) 位置不可见（玩家初始区域）
     * 其他位置可见（待探索区域）
   - 支持动态控制每个遮罩层的可见性

4. **边界检查机制**
   - 自动将超出范围的位置限制在边界内
   - 保证游戏元素始终在可见区域内
   - 提供平滑的边界过渡

### 3. 天气系统

天气系统通过事件定时器定期生成天气卡牌，为游戏增添动态变化：

1. **天气类型**
   - 刮风：带来清新的空气
   - 下雨：滋润大地万物

2. **生成机制**
   - 每120秒触发一次天气检查
   - 30%概率生成天气卡牌
   - 随机选择天气类型
   - 在屏幕范围内随机生成位置

3. **天气效果**
   - 天气卡牌会在生成后随机移动
   - 持续120秒后自动消失
   - 可以通过点击触发特殊效果

### 4. 合成系统

合成系统是游戏的核心玩法之一，允许玩家将多张卡牌组合成新的卡牌：

1. **配方管理**
   - 支持多种配方定义（原料 → 产物）
   - 配方数据存储在 `RecipeConstant` 中
   - 支持动态添加新配方

2. **合成流程**
   - 将符合配方的卡牌堆叠在一起
   - 系统自动检测配方匹配
   - 显示合成进度条
   - 合成完成后生成产物卡牌

3. **进度管理**
   - 实时显示合成进度
   - 支持拖拽移动时保持合成状态
   - 合成任务可以在堆叠间转移

4. **特殊功能**
   - 部分卡牌有合成次数限制
   - 支持一对多的合成产物
   - 合成完成后触发卡牌特殊效果

### 5. 卡牌交互

卡牌系统支持多种交互方式：

1. **创建与回收**
   - 使用卡牌池系统管理卡牌实例
   - 支持自动回收和手动回收

2. **移动操作**
   - 拖拽移动：用户可以自由拖拽卡牌
   - 随机移动：系统随机选择目标位置
   - 瞬间移动：直接将卡牌移动到目标位置

3. **堆叠系统**
   - 支持卡牌自动堆叠
   - 管理卡牌组的层级关系
   - 智能合成检测和状态保持

## Strange Stone 调用链路

奇怪石堆(Strange Stone Pile)是游戏中的特殊卡牌，具有事件触发功能。以下是其完整的调用链路：

### 1. 生成阶段

**森林道路卡包** (`forest_road_card_pack.gd`)
- 在第3次点击时，调用 `generate_initial_resources()` 方法
- 生成包括 `strange_stone_pile` 在内的初始资源卡牌
- 特别处理：给奇怪石堆添加 `event_1` 标签

```gdscript
# 森林道路生成奇怪石堆
if type == "strange_stone_pile":
    resource.add_tag("event_1")  # 添加事件标签
```

### 2. 卡牌实现

**奇怪石堆卡包** (`strange_stone_pile_card_pack.gd`)
- 继承自 `CardPackBase`
- 初始化时添加 `fixed` 标签，防止拖动
- 设置合成完成回调 `after_recipe_done`

### 3. 合成触发链路

**合成系统** (`recipe_util.gd`)
1. 当奇怪石堆参与合成时，合成完成后调用 `_complete_crafting()`
2. 遍历参与合成的卡牌，调用各自的 `after_recipe_done` 回调
3. 奇怪石堆的回调被触发

**奇怪石堆回调处理**
1. 获取卡牌实例的所有标签
2. 遍历标签，查找以 `event_` 开头的标签
3. 提取事件ID（如 `event_1` -> ID: 1）
4. 调用 `EventUtil.trigger_event(event_id)`

### 4. 事件执行

**事件系统** (`event_util.gd`)
- `trigger_event(1)` 被调用
- 执行事件1：移除右边(1,0)位置的遮罩层
- 调用 `AreaUtil.set_fog_visible(1, 0, false)`

**区域管理** (`area_util.gd`)
- 设置指定位置的遮罩层不可见
- 同时扩展卡牌和相机的移动边界
- 调用 `_expand_bounds_for_fog_opening()` 方法

### 5. 完整调用链

```
森林道路点击(第3次) 
    ↓
生成奇怪石堆 + 添加event_1标签
    ↓
玩家将奇怪石堆与其他卡牌合成
    ↓
合成系统检测到配方匹配
    ↓
合成完成，调用after_recipe_done回调
    ↓
奇怪石堆检查event_标签
    ↓
EventUtil.trigger_event(1)
    ↓
AreaUtil.set_fog_visible(1, 0, false)
    ↓
移除遮罩层 + 扩展移动边界
    ↓
奇怪石堆卡牌被回收
```

### 6. 关键文件

- `forest_road_card_pack.gd`: 生成奇怪石堆并添加事件标签
- `strange_stone_pile_card_pack.gd`: 奇怪石堆的具体实现
- `recipe_util.gd`: 合成系统，调用after_recipe_done回调
- `event_util.gd`: 事件系统，处理事件触发
- `area_util.gd`: 区域管理，处理遮罩层和边界扩展

## 开发环境

- Godot 4.4.1
- GDScript

## 通用方法使用指南

### 1. 卡牌生成与移动

#### 正确的卡牌生成流程
```gdscript
# 1. 先在原位置生成卡牌
var card = CardUtil.create_card_from_pool(root, "card_type", original_position)
if card:
    # 2. 再移动到目标位置
    CardUtil.move_card(card, target_position)
    GlobalUtil.log("生成卡牌并移动到位置: " + str(target_position), GlobalUtil.LogLevel.INFO)
```

#### 位置生成与避让
```gdscript
# 使用全局常量定义距离参数
var target_position = CardUtil.get_valid_position(
    base_position, 
    GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE,  # 最小距离
    GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE   # 最大距离
)
```

### 2. 全局常量管理

#### 卡牌生成距离常量
```gdscript
# 在 GlobalConstants 中定义的常量
const CARD_SPAWN_MIN_DISTANCE_CLOSE: float = CARD_WIDTH * 0.5   # 近距离最小距离（100.0）
const CARD_SPAWN_MAX_DISTANCE_CLOSE: float = CARD_WIDTH * 1.5   # 近距离最大距离（300.0）
const CARD_SPAWN_MIN_DISTANCE_FAR: float = CARD_WIDTH * 3.0     # 远距离最小距离（600.0）
const CARD_SPAWN_MAX_DISTANCE_FAR: float = CARD_WIDTH * 5.0     # 远距离最大距离（1000.0）

# 使用方式
var pos = CardUtil.get_valid_position(base_pos, GlobalConstants.CARD_SPAWN_MIN_DISTANCE_CLOSE, GlobalConstants.CARD_SPAWN_MAX_DISTANCE_CLOSE)
```

### 3. 位置避让系统

#### 基于现有卡牌的位置避让
```gdscript
# CardUtil.get_valid_position 会自动检查与现有卡牌的距离
# 内部使用 all_cards 数组进行避让计算，无需手动管理位置记录
static func is_position_overlapping(pos: Vector2, min_spacing: float) -> bool:
    for card in all_cards:
        if card == null or not is_instance_valid(card):
            continue
        if pos.distance_to(card.global_position) < min_spacing:
            return true
    return false
```

### 4. 日志记录规范

#### 标准日志格式
```gdscript
# 带卡牌实例ID的日志
GlobalUtil.log("卡牌实例ID:" + str(card_instance.get_instance_id()) + " 执行操作描述", GlobalUtil.LogLevel.INFO)

# 位置相关日志
GlobalUtil.log("操作描述，位置: " + str(position), GlobalUtil.LogLevel.INFO)

# 错误日志
GlobalUtil.log("操作失败原因", GlobalUtil.LogLevel.WARNING)
```

## 注意事项

1. **卡牌生成**：始终先在原位置生成，再移动到目标位置
2. **常量使用**：使用GlobalConstants中的常量替代魔法值
3. **位置避让**：依赖CardUtil.all_cards自动避让，无需手动管理
4. **生命周期**：确保正确处理卡牌的创建、移动和回收
5. **边界检查**：所有位置操作都会自动进行边界限制