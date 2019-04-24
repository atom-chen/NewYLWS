

local Time = Time
local Vector3 = Vector3
local Vector3_Get = Vector3.Get
local Vector2 = Vector2
local BattleEnum = BattleEnum
local Language = Language
local table_insert = table.insert
local table_remove = table.remove
local string_format = string.format
local IsNull = IsNull
local GameUtility = CS.GameUtility
local ACTOR_ATTR = ACTOR_ATTR
local ScreenPointToLocalPointInRectangle = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle
local OneFloatMsg = require "GameLogic.Battle.FloatMsg.OneFloatMsg"
local OneFloatGradientMsg = require "GameLogic.Battle.FloatMsg.OneFloatGradientMsg"
--local OneFloatBaojiMsg = require "GameLogic.Battle.FloatMsg.OneFloatBaojiMsg"
local OneBuffMaskMsg = require "GameLogic.Battle.FloatMsg.OneBuffMaskMsg"
local OneSkillMaskMsg = require "GameLogic.Battle.FloatMsg.OneSkillMaskMsg"
local WorldArtFont = require "GameLogic.Battle.FloatMsg.WorldArtFont"
local OneActiveSkillMsg = require "GameLogic.Battle.FloatMsg.OneActiveSkillMsg"
local ActorManagerInst = ActorManagerInst
local GameObjectPoolNoActiveInst = GameObjectPoolNoActiveInst
local UIBattleFloatView = BaseClass("UIBattleFloatView", UIBaseView)
local base = UIBaseView
local TheGameIds = TheGameIds
local UIManagerInst = UIManagerInst

local LENGTH_BAOJI = 1.1
local LENGTH_NORMAL = 0.8
local LENGTH_RECOVER = 1
local LENGTH_MISS = 0.6
local LENGTH_NUQI = 0.85
local LENGTH_BUFFMASK = 1.2
local LENGTH_SKILLMASK = 0.8

local ANIM_RECOVER = "Heal"
local ANIM_MISS = "miss"
local ANIM_NUQI = "BattleMsg_rage"
local ANIM_FLOATUP = "normal_floatup"
local ANIM_BAOJI_FLOATUP = "baoji_floatup"
local ANIM_GUWU = "BattleMsg_guwu"
local ANIM_FLOATSKILL = "Float_Skill"
local ANIM_FLOATUP2 = "damage"
local ANIM_SKILLSHOW = "damage"


local OFFSET_ON_HEAD = Vector3.New(0, 0.3, 0)
local MSG_SIZE = Vector3.New(1.2, 1.2, 1.2)
local MSG_BUFFMASK = Vector3.New(1.5, 1.5, 1.5)
local MSG_SKILLMASK = Vector3.New(0.6, 0.6, 0.6)
local OFFSET_POS_Y = 30
local baojiTextScale = Vector3.New(1, 1, 1)
local baojiImageDelta = Vector2.New(50, 50)

function UIBattleFloatView:OnCreate()
	base.OnCreate(self)

	self.m_mainCamera = CS.UnityEngine.Camera.main

	self.m_interval = 0
	self.m_id = 0
	self.m_dic = {}
	self.m_delList = {}
	self.m_attrEffectList = {}
	self.m_buffMaskList = {}
	self.m_skillMaskList = {}
	self.m_msgKeepDic = {}		-- {actor_id -> { msgs[], last_create_time} }
end

function UIBattleFloatView:OnDestroy()
	base.OnDestroy(self)

	self.m_mainCamera = nil
	
	self.m_msgKeepDic = nil
	for _, v in pairs(self.m_dic) do
		v:Delete()
	end
	self.m_dic = nil
	self.m_delList = nil
	self.m_attrEffectList = nil
	self.m_buffMaskList = nil
	self.m_skillMaskList = nil
end

function UIBattleFloatView:Update()
	self:UpdateAttrEffect()
   
	self.m_interval = self.m_interval + Time.deltaTime
	if self.m_interval >= 0.12 then
		local deltaS = self.m_interval
		self.m_interval = 0

		for id, v in pairs(self.m_dic) do
			local isEnd = v:Update(deltaS)
			if isEnd then
				table_insert(self.m_delList, id)
			end
		end

		if #self.m_delList > 0 then
			for i = 1, #self.m_delList do
				local id = self.m_delList[i]
				local v = self.m_dic[id]
				if v then
					self:RemoveAdjustMsg(v)
					v:Delete()
				end
				self.m_dic[id] = nil
			end
			self.m_delList = {}
		end
	end	

