local UIUtil = UIUtil
local math_ceil = math.ceil
local string_format = string.format
local BattleHorseSettlementItem = BaseClass("BattleHorseSettlementItem", UIBaseItem)
local base = UIBaseItem

function BattleHorseSettlementItem:OnCreate()
    base.OnCreate(self)

    self.m_rankText, self.m_nameText, self.m_horseNameText, self.m_costTimeText = UIUtil.GetChildTexts(self.transform, {
        "bgImage/rankText",
        "nameText",
        "horseNameText",
        "costTimeText",
    })

    self.m_bg = UIUtil.AddComponent(UIImage, self, "bg", AtlasConfig.DynamicLoad)
    self.m_bgImage = UIUtil.AddComponent(UIImage, self, "bgImage", AtlasConfig.DynamicLoad)
    self.m_icon = UIUtil.AddComponent(UIImage, self, "icon", AtlasConfig.ItemIcon)
end

function BattleHorseSettlementItem:OnDestroy()
    base.OnDestroy(self)
end

function BattleHorseSettlementItem:SetData(rankInfo)
    if not rankInfo then
        return
    end

    local horseCfg = ConfigUtil.GetZuoQiCfgByID(rankInfo.horse_id)
    if horseCfg then
        self.m_horseNameText.text = string_format(Language.GetString(4168), rankInfo.horse_stage, horseCfg["name"..math_ceil(rankInfo.horse_stage)])
    end

    self.m_rankText.text = math_ceil(rankInfo.rank)
    self.m_nameText.text = rankInfo.name
    local costTime = math_ceil(rankInfo.cost_time * 100) / 100
    self.m_costTimeText.text = costTime
    
    local isSelf = Player:GetInstance():GetUserMgr():CheckIsSelf(rankInfo.uid)
    local bgIcon = isSelf and "ph02.png" or "ph01.png"
    local bgImageIcon = isSelf and "ph06.png" or "ph07.png"
    local horseIcon = math_ceil(rankInfo.horse_id)..math_ceil(rankInfo.horse_stage)..".png"
    self.m_bg:SetAtlasSprite(bgIcon, false)
    self.m_bgImage:SetAtlasSprite(bgImageIcon, false)
    self.m_icon:SetAtlasSprite( horseIcon ,false)
end

return BattleHorseSettlementItem

