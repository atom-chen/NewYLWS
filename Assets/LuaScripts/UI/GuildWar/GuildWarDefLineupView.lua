
local UILineupMainView = require("UI.Lineup.UILineupMainView")
local GuildWarDefLineupView = BaseClass("GuildWarDefLineupView", UILineupMainView)
local base = UILineupMainView

local BaseView = UIBaseView

local DefBuzhenID = 10001
local DefBuzhenID2 = 10002
local DefBuzhenID3 = 10003
local GuildWarMgr = Player:GetInstance():GetGuildWarMgr()

local unpack = unpack or table.unpack
local SplitString = CUtil.SplitString
local Language = Language

function GuildWarDefLineupView:OnEnable(...)
    BaseView.OnEnable(self, ...)

    self.m_buzhenID = DefBuzhenID
    self.m_lineup3Locked = false

    self.m_TabBtnImage:SetAtlasSprite('jtzb30.png')
    self.m_TabBtn2Image:SetAtlasSprite('jtzb17.png')
    self.m_TabBtn3Image:SetAtlasSprite('jtzb17.png')

    self:CreateRoleContainer()
    self.m_bottomContainer.sizeDelta = Vector2.New(1540, self.m_bottomContainer.sizeDelta.y)
    self:HandleClick()
    self:TweenOpen()

    GuildWarMgr:ReqDefBuZhenList()
end

function GuildWarDefLineupView:OnClick(go, x, y)
    local name = go.name
    if name == "LineupTabBtn" then
        if self.m_buzhenID ~= DefBuzhenID then
            self.m_buzhenID = DefBuzhenID

            self.m_TabBtnImage:SetAtlasSprite('jtzb30.png')
            self.m_TabBtn2Image:SetAtlasSprite('jtzb17.png')
            self.m_TabBtn3Image:SetAtlasSprite('jtzb17.png')

            self:UpdateLineup()
        end
       
    elseif name == "LineupTab2Btn" then
        if self.m_buzhenID ~= DefBuzhenID2 then
            self.m_buzhenID = DefBuzhenID2

            self.m_TabBtnImage:SetAtlasSprite('jtzb17.png')
            self.m_TabBtn2Image:SetAtlasSprite('jtzb30.png')
            self.m_TabBtn3Image:SetAtlasSprite('jtzb17.png')

            self:UpdateLineup()
        end
        
    elseif name == "LineupTab3Btn" then
        if not self.m_lineup3Locked then
            if self.m_buzhenID ~= DefBuzhenID3 then
                self.m_buzhenID = DefBuzhenID3
                
                self.m_TabBtnImage:SetAtlasSprite('jtzb17.png')
                self.m_TabBtn2Image:SetAtlasSprite('jtzb17.png')
                self.m_TabBtn3Image:SetAtlasSprite('jtzb30.png')

                self:UpdateLineup()
            end
        end

    elseif name == "lineupManageBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UILineupManager, self.m_buzhenID)
        return 
    end

    UILineupMainView.OnClick(self, go, x, y)
end

function GuildWarDefLineupView:InitView()
    base.InitView(self)
    
    local lineupTabBtnText, lineupTab2BtnText, lineupTab3BtnText
     = UIUtil.GetChildTexts(self.transform, {
        "RightContainer/LineupTabBtn/LineupTabBtnText",
        "RightContainer/LineupTab2Btn/LineupTab2BtnText",
        "RightContainer/LineupTab3Btn/LineupTab3BtnText",
    })

    local lineupNames = SplitString(Language.GetString(2336), '|')
    lineupTabBtnText.text, lineupTab2BtnText.text, lineupTab3BtnText.text = unpack(lineupNames)

    self.m_rightContainerTran, self.m_lineupTab3LockGo, 
    self.m_lineupTabBtn, self.m_lineupTab2Btn, self.m_lineupTab3Btn = UIUtil.GetChildTransforms(self.transform, {
        "RightContainer",
        "RightContainer/LineupTab3Btn/Lock",
        "RightContainer/LineupTabBtn",
        "RightContainer/LineupTab2Btn",
        "RightContainer/LineupTab3Btn"
    })

    self.m_TabBtnImage = UIUtil.AddComponent(UIImage, self, "RightContainer/LineupTabBtn", AtlasConfig.DynamicLoad)
    self.m_TabBtn2Image = UIUtil.AddComponent(UIImage, self, "RightContainer/LineupTab2Btn", AtlasConfig.DynamicLoad)
    self.m_TabBtn3Image = UIUtil.AddComponent(UIImage, self, "RightContainer/LineupTab3Btn", AtlasConfig.DynamicLoad)    

    self.m_rightContainerTran.gameObject:SetActive(true)
    self.m_lineupTab3LockGo = self.m_lineupTab3LockGo.gameObject

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_lineupTabBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_lineupTab2Btn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_lineupTab3Btn.gameObject, onClick)

    self.m_lineupTab3BtnImage = self:AddComponent(UIImage, "RightContainer/LineupTab3Btn")
end

function GuildWarDefLineupView:UpdateLineup()
    base.UpdateLineup(self)
    
    self.m_lineup3Locked = GuildWarMgr:GetBuzhenLimit() <= 2
    self.m_lineupTab3LockGo:SetActive(self.m_lineup3Locked)
    self.m_lineupTab3BtnImage:EnableRaycastTarget(not self.m_lineup3Locked)
end

function GuildWarDefLineupView:WalkLineup(filter)
    self.m_lineupMgr:WalkMain(self.m_buzhenID, filter)
end

function GuildWarDefLineupView:ClickFightBtn()
    UIUtil.TryClick(self.m_fightBtn)
    GuildWarMgr:ReqSetDefBuZhen()
end

function GuildWarDefLineupView:GetBuZhenID()
    return self.m_buzhenID
end

function GuildWarDefLineupView:ModifyLineupSeq(standPos, newSeq)
    self.m_lineupMgr:ModifyLineupSeq(self.m_buzhenID, false, standPos, newSeq)
end

function GuildWarDefLineupView:OpenWujiangSeleteUI(standPos)
    UIManagerInst:OpenWindow(UIWindowNames.UIGuildWarLineupSelect, self.m_buzhenID, standPos)
end

function GuildWarDefLineupView:ClearLineup()
    self.m_lineupMgr:ClearLineup(self.m_buzhenID)
    self:UpdateLineup()
end

function GuildWarDefLineupView:OnSelectWuJiangCardItem(selectWujiangSeq, data1, standPos)

    self:ModifyLineupSeq(standPos, selectWujiangSeq)

    --卸下其他阵容的相同武将
    for i = DefBuzhenID, DefBuzhenID3 do 
        if self.m_buzhenID ~= i then
            self.m_lineupMgr:UnLoadLineupSeq(i, false, selectWujiangSeq)
        end
    end

    self.m_selectWujiangPos = standPos
    self:UpdateLineup()
    self:TweenItemPos(standPos)
end

function GuildWarDefLineupView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_lineupTabBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_lineupTab2Btn.gameObject)
    UIUtil.RemoveClickEvent(self.m_lineupTab3Btn.gameObject)

    base.OnDestroy(self)
end

return GuildWarDefLineupView