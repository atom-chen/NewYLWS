local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local ConfigUtil = ConfigUtil
local GameObject = CS.UnityEngine.GameObject
local table_insert = table.insert
local UIGodBeastTalentItem = require "UI.UIGodBeast.View.UIGodBeastTalentItem"
local UIGodBeastAllTalentView = BaseClass("UIGodBeastAllTalentView", UIBaseView)
base = UIBaseView

function UIGodBeastAllTalentView:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function UIGodBeastAllTalentView:InitView()
    self.m_closeBtn,self.m_talentItemPrefab,self.m_itemContent = UIUtil.GetChildTransforms(self.transform, {
        "closeBtn",
        "talentItemPrefab",
        "BgRoot/ItemScrollView/Viewport/ItemContent",
    })

    self.m_talentItemPrefab = self.m_talentItemPrefab.gameObject

    self.m_talentList = {}
end

function UIGodBeastAllTalentView:OnEnable(...)
    base.OnEnable(self, ...)
    local initOrder = ...
    self:HandleClick()
    self:UpdateData()
end

function UIGodBeastAllTalentView:UpdateData()
    if not self.m_talentList then
        self.m_talentList = {}
    end

    local talentList = ConfigUtil.GetGodBeastTalentAllCfg()
    if talentList then
        for k,v in pairs(talentList) do
            local go = GameObject.Instantiate(self.m_talentItemPrefab)
            if not IsNull(go) then
                local talentItem  = UIGodBeastTalentItem.New(go, self.m_itemContent)
                local talentInfo = self:GetTalentInfo(v)
                if talentItem then
                    talentItem:SetData(k, talentInfo, true, nil)
                    table_insert(self.m_talentList, talentItem)
                end
            end
        end
    end
end

function UIGodBeastAllTalentView:GetTalentInfo(talentData)
    local talentInfo = {
        talent_id = talentData.id,
        talent_level = 9,
    }
    return talentInfo
end

function UIGodBeastAllTalentView:OnDisable()
    self:RemoveClick()
    self:ClearTalentList()
end

function UIGodBeastAllTalentView:ClearTalentList()
    if self.m_talentList then
        for i, v in pairs(self.m_talentList) do
            v:Delete()
        end
        self.m_talentList = nil
    end
end

function UIGodBeastAllTalentView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function UIGodBeastAllTalentView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
end

function UIGodBeastAllTalentView:OnClick(go, x, y)
    if go.name == "closeBtn" then
        self:CloseSelf()
    end
end

return UIGodBeastAllTalentView