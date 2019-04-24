local IsNull = IsNull
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local FixNewVector3 = FixMath.NewFixVector3
local BattleWujiangItem = BaseClass("BattleWujiangItem", UIBaseItem)
local base = UIBaseItem
local BattleEnum = BattleEnum
local SkillPoolInst = SkillPoolInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local IsEditor = CS.GameUtility.IsEditor

function BattleWujiangItem:OnCreate()
    base.OnCreate(self)

    self.m_lineupPos = 0
    self.m_bloodBarSlider = UIUtil.AddComponent(UIImage, self, "barRoot/bloodBar", AtlasConfig.DynamicLoad)
    self.m_nuqiRT = UIUtil.FindComponent(self.transform, typeof(CS.UnityEngine.RectTransform), "barRoot/nuqi")
    self.m_frameImage = UIUtil.AddComponent(UIImage, self, "frame", AtlasConfig.DynamicLoad)
    self.m_nuqiImage = UIUtil.AddComponent(UIImage, self, "barRoot/nuqi", AtlasConfig.DynamicLoad)
    self.m_iconImage = UIUtil.AddComponent(UIImage, self, "icon", AtlasConfig.RoleIcon)
    self.m_barRoot = UIUtil.FindTrans(self.transform, "barRoot")

    self.m_barRoot = self.m_barRoot.gameObject
    self.m_nuqiWidth = self.m_nuqiRT.sizeDelta.x
    self.m_nuqiHeight = self.m_nuqiRT.sizeDelta.y
    
    self:HandleClick()
    self:UpdateNuqiBar(0)

    self.m_layerName = UILogicUtil.FindLayerName(self.transform)
end

function BattleWujiangItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_iconImage.gameObject)

    UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)

    self:ClearNuqiEffect()

    self.m_actorID = false
    self.m_bloodBarSlider = false
    self.m_nuqiRT = false
    self.m_frameImage = false
    self.m_nuqiWidth = false
    self.m_nuqiHeight = false
    self.m_lineupPos = 0

    base.OnDestroy(self)
end

function BattleWujiangItem:HandleClick()
    UIUtil.AddClickEvent(self.m_iconImage.gameObject, UILogicUtil.BindClick(self, self.OnClick))
end

function BattleWujiangItem:OnClick(go, x, y)
    if go.name == "icon" then
        self:ExSkill()
    end
end

function BattleWujiangItem:SetData(actorID, viewBaseOrder)
    self.m_actorID = actorID
    self.m_viewBaseOrder = viewBaseOrder

    local actor = ActorManagerInst:GetActor(self.m_actorID)
    if actor then
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(actor:GetWujiangID())
        if wujiangCfg then
            self.m_iconImage:SetAtlasSprite(wujiangCfg.sIcon)
            UILogicUtil.SetWuJiangFrame(self.m_frameImage, wujiangCfg.rare)
        end
        self.m_lineupPos = actor:GetLineupPos()

        self:UpdateBloodBar(0)
        self:UpdateNuqiBar(0)
    end
end

function BattleWujiangItem:UpdateBloodBar(chgVal)
    local actor = ActorManagerInst:GetActor(self.m_actorID)
    if not actor then
       return 
    end

    local actorData = actor:GetData()
    if not actorData then
        return
    end

    local curHP = actorData:GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local maxHP = actorData:GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP)
    self.m_bloodBarSlider:SetFillAmount(curHP / maxHP)
end

function BattleWujiangItem:UpdateNuqiBar(chgVal)

    local actor = ActorManagerInst:GetActor(self.m_actorID)
    if not actor then
       return 
    end

    local actorData = actor:GetData()
    if not actorData then
        return
    end

    if not actor:IsLive() then
        return 
     end

    local nguiPercent = actorData:GetNuqi() / BattleEnum.ActorConfig_MAX_NUQI
    self.m_nuqiImage:SetFillAmount(nguiPercent)

    if nguiPercent < 1 then
        self:ClearNuqiEffect()
    else
        if not self.nuqiEffect then
            local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
            
            self.nuqiEffect = UIUtil.AddComponent(UIEffect, self, "", sortOrder, "UI/Effect/Prefabs/nuqi")
        end
    end
end

function BattleWujiangItem:ExSkill()
    if CtlBattleInst:GetLogic():IsAutoFight() then
        return
    end
    
    local skillInputMgr = CtlBattleInst:GetSkillInputMgr()
    if not skillInputMgr then
        return
    end

    local performer = ActorManagerInst:GetActor(self.m_actorID)
    if not performer then
        return
    end
   
    local battleLogic = CtlBattleInst:GetLogic()
    if battleLogic then
       if not battleLogic:CanDaZhao(performer:GetCamp()) then
            return
       end
    end
    
    local dazhao = performer:GetSkillContainer():GetDazhao()
    if not dazhao then
        return
    end

    local skillCfg = ConfigUtil.GetSkillCfgByID(dazhao:GetID())
    if not skillCfg then
        return
    end

    if IsEditor() then
        local isNuFull = performer:IsNuqiFull()
        if not isNuFull then
            performer:ChangeNuqi(1000, BattleEnum.NuqiReason_OTHER, skillCfg)
            return
        end
    end

    if not performer:CanDaZhao() then
        return
    end

    local skillBase = SkillPoolInst:GetSkill(skillCfg, dazhao:GetLevel())
    if not skillBase then
        return
    end

    BattleCameraMgr:StopDazhaoPerform()
    if skillCfg.type == SKILL_TYPE.DAZHAO_NO_SELECT then
        FrameCmdFactory:GetInstance():ProductCommand(BattleEnum.FRAME_CMD_TYPE_SKILL_INPUT_END, FixNewVector3(0, 0, 0), self.m_actorID, 0)
        return
    end

    BattleCameraMgr:SetCinemachineBrainActive(false)
    CtlBattleInst:FramePause()
    skillInputMgr:Active(performer, skillBase)

    if skillCfg.type == SKILL_TYPE.DAZHAO then
        -- 搞一个通用的
        
        -- local wujiangCfg = ConfigUtil.GetWujiangCfgByID(performer:GetWujiangID())
        -- if wujiangCfg and wujiangCfg.askAudio > 0 then
           
        --     AudioMgr:PlayAudio(wujiangCfg.askAudio, nil, false)
        -- end
    end
end

function BattleWujiangItem:GetActorID()
    return self.m_actorID
end

function BattleWujiangItem:GetLineupPos()
    return self.m_lineupPos
end

function BattleWujiangItem:SetSiblingIndex(index)
    self.transform:SetSiblingIndex(index)
end

function BattleWujiangItem:OnActorDie()
    self.m_nuqiImage:SetColor(Color.black)
    self.m_frameImage:SetColor(Color.black)
    self.m_iconImage:SetColor(Color.black)

    self:ClearNuqiEffect()
end

function BattleWujiangItem:ClearNuqiEffect()
    if self.nuqiEffect then
        --self:RemoveComponent(self.nuqiEffect:GetName(), UIEffect)
        self.nuqiEffect:Delete()
        self.nuqiEffect = nil
    end 
end

function BattleWujiangItem:HideBloodAndNuqi()
    self.m_barRoot:SetActive(false)
end

function BattleWujiangItem:ShowBloodAndNuqi()
    self.m_barRoot:SetActive(true)
end

return BattleWujiangItem

