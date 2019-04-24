local UIMountChoiceSuccView = BaseClass("UIMountChoiceSuccView", UIBaseView)
local base = UIBaseView

local string_format = string.format
local CommonDefine = CommonDefine
local Language = Language
local UILogicUtil = UILogicUtil
local UIUtil = UIUtil
local math_ceil = math.ceil
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()

function UIMountChoiceSuccView:OnCreate()
    base.OnCreate(self)

    self.m_mountNameText, self.m_mountStageText, self.m_mountTypeText,
    self.m_mountAttrText, self.m_titleText = UIUtil.GetChildTexts(self.transform, {
        "Container/MountNameText",
        "Container/MountStageText",
        "Container/MountTypeText",
        "Container/MountAttrText",
        "Container/bg2/TitleBg/TitleText",
    })

    self.m_titleText.text = Language.GetString(3595)

    self.m_awardItemPos, self.m_backBtn = UIUtil.GetChildTransforms(self.transform, {
        "Container/AwardItemPos",
        "CloseBtn",
    })

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
end

function UIMountChoiceSuccView:OnClick(go)
    if go.name == "CloseBtn" then
        self:CloseSelf()
    end
end

function UIMountChoiceSuccView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, awardList = ...
    if awardList then
        local awardData = awardList[1]
        if awardData then
            local mountData = awardData:GetZuoqiData()
            if mountData then
                local mountCfg = ConfigUtil.GetZuoQiCfgByID(mountData:GetItemID())
                if mountCfg then
                    self.m_mountNameText.text = UILogicUtil.GetZuoQiNameByStage(mountData:GetStage(), mountCfg)
                    self.m_mountStageText.text = string_format(Language.GetString(3596), mountData:GetStage(), mountData:GetMaxStage())
                    self.m_mountTypeText.text = string_format(Language.GetString(3540), mountCfg.horse_name)
                    self:UpdateAttr(mountData)
                end
            end

            self:UpdateAwardItem(awardData)
        end
    end
end

function UIMountChoiceSuccView:UpdateAttr(mountData)
    local baseAttr = mountData:GetBaseFirstAttr()
    if baseAttr then
        local attrNameList = CommonDefine.first_attr_name_list
        local attrStr = ""
        for i, v in pairs(attrNameList) do
            local val = math_ceil(baseAttr[v])
            if val then
                local attrType = CommonDefine[v]
                if attrType then
                    val = tostring(val)
                    if #val < 2 then
                        attrStr = attrStr..string_format(Language.GetString(3578), Language.GetString(attrType + 10), tostring(val))
                    else
                        attrStr = attrStr..string_format(Language.GetString(3549), Language.GetString(attrType + 10), tostring(val))
                    end
                    if i == 2 then
                        attrStr = attrStr.."\n"
                    elseif i == 1 or i == 3 then
                        attrStr = attrStr.."    "
                    end
                end
            end
        end
        self.m_mountAttrText.text =  attrStr
    end
end

function UIMountChoiceSuccView:UpdateAwardItem(awardData)
    if not awardData then
        return
    end

    self.m_awardItemListLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
    UIGameObjectLoaderInst:GetGameObject(self.m_awardItemListLoadSeq, CommonAwardItemPrefab, function(obj)
        self.m_awardItemListLoadSeq = 0
        if not obj then
            return
        end

        local CreateAwardParamFromAwardData = PBUtil.CreateAwardParamFromAwardData
        if awardData then                
            local awardItem = CommonAwardItem.New(obj, self.m_awardItemPos, CommonAwardItemPrefab)
            if awardItem then
                local itemIconParam = CreateAwardParamFromAwardData(awardData)
                awardItem:SetAnchoredPosition(Vector3.zero)
                awardItem:SetLocalScale(Vector3.one)
                awardItem:UpdateData(itemIconParam)
                self.m_awardItem = awardItem
            end
        end
    end)
end

function UIMountChoiceSuccView:OnDisable()
    if self.m_awardItem then
        self.m_awardItem:Delete()
        self.m_awardItem = nil
    end

    if self.m_awardItemListLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_awardItemListLoadSeq)
        self.m_awardItemListLoadSeq = 0
    end
    
    base.OnDisable(self)
end

return UIMountChoiceSuccView