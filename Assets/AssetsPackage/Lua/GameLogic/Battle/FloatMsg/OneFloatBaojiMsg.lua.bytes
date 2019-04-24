local Vector3 = Vector3
local BattleEnum = BattleEnum
local IsNull = IsNull
local Animator = CS.UnityEngine.Animator
local TextMeshProUGUI = CS.TMPro.TextMeshProUGUI
local RectTransform = CS.UnityEngine.RectTransform
local VertexGradient = CS.TMPro.VertexGradient
local OneFloatBaojiMsg = BaseClass("OneFloatBaojiMsg")

local GameUtility = CS.GameUtility
local Type_Animator = typeof(Animator)
local Type_TextMeshProUGUI = typeof(TextMeshProUGUI)
local Type_RectTransform = typeof(RectTransform)
local Type_UIImage = typeof(CS.UnityEngine.UI.Image)
local AtlasConfig = AtlasConfig
local Color = Color
local GameObjectPoolNoActiveInst = GameObjectPoolNoActiveInst

function OneFloatBaojiMsg:__init(go, uiPos, length, delay, txt, anim, path, hurtType, textScale)
    self.m_leftS = length + delay      -- S
    self.m_delay = delay        -- S
    self.m_text = txt or ''
    self.m_go = go
    self.m_anim = anim
    self.m_animator = false
    self.m_uiPos = uiPos
    self.m_path = path
    self.m_hurtType = hurtType
    self.m_baojiImg = false
    self.m_textScale = textScale or Vector3.one
end

function OneFloatBaojiMsg:__delete()    
    local rectTran = self.m_go.transform:GetComponentInChildren(Type_RectTransform)
    rectTran.anchoredPosition3D = Vector3.zero
    rectTran.localScale = Vector3.one

    GameObjectPoolNoActiveInst:RecycleGameObject(self.m_path, self.m_go)
        
    if self.m_baojiImg then
        self.m_baojiImg =  nil
    end

    self.m_baojiImg = nil
    self.m_go = nil
    self.m_anim = nil
    self.m_animator = nil
    self.m_uiPos = uiPos
end

function OneFloatBaojiMsg:Start()
    if not self.m_go then
        return
    end

    self.m_animator = self.m_go:GetComponentInChildren(Type_Animator)
    if not self.m_animator then
        return
    end

    local textMesh = self.m_go:GetComponentInChildren(Type_TextMeshProUGUI)
    if not textMesh then
        return
    end

    local trans = self.m_go.transform    
        
    GameUtility.SetLocalPosition(trans, self.m_uiPos.x, self.m_uiPos.y, self.m_uiPos.z)

    textMesh.text = self.m_text

    self.m_baojiImg = trans:GetComponentInChildren(Type_UIImage)

    local sprite_name = "baoji.png"

    if self.m_hurtType == BattleEnum.HURTTYPE_PHY_HURT then
        sprite_name = "baoji3.png"
        --textMesh.colorGradient = OneFloatBaojiMsg.Phy_Gradient
    elseif self.m_hurtType == BattleEnum.HURTTYPE_MAGIC_HURT then
        sprite_name = "baoji2.png"
        --textMesh.colorGradient = OneFloatBaojiMsg.Magic_Gradient
    else
        sprite_name = "baoji.png"
        --textMesh.colorGradient = OneFloatBaojiMsg.Real_Gradient
    end
    
    AtlasManager:GetInstance():LoadImageAsync(AtlasConfig.BattleDynamicLoad, sprite_name, function(sprite, p_sprite_name)
            -- 预设已经被销毁
            if IsNull(self.m_baojiImg) then
                return
            end
            
            -- 被加载的Sprite不是当前想要的Sprite：可能预设被复用，之前的加载操作就要作废
            if sprite_name ~= p_sprite_name then
                return
            end
            
            if not IsNull(sprite) then
                self.m_baojiImg.sprite = sprite
            end
        end, sprite_name)

    if self.m_delay <= 0 then
        trans.localScale = self.m_textScale
        -- trans:GetChild(0).localScale = Vector3.one
        self.m_animator:Play(self.m_anim, 0, 0)
    else
        trans.localScale = Vector3.zero
        self.m_animator.enabled = false
    end
end

function OneFloatBaojiMsg:Update(deltaS)
    if self.m_delay > 0 then
        self.m_delay = self.m_delay - deltaS
        if self.m_delay <= 0 then
            GameUtility.SetLocalScale(self.m_go.transform, self.m_textScale.x, self.m_textScale.y, self.m_textScale.z)

            -- self.m_go.transform:GetChild(0).localScale = Vector3.one
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

return OneFloatBaojiMsg