end

function UIBattleFloatView:OnAddListener()
	base.OnAddListener(self)
	self:AddUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_HP, self.OnShowHP)
	self:AddUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_NUQI, self.OnShowNuqi)
	self:AddUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_JUDGE, self.OnShowJudge)
	self:AddUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_ATTR, self.OnShowAttr)
	self:AddUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_MASK, self.ShowBuffMask)
	self:AddUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_INSCRIPANDHORSESKILL, self.FloatInscripAndHorseSkillName)
    self:AddUIListener(UIMessageNames.UIBATTLE_ACTOR_INTERRUPT_GUIDE, self.OnInterruptGuide)
	self:AddUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_SKILL_MASK, self.ShowSkillMask)
	self:AddUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_ACTIVE_SKILL, self.ShowActiveSkillName)
	self:AddUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_HURT_END, self.OnShowFloatHurt)
end

function UIBattleFloatView:OnRemoveListener()
	base.OnRemoveListener(self)
	self:RemoveUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_HP, self.OnShowHP)
	self:RemoveUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_NUQI, self.OnShowNuqi)
	self:RemoveUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_JUDGE, self.OnShowJudge)
	self:RemoveUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_ATTR, self.OnShowAttr)
	self:RemoveUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_MASK, self.ShowBuffMask)
	self:RemoveUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_INSCRIPANDHORSESKILL, self.FloatInscripAndHorseSkillName)
    self:RemoveUIListener(UIMessageNames.UIBATTLE_ACTOR_INTERRUPT_GUIDE, self.OnInterruptGuide)
	self:RemoveUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_SKILL_MASK, self.ShowSkillMask)
	self:RemoveUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_ACTIVE_SKILL, self.ShowActiveSkillName)
	self:RemoveUIListener(UIMessageNames.UIBATTLEFLOAT_SHOW_HURT_END, self.OnShowFloatHurt)
end

function UIBattleFloatView:MakeID()
	self.m_id = self.m_id + 1
	return self.m_id
end

function UIBattleFloatView:OnShowFloatHurt(actor, floatType)
	if not CtlBattleInst:IsInFight() then
        return
    end

	if not actor then
        return
	end 

	local bloodBar = actor:GetBloodBarTransform()
	if not bloodBar then
		return
	end

	if floatType == ACTOR_ATTR.HURT_OTHER_END_DOWN then 
		self:DoFloatGradient(Language.GetString(138), bloodBar, TheGameIds.AttrMsgPrefab)
	elseif floatType == ACTOR_ATTR.HURT_OTHER_END_UP then 
		self:DoFloatGradient(Language.GetString(139), bloodBar, TheGameIds.AttrMsgPrefab)
	elseif floatType == ACTOR_ATTR.BE_HURT_END_DOWN then 
		self:DoFloatGradient(Language.GetString(140), bloodBar, TheGameIds.AttrMsgPrefab)
	elseif floatType == ACTOR_ATTR.BE_HURT_END_UP then 
		self:DoFloatGradient(Language.GetString(141), bloodBar, TheGameIds.AttrMsgPrefab)
	end
end

function UIBattleFloatView:OnShowHP(actor, giver, hurtType, chgVal, judge)
	if not CtlBattleInst:IsInFight() then
        return
    end

	if not actor then
        return
	end
	
	if IsNull(self.m_mainCamera) then
		return
	end

    if chgVal > 0 then
		if judge == BattleEnum.ROUNDJUDGE_BAOJI then
            self:FloatBaoji(actor, chgVal)
		else
			self:FloatAddHP(actor, chgVal)
		end
		
    elseif chgVal < 0 then       
        if judge == BattleEnum.ROUNDJUDGE_BAOJI then
            self:FloatBaoji(actor, chgVal, hurtType)
        else
            self:FloatNormalHurt(actor, -chgVal, hurtType)
        end
    end
end

