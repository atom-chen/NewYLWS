local table_insert = table.insert

local UIGuildWorshipView = BaseClass("UIGuildWorshipView", UIBaseView)
local base = UIBaseView

local GameObject = CS.UnityEngine.GameObject
local GuildMgr = Player:GetInstance().GuildMgr
local GuildWorshipItem = require "UI.Guild.View.GuildWorshipItem"


function UIGuildWorshipView:OnCreate()
    base.OnCreate(self)

    self.m_worshipItemList = {}

    self:InitView()
end


function UIGuildWorshipView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
	for i, v in ipairs(self.m_worshipItemList) do
        v:Delete()
    end
    self.m_worshipItemList = nil

	base.OnDestroy(self)
end

function UIGuildWorshipView:InitView()

    local titleText, tipsText = UIUtil.GetChildTexts(self.transform, {
        "Container/TitleBg/TitleText",
        "Container/TipsText",
    })

    titleText.text = Language.GetString(1369)
    tipsText.text = Language.GetString(1326)

    self.m_worshipItemPrefab, self.m_closeBtn, self.m_worshipParent  = UIUtil.GetChildTransforms(self.transform, {
        "WorshipItemPrefab",
        "CloseBtn",
        "Container/WorshipList"
    })

    self.m_worshipItemPrefab = self.m_worshipItemPrefab.gameObject


    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function UIGuildWorshipView:OnClick(go)
    if go.name == "CloseBtn" then
        self:CloseSelf()   
    end
end

function UIGuildWorshipView:OnEnable(...)
   
    base.OnEnable(self, ...)
    _, uid = ...

    local worship_type_list = { CommonDefine.GUILD_WORSHIP_FREE, CommonDefine.GUILD_WORSHIP_TONGQIAN, CommonDefine.GUILD_WORSHIP_YUANBAO }

    for i = 1, #worship_type_list do 
        local worshipItem = self.m_worshipItemList[i]
        if not worshipItem then
            local go = GameObject.Instantiate(self.m_worshipItemPrefab)
            worshipItem = GuildWorshipItem.New(go, self.m_worshipParent)
            worshipItem:SetAnchoredPosition(Vector3.New(-180 + 180 * (i - 1), 43, 0))
            table_insert(self.m_worshipItemList, worshipItem)
        end
        worshipItem:UpdateData(worship_type_list[i], uid)
    end
end

return UIGuildWorshipView
