# 卡牌系统 (Card System)

## 文件结构

```
/scripts/cards/
├── card_pack_base.gd           # 卡包基类
├── card_util.gd                # 卡牌工具类
├── card_decorator_base.gd      # 装饰器基类
├── card_decorator_manager.gd   # 装饰器管理器
├── decorators/                 # 装饰器目录
│   ├── README.md              # 装饰器系统文档
│   └── fixed_decorator.gd     # 固定装饰器
├── prefabs/                    # 卡牌预制体目录
│   ├── README.md              # 预制体说明文档
│   ├── strike_card_pack.gd
│   ├── defend_card_pack.gd
│   ├── wind_card_pack.gd      # 刮风卡牌
│   ├── rain_card_pack.gd      # 下雨卡牌
│   └── ...
└── README.md                  # 本文档
```

## 核心组件

### 1. 卡包基类 (CardPackBase)

`card_pack_base.gd` 定义了卡牌的基本属性和行为：

```gdscript
var pack_name: String        # 卡包名称
var description: String      # 卡包描述
var card_name: String       # 卡牌名称
var card_description: String # 卡牌描述
var card_type: String       # 卡牌类型标识符
var on_click: Callable      # 点击效果回调
var pack_image: String      # 卡牌图片路径
var tags: Array[String] = [] # 卡牌标签数组（装饰器系统）
```

**标签系统方法：**
```gdscript
add_tag(tag: String)         # 添加标签
remove_tag(tag: String)      # 移除标签
has_tag(tag: String) -> bool # 检查标签是否存在
get_tags() -> Array[String]  # 获取所有标签
clear_tags()                 # 清空所有标签
```

生命周期方法：
- `_init()`: 初始化卡包基本信息
- `set_card_data()`: 设置卡牌数据
- `get_card_data()`: 获取卡牌数据
- `after_init()`: 卡牌创建后的初始化回调
- `after_recipe_done()`: 参与合成后的回调

### 2. 卡牌工具类 (CardUtil)

`card_util.gd` 提供了卡牌管理和交互的核心功能：

1. **卡牌池管理**
   - `initialize_card_pool()`: 初始化卡牌池
   - `get_card_from_pool()`: 从池中获取卡牌
   - `remove()`: 回收卡牌到池中，完整清理装饰器管理器和标签系统

2. **卡牌创建**
   - `create_card_from_pool()`: 从池中创建卡牌
   - `load_from_card_type()`: 加载卡牌类型数据
   - `load_from_card_pack()`: 从卡包加载数据

3. **卡牌交互**
   - `move_card()`: 移动卡牌（带边界检查）
   - `random_move_card()`: 随机移动卡牌（带边界检查）
   - `goto_card()`: 瞬移卡牌（带边界检查）
   - `setup_input_detection()`: 设置输入检测

4. **堆叠管理**
   - `check_and_stack_card()`: 检查并堆叠卡牌
   - `stack_card_group_on_target()`: 堆叠卡牌组
   - `remove_from_current_stack()`: 从当前堆叠移除

5. **装饰器系统**
   - `add_fixed_decorator()`: 添加固定装饰器，防止拖动
   - `remove_fixed_decorator()`: 移除固定装饰器
   - `is_fixed() -> bool`: 检查卡牌是否被固定
   - `add_decorator(decorator_class)`: 添加指定类型的装饰器
   - `remove_decorator(tag) -> bool`: 移除指定标签的装饰器
   - `has_decorator(tag) -> bool`: 检查是否存在指定装饰器
   - `get_all_decorator_tags() -> Array[String]`: 获取所有装饰器标签
   - `is_card_fixed(card) -> bool`: 静态方法，检查任意卡牌是否被固定

### 3. 区域管理 (AreaUtil)

`area_util.gd` 提供了卡牌移动范围和遮罩层的管理功能：

1. **边界管理**
   - 定义卡牌移动的有效范围
   - 提供位置限制和边界检查
   - 确保卡牌始终在游戏区域内

2. **遮罩层交互**
   - 5x5 网格遮罩系统（-2,-2 到 2,2）
   - 卡牌移动时可以探索新区域
   - 通过 `set_fog_visible` 控制遮罩层
   - 支持获取指定位置的遮罩层状态

3. **应用场景**
   - 卡牌拖拽：限制拖拽范围
   - 随机移动：确保目标位置有效
   - 瞬移操作：验证目标位置
   - 区域探索：与遮罩层系统交互

### 4. 天气卡牌系统

天气卡牌是一种特殊的卡牌类型，由事件系统定时生成：

1. **刮风卡牌 (wind_card_pack.gd)**
   - 带来清新的空气
   - 生成后随机移动
   - 120秒后自动回收
   - 点击触发特殊效果

2. **下雨卡牌 (rain_card_pack.gd)**
   - 滋润大地万物
   - 生成后随机移动
   - 120秒后自动回收
   - 点击触发特殊效果