function UIBattleFloatView:ShowBuffMask(actor, count, statusType)
	if not CtlBattleInst:IsInFight() then
        return
    end
	if count <= 0 or not actor or not actor:IsLive() then
		return
	end

	local bloodBar = actor:GetBloodBarTransform()
	if not bloodBar then
		return
	end

	local ok, outV2 = GameUtility.TransformWorld2RectPos(self.m_mainCamera, UIManagerInst.UICamera, bloodBar, self.rectTransform, 0.1)
	local v_new = Vector3.New(outV2.x, outV2.y, 0)

	local actorID  = actor:GetActorID()
	for id,aID in pairs(self.m_buffMaskList) do
		if aID == actorID then
			local msgAdd = self.m_dic[id]
			if msgAdd then
				if msgAdd:GetDelay() > 0 and statusType == msgAdd:GetStatusType() then
					msgAdd:SetMaskText(string_format("x%d", count), v_new)
					return
				end

				self.m_buffMaskList[id] = nil
			end

			break
		end
	end

	local x,y,z = actor:GetPosition():GetXYZ()
	local actorPos = Vector3.New(x,0,z)
	
	GameObjectPoolNoActiveInst:GetGameObjectAsync(TheGameIds.BuffMaskPrefab,
		function(inst)
			inst.transform:SetParent(self.transform)
			local id = self:MakeID()
			local msg = OneBuffMaskMsg.New(inst, v_new, LENGTH_BUFFMASK, 0.3, string_format("x%d", count), 
			ANIM_FLOATUP, TheGameIds.BuffMaskPrefab, statusType ,MSG_BUFFMASK)			
			self.m_dic[id] = msg
			msg:Start()
			self.m_buffMaskList[id] = actorID
		end)
end

function UIBattleFloatView:ShowSkillMask(actor, count, type, path)
	if not CtlBattleInst:IsInFight() then
        return
    end
	if count == nil or not actor or not actor:IsLive() or type == nil then
		return
	end
 
	local bloodBar = actor:GetBloodBarTransform()
	if not bloodBar then
		return
	end

	local ok, outV2 = GameUtility.TransformWorld2RectPos(self.m_mainCamera, UIManagerInst.UICamera, bloodBar, self.rectTransform, 1)
	local v_new = Vector3.New(outV2.x, outV2.y, 0)
	local actorID  = actor:GetActorID()
	for id,aID in pairs(self.m_skillMaskList) do
		if aID == actorID then
			local msgAdd = self.m_dic[id]
			if msgAdd then
				if msgAdd:GetDelay() > 0 and msgAdd:GetSkillMaskType() == type and msgAdd:GetCount() < count then
					msgAdd:SetMaskText(count, v_new)
					return
				end

				self.m_skillMaskList[id] = nil
			end

			break
		end
	end

	GameObjectPoolNoActiveInst:GetGameObjectAsync(path,
		function(inst)
			inst.transform:SetParent(self.transform)
			local id = self:MakeID()
			local msg = OneSkillMaskMsg.New(inst, v_new, 0.5, 0.5, count, 
			ANIM_SKILLSHOW, path ,MSG_SKILLMASK, type)			
			self.m_dic[id] = msg
			msg:Start()
			self.m_skillMaskList[id] = actorID
		end)
end

function UIBattleFloatView:ShowActiveSkillName(actor, skillCfg)
	if not CtlBattleInst:IsInFight() then
        return
    end
	if not actor or not actor:IsLive() or not skillCfg  then
		return
	end

	local bloodBar = actor:GetBloodBarTransform()
	if not bloodBar then
		return
	end

	local ok, outV2 = GameUtility.TransformWorld2RectPos(self.m_mainCamera, UIManagerInst.UICamera, bloodBar, self.rectTransform, 0.1)
	local v_new = Vector3.New(outV2.x, outV2.y, 0)

	local actorCamp = actor:GetCamp()
	local prefabPath = nil
	if actorCamp == BattleEnum.ActorCamp_LEFT then
		prefabPath = TheGameIds.FloatSkillMsgLeftPrefab
	elseif actorCamp == BattleEnum.ActorCamp_RIGHT then
		prefabPath = TheGameIds.FloatSkillMsgRightPrefab
	end

	local x,y,z = actor:GetPosition():GetXYZ()
	local actorPos = Vector3.New(x,0,z)
	GameObjectPoolNoActiveInst:GetGameObjectAsync(prefabPath,
		function(inst)
			inst.transform:SetParent(self.transform)
			local id = self:MakeID()
			local msg = OneActiveSkillMsg.New(inst, v_new, 1, skillCfg.name, 
			ANIM_FLOATSKILL, prefabPath, actor:GetActorID(), baojiTextScale, self.transform)			
			self.m_dic[id] = msg
			msg:Start()
		end
	)
