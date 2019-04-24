local UILineupMainView = require("UI.Lineup.UILineupMainView")
local UILineupEditView = BaseClass("UILineupEditView", UILineupMainView)
local base = UILineupMainView
local table_insert = table.insert
local Language = Language
local SplitString = CUtil.SplitString

function UILineupEditView:OnEnable(...)
    local initorder
    initorder, self.m_battleType, self.m_buzhenID = ...
    base.OnEnable(self, ...)

    self.m_editText.gameObject:SetActive(true)
    self.m_saveBtn.gameObject:SetActive(true)
    self.m_fightBtn.gameObject:SetActive(false)
    self.m_lineupManagerBtn.gameObject:SetActive(false)
end

function UILineupEditView:OnDisable()
    self.m_editText.gameObject:SetActive(false)
    self.m_saveBtn.gameObject:SetActive(false)
    self.m_fightBtn.gameObject:SetActive(true)
    self.m_lineupManagerBtn.gameObject:SetActive(true)
    UIUtil.RemoveClickEvent(self.m_saveBtn.gameObject)
    base.OnDisable(self)
end

function UILineupEditView:OnDestroy()

	base.OnDestroy(self)
end

-- 初始化UI变量
function UILineupEditView:InitView()
    base.InitView(self)
    self.m_editText = self:AddComponent(UIText, "TopContainer/editText")
    self.m_editText.text = Language.GetString(1105)
    self.m_saveBtn = UIUtil.FindTrans(self.transform, "BottomContainer/center/saveBtn")

end

function UILineupEditView:GetBuZhenID()
    return self.m_buzhenID
end

function UILineupEditView:HandleClick()
    base.HandleClick(self)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_saveBtn.gameObject, onClick)
end

function UILineupEditView:OnClick(go, x, y)
    local name = go.name
    if name == "backBtn" then
        UIManagerInst:CloseWindow(UIWindowNames.UILineupEdit)
    elseif string.contains(name, "itemBg_") then
        local strList = SplitString(name, "_")
        local standPos = tonumber(strList[2])
        self:OpenWujiangSeleteUI(standPos)
    elseif name == "lineupManageBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UILineupManager)
    elseif name == "clearBtn" then
        self.m_lineupMgr:ClearLineup(self.m_buzhenID)
        self:UpdateLineup()
    elseif name == "saveBtn" then
        self:CheckLineupBeforeSave()
    elseif name == "dragonBtn" then
        self:OpenDragonPanel()
    elseif name == "dragonBg" then
        self.m_dragonContainer:SetActive(false)
        self.m_dragonIconGrid.localScale = Vector3.New(1, 0, 1)
    elseif name == "dragonCloseBtn" then
        self.m_dragonContainer:SetActive(false)
        self.m_dragonIconGrid.localScale = Vector3.New(1, 0, 1)
    else
        
    end
end

function UILineupEditView:OpenWujiangSeleteUI(standPos)
    UIManagerInst:OpenWindow(UIWindowNames.UILineupEditRoleSelect, self.m_buzhenID, standPos)
end

function UILineupEditView:CheckLineupBeforeSave()
    local lineupRoleCount = self:GetLineupRoleCount()
    if lineupRoleCount == 0 then
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(1107),Language.GetString(1117), 
                                           Language.GetString(1109))
        return
    end

    local allRoleCount = Player:GetInstance():GetWujiangMgr():GetWujiangCount()
    if lineupRoleCount < CommonDefine.LINEUP_WUJIANG_COUNT and lineupRoleCount < allRoleCount then
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(1107),Language.GetString(1118), 
        Language.GetString(10), Bind(self, self.SaveLineup), Language.GetString(5))
        return
    end

    self:SaveLineup()
end

function UILineupEditView:SaveLineup()
    Player:GetInstance():GetLineupMgr():ReqArrangeBuZhen(self.m_buzhenID)

    self:CloseSelf()
end

function UILineupEditView:WalkLineup(filter)
    self.m_lineupMgr:WalkMain(self.m_buzhenID, filter)
end

function UILineupEditView:ModifyLineupSeq(standPos, newSeq)
    self.m_lineupMgr:ModifyLineupSeq(self.m_buzhenID, false, standPos, newSeq)
end

function UILineupEditView:SwapLineupSeq(standPos1, standPos2)
    self.m_lineupMgr:SwapLineupSeq(self.m_buzhenID, false, standPos1, standPos2)
end

function UILineupEditView:GetLineupRoleCount()
    local count = 0
    self.m_lineupMgr:Walk(self.m_buzhenID, function(wujiangBriefData)
        count = count + 1
    end)
    return count
end

return UILineupEditView