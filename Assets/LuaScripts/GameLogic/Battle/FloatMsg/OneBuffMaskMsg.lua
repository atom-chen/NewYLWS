local Vector3 = Vector3
local BattleEnum = BattleEnum
local IsNull = IsNull
local Animator = CS.UnityEngine.Animator
local TextMeshProUGUI = CS.TMPro.TextMeshProUGUI
local RectTransform = CS.UnityEngine.RectTransform
local GameUtility = CS.GameUtility
local OneBuffMaskMsg = BaseClass("OneBuffMaskMsg")
local Color = Color
local Type_Animator = typeof(Animator)
local Type_TextMeshProUGUI = typeof(TextMeshProUGUI)
local Type_RectTransform = typeof(RectTransform)
local Type_UIImage = typeof(CS.UnityEngine.UI.Image)
local AtlasConfig = AtlasConfig
local StatusEnum = StatusEnum
local GameObjectPoolNoActiveInst = GameObjectPoolNoActiveInst


function OneBuffMaskMsg:__init(go, uiPos, length, delay, txt, anim, path, statusType, textScale)
    self.m_leftS = length + delay
    self.m_animTimeReset = length + delay
    self.m_delay = delay        -- S
    self.m_text = txt or ''
    self.m_go = go
    self.m_anim = anim
    self.m_animator = false
    self.m_uiPos = uiPos
    self.m_path = path
    self.m_buffmaskImg = false
    self.m_bufftextMesh = false
    self.m_statusType = statusType
    self.m_textScale = textScale or Vector3.one
end

function OneBuffMaskMsg:__delete()    
    local rectTran = self.m_go.transform:GetComponentInChildren(Type_RectTransform)
    rectTran.anchoredPosition3D = Vector3.zero
    rectTran.localScale = Vector3.one

    GameObjectPoolNoActiveInst:RecycleGameObject(self.m_path, self.m_go)
        
    if self.m_buffmaskImg then
        self.m_buffmaskImg.color = Color.white
        self.m_buffmaskImg =  nil
    end

    if self.m_bufftextMesh then
        self.m_bufftextMesh.color = Color.white
        self.m_bufftextMesh =  nil
    end

    self.m_buffmaskImg = nil
    self.m_bufftextMesh = nil
    self.m_go = nil
    self.m_anim = nil

    self.m_animator = nil
    self.m_uiPos = uiPos
end

function OneBuffMaskMsg:Start()
    if not self.m_go then
        return
    end

    self.m_animator = self.m_go:GetComponentInChildren(Type_Animator)
    if not self.m_animator then
        return
    end

    local trans = self.m_go.transform    
    GameUtility.SetLocalPosition(trans, self.m_uiPos.x, self.m_uiPos.y, self.m_uiPos.z)

    self.m_buffmaskImg = trans:GetComponentInChildren(Type_UIImage)
    self.m_bufftextMesh = self.m_go:GetComponentInChildren(Type_TextMeshProUGUI)
    if not self.m_bufftextMesh then
        return
    end

    self.m_bufftextMesh.text = self.m_text
    local sprite_name = "10483.png"

    if self.m_statusType == StatusEnum.STATUSTYPE_DIAOCHANMARK then
        sprite_name = "10483.png"
    elseif self.m_statusType == StatusEnum.STAUTSTYPE_ZHOUYUBUFF then
        sprite_name = "10293.png"
    end

    AtlasManager:GetInstance():LoadImageAsync(ImageConfig.SkillIcon, sprite_name, function(sprite, p_sprite_name)
            -- 预设已经被销毁
            if IsNull(self.m_buffmaskImg) then
                return
            end

            -- 被加载的Sprite不是当前想要的Sprite：可能预设被复用，之前的加载操作就要作废
            if sprite_name ~= p_sprite_name then
                return
            end

            if not IsNull(sprite) then
                self.m_buffmaskImg.sprite = sprite
            end
        end, sprite_name)

    GameUtility.SetLocalScale(trans, self.m_textScale.x, self.m_textScale.y, self.m_textScale.z)

    if self.m_delay <= 0 then
        self.m_animator:Play(self.m_anim, 0, 0)
    else
        self.m_animator.enabled = false
    end
end

function OneBuffMaskMsg:GetDelay()
    return self.m_delay
end

function OneBuffMaskMsg:GetStatusType()
    return self.m_statusType
end

function OneBuffMaskMsg:SetMaskText(text, newUIPos)
    if self.m_bufftextMesh then
        self.m_bufftextMesh.text = text
        self.m_leftS = self.m_animTimeReset
        self.m_delay = 0.3
        GameUtility.SetLocalPosition(self.m_go.transform, newUIPos.x, newUIPos.y, newUIPos.z)
    end
end

function OneBuffMaskMsg:Update(deltaS)
    if self.m_delay > 0 then
        self.m_delay = self.m_delay - deltaS
        if self.m_delay <= 0 then
            GameUtility.SetLocalScale(self.m_go.transform, self.m_textScale.x, self.m_textScale.y, self.m_textScale.z)
            self.m_animator.enabled = true
            self.m_animator:Play(self.m_anim, 0, 0)
        end
    end

    self.m_leftS = self.m_leftS - deltaS
    if self.m_leftS <= 0 then
        return true
    end

    return false
end

return OneBuffMaskMsg