end

function UIBattleFloatView:OnShowNuqi(actor, chgVal, reason)
	if not CtlBattleInst:IsInFight() then
        return
    end
	if not actor then
        return
	end
	
	if IsNull(self.m_mainCamera) then
		return
	end

	if chgVal > 0 then
		self:FloatAddNuqi(actor, chgVal, reason)
	elseif chgVal < 0 then
		self:FloatLoseNuqi(actor, -chgVal, reason)
	end
end


function UIBattleFloatView:DoFloat(txt, bloodBar, anim, res_path, length, textScale, delay)
	length = length or 1
	delay = delay or 0
	
	textScale = textScale or Vector3.one

	local ok, outV2 = GameUtility.TransformWorld2RectPos(self.m_mainCamera, UIManagerInst.UICamera, bloodBar, self.rectTransform, 0)
	local v_new = Vector3.New(outV2.x, outV2.y + OFFSET_POS_Y, 0)
	
	GameObjectPoolNoActiveInst:GetGameObjectAsync(res_path,
		function(inst)
			
			inst.transform:SetParent(self.transform)
			local id = self:MakeID()
			local msg = OneFloatMsg.New(inst, v_new, length, delay, txt, anim, res_path, textScale)			
			self.m_dic[id] = msg
			msg:Start()
		end)
end

function UIBattleFloatView:DoFloatGradient(txt, bloodBar, res_path)
	local ok, outV2 = GameUtility.TransformWorld2RectPos(self.m_mainCamera, UIManagerInst.UICamera, bloodBar, self.rectTransform, 0)
	local v_new = Vector3.New(outV2.x, outV2.y - OFFSET_POS_Y, 0)
	
	GameObjectPoolNoActiveInst:GetGameObjectAsync(res_path,
		function(inst)
			inst.transform:SetParent(self.transform)
			local id = self:MakeID()
			local msg = OneFloatGradientMsg.New(inst, v_new, txt, res_path)			
			self.m_dic[id] = msg
			msg:Start()
		end)
end


function UIBattleFloatView:ShowOnHead(actorID, effectID)
	local tbl = self.m_attrEffectList[actorID]
	if not tbl then
		tbl = {}
		self.m_attrEffectList[actorID] = tbl
	end

	table_insert(tbl, effectID)
end

function UIBattleFloatView:UpdateAttrEffect()
	local isEmpty = true
	local EffectMgr = EffectMgr
	for actorID, tbl in pairs(self.m_attrEffectList) do
		isEmpty = false
		local count = 0
		for _, effectID in ipairs(tbl) do
			local offset = OFFSET_ON_HEAD + Vector3.New(0, 0.2 * count, 0)
			count = count + 1
			EffectMgr:AddEffect(actorID, effectID, 0, nil, nil, offset)
		end
	end

	if not isEmpty then
		self.m_attrEffectList = {}
	end
end

