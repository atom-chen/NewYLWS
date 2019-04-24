local math_ceil = math.ceil
local table_insert = table.insert
local string_format = string.format
local UIUtil = UIUtil
local Language = Language
local ConfigUtil = ConfigUtil
local GameObject = CS.UnityEngine.GameObject
local GuildMgr = Player:GetInstance().GuildMgr
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local GuildSkillItem = require "UI.Guild.View.GuildSkillItem"
local GuildSkillPrefabPath = "UI/Prefabs/Guild/GuildSkillItem.prefab"

local UIGuildSkillView = BaseClass("UIGuildSkillView", UIBaseView)
local base = UIBaseView

function UIGuildSkillView:OnCreate()
    base.OnCreate(self)
    local titleText = UIUtil.GetChildTexts(self.transform, {"bgRoot/titleText"})

    titleText.text = Language.GetString(1422)

    self.m_backBtn, self.ruleBtn, self.m_itemContent, self.m_backBtn2 = UIUtil.GetChildTransforms(self.transform, {
        "Panel/backBtn",
        "bgRoot/ruleBtn",
        "bgRoot/ItemScrollView/Viewport/ItemContent",
        "backBtn2",
    })

    self.m_scrollView = self:AddComponent(LoopScrowView, "bgRoot/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateItem))

    self.m_skillItemList = {}
    self.m_seq = 0

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.ruleBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_backBtn2.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UIGuildSkillView:OnClick(go)
    if go.name == "backBtn" or go.name == "backBtn2" then
        self:CloseSelf()
    elseif go.name == "ruleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 130) 
    end
end

function UIGuildSkillView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.ruleBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtn2.gameObject)
    base.OnDestroy(self)
end

function UIGuildSkillView:OnAddListener()
	base.OnAddListener(self)
	
    self:AddUIListener(UIMessageNames.MN_GUILD_RSP_GUILD_SKILL_LIST, self.UpdateData)
end

function UIGuildSkillView:OnRemoveListener()
	base.OnRemoveListener(self)
	
    self:RemoveUIListener(UIMessageNames.MN_GUILD_RSP_GUILD_SKILL_LIST, self.UpdateData)
end

function UIGuildSkillView:OnEnable(...)
    base.OnEnable(self, ...)

    GuildMgr:ReqGuildSkill()
end

function UIGuildSkillView:UpdateData(skillList)
    self.m_skillData = skillList
    self.m_skillCfgList = ConfigUtil.GetGuildSkillCfg()
    if not self.m_skillData or not self.m_skillCfgList then
        return
    end

    if #self.m_skillItemList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_seq, GuildSkillPrefabPath, 12, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local skillItem = GuildSkillItem.New(objs[i], self.m_itemContent, GuildSkillPrefabPath)
                    table_insert(self.m_skillItemList, skillItem)
                end
            end
        end)
        self.m_scrollView:UpdateView(true, self.m_skillItemList, self.m_skillCfgList)
    else
        self.m_scrollView:UpdateView(false, self.m_skillItemList, self.m_skillCfgList)
    end
    
end

function UIGuildSkillView:UpdateItem(item, realIndex)
    if self.m_skillCfgList then
        if item and realIndex > 0 and realIndex <= #self.m_skillCfgList then
            local data = self.m_skillCfgList[realIndex]
            item:UpdateData(data, self.m_skillData)
        end
    end
end

function UIGuildSkillView:OnDisable()
    UIGameObjectLoader:CancelLoad(self.m_seq)
    self.m_seq = 0

    for i, v in ipairs(self.m_skillItemList) do
        v:Delete()
    end
    self.m_skillItemList = {}
    base.OnDisable(self)
end

return UIGuildSkillView