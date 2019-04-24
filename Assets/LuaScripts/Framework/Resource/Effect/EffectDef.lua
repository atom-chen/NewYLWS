EffectEnum = {
    BUFF_DOWN_DAMAGE = 1,                --伤害下降
    BUFF_UP_DAMAGE = 2,                  --伤害上升
    BUFF_UP_ATK = 3,                     --攻击上升
    BUFF_DOWN_ATK = 4,                   --攻击下降
    BUFF_UP_DEF = 5,                     --防御上升
    BUFF_DOWN_DEF = 6,                   --防御下降
    BUFF_UP_ATK_SPEED = 7,               --攻速上升
    BUFF_DOWN_ATK_SPEED = 8,             --攻速下降
    BUFF_UP_MOVE_SPEED = 9,              --移速上升
    BUFF_DOWN_MOVE_SPEED = 10,           --移速下降

    ATTACH_POINT_NONE = 0,
	ATTACH_POINT_HEAD = 1,                  --头上
	ATTACH_POINT_LHAND = 2,                 --左手
	ATTACH_POINT_RHAND = 3,                 --右手
	ATTACH_POINT_BODY = 4,                  --身体
	ATTACH_POINT_RIGHT_WEAPON = 5,          --右武器
    ATTACH_POINT_LEFT_WEAPON = 6,           --左武器
    ATTACH_POINT_FOOT = 7,                  --脚下   
    ATTACH_POINT_SPINE = 8,                  
    ATTACH_POINT_PELVIS = 9,                -- 郭嘉翅膀挂点
    
    EFFECT_TYPE_NONE = 0,               
    EFFECT_TYPE_SKILL = 1,              --技能释放
    EFFECT_TYPE_BE_HIT = 2,             --受击
    EFFECT_TYPE_MOVE = 3,               --移动
    EFFECT_TYPE_STATUS = 4,             --状态
}