function UIBattleFloatView:OnShowAttr(actor, attr, oldVal, newVal)
	if not CtlBattleInst:IsInFight() then
        return
    end
	if not actor then
		return
	end

	local bloodBar = actor:GetBloodBarTransform()
	if not bloodBar then
		return
	end
	
	if attr == ACTOR_ATTR.FIGHT_PHY_ATK or attr == ACTOR_ATTR.FIGHT_MAGIC_ATK then
		if newVal > oldVal then
			-- 攻击上升
			self:ShowOnHead(actor:GetActorID(), 21002)
		elseif newVal < oldVal then
			-- 攻击下降
			self:ShowOnHead(actor:GetActorID(), 21001)
		end

		local baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
		if attr == ACTOR_ATTR.FIGHT_MAGIC_ATK then
			baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
		end

		if oldVal > baseVal and newVal <= baseVal then
			-- 攻击上升结束
			self:DoFloatGradient(Language.GetString(122), bloodBar, TheGameIds.AttrMsgPrefab)
		elseif oldVal < baseVal and newVal >= baseVal then
			-- 攻击下降结束
			self:DoFloatGradient(Language.GetString(123), bloodBar, TheGameIds.AttrMsgPrefab)
		end

	elseif attr == ACTOR_ATTR.PHY_HURTOTHER_MULTIPLE or attr == ACTOR_ATTR.MAGIC_HURTOTHER_MULTIPLE then
		if newVal > oldVal then
			-- 攻击上升
			self:ShowOnHead(actor:GetActorID(), 21002)
		elseif newVal < oldVal then
			-- 攻击下降
			self:ShowOnHead(actor:GetActorID(), 21001)
		end

		local baseVal = actor:GetData():GetProbValue(ACTOR_ATTR.PHY_HURTOTHER_MULTIPLE)
		if attr == ACTOR_ATTR.MAGIC_HURTOTHER_MULTIPLE then
			baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.MAGIC_HURTOTHER_MULTIPLE)
		end

		if oldVal > baseVal and newVal <= baseVal then
			-- 攻击上升结束
			self:DoFloatGradient(Language.GetString(122), bloodBar, TheGameIds.AttrMsgPrefab)
		elseif oldVal < baseVal and newVal >= baseVal then
			self:DoFloatGradient(Language.GetString(123), bloodBar, TheGameIds.AttrMsgPrefab)
		end

	elseif attr == ACTOR_ATTR.FIGHT_PHY_DEF or attr == ACTOR_ATTR.FIGHT_MAGIC_DEF then
		if newVal > oldVal then
			-- 防御上升
			self:ShowOnHead(actor:GetActorID(), 21010)
		elseif newVal < oldVal then
			-- 防御下降
			self:ShowOnHead(actor:GetActorID(), 21009)
		end

		local baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
		if attr == ACTOR_ATTR.FIGHT_MAGIC_DEF then
			baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
		end

		if oldVal > baseVal and newVal <= baseVal then
			-- 防御上升结束
			self:DoFloatGradient(Language.GetString(124), bloodBar, TheGameIds.AttrMsgPrefab)
		elseif oldVal < baseVal and newVal >= baseVal then
			self:DoFloatGradient(Language.GetString(125), bloodBar, TheGameIds.AttrMsgPrefab)
		end

	elseif attr == ACTOR_ATTR.FIGHT_ATKSPEED then
		if newVal > oldVal then
			-- 攻速上升
			self:ShowOnHead(actor:GetActorID(), 21004)
		elseif newVal < oldVal then
			-- 攻速下降
			self:ShowOnHead(actor:GetActorID(), 21003)
		end

		local baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
		if oldVal > baseVal and newVal <= baseVal then
			-- 攻速上升结束
			self:DoFloatGradient(Language.GetString(126), bloodBar, TheGameIds.AttrMsgPrefab)
		elseif oldVal < baseVal and newVal >= baseVal then
			self:DoFloatGradient(Language.GetString(127), bloodBar, TheGameIds.AttrMsgPrefab)
		end

	elseif attr == ACTOR_ATTR.FIGHT_MINGZHONG or attr == ACTOR_ATTR.MINGZHONG_PROB_CHG then
		if newVal > oldVal then
			-- 命中上升
			self:ShowOnHead(actor:GetActorID(), 21012)			
		elseif newVal < oldVal then
			-- 命中下降
			self:ShowOnHead(actor:GetActorID(), 21011)				
		end

		local baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_MINGZHONG)
		if oldVal > baseVal and newVal <= baseVal then
			-- 上升结束
			self:DoFloatGradient(Language.GetString(128), bloodBar, TheGameIds.AttrMsgPrefab)
		elseif oldVal < baseVal and newVal >= baseVal then
			-- 下降结束
			self:DoFloatGradient(Language.GetString(129), bloodBar, TheGameIds.AttrMsgPrefab)
		end

	elseif attr == ACTOR_ATTR.FIGHT_SHANBI or attr == ACTOR_ATTR.SNAHBI_PROB_CHG then
		if newVal > oldVal then
			-- 闪避上升
			self:ShowOnHead(actor:GetActorID(), 21006)	
		elseif newVal < oldVal then
			-- 闪避下降
			self:ShowOnHead(actor:GetActorID(), 21005)	
		end

		local baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_SHANBI)
		if oldVal > baseVal and newVal <= baseVal then
			-- 上升结束
			self:DoFloatGradient(Language.GetString(130), bloodBar, TheGameIds.AttrMsgPrefab)
		elseif oldVal < baseVal and newVal >= baseVal then
			-- 下降结束
			self:DoFloatGradient(Language.GetString(131), bloodBar, TheGameIds.AttrMsgPrefab)
		end

	elseif attr == ACTOR_ATTR.FIGHT_PHY_BAOJI or attr == ACTOR_ATTR.FIGHT_MAGIC_BAOJI or attr == ACTOR_ATTR.MAGIC_BAOJI_PROB_CHG or attr == ACTOR_ATTR.PHY_BAOJI_PROB_CHG then
		if newVal > oldVal then
			-- 暴击上升
			self:ShowOnHead(actor:GetActorID(), 21008)	
		elseif newVal < oldVal then
			-- 暴击下降
			self:ShowOnHead(actor:GetActorID(), 21007)	
		end

		local baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_BAOJI)
		if attr == ACTOR_ATTR.FIGHT_MAGIC_BAOJI then
			baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_BAOJI)
		end

		if oldVal > baseVal and newVal <= baseVal then
			-- 上升结束
			self:DoFloatGradient(Language.GetString(132), bloodBar, TheGameIds.AttrMsgPrefab)
		elseif oldVal < baseVal and newVal >= baseVal then
			self:DoFloatGradient(Language.GetString(133), bloodBar, TheGameIds.AttrMsgPrefab)
		end

	elseif attr == ACTOR_ATTR.FIGHT_BAOJI_HURT then
		if newVal > oldVal then
			-- 暴伤上升
			self:ShowOnHead(actor:GetActorID(), 21014)	
		end

		local baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_BAOJI_HURT)
		if oldVal > baseVal and newVal <= baseVal then
			-- 上升结束
			self:DoFloatGradient(Language.GetString(134), bloodBar, TheGameIds.AttrMsgPrefab)
		end

	elseif attr == ACTOR_ATTR.FIGHT_PHY_SUCKBLOOD or attr == ACTOR_ATTR.FIGHT_MAGIC_SUCKBLOOD then
		if newVal > oldVal then
			-- 吸血上升
			self:ShowOnHead(actor:GetActorID(), 21013)	
		end

		local baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_SUCKBLOOD)
		if attr == ACTOR_ATTR.FIGHT_MAGIC_SUCKBLOOD then
			baseVal = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_SUCKBLOOD)
		end

		if oldVal > baseVal and newVal <= baseVal then
			-- 上升结束
			self:DoFloatGradient(Language.GetString(136), bloodBar, TheGameIds.AttrMsgPrefab)
		end
	end
