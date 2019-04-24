local UILineupMainView = require("UI.Lineup.UILineupMainView")
local UILineupArenaEditView = BaseClass("UILineupArenaEditView", UILineupMainView)
local base = UILineupMainView
local table_insert = table.insert
local Language = Language
local math_ceil = math.ceil
local BattleEnum = BattleEnum
local SplitString = CUtil.SplitString
local table_keys = table.keys
local string_format = string.format

function UILineupArenaEditView:OnEnable(...)
    local initorder
    initorder, self.m_battleType, self.m_buzhenID = ...
    base.OnEnable(self, ...)
    self:UpdateLineup()
    self.m_editText.gameObject:SetActive(true)
    self.m_saveBtn.gameObject:SetActive(true)
    self.m_fightBtn.gameObject:SetActive(false)
end

function UILineupArenaEditView:OnDisable()
    UIUtil.RemoveClickEvent(self.m_saveBtn.gameObject)

    self.m_editText.gameObject:SetActive(false)
    self.m_saveBtn.gameObject:SetActive(false)
    self.m_fightBtn.gameObject:SetActive(true)
    base.OnDisable(self)
end

function UILineupArenaEditView:OnDestroy()
    self.m_arenaMgr = nil

	base.OnDestroy(self)
end

-- 初始化UI变量
function UILineupArenaEditView:InitView()
    base.InitView(self)
    self.m_editText = self:AddComponent(UIText, "TopContainer/editText")
    self.m_editText.text = Language.GetString(1105)
    self.m_saveBtn = UIUtil.FindTrans(self.transform, "BottomContainer/center/saveBtn")

    self.m_arenaMgr = Player:GetInstance():GetArenaMgr()
end

function UILineupArenaEditView:HandleClick()
    base.HandleClick(self)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_saveBtn.gameObject, onClick)
end

function UILineupArenaEditView:OnClick(go, x, y)
    local name = go.name
    if name == "backBtn" then
        UIManagerInst:CloseWindow(UIWindowNames.UILineupArenaEdit)
    elseif string.contains(name, "itemBg_") then
        local strList = SplitString(name, "_")
        local standPos = tonumber(strList[2])
        self:OpenWujiangSeleteUI(standPos)
    elseif name == "lineupManageBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UILineupManager, self.m_battleType)
    elseif name == "clearBtn" then
        self.m_arenaMgr:ClearLineup()
        self:UpdateLineup()
    elseif name == "saveBtn" then
        self:CheckLineupBeforeSave()
    elseif name == "dragonBtn" then
        self:OpenDragonPanel()
    elseif name == "dragonBg" then
        self.m_dragonContainer:SetActive(false)
        self.m_dragonIconGrid.localScale = Vector3.New(1, 0, 1)
    end
end

function UILineupArenaEditView:OpenWujiangSeleteUI(standPos)
    UIManagerInst:OpenWindow(UIWindowNames.UIArenaEditRoleSelect, 0, standPos)
end

function UILineupArenaEditView:CheckLineupBeforeSave()
    local lineupRoleCount = self:GetLineupRoleCount()
    if lineupRoleCount == 0 then
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(1107),Language.GetString(1108), 
                                           Language.GetString(1109))
        return
    end

    local allRoleCount = Player:GetInstance():GetWujiangMgr():GetWujiangCount()
    if lineupRoleCount < CommonDefine.LINEUP_WUJIANG_COUNT and lineupRoleCount < allRoleCount then
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(1107),Language.GetString(1106), 
        Language.GetString(10), Bind(self, self.SaveLineup), Language.GetString(5))
        return
    end

    self:SaveLineup()
end

function UILineupArenaEditView:GetLineupRoleCount()
    local count = 0
    Player:GetInstance():GetArenaMgr():WalkMain(function(standPos, wujiangBriefData)
        if wujiangBriefData then
            count = count + 1
        end
    end)

    return count
end

function UILineupArenaEditView:SaveLineup()
    self.m_arenaMgr:ReqEditDefendInfo()

    self:CloseSelf()
end

function UILineupArenaEditView:UpdateLineup()
    self:UpdateLineupIcons()
    self:UpdateWujiang()
    self:UpdateDragonBtn()

    self.m_powerText.text = string.format("%d", self.m_arenaMgr:GetLineupTotalPower())
