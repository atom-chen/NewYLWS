local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local string_format = string.format
local math_ceil = math.ceil
local GameUtility = CS.GameUtility
local UIGodBeastSkillItem = BaseClass("UIGodBeastSkillItem", UIBaseItem)
local base = UIBaseItem


function UIGodBeastSkillItem:OnCreate()
    self.m_skillIconImage = UIUtil.AddComponent(UIImage, self, "SkillIcon", ImageConfig.GodBeast)
    self.m_selectImage = UIUtil.GetChildTransforms(self.transform, { "SelectImage" })
    self.m_skillNameText = UIUtil.GetChildTexts(self.transform, { "skillNameText" })
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_skillIconImage.gameObject, onClick)

    self.m_skillIndex = 0
end

function UIGodBeastSkillItem:GetSkillIndex()
   return  self.m_skillIndex
end

function UIGodBeastSkillItem:SetData(godBeastId, skillIndex, unlocked, selfOnClickCallback)
    self.m_skillIndex = skillIndex
    self.m_selfOnClickCallback = selfOnClickCallback

    if godBeastId then
        self.m_skillIconImage:SetAtlasSprite(math_ceil(godBeastId)..skillIndex..".png", false)
    end

    GameUtility.SetUIGray(self.m_skillIconImage.gameObject, unlocked ~= 0)

    if unlocked == 0 then
        self.m_skillNameText.text = Language.GetString(3608)
    else
        self.m_skillNameText.text = string_format(Language.GetString(3609), unlocked)
    end
end

function UIGodBeastSkillItem:SetSelect(isSelect)
    self.m_selectImage.gameObject:SetActive(isSelect)
end

function UIGodBeastSkillItem:OnClick(go, x, y)
    if self.m_selfOnClickCallback then
        self.m_selfOnClickCallback(self)
    end
end

function UIGodBeastSkillItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_skillIconImage.gameObject)
    if self.m_skillIconImage then
        self.m_skillIconImage:Delete()
        self.m_skillIconImage = nil
    end
    base.OnDestroy(self)
end

return UIGodBeastSkillItem