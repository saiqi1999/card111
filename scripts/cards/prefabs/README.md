# 卡包预制体文件夹 (Card Pack Prefabs)

此文件夹包含各种卡包的预制体脚本文件。

## 文件结构

- `strike_card_pack.gd` - 打击卡包类，继承自卡包基类
- `defend_card_pack.gd` - 防御卡包类，继承自卡包基类

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

## 扩展说明

当需要添加新的卡包类型时，可以在此文件夹中创建新的卡包脚本文件，并在 `card_util.gd` 的 `get_card_pack_by_type()` 方法中添加对应的加载逻辑。