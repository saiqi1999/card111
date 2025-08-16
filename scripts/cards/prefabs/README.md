# 卡包预制体文件夹 (Card Pack Prefabs)

此文件夹包含各种卡包的预制体脚本文件。

## 文件结构

- `strike_card_pack.gd` - 打击卡包类，继承自卡包基类
- `defend_card_pack.gd` - 防御卡包类，继承自卡包基类
- `want_slime_card_pack.gd` - Want Slime卡包类，继承自卡包基类
- `basic_skill_pack_card_pack.gd` - Basic Skill Pack卡包类，继承自卡包基类

## 卡包说明

### 打击卡包 (StrikeCardPack)

`strike_card_pack.gd` 实现了打击卡牌的基本功能：

- **卡牌属性**：
  - 名称：打击
  - 描述：造成6点伤害
  - 图像：strike.png

- **特殊功能**：
  - 点击特效：打印卡牌实例ID和1-100的随机数
  - 继承自卡包基类的所有基础功能

#### 使用示例

```gdscript
# 通过CardUtil获取打击卡包
var strike_pack = CardUtil.get_card_pack_by_type("strike")

# 创建打击卡牌
var card_instance = CardUtil.create_card_from_pool(root_node, "strike", Vector2(100, 100))
```

### 防御卡包 (DefendCardPack)

`defend_card_pack.gd` 实现了防御卡牌的基本功能：

- **卡牌属性**：
  - 名称：防御
  - 描述：获得5点护甲
  - 图像：defend.jpg

- **特殊功能**：
  - 点击特效：打印卡牌实例ID和获得的护甲值
  - 继承自卡包基类的所有基础功能

#### 使用示例

```gdscript
# 通过CardUtil获取防御卡包
var defend_pack = CardUtil.get_card_pack_by_type("defend")

# 创建防御卡牌
var card_instance = CardUtil.create_card_from_pool(root_node, "defend", Vector2(100, 100))
```

### Want Slime卡包 (WantSlimeCardPack)

`want_slime_card_pack.gd` 实现了召唤史莱姆卡牌的功能：

- **卡牌属性**：
  - 名称：Want Slime
  - 描述：召唤一只可爱的史莱姆
  - 图像：wantSlime.jpg

- **特殊功能**：
  - 点击特效：随机生成史莱姆属性（生命值5-14，攻击力1-3）
  - 继承自卡包基类的所有基础功能

#### 使用示例

```gdscript
# 通过CardUtil获取Want Slime卡包
var slime_pack = CardUtil.get_card_pack_by_type("want_slime")

# 创建Want Slime卡牌
var card_instance = CardUtil.create_card_from_pool(root_node, "want_slime", Vector2(100, 100))
```

### Basic Skill Pack卡包 (BasicSkillPackCardPack)

`basic_skill_pack_card_pack.gd` 实现了卡牌生成器的功能：

- **卡牌属性**：
  - 名称：Basic Skill Pack
  - 描述：生成随机卡牌并移动
  - 图像：basicSkillPack.jpg

- **特殊功能**：
  - 点击特效：从当前位置生成随机的打击或防御卡牌
  - 生成的卡牌会自动随机移动到非中心区域
  - 内置计数器：生成5张卡牌后自动回收到卡牌池
  - 生成的卡牌命名为"技能包生成[类型] #[序号]"
  - 继承自卡包基类的所有基础功能

#### 使用示例

```gdscript
# 通过CardUtil获取Basic Skill Pack卡包
var skill_pack = CardUtil.get_card_pack_by_type("basic_skill_pack")

# 创建Basic Skill Pack卡牌
var card_instance = CardUtil.create_card_from_pool(root_node, "basic_skill_pack", Vector2(100, 100))
```

## 扩展说明

当需要添加新的卡包类型时，可以在此文件夹中创建新的卡包脚本文件，并在 `card_util.gd` 的 `get_card_pack_by_type()` 方法中添加对应的加载逻辑。新卡牌类型会自动被调试系统的 `random2` 命令包含。