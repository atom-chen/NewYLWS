local table_insert = table.insert
local table_sort = table.sort
local ItemDefine = ItemDefine

local UIGuildDonationView = BaseClass("UIGuildDonationView", UIBaseView)
local base = UIBaseView

local GameObject = CS.UnityEngine.GameObject
local GuildMgr = Player:GetInstance().GuildMgr
local GuildDonationItem = require "UI.Guild.View.GuildDonationItem"


function UIGuildDonationView:OnCreate()

    base.OnCreate(self)

    self.m_donationItemList = {}

    self:InitView()
end

function UIGuildDonationView:InitView()
    self.m_donationItemPrefab, self.m_closeBtn, self.m_containerTrans, self.m_closeBtn2,
    self.m_ruleBtnTr
    = UIUtil.GetChildTransforms(self.transform, {
        "DonationItemPrefab",
        "CloseBtn",
        "Container",
        "Container/CloseBtn2",
        "Container/ruleBtn",
        
    })
    self.m_donationItemPrefab = self.m_donationItemPrefab.gameObject

    local titleText = UIUtil.FindText(self.transform, "Container/TitleBg/TitleText")
    titleText.text = Language.GetString(1348)

    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn2.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtnTr.gameObject, onClick)
    
end

function UIGuildDonationView:OnClick(go)
    if go.name == "CloseBtn" or go.name == "CloseBtn2" then
        self:CloseSelf()  
    elseif go.name == "ruleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 112) 
    
    end
end

function UIGuildDonationView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn2.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtnTr.gameObject)
    

    base.OnDestroy(self)
end

function UIGuildDonationView:OnEnable(...)
   
    base.OnEnable(self, ...)

    self:UpdateData()
end

function UIGuildDonationView:OnDisable(...)

    for i, v in ipairs(self.m_donationItemList) do
        v:Delete()
    end
    self.m_donationItemList = {}

    base.OnDisable(self)
end


function UIGuildDonationView:OnAddListener()
	base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_GUILD_DONATION_UPDATE, self.UpdateData)
    
end

function UIGuildDonationView:OnRemoveListener()
	base.OnRemoveListener(self)
	
    self:RemoveUIListener(UIMessageNames.MN_GUILD_DONATION_UPDATE, self.UpdateData)
end

function UIGuildDonationView:UpdateData(awardList)
    local guild_donate_cfg_list = ConfigUtil.GetConfigTbl("Config.Data.lua_guild_donate")
    if not guild_donate_cfg_list then
        return
    end

    local cfgIDlist = {}
    for k, v in pairs(guild_donate_cfg_list) do 
        table_insert(cfgIDlist, k)
    end
    table_sort(cfgIDlist, function(a, b)
		return a < b
    end)
   
    for i = 1, #cfgIDlist do 
        local donationItem = self.m_donationItemList[i]
        if not donationItem then
            local go = GameObject.Instantiate(self.m_donationItemPrefab)
            donationItem = GuildDonationItem.New(go, self.m_containerTrans)
            donationItem:SetLocalPosition(Vector3.New(-280 + (i - 1) * 280, 13, 0))
            table_insert(self.m_donationItemList, donationItem)
        end
        
        donationItem:UpdateData(cfgIDlist[i])
    end
    if awardList and #awardList > 0 then
        local uiData = {
            openType = 1,
            awardDataList = awardList,
        }
        UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
    end
end


return UIGuildDonationView