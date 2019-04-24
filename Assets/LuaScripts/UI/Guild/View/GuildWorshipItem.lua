local GuildWorshipItem = BaseClass("GuildWorshipItem", UIBaseItem)
local base = UIBaseItem

local UIUtil = UIUtil
local CommonDefine = CommonDefine
local GuildMgr = Player:GetInstance().GuildMgr

function GuildWorshipItem:OnCreate()

    self.m_worShipUID = false

    self:InitView()
end

function GuildWorshipItem:InitView()

    self.m_itemCountText, self.m_costItemCountText, self.m_tipsText = UIUtil.GetChildTexts(self.transform, { 
        "Click/ItemCountText", 
        "CostItemImage/CostItemCountText",
        "TipsText"
    })

    self.m_clickTrans = UIUtil.GetChildTransforms(self.transform, {
        "Click"
    })


    self.m_costItemImage = UIUtil.AddComponent(UIImage, self, "CostItemImage", AtlasConfig.ItemIcon)
    self.m_costItemGo = self.m_costItemImage.gameObject

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_clickTrans.gameObject, onClick)
end

function GuildWorshipItem:OnClick(go)
    if go.name == "Click" then
        if self.m_worShipCfg and self.m_worShipUID then
            GuildMgr:ReqWorship(self.m_worShipUID, self.m_worShipCfg.id)
        end
    end
end

function GuildWorshipItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_clickTrans.gameObject)
    self.m_costItemGo = nil
    if self.m_costItemImage then
        self.m_costItemImage:Delete()
        self.m_costItemImage = nil
    end
    base.OnDestroy(self)
end

function GuildWorshipItem:UpdateData(worshiptype, uid)

    local worShipCfg = ConfigUtil.GetGuildWorShipCfgByID(worshiptype)
    if not worShipCfg then
        return 
    end

    self.m_worShipCfg = worShipCfg
    self.m_worShipUID = uid

    self.m_tipsText.text = ""
    self.m_costItemGo:SetActive(false)

    self.m_itemCountText.text = worShipCfg.award_stamina

    if worshiptype == CommonDefine.GUILD_WORSHIP_FREE then
        self.m_tipsText.text = worShipCfg.name
        return
        
    elseif worshiptype == CommonDefine.GUILD_WORSHIP_TONGQIAN then
        self.m_costItemGo:SetActive(true)
        self.m_costItemImage:SetAtlasSprite("10001.png")

    elseif worshiptype == CommonDefine.GUILD_WORSHIP_YUANBAO then
        self.m_costItemGo:SetActive(true)
        self.m_costItemImage:SetAtlasSprite("10002.png")

    end
    self.m_costItemCountText.text = worShipCfg.need_item_num
end

return GuildWorshipItem