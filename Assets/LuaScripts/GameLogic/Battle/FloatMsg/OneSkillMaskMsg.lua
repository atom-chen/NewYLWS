local Vector3 = Vector3
local BattleEnum = BattleEnum
local IsNull = IsNull
local Animator = CS.UnityEngine.Animator
local TextMeshProUGUI = CS.TMPro.TextMeshProUGUI
local RectTransform = CS.UnityEngine.RectTransform
local OneSkillMaskMsg = BaseClass("OneSkillMaskMsg")
local Color = Color
local Type_Animator = typeof(Animator)
local Type_TextMeshProUGUI = typeof(TextMeshProUGUI)
local Type_RectTransform = typeof(RectTransform)
local Type_UIImage = typeof(CS.UnityEngine.UI.Image)
local GameUtility = CS.GameUtility
local AtlasConfig = AtlasConfig
local GameObjectPoolNoActiveInst = GameObjectPoolNoActiveInst
local string_format = string.format

function OneSkillMaskMsg:__init(go, uiPos, length, delay, count, anim, path, textScale, type)
    self.m_leftS = length + delay
    self.m_animTimeReset = length + delay
    self.m_delay = delay        -- S
    self.m_text = txt or ''
    self.m_count = count or 0
    self.m_go = go
    self.m_anim = anim
    self.m_animator = false
    self.m_uiPos = uiPos
    self.m_buffmaskImg = false
    self.m_bufftextMesh = false
    self.m_statusType = statusType
    self.m_textScale = textScale or Vector3.one
    self.m_maskType = type
    self.m_path = path

    local trans = self.m_go.transform
    
    GameUtility.SetLocalPosition(trans, self.m_uiPos.x, self.m_uiPos.y, self.m_uiPos.z)
    GameUtility.SetLocalScale(trans, self.m_textScale.x, self.m_textScale.y, self.m_textScale.z)

    self.m_skillNameText, self.m_countText =
    UIUtil.GetChildTexts(trans, {
        "Image/SkillNameText",
        "Image/CountText",
    })

    self.m_imageTrans = 
    UIUtil.GetChildTransforms(trans, {
        "Image",
    })

    self.m_orignalPos = self.m_imageTrans.localPosition
end

function OneSkillMaskMsg:__delete()   
    local rectTran = self.m_go.transform:GetComponentInChildren(Type_RectTransform)
    rectTran.localScale = Vector3.one
    GameUtility.SetLocalPosition(self.m_go.transform, 0, 0, 0)
    GameUtility.SetLocalPosition(m_imageTrans, self.m_orignalPos.x, self.m_orignalPos.y, self.m_orignalPos.z)

    GameObjectPoolNoActiveInst:RecycleGameObject(self.m_path, self.m_go)
        
    self.m_skillNameText = nil
    self.m_count = 0
    self.m_go = nil
    self.m_anim = nil

    self.m_animator = nil
    self.m_uiPos = nil
end

function OneSkillMaskMsg:Start()
    if not self.m_go then
        return
    end

    self.m_animator = self.m_go:GetComponentInChildren(Type_Animator)
    if not self.m_animator then
        return
    end

    local name = ''
    if self.m_maskType == BattleEnum.SKILL_MASK_DIAOCHAN then
        name = Language.GetString(3665)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_ZHOUYU then
        name = Language.GetString(3664)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_ZHANGLIAO then
        name = Language.GetString(3666)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_CAIWENJI_PRO then
        name = Language.GetString(3667)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_CAIWENJI_ANG then
        name = Language.GetString(3668)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_CAIWENJI_POS then
        name = Language.GetString(3669)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_HUANGZHONG then
        name = Language.GetString(3670)
        
    elseif self.m_maskType == BattleEnum.SKILL_MASK_DIANWEI then
        name = Language.GetString(3671)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_ZHAOYUN then
        name = Language.GetString(3672)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_YUANSHAO then
        name = Language.GetString(3673)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_YUANSHU then
        name = Language.GetString(3674)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_NANMANJIANGLING then
        name = Language.GetString(3675)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_ZHANGFEI then
        name = Language.GetString(3676)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_HUANGXIONG then
        name = Language.GetString(3677)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_PANGTONG then
        name = Language.GetString(3678)

    elseif self.m_maskType == BattleEnum.SKILL_MASK_LVBU then
        name = Language.GetString(3679)

    end

    self.m_skillNameText.text = name
    if self.m_count <= 0 then
        self.m_countText.text = ''
    else
        self.m_countText.text = string_format("x%d", self.m_count)
    end

    self.m_animator:Play(self.m_anim, 0, 0)
end

function OneSkillMaskMsg:GetDelay()
    return self.m_delay
end

function OneSkillMaskMsg:GetSkillMaskType()
    return self.m_maskType
end

function OneSkillMaskMsg:GetCount()
    return self.m_count
end

function OneSkillMaskMsg:SetMaskText(count, newPos)
    self.m_count = count
    if self.m_count <= 0 then
        self.m_countText.text = ''
    else
        self.m_countText.text = string_format("x%d", self.m_count)
    end

    self.m_leftS = self.m_animTimeReset
    self.m_delay = 0.5
    GameUtility.SetLocalPosition(self.m_go.transform, newPos.x, newPos.y, newPos.z)
end

function OneSkillMaskMsg:Update(deltaS)
    if self.m_delay > 0 then
        self.m_delay = self.m_delay - deltaS
        if self.m_delay <= 0 then
            -- self.m_animator:Play(self.m_anim, 0, 0)
        end
    end

    self.m_leftS = self.m_leftS - deltaS
    if self.m_leftS <= 0 then
        return true
    end

    return false
end

return OneSkillMaskMsg