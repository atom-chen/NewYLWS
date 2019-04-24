
local UIUtil = UIUtil
local Language = Language
local ConfigUtil = ConfigUtil
local CommonDefine = CommonDefine
local math_ceil = math.ceil
local string_format = string.format
local GameUtility = CS.GameUtility
local GameObject = CS.UnityEngine.GameObject
local MountMgr = Player:GetInstance():GetMountMgr()

local ImproveAttrItem = BaseClass("ImproveAttrItem", UIBaseItem)
local base = UIBaseItem

function ImproveAttrItem:OnCreate()
    base.OnCreate(self)

    self.m_attrNameText = UIUtil.GetChildTexts(self.transform, {"AttrNameText"})
    self.m_newImgGo, self.m_activeBtn = UIUtil.GetChildTransforms(self.transform, {"new", "attrImg"})

    self.m_attrImg = UIUtil.AddComponent(UIImage, self, "attrImg")
    self.m_attribute = false
    self.m_huntImpriveId = 0
    self.m_huntId = 0
    self.m_level = 0

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_activeBtn.gameObject, onClick)
end

function ImproveAttrItem:OnClick(go)
    if go.name == "attrImg" then
        if self.m_attribute.status == 1 then
            local pos = self:GetTransform().position
            local text = ""
            local levelUpCfg = ConfigUtil.GetHuntLevelUpCfgByID(self.m_huntImpriveId)
            local nameList = CommonDefine.first_attr_name_list
            if levelUpCfg then
                if self.m_attribute.param == 0 then
                    text = string_format(Language.GetString(3557), Language.GetString(self.m_attribute.attr_id + 10), levelUpCfg["min_"..nameList[self.m_attribute.attr_id]])
                elseif self.m_attribute.param == 1 then
                    text = string_format(Language.GetString(3556), Language.GetString(self.m_attribute.attr_id + 10), levelUpCfg["max_"..nameList[self.m_attribute.attr_id]])
                end
            end
            UIManagerInst:OpenWindow(UIWindowNames.UIIconTips, pos, text)
        else
            UIManagerInst:OpenWindow(UIWindowNames.UIMountAttrImprove, self.m_huntImpriveId, self.m_attribute.attr_id,
            self.m_attribute.param, Bind(MountMgr, MountMgr.ReqActiveAttr, self.m_huntId, self.m_level, self.m_attribute.attr_id, self.m_attribute.param))
        end
    end
end

function ImproveAttrItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_activeBtn.gameObject)
    base.OnDestroy(self)
end

function ImproveAttrItem:SetData(oneAttr, huntImproveId, huntId, level)
    if not oneAttr then
        return
    end

    self.m_attribute = oneAttr
    self.m_huntImpriveId = huntImproveId or 0
    self.m_huntId = huntId
    self.m_level = level
    self.m_attrImg:SetAtlasSprite("ly"..math_ceil(oneAttr.attr_id)..".png", false, AtlasConfig.DynamicLoad)
    self.m_attrNameText.text = Language.GetString(oneAttr.attr_id + 10)
    GameUtility.SetUIGray(self.m_attrImg.gameObject, oneAttr.status ~= 1 or not oneAttr.status)
end

return ImproveAttrItem