## 卡牌生命周期

1. **创建阶段**
   ```gdscript
   # 1. 从卡牌池获取实例
   var card = CardUtil.get_card_from_pool()
   
   # 2. 加载卡牌数据
   CardUtil.load_from_card_type(card, card_type)
   
   # 3. 调用after_init初始化
   card_pack.after_init(card)
   ```

2. **使用阶段**
   - 响应点击事件
   - 参与合成配方
   - 执行特殊效果

3. **回收阶段**
   ```gdscript
   # 回收卡牌到池中
   CardUtil.remove(card_instance)
   ```

### 卡牌回收

卡牌回收时会执行以下步骤：
1. 清理装饰器管理器（调用destroy方法并置空）
2. 清理卡牌标签系统（调用clear_tags方法）
3. 从场景树中移除卡牌节点
4. 注销事件监听器
5. 重置卡牌状态
6. 返回到卡牌池中等待复用

## 卡牌交互类型

1. **点击效果**
   ```gdscript
   # 在卡包中定义点击效果
   func on_card_click(card_instance):
       # 处理点击逻辑
       pass
   ```

2. **合成效果**
   ```gdscript
   # 在卡包中处理合成后的效果
   func after_recipe_done(card_instance, crafting_cards):
       # 处理合成后的逻辑
       pass
   ```

3. **自动回收**
   ```gdscript
   # 在卡包中设置定时回收
   func after_init(card_instance):
       start_recycle_timer(card_instance)
   ```

## 合成系统集成

卡牌系统与合成系统深度集成，支持以下功能：

### 1. 合成参与

卡牌可以作为合成原料参与配方：

```gdscript
# 在卡包中实现合成后回调
func after_recipe_done(card_instance, crafting_cards):
    # 处理合成完成后的逻辑
    # 例如：增加使用计数、触发特殊效果等
    pass
```

### 2. 合成状态保持

在拖拽移动时，卡牌会保持合成状态：
- 拖拽正在合成的卡牌组时，合成进度会转移到新位置
- 合成进度条会跟随卡牌移动
- 合成任务在堆叠操作后自动恢复

### 3. 特殊卡牌行为

部分卡牌具有合成相关的特殊行为：
- **碎木头卡牌**: 参与3次合成后自动回收
- **天气卡牌**: 可以作为合成原料，具有特殊效果
- **技能卡牌**: 合成后可能产生增强效果

### 4. 合成检测

卡牌堆叠时会自动检测合成条件：
- 系统自动匹配可用配方
- 符合条件时立即开始合成
- 显示合成进度条和剩余时间

## 装饰器系统 (Decorator System)

装饰器系统使用装饰器设计模式为卡牌实例动态添加额外的行为和属性。通过标签系统，可以灵活地管理卡牌的特殊状态和功能。

### 核心组件

1. **CardDecoratorBase**: 装饰器基类，定义装饰器的基本接口
2. **CardDecoratorManager**: 装饰器管理器，统一管理单个卡牌的所有装饰器
3. **FixedDecorator**: 固定装饰器，为卡牌添加"fixed"标签，防止拖动

### 设计原理

- **标签系统**: 标签存储在 `CardPackBase.tags` 数组中，作为卡包的可继承字段
- **装饰器模式**: 通过装饰器动态添加和移除卡牌行为，不修改原有代码结构
- **统一管理**: 每个卡牌实例都有一个装饰器管理器，负责管理所有装饰器

### 使用示例

```gdscript
# 基本使用
var card = get_card_instance()

# 添加固定装饰器
card.add_fixed_decorator()
print("卡牌已被固定，无法拖动")

# 检查卡牌状态
if card.is_fixed():
    print("卡牌被固定")

# 移除固定装饰器
card.remove_fixed_decorator()
print("卡牌可以正常拖动")

# 直接操作标签
card.card_pack.add_tag("special")
if card.card_pack.has_tag("special"):
    print("这是特殊卡牌")
```

### 扩展性

装饰器系统具有良好的扩展性，可以轻松添加新的装饰器类型：

1. 继承 `CardDecoratorBase` 创建新装饰器
2. 在 `CardDecoratorManager` 中注册新装饰器类型
3. 在 `CardUtil` 中添加便捷方法

详细信息请参考 [装饰器系统文档](decorators/README.md)

## 注意事项

1. 创建新卡牌时使用卡牌池系统，避免频繁实例化
2. 自定义卡牌行为时，确保正确实现生命周期方法
3. 回收卡牌时使用CardUtil.remove，不要直接删除节点
4. 堆叠操作要考虑性能影响，避免过度堆叠
5. 移动卡牌时使用CardUtil提供的方法，确保边界检查
6. 实现 `after_recipe_done` 方法时要处理好卡牌的生命周期
7. 合成相关的卡牌操作要考虑合成状态的保持和转移