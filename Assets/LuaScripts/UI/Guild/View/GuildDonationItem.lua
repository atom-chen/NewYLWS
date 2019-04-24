local string_format = string.format
local table_insert = table.insert

local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local GuildDonationItem = BaseClass("GuildDonationItem", UIBaseItem)
local base = UIBaseItem

local GuildMgr = Player:GetInstance().GuildMgr

function GuildDonationItem:OnCreate()

    self.m_cfgID = false
    self.m_awardItemList = {}
    self.m_seq = 0

    self:InitView()
end

function GuildDonationItem:InitView()
    self.m_donateBtn, self.m_donationStatusTextGo, self.m_gridTr = UIUtil.GetChildTransforms(self.transform, {
        "DonateBtn",
        "DonationStatusText",
        "AwardGrid",
    })

    self.m_donateBtn = self.m_donateBtn.gameObject
    self.m_donationStatusTextGo = self.m_donationStatusTextGo.gameObject

    local donationText, awardText, awardDonationText, donateBtnText
    self.m_nameText, awardText, awardDonationText, self.m_awardDonationValText,
    donationText, self.m_donationItemCountText, donateBtnText, self.m_donationStatusText =  
    UIUtil.GetChildTexts(self.transform, {
        "NameBg/NameText",
        "AwardText",
        "AwardDonationText",
        "AwardDonationText/AwardDonationValText",
        "DonationItem/DonationText",
        "DonationItem/DonationItemCountText",
        "DonateBtn/DonateBtnText",
        "DonationStatusText" ,  
    })

    awardText.text = Language.GetString(1350)
    donationText.text = Language.GetString(1349)
    awardDonationText.text = Language.GetString(1351)
    donateBtnText.text = Language.GetString(1348)

    self.m_donationItemImage = UIUtil.AddComponent(UIImage, self, "DonationItem", AtlasConfig.ItemIcon)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_donateBtn, onClick)
end

function GuildDonationItem:OnClick(go)
    if go == self.m_donateBtn then
        if self.m_cfgID then
            GuildMgr:ReqDonate(self.m_cfgID)
        end
    end
end

function GuildDonationItem:OnDestroy()
    UIGameObjectLoaderInstance:CancelLoad(self.m_seq)
    self.m_seq = 0

    for i, v in pairs(self.m_awardItemList) do
        v:Delete()
    end
    self.m_awardItemList = {}

    UIUtil.RemoveClickEvent(self.m_donateBtn)
    base.OnDestroy(self)
end

function GuildDonationItem:UpdateData(id)
    
    local cfg = ConfigUtil.GetGuildDonateCfgByID(id)
    if cfg then
        self.m_cfgID = id
        self.m_nameText.text = cfg.name
        self.m_awardDonationValText.text = cfg.award_huoyue
        
        for i, v in ipairs(cfg.award_item_list) do
            local awardItem = self.m_awardItemList[i]
            if not awardItem then
                self.m_seq = UIGameObjectLoaderInstance:PrepareOneSeq()
                UIGameObjectLoaderInstance:GetGameObject(self.m_seq, CommonAwardItemPrefab, function(obj)
                    self.m_seq = 0
                    if obj then
                        awardItem = CommonAwardItem.New(obj, self.m_gridTr, CommonAwardItemPrefab)
                        awardItem:SetLocalScale(Vector3.New(0.7, 0.7, 0.7))
                        table_insert(self.m_awardItemList, awardItem)
                        local iconParam = AwardIconParamClass.New(v[1], v[2])
                        awardItem:UpdateData(iconParam)
                    end
                end)
            else
                local iconParam = AwardIconParamClass.New(v[1], v[2])
                awardItem:UpdateData(iconParam)
            end
        end

        local donateID = cfg.donate_info[1]
        if donateID == ItemDefine.TongQian_ID then
            self.m_donationItemImage:SetAtlasSprite("10001.png")
        elseif donateID == ItemDefine.YuanBao_ID then
            self.m_donationItemImage:SetAtlasSprite("10002.png")
        end
        self.m_donationItemCountText.text = cfg.donate_info[2]

        local status = GuildMgr:GetDonationStatus(id)
        
        if status == 1 then
            self.m_donateBtn:SetActive(false)
            self.m_donationStatusText.text = Language.GetString(1352)
        else
            local userData =  Player:GetInstance():GetUserMgr():GetUserData()
            if userData.vip_level < cfg.need_vip_level then
               self.m_donationStatusText.text = string_format(Language.GetString(1353), cfg.need_vip_level)
               self.m_donateBtn:SetActive(false)
            end
        end
    end
end

return GuildDonationItem