end



function UIBattleFloatView:WPosToLocalPos(bloodBar)
	local ok, outV2 = GameUtility.TransformWorld2RectPos(self.m_mainCamera, UIManagerInst.UICamera, bloodBar, self.rectTransform, 0)
	return Vector3.New(outV2.x, outV2.y + OFFSET_POS_Y, 0)
end


function UIBattleFloatView:DoFloatNum(val, uiPos, anim, length, name_part, actorID)
	length = length or 1
	
	GameObjectPoolNoActiveInst:GetGameObjectAsync(TheGameIds.WorldArtFont,
		function(inst)
			if IsNull(inst) then
				return
			end
			local id = self:MakeID()
			local msg = WorldArtFont.New(inst, self.transform, nil, uiPos, anim, length, TheGameIds.WorldArtFont)			
			self.m_dic[id] = msg
			msg:AddArtFontNumber(val, name_part)
			msg:Start()
			self:AdjustMsg(actorID, msg)
		end)
end


function UIBattleFloatView:FloatAddHP(actor, chgVal)
	local bloodBar = actor:GetBloodBarTransform()
	if not bloodBar then
		return
	end

	local uiPos = self:WPosToLocalPos(bloodBar)
	uiPos = Vector3.New(uiPos.x, uiPos.y + 25, uiPos.z)
	self:DoFloatNum(chgVal, uiPos, ANIM_RECOVER, LENGTH_RECOVER, "number4", actor:GetActorID())
