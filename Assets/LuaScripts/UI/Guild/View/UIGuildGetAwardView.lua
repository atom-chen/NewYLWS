local table_insert = table.insert
local string_format = string.format

local UIGuildGetAwardView = BaseClass("UIGuildGetAwardView", UIBaseView)
local base = UIBaseView

local GameObject = CS.UnityEngine.GameObject
local GuildAwardItem = require "UI.Guild.View.GuildAwardItem"
local GuildMgr = Player:GetInstance().GuildMgr

local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local Award_Type_Worship = 1
local Award_Type_GuildWar = 2

function UIGuildGetAwardView:OnCreate()
    base.OnCreate(self)

    self.m_worshipAwardItemList = {}
    self.m_guildWarAwardList = {}
    self.m_seq = 0

    self.m_closeBtn, self.m_beWorshipedAwardParent, self.m_awardItmePrefab, self.m_getAwardBtn,
    self.m_gridTr = UIUtil.GetChildTransforms(self.transform, {
        "CloseBtn",
        "Container/Content/BeWorshipedAwardList",
        "AwardItmePrefab",
        "Container/Content/GetAwardBtn",
        "Container/Content/Grid",
    })

    local guildWarAwardText, getAwardBtnText, titleText
    self.m_beWorshipedCountText, getAwardBtnText, guildWarAwardText, titleText = UIUtil.GetChildTexts(self.transform, {
        "Container/Content/BeWorshipedCountText",
        "Container/Content/GetAwardBtn/GetAwardBtnText",
        "Container/Content/GuildWarAwardText",
        "Container/bg2/TitleBg/TitleText",
    })

    guildWarAwardText.text = Language.GetString(1383)
    getAwardBtnText.text = Language.GetString(1380)
    titleText.text = Language.GetString(2458)

    self.m_awardItmePrefab = self.m_awardItmePrefab.gameObject

    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_getAwardBtn.gameObject, onClick)
end

function UIGuildGetAwardView:OnAddListener()
	base.OnAddListener(self)
	
    self:AddUIListener(UIMessageNames.MN_GUILD_RSP_TAKE_ALL_AWARD, self.RspTakeAward)
end

function UIGuildGetAwardView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_GUILD_RSP_TAKE_ALL_AWARD, self.RspTakeAward)
	
    base.OnRemoveListener(self)
end

function UIGuildGetAwardView:RspTakeAward()
    self:CloseSelf()
end

function UIGuildGetAwardView:OnClick(go)
    if go.name == "CloseBtn" then
        self:CloseSelf()   
    elseif go.name == "GetAwardBtn" then
        GuildMgr:ReqTakeAllAward()
    end
end

function UIGuildGetAwardView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_getAwardBtn.gameObject)
    base.OnDestroy(self)
end

function UIGuildGetAwardView:OnEnable(...)
   
    base.OnEnable(self, ...)

    _, awardList, be_worshiped_count = ...
    
    self:UpateData(awardList, be_worshiped_count)
end


function UIGuildGetAwardView:UpateData(awardList, be_worshiped_count)
    if not awardList then
        return
    end

    self.m_beWorshipedCountText.text = string_format(Language.GetString(1381), be_worshiped_count)
    self:UpdateWorshipAwardItemList()
end

function UIGuildGetAwardView:UpdateWorshipAwardItemList()
    -- if #self.m_worshipAwardItemList == 0 then
    --     for i = 1, 2 do
    --         local go = GameObject.Instantiate(self.m_awardItmePrefab)
    --         local awardItem = GuildAwardItem.New(go, self.m_beWorshipedAwardParent)
    --         awardItem:SetAnchoredPosition(Vector3.New(345.2 * (i - 1), 0, 0))
    --         table_insert(self.m_worshipAwardItemList, awardItem)
    --     end
    -- end

    for i, v in ipairs(awardList) do
        if v and v.type == Award_Type_Worship then
            for index, item in ipairs(v.item_list) do
                local awardItem = self.m_worshipAwardItemList[index]
                if not awardItem then
                    local go = GameObject.Instantiate(self.m_awardItmePrefab)
                    awardItem = GuildAwardItem.New(go, self.m_beWorshipedAwardParent)
                    awardItem:SetAnchoredPosition(Vector3.New(345.2 * (i - 1), 0, 0))
                    table_insert(self.m_worshipAwardItemList, awardItem)
                end
                awardItem:UpdateData(item:GetItemID(), item:GetItemCount())
            end
        elseif v and v.type == Award_Type_GuildWar then
            for index, item in ipairs(v.item_list) do
                local awardItem = self.m_guildWarAwardList[index]
                if not awardItem then
                    self.m_seq = UIGameObjectLoaderInstance:PrepareOneSeq()
                    UIGameObjectLoaderInstance:GetGameObject(self.m_seq, CommonAwardItemPrefab, function(obj)
                        self.m_seq = 0
                        if obj then
                            awardItem = CommonAwardItem.New(obj, self.m_awardGridTr, CommonAwardItemPrefab)
                            awardItem:SetLocalScale(Vector3.New(0.8, 0.8, 0.8))
                            table_insert(self.m_guildWarAwardList, awardItem)
                            local iconParam = AwardIconParamClass.New(item:GetItemID(), item:GetItemCount())
                            awardItem:UpdateData(iconParam)
                        end
                    end)
                else
                    local iconParam = AwardIconParamClass.New(item:GetItemID(), item:GetItemCount())
                    awardItem:UpdateData(iconParam)
                end
            end
        end
    end
end


function UIGuildGetAwardView:OnDisable()
	for i, v in ipairs(self.m_worshipAwardItemList) do
        v:Delete()
    end
    self.m_worshipAwardItemList = {}

	base.OnDisable(self)
end


return UIGuildGetAwardView
