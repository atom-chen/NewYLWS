local string_format = string.format
local table_insert = table.insert
local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local Language = Language
local CommonDefine = CommonDefine
local GameObject = CS.UnityEngine.GameObject
local FuliMgr = Player:GetInstance():GetFuliMgr()
local UserMgr = Player:GetInstance():GetUserMgr()
local StamainItemClass = require "UI.UIFuli.View.StamainItem"


local DetailGetStamainHelper = BaseClass("DetailGetStamainHelper")

function DetailGetStamainHelper:__init(fuliTr, fuliView)
    self.m_fuliView = fuliView

    self.m_titleText = UIUtil.GetChildTexts(fuliTr, {"Container/Fuli/bg/RightContainer/GetStamain/Title/Text"})

    self.m_getStamainTr, self.m_stamainItemTr, self.m_gridTr = UIUtil.GetChildTransforms(fuliTr, {
        "Container/Fuli/bg/RightContainer/GetStamain",
        "Container/Fuli/bg/RightContainer/GetStamain/StamainItem",
        "Container/Fuli/bg/RightContainer/GetStamain/Grid",
    })
    
    self.m_stamainItemPrefab = self.m_stamainItemTr.gameObject
    self.m_getStamainGo = self.m_getStamainTr.gameObject

    self.m_stamainItemList = {}

end

function DetailGetStamainHelper:__delete()
    self.m_fuliView = nil
    self:Close()
end

function DetailGetStamainHelper:Close()
    self.m_getStamainGo:SetActive(false)

    for _, v in ipairs(self.m_stamainItemList) do
        GameObject.Destroy(v:GetGameObject())
    end
    self.m_stamainItemList = {}
end

function DetailGetStamainHelper:UpdateInfo(isReset)
    local oneFuli = self.m_fuliView:GetOneFuli()
    if not oneFuli then
        return
    end

    self.m_getStamainGo:SetActive(true)
    self.m_titleText.text = self.m_fuliView:GetTitleName()
    for i, v in ipairs(oneFuli.entry_list) do
        local stamainItem = self.m_stamainItemList[i]
        if not stamainItem then
            local go = GameObject.Instantiate(self.m_stamainItemPrefab)
            stamainItem = StamainItemClass.New(go, self.m_gridTr)
            table_insert(self.m_stamainItemList, stamainItem)
            stamainItem:UpdateData(v.award_list[1], v.status, v.e_param1, v.e_param2, v.condition, v.index, self.m_fuliView:GetFuliId())
        else
            stamainItem:UpdateData(v.award_list[1], v.status, v.e_param1, v.e_param2, v.condition, v.index, self.m_fuliView:GetFuliId())
        end
    end
end


return DetailGetStamainHelper