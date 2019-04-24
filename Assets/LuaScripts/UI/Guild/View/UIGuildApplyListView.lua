local table_insert = table.insert
local table_remove = table.remove
local string_split = string.split
local table_findIndex = table.findIndex
local string_format = string.format
local CommonDefine = CommonDefine

local UIGuildApplyListView = BaseClass("UIGuildApplyListView", UIBaseView)
local base = UIBaseView

local GameObject = CS.UnityEngine.GameObject
local GuildMgr = Player:GetInstance().GuildMgr
local GuildApplyItem = require "UI.Guild.View.GuildApplyItem"

function UIGuildApplyListView:OnCreate()

    base.OnCreate(self)

    self.m_applyItemList = {}

    self:InitView()
end


function UIGuildApplyListView:OnEnable(...)
    base.OnEnable(self, ...)
    
    self:RspSetJoinType()

    GuildMgr:ReqApplyList()
end

function UIGuildApplyListView:OnDisable(...)
   
    for i, v in ipairs(self.m_applyItemList) do
        v:Delete()
    end
    self.m_applyItemList = {}

    self.m_applyList = nil

    base.OnDisable(self)
end


function UIGuildApplyListView:InitView()
    self.m_closeBtn, self.m_applyItemPrefab, self.m_itemContent, self.m_needApplyBtn, self.m_notApplyBtn,
    self.m_needApplyTr, self.m_notApplyTr = UIUtil.GetChildTransforms(self.transform, {
        "CloseBtn",
        "ApplyItemPrefab",
        "Container/ItemScrollView/Viewport/ItemContent",
        "Container/NeedApply",
        "Container/AllPeople",
        "Container/NeedApply/Background/Checkmark",
        "Container/AllPeople/Background/Checkmark",
    })

    self.m_needApplyGo = self.m_needApplyTr.gameObject
    self.m_notApplyGo = self.m_notApplyTr.gameObject
    self.m_applyItemPrefab = self.m_applyItemPrefab.gameObject

    local btnNameTexts = string_split(Language.GetString(1366), "|")
    local titleText, conditionText, labelText1, labelText2
    titleText, conditionText, labelText1, labelText2, self.m_notApplyText = UIUtil.GetChildTexts(self.transform, {
        "Container/TitleBg/TitleText",
        "Container/Condition",
        "Container/AllPeople/Label",
        "Container/NeedApply/Label",
        "Container/NotApply",
    })
    titleText.text = btnNameTexts[3]
    conditionText.text = Language.GetString(1395)
    labelText1.text = Language.GetString(1396)
    labelText2.text = Language.GetString(1397)

    self.m_scrollView = self:AddComponent(LoopScrowView, "Container/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateApplyItem))

    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_needApplyBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_notApplyBtn.gameObject, onClick)
end

function UIGuildApplyListView:OnClick(go)
    if go.name == "CloseBtn" then
        self:CloseSelf()   
    elseif go.name == "AllPeople" then
        if GuildMgr.JoinGuildCondition == CommonDefine.Not_Apply then
            return
        end
        local guildJob = Player:GetInstance():GetUserMgr():GetUserData().guild_job
        if guildJob == CommonDefine.GUILD_POST_MILITARY or guildJob == CommonDefine.GUILD_POST_NORMAL then
            UILogicUtil.FloatAlert(Language.GetString(1438))
            return
        end
        GuildMgr:ReqSetJionType(CommonDefine.Not_Apply)
    elseif go.name == "NeedApply" then
        if GuildMgr.JoinGuildCondition == CommonDefine.Need_Apply then
            return
        end
        local guildJob = Player:GetInstance():GetUserMgr():GetUserData().guild_job
        if guildJob == CommonDefine.GUILD_POST_MILITARY or guildJob == CommonDefine.GUILD_POST_NORMAL then
            UILogicUtil.FloatAlert(Language.GetString(1438))
            return
        end
        GuildMgr:ReqSetJionType(CommonDefine.Need_Apply)
    end
end

function UIGuildApplyListView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_needApplyBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_notApplyBtn.gameObject)
    base.OnDestroy(self)
end

function UIGuildApplyListView:OnAddListener()
	base.OnAddListener(self)
	
     self:AddUIListener(UIMessageNames.MN_GUILD_APPLY_LIST, self.UpdateApplyList)
     self:AddUIListener(UIMessageNames.MN_EXAMINE_GUILD, self.ExamineBack)
     self:AddUIListener(UIMessageNames.MN_GUILD_RSP_SET_JOIN_TYPE, self.RspSetJoinType)
end

function UIGuildApplyListView:OnRemoveListener()
	base.OnRemoveListener(self)
	
    self:RemoveUIListener(UIMessageNames.MN_GUILD_APPLY_LIST, self.UpdateApplyList)
    self:RemoveUIListener(UIMessageNames.MN_EXAMINE_GUILD, self.ExamineBack)
    self:RemoveUIListener(UIMessageNames.MN_GUILD_RSP_SET_JOIN_TYPE, self.RspSetJoinType)
end

function UIGuildApplyListView:RspSetJoinType()
    if GuildMgr.JoinGuildCondition == CommonDefine.Not_Apply then
        self.m_notApplyGo:SetActive(true)
        self.m_needApplyGo:SetActive(false)
    elseif GuildMgr.JoinGuildCondition == CommonDefine.Need_Apply then
        self.m_needApplyGo:SetActive(true)
        self.m_notApplyGo:SetActive(false)
    end
end

function UIGuildApplyListView:UpdateApplyList(apply_list)
    self.m_notApplyText.text = ""
    if not apply_list then
        self.m_notApplyText.text = Language.GetString(1398)
        return 
    end

    if #apply_list == 0 then
        self.m_notApplyText.text = Language.GetString(1398)
    end

    self.m_applyList = apply_list

    if #self.m_applyItemList == 0 then
        for i = 1, 9 do
            local go = GameObject.Instantiate(self.m_applyItemPrefab)
            local applyItem = GuildApplyItem.New(go, self.m_itemContent)
            table_insert(self.m_applyItemList, applyItem)
        end
        self.m_scrollView:UpdateView(true, self.m_applyItemList, self.m_applyList)
    else
        self.m_scrollView:UpdateView(false, self.m_applyItemList, self.m_applyList)
    end 
end

function UIGuildApplyListView:UpdateApplyItem(item, realIndex)
    if self.m_applyList then
        if item and realIndex > 0 and realIndex <= #self.m_applyList then
            item:UpdateData(self.m_applyList[realIndex])
        end
    end
end

function UIGuildApplyListView:ExamineBack(uid, result)
    if self.m_applyList then

        if result == 0 then
            local userName = ""
            for i, v in ipairs(self.m_applyList) do
                if v.user_brief.uid == uid then
                    userName = v.user_brief.name
                end
            end
            if userName ~= "" then
                UILogicUtil.FloatAlert(string_format(Language.GetString(1437), userName))
            end
            local findIndex = table_findIndex(self.m_applyList, function(v)
                return v.user_brief and v.user_brief.uid == uid
            end)
            
            if findIndex > 0 then
                table_remove(self.m_applyList, findIndex)
            end
        end

        if #self.m_applyList == 0 then
            self.m_notApplyText.text = Language.GetString(1398)
        end

        self.m_scrollView:UpdateView(true, self.m_applyItemList, self.m_applyList) 

        GuildMgr:SetGuildApplyRedPointStatus(self.m_applyList)
    end
end 


return UIGuildApplyListView