local string_format = string.format
local math_ceil = math.ceil
local Vector3 = Vector3
local string_split = CUtil.SplitString
local table_insert = table.insert
local ConfigUtil = ConfigUtil
local BagItemPath = TheGameIds.CommonBagItemPrefab
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local UIBagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()

local LieZhuanItem = BaseClass("LieZhuanItem", UIBaseItem)
local base = UIBaseItem

function LieZhuanItem:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function LieZhuanItem:InitView()
    local awardText
    self.m_titleText, self.m_limitText, awardText , self.m_outputText, self.m_lockedText = UIUtil.GetChildTexts(self.transform, {
        "titleImage/titleText",
        "limitText",
        "awardText",
        "outputText",
        "locked/bg/lockedText",
    })
    self.m_awardContent , self.m_locked = UIUtil.GetChildTransforms(self.transform, { "awardContent", "locked", })
    self.m_bannerImage = UIUtil.AddComponent(UIImage, self, "bannerImage", ImageConfig.LieZhuan)
    self.m_sCountryNameList = string_split(Language.GetString(3750), ",")
    self.m_awardItemList = {}
    self.m_countryId = 0

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self:GetGameObject(), onClick)

    awardText.text = Language.GetString(3754)
end

function LieZhuanItem:OnClick(go)
    if go == self:GetGameObject() then
        if self.m_countryId ~= 0 then
            local sysId = LieZhuanMgr:GetSysIdByCountry(self.m_countryId)
            if not UILogicUtil.IsSysOpen(sysId, false) then
                return
            end
            UILogicUtil.SysShowUI(sysId)
        end
    end
end

function LieZhuanItem:UpdateData(countryId, teamCount, maxPassCopy)
    if countryId and teamCount and countryId > 0 then
        self.m_countryId = countryId
        local countryStr = self.m_sCountryNameList[countryId]
        self.m_titleText.text = string_format(Language.GetString(3751), countryStr)
        self.m_limitText.text = string_format(Language.GetString(3753), countryStr)
        self.m_outputText.text = Language.GetString(3743 + countryId)
        self.m_bannerImage:SetAtlasSprite(countryId..".png", true)
        
        local maxCopyId = LieZhuanMgr:GetMaxCopyIdByCountry(countryId)
        if maxPassCopy > maxCopyId then
            maxPassCopy = maxCopyId
        end
        
        local copyCfg = ConfigUtil.GetLieZhuanCopyCfgByID(maxPassCopy)
        if copyCfg then
            self:UpdateItemData(copyCfg.preview_award)
        end

        local sysId = LieZhuanMgr:GetSysIdByCountry(countryId)
        if sysId then
            self:SetLockStatus(UILogicUtil.IsSysOpen(sysId, false), sysId)
        end
    end
end

function LieZhuanItem:UpdateItemData(awardItemList)
    self:ClearAwardItem()
    if not self.m_awardItemList then
        self.m_awardItemList = {}
    end
    for k, v in pairs(awardItemList) do
        self.m_seq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObject(self.m_seq, BagItemPath, function(go)
            self.m_seq = 0
            if not IsNull(go) then
                local bagItem = UIBagItem.New(go, self.m_awardContent, BagItemPath)
                bagItem.transform.localScale = Vector3.New(0.7,0.7,0.7)
                bagItem.m_gameObject.name = v[1]
                table_insert(self.m_awardItemList, bagItem)
                local itemCfg = ConfigUtil.GetItemCfgByID(v[1])
                if itemCfg then
                    local itemIconParam = ItemIconParam.New(itemCfg, 0)
                    if itemIconParam then
                        itemIconParam.onClickShowDetail = true
                        bagItem:UpdateData(itemIconParam)
                    end
                end
            end
        end)
    end
end

function LieZhuanItem:ClearAwardItem()
    if self.m_awardItemList then
        for i, v in ipairs(self.m_awardItemList) do
            UIUtil.RemoveEvent(v:GetGameObject())   
            v:Delete()
        end
        self.m_awardItemList = nil
    end
end

function LieZhuanItem:SetLockStatus(isOpen, sysID)
    self.m_locked.gameObject:SetActive(not isOpen)
    if not isOpen then
        local sysOpenCfg = ConfigUtil.GetSysopenCfgByID(sysID)
        if sysOpenCfg then
            self.m_lockedText.text = sysOpenCfg.sDesc
        end
    end
end

function LieZhuanItem:OnDestroy()
    UIUtil.RemoveClickEvent(self:GetGameObject())
    if self.m_bannerImage then
        self.m_bannerImage:Delete()
        self.m_bannerImage = nil
    end
    self:ClearAwardItem()
    base.OnDestroy(self)
end

return LieZhuanItem