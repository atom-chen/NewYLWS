local Vector3 = Vector3
local ConfigUtil = ConfigUtil
local table_insert = table.insert
local GameObject = CS.UnityEngine.GameObject
local UIUtil = UIUtil

local GuildWarUserTitleView = BaseClass("GuildWarUserTitleView", UIBaseView)
local base = UIBaseView

local GuildWarUserTitleItem = require("UI.GuildWar.GuildWarUserTitleItem")

function GuildWarUserTitleView:OnCreate()
    base.OnCreate(self)
    
    self.m_userTitleItemList = {}

    self:InitView()
end

function GuildWarUserTitleView:OnDestroy()
    for i, v in ipairs(self.m_userTitleItemList) do
        v:Delete()
    end
    self.m_userTitleItemList = nil

    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

function GuildWarUserTitleView:OnEnable(...)
    base.OnEnable(self, ...)
    
    if #self.m_userTitleItemList == 0 then
        local cfgList = ConfigUtil.GetGuildWarCraftDefTitleCfgList()
        if cfgList then
            for i, v in ipairs(cfgList) do
                local go = GameObject.Instantiate(self.m_userTitleItemPrefab)
                local userTitleItem = GuildWarUserTitleItem.New(go, self.m_container)
                userTitleItem:UpdateData(v)
                userTitleItem:SetLocalPosition(Vector3.New(-342.8 , 191 - (i - 1) * 147, 0))
                table_insert(self.m_userTitleItemList, userTitleItem)
            end
        end
    end
end

function GuildWarUserTitleView:InitView()
    self.m_userTitleItemPrefab, self.m_container, self.m_closeBtn = UIUtil.GetChildTransforms(self.transform, {
        "UserTitleItemPrefab",
        "Container",
        "CloseBtn"
    })

    local titleText = UIUtil.FindText(self.transform, "Container/bg2/TitleBg/TitleText")
    titleText.text = Language.GetString(2323) 

    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function GuildWarUserTitleView:OnClick(go, x, y)
    if go.name == "CloseBtn" then
        self:CloseSelf()
    end
end

return GuildWarUserTitleView