end

function UILineupArenaEditView:UpdateDragonBtn()
    local dragon = self.m_arenaMgr:GetDefineLineupData().summon or 0
    if dragon > 0 then
        UILogicUtil.SetDragonIcon(self.m_dragonBtnImage, dragon)
    else
        local defaultDragon = self:GetDefaultGodBeast()
        if defaultDragon then
            self.m_dragonBtn:SetActive(true)
            UILogicUtil.SetDragonIcon(self.m_dragonBtnImage, defaultDragon)
            self.m_arenaMgr:SetLineupDragon(defaultDragon)
        else
            self.m_dragonBtn:SetActive(false)
        end
    end
end

function UILineupArenaEditView:OnClickDragonIcon(dragonID)
    self.m_arenaMgr:SetLineupDragon(dragonID)
    self:UpdateDragonPanel()
    self:UpdateDragonBtn()
end

function UILineupArenaEditView:UpdateDragonPanel()
    local curDragonID = self.m_arenaMgr:GetDefineLineupData().summon or 0
    if curDragonID <= 0 then
        curDragonID = self:GetDefaultGodBeast()
    end
    local godBeasdMgr = Player:GetInstance():GetGodBeastMgr()
    local dragonList = table_keys(ConfigUtil.GetGodBeastCfgList())
    for i,id in ipairs(dragonList) do
        local dragonData = godBeasdMgr:GetGodBeastByID(id)
        self.m_dragonIconItemList[i]:SetData(id, dragonData == nil)
        self.m_dragonIconItemList[i]:OnSelect(id == curDragonID)
    end
    local curDragonData = godBeasdMgr:GetGodBeastByID(curDragonID)
    if curDragonData then
        for i = 1, CommonDefine.DRAGON_TELENT_COUNT do
            local talentData = nil
            if curDragonData.dragon_talent_list then
                talentData = curDragonData.dragon_talent_list[i]
            end
            self.m_talentIconList[i]:SetData(talentData)
        end
    end

    self:UpdateDragonSkillDec()
    local dragonCfg = ConfigUtil.GetGodBeastCfgByID(curDragonID)
    if dragonCfg then
        self.m_dragonNameText.text = string_format(Language.GetString(1125), dragonCfg.sName, curDragonData.level)
    end
end

function UILineupArenaEditView:UpdateDragonSkillDec() 
    local dragonID = self.m_arenaMgr:GetDefineLineupData().summon or 0
    if dragonID <= 0 then
        dragonID = self:GetDefaultGodBeast()
    end
    local dragonCfg = ConfigUtil.GetGodBeastCfgByID(dragonID)
    local dragonData = Player:GetInstance():GetGodBeastMgr():GetGodBeastByID(dragonID)
    local str = dragonCfg.sSkillDesc
    local x = dragonCfg.x + dragonCfg.ax * dragonData.level
    local x1 = math_ceil(x)
    x = x == x1 and x1 or x
    local skillCount = 0
    for k,v in pairs(dragonCfg.unlocklevel) do
        if dragonData.level >= v then
            skillCount = skillCount + 1
        end
    end

    local y = dragonCfg.y + dragonCfg.ay * skillCount
    local y1 = math_ceil(y)
    y = y == y1 and y1 or y

    str = str:gsub("{x}", "<color=#1feb0b>" .. x .. "</color>")
    str = str:gsub("{y}", y)
    self.m_skillDesText.text = "<color=#ffeea4>" .. dragonCfg.sSkillName .. "</color>".."："..str
end

function UILineupArenaEditView:WalkLineup(filter)
    self.m_arenaMgr:WalkMain(filter)
end

function UILineupArenaEditView:ModifyLineupSeq(standPos, newSeq)
    self.m_arenaMgr:ModifyLineupSeq(standPos, newSeq)
end

function UILineupArenaEditView:SwapLineupSeq(standPos1, standPos2)
    self.m_arenaMgr:SwapLineupSeq(standPos1, standPos2)
end

function UILineupArenaEditView:IsCheckLineupIllegal()
    return false
end

return UILineupArenaEditView