end


function UIBattleFloatView:FloatAddNuqi(actor, chgVal, reason)

	local bloodBar = actor:GetBloodBarTransform()
	if not bloodBar then
		return
	end

	local uiPos = self:WPosToLocalPos(bloodBar)

	local img_str = ""
	if reason == BattleEnum.NuqiReason_KILL then
		img_str = "zhandou128.png"
	elseif reason == BattleEnum.NuqiReason_SKILL_RECOVER then
		img_str = "zhandou127.png"
	else
		return
	end

	length = length or 1
	local name_part = "number5"

	GameObjectPoolNoActiveInst:GetGameObjectAsync(TheGameIds.WorldArtFont,
		function(inst)
			if IsNull(inst) then
				return
			end
			local id = self:MakeID()
			local msg = WorldArtFont.New(inst, self.transform, nil, uiPos, ANIM_NUQI, LENGTH_NUQI, TheGameIds.WorldArtFont)			
			self.m_dic[id] = msg
			msg:SetLineSpace()
			msg:AddArtFontImg(img_str, 60)
			msg:AddArtFontImg("zhandou58.png", 28)
			msg:AddArtFontNumber(chgVal, name_part)
			msg:Start()
			self:AdjustMsg(actor:GetActorID(), msg)
		end)
end

function UIBattleFloatView:FloatLoseNuqi(actor, chgVal, reason)
	if reason == BattleEnum.NuqiReason_STOLEN then

		local bloodBar = actor:GetBloodBarTransform()
		if not bloodBar then
			return
		end

		local uiPos = self:WPosToLocalPos(bloodBar)

		GameObjectPoolNoActiveInst:GetGameObjectAsync(TheGameIds.WorldArtFont,
			function(inst)
				if IsNull(inst) then
					return
				end
				local id = self:MakeID()
				local msg = WorldArtFont.New(inst, self.transform, nil, uiPos, ANIM_NUQI, LENGTH_NUQI, TheGameIds.WorldArtFont)			
				self.m_dic[id] = msg
				msg:AddArtFontImg("zhandou34.png", 14)
				msg:AddArtFontNumber(chgVal, "number6")
				msg:Start()
				self:AdjustMsg(actor:GetActorID(), msg)
		end)
	end
end

function UIBattleFloatView:FloatNormalHurt(actor, chgVal, hurtType)
	local bloodBar = actor:GetBloodBarTransform()
	if not bloodBar then
		return
	end

	local uiPos = self:WPosToLocalPos(bloodBar)
	local name_part = ""

	if hurtType == BattleEnum.HURTTYPE_PHY_HURT then
		name_part = "number"
	elseif hurtType == BattleEnum.HURTTYPE_MAGIC_HURT then
		name_part = "number1"
	else
		name_part = "number2"
	end
	
    self:DoFloatNum(chgVal, uiPos, ANIM_FLOATUP2, LENGTH_NORMAL, name_part, actor:GetActorID())
end


function UIBattleFloatView:FloatBaoji(actor, chgVal, hurtType)
	local bloodBar = actor:GetBloodBarTransform()
	if not bloodBar then
		return
	end
	
	local ok, outV2 = GameUtility.TransformWorld2RectPos(self.m_mainCamera, UIManagerInst.UICamera, bloodBar, self.rectTransform, 0)

	local v_new = Vector3.New(outV2.x, outV2.y + 50, 0)

	local name_part = ""
	local img_str = ""
	if chgVal < 0 then
		if hurtType == BattleEnum.HURTTYPE_PHY_HURT then
			name_part = "number"
			img_str = "baoji3.png"
		elseif hurtType == BattleEnum.HURTTYPE_MAGIC_HURT then
			name_part = "number1"
			img_str = "baoji2.png"
		else
			name_part = "number2"
			img_str = "baoji.png"
		end

		chgVal = -chgVal
		
	elseif chgVal > 0 then
		name_part = "number4"
		img_str = "baoji4.png"
	end

	GameObjectPoolNoActiveInst:GetGameObjectAsync(TheGameIds.WorldArtFont,
		function(inst)
			if IsNull(inst) then
				return
			end
			local id = self:MakeID()
			local msg = WorldArtFont.New(inst, self.transform, nil, v_new, ANIM_BAOJI_FLOATUP, LENGTH_BAOJI, TheGameIds.WorldArtFont)			
			self.m_dic[id] = msg
			msg:AddArtFontImg(img_str, 46, baojiImageDelta)
			msg:AddArtFontNumber(chgVal, name_part)
			msg:Start()
			self:AdjustMsg(actor:GetActorID(), msg)
		end)
end

function UIBattleFloatView:AdjustMsg(actorID, msg)
	local l = self.m_msgKeepDic[actorID]
	if not l then
		l = { msgs = {}, last_create_time = 0 }
		self.m_msgKeepDic[actorID] = l
	end


	local now = Time.realtimeSinceStartup
	if now - l.last_create_time < 0.08 then
		for _, v in ipairs(l.msgs) do
			v:MoveUp(70)
		end
	end

	msg:SetOwner(actorID)

	l.last_create_time = now
	table_insert(l.msgs, msg)
end

function UIBattleFloatView:RemoveAdjustMsg(msg)
	if msg.GetOwner then
		local actorID = msg:GetOwner()
		local l = self.m_msgKeepDic[actorID]
		if l then
			for i, v in ipairs(l.msgs) do
				if v == msg then
					table_remove(l.msgs, i)
					return
				end
			end
		end
	end
end

function UIBattleFloatView:OnShowJudge(actor, judge, reason)
	if not CtlBattleInst:IsInFight() then
        return
    end
	if not actor then
		return
	end
	
	if IsNull(self.m_mainCamera) then
		return
	end

	local bloodBar = actor:GetBloodBarTransform()
	if not bloodBar then
		return
	end

	local img_str = ""
	local width = 72
	if judge == BattleEnum.ROUNDJUDGE_NON_MINGZHONG then
		img_str = "zhandou73.png"
		width = 108
	elseif judge == BattleEnum.ROUNDJUDGE_SHANBI then
		img_str = "zhandou72.png"
		width = 60
	elseif judge == BattleEnum.ROUNDJUDGE_GEDANG then
		img_str = "zhandou71.png"
	elseif judge == BattleEnum.ROUNDJUDGE_IMMUNE then
		img_str = "zhandou70.png"
	elseif judge == BattleEnum.ROUNDJUDGE_XISHOU then
		img_str = "zhandou70.png"
	end

	local uiPos = self:WPosToLocalPos(bloodBar)
	
	GameObjectPoolNoActiveInst:GetGameObjectAsync(TheGameIds.WorldArtFont,
		function(inst)
			if IsNull(inst) then
				return
			end
			local id = self:MakeID()
			local msg = WorldArtFont.New(inst, self.transform, nil, uiPos, ANIM_MISS, LENGTH_MISS, TheGameIds.WorldArtFont)			
			self.m_dic[id] = msg
			msg:AddArtFontImg(img_str, width)
			msg:Start()
		end)
 end


 function UIBattleFloatView:FloatInscripAndHorseSkillName(actor, giver)
	if not CtlBattleInst:IsInFight() then
        return
    end
	if not giver then
		return
	end

	local bloodBar = actor:GetBloodBarTransform()
	if not bloodBar then
		return
	end
	
	local skillCfg = ConfigUtil.GetInscriptionAndHorseSkillCfgByID(giver.skillID)
    if not skillCfg then
        return
    end
	
	self:DoFloat(skillCfg.name, bloodBar, ANIM_GUWU, TheGameIds.FloatMsgPrefab, 1.34)
end

function UIBattleFloatView:OnInterruptGuide(actorID)
	if not CtlBattleInst:IsInFight() then
        return
    end
	local actor = ActorManagerInst:GetActor(actorID)
	if actor and actor:IsLive() then
		local bloodBar = actor:GetBloodBarTransform()
		if not bloodBar then
			return
		end

		self:DoFloat(Language.GetString(3519), bloodBar, ANIM_GUWU, TheGameIds.FloatMsgPrefab, 1.34)
	end
end


return UIBattleFloatView
		

