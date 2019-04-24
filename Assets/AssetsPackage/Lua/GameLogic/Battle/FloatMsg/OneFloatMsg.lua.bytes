local Vector3 = Vector3
local IsNull = IsNull
local Animator = CS.UnityEngine.Animator
local TextMeshProUGUI = CS.TMPro.TextMeshProUGUI
local RectTransform = CS.UnityEngine.RectTransform

local GameUtility = CS.GameUtility
local OneFloatMsg = BaseClass("OneFloatMsg")

local Type_Animator = typeof(Animator)
local Type_Text = typeof(CS.UnityEngine.UI.Text)
--local Type_TextMeshProUGUI = typeof(TextMeshProUGUI)
local Type_RectTransform = typeof(RectTransform)
local GameObjectPoolNoActiveInst = GameObjectPoolNoActiveInst

function OneFloatMsg:__init(go, uiPos, length, delay, txt, anim, path, textScale)
    self.m_leftS = length + delay      -- S
    self.m_delay = delay        -- S
    self.m_text = txt or ''
    self.m_go = go
    self.m_anim = anim
    self.m_animator = false
    self.m_uiPos = uiPos
    self.m_path = path
    self.m_textScale = textScale or Vector3.one
end

function OneFloatMsg:__delete()    
    local rectTran = self.m_go.transform:GetComponentInChildren(Type_RectTransform)
    rectTran.anchoredPosition3D = Vector3.zero
    rectTran.localScale = Vector3.one

    GameObjectPoolNoActiveInst:RecycleGameObject(self.m_path, self.m_go)
        
    self.m_go = nil
    self.m_anim = nil
    self.m_animator = nil
    self.m_uiPos = uiPos
end

function OneFloatMsg:Start()
    if not self.m_go then
        return
    end

    self.m_animator = self.m_go:GetComponentInChildren(Type_Animator)
    if not self.m_animator then
        return
    end

    local text = self.m_go:GetComponentInChildren(Type_Text)
    if not text then
        return
    end

    local trans = self.m_go.transform    
    
    GameUtility.SetLocalPosition(trans, self.m_uiPos.x, self.m_uiPos.y, self.m_uiPos.z)

    text.text = self.m_text

    if self.m_delay <= 0 then
        trans.localScale = self.m_textScale
        -- trans:GetChild(0).localScale = Vector3.one
        self.m_animator:Play(self.m_anim, 0, 0)
    else
        trans.localScale = Vector3.zero
        self.m_animator.enabled = false
    end

end

function OneFloatMsg:Update(deltaS)
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

return OneFloatMsg