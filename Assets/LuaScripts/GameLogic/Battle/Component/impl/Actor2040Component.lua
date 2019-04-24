local ActorComponent = require "GameLogic.Battle.Component.ActorComponent"
local Actor2040Component = BaseClass("Actor2040Component", ActorComponent)

function Actor2040Component:__init()
    ActorComponent.__init(self)
    self.m_boneHam = false
end

function Actor2040Component:OnBorn(actor_go, actor)
    ActorComponent.OnBorn(self, actor_go, actor)
    self.m_boneHam = self.m_transform:Find("Dummy/Bone_ham")
end

function Actor2040Component:ShowBoneham(isShow)
    if self.m_boneHam then
        self.m_boneHam.gameObject:SetActive(isShow)
    else
        local tranform = self:GetTransform()
        if tranform then
            self.m_boneHam = tranform:Find("Dummy/Bone_ham")
            if self.m_boneHam then
                self.m_boneHam.gameObject:SetActive(isShow)
            end
        end
    end
end

return Actor2040Component