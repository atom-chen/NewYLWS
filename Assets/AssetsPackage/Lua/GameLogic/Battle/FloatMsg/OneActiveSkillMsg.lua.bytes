local Vector3 = Vector3
local Vector3_Get = Vector3.Get
local IsNull = IsNull
local ScreenPointToLocalPointInRectangle = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle
local Animator = CS.UnityEngine.Animator
local RectTransform = CS.UnityEngine.RectTransform
local OneActiveSkillMsg = BaseClass("OneActiveSkillMsg")
local Type_Animator = typeof(Animator)
local Type_RectTransform = typeof(RectTransform)
local ActorManagerInst = ActorManagerInst
local GameObjectPoolNoActiveInst = GameObjectPoolNoActiveInst
local GameUtility = CS.GameUtility

function OneActiveSkillMsg:__init(go, uiPos, length, txt, anim, path, actorID, textScale, parentRectTrans)
    self.m_leftS = length
    self.m_text = txt or ''
    self.m_go = go
    self.m_anim = anim
    self.m_animator = false
    self.m_uiPos = uiPos
    self.m_path = path
    self.m_skillMsgImage = false
    self.m_actorID = actorID
    self.m_textScale = textScale or Vector3.one
    self.m_skillNameText = nil
    self.m_beControlTime = 0
	self.m_mainCamera = CS.UnityEngine.Camera.main
    self.m_rectTran = parentRectTrans
end

function OneActiveSkillMsg:__delete()    
    local rectTran = self.m_go.transform:GetComponentInChildren(Type_RectTransform)
    rectTran.anchoredPosition3D = Vector3.zero
    rectTran.localScale = Vector3.one

    GameObjectPoolNoActiveInst:RecycleGameObject(self.m_path, self.m_go)
        
    self.m_skillMsgImage = nil
    self.m_go = nil
    self.m_anim = nil

    self.m_animator = nil
    self.m_uiPos = uiPos
    self.m_leftS = 0
    self.m_text = 0
    self.m_path = nil
    self.m_actorID = 0
    self.m_textScale = Vector3.one
    self.m_skillNameText = nil
    self.m_beControlTime = 0
	self.m_mainCamera = nil
	self.m_rectTran = nil
end

function OneActiveSkillMsg:Start()
    if not self.m_go then
        return
    end

    self.m_animator = self.m_go:GetComponentInChildren(Type_Animator)
    if not self.m_animator then
        return
    end

    local trans = self.m_go.transform    
    GameUtility.SetLocalPosition(trans, self.m_uiPos.x, self.m_uiPos.y, self.m_uiPos.z)

    self.m_skillNameText = UIUtil.GetChildTexts(trans, {
        "msgGroup/msgText",
    })

    self.m_skillNameText.text = self.m_text
    
    GameUtility.SetLocalScale(trans, self.m_textScale.x, self.m_textScale.y, self.m_textScale.z)
    self.m_animator:Play(self.m_anim, 0, 0)
end

function OneActiveSkillMsg:Update(deltaS)
    self.m_leftS = self.m_leftS - deltaS
    if self.m_leftS <= 0 then
        return true
    end

    return false
end


return OneActiveSkillMsg