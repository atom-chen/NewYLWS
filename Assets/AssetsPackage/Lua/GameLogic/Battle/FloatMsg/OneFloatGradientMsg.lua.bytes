local Vector3 = Vector3
local IsNull = IsNull
local Animator = CS.UnityEngine.Animator
local TextMeshProUGUI = CS.TMPro.TextMeshProUGUI
local RectTransform = CS.UnityEngine.RectTransform

local GameUtility = CS.GameUtility
local OneFloatGradientMsg = BaseClass("OneFloatGradientMsg")

local Type_Animator = typeof(Animator)
local Type_TextMeshProUGUI = typeof(TextMeshProUGUI)
local Type_RectTransform = typeof(RectTransform)
local GameObjectPoolNoActiveInst = GameObjectPoolNoActiveInst

function OneFloatGradientMsg:__init(go, uiPos, txt, path, charCount)
    self.m_text = txt or ''
    self.m_go = go
    self.m_uiPos = uiPos
    self.m_path = path
    self.m_showCount = 0    
    self.m_charCount = charCount or 6
    self.m_textMesh = self.m_go:GetComponentInChildren(Type_TextMeshProUGUI)
end

function OneFloatGradientMsg:__delete()    -- todo
    local rectTran = self.m_go.transform:GetComponentInChildren(Type_RectTransform)
    rectTran.anchoredPosition3D = Vector3.zero
    rectTran.localScale = Vector3.one

    self.m_textMesh.maxVisibleCharacters = 99999
    self.m_textMesh:ForceMeshUpdate()
    self.m_textMesh = nil

    GameObjectPoolNoActiveInst:RecycleGameObject(self.m_path, self.m_go)

    self.m_go = nil
    self.m_anim = nil
    self.m_uiPos = uiPos
end

function OneFloatGradientMsg:Start()
    
    local trans = self.m_go.transform    
    
    GameUtility.SetLocalPosition(trans, self.m_uiPos.x, self.m_uiPos.y, self.m_uiPos.z)
    GameUtility.SetLocalScale(trans, 1, 1, 1)

    self.m_textMesh.maxVisibleCharacters = 1
    self.m_textMesh.text = self.m_text
end

function OneFloatGradientMsg:Update(deltaS)
    if self.m_showCount >= self.m_charCount then
        return true
    end

    self.m_showCount = self.m_showCount + 1
    self.m_textMesh.maxVisibleCharacters = self.m_showCount
    self.m_textMesh:ForceMeshUpdate()

    return false
end

return OneFloatGradientMsg