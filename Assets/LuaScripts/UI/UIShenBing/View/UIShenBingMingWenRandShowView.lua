

local UIShenBingMingWenRandShowView = BaseClass("UIShenBingMingWenRandShowView", UIBaseView)
local base = UIBaseView


local GameUtility = CS.GameUtility
local DOTween = CS.DOTween.DOTween
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local UIUtil = UIUtil
local table_sort = table.sort
local math_ceil = math.ceil

local TweenAlphaTime = 0.3
local ScaleTime = 0.2
local RandTime = 1.5
local MingQianScaleTime = 0.4

function UIShenBingMingWenRandShowView:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function UIShenBingMingWenRandShowView:InitView()
    local inscriptionImgTran, inscriptionImg2Tran, inscriptionImg3Tran

    inscriptionImgTran, inscriptionImg2Tran, inscriptionImg3Tran,
    self.m_closeBtn = UIUtil.GetChildTransforms(self.transform, {
        "MingWenGrid/InscriptionImg",
        "MingWenGrid/InscriptionImg2",
        "MingWenGrid/InscriptionImg3",
        "CloseBtn"
    })

    self.m_inscriptionImgTranList = {
        inscriptionImgTran, inscriptionImg2Tran, inscriptionImg3Tran
    }

    local inscriptionImg = self:AddComponent(UIImage, inscriptionImgTran.gameObject, ImageConfig.MingWen)
    local inscriptionImg2 = self:AddComponent(UIImage, inscriptionImg2Tran.gameObject, ImageConfig.MingWen)
    local inscriptionImg3 = self:AddComponent(UIImage, inscriptionImg3Tran.gameObject, ImageConfig.MingWen)

    self.m_closeBtnImg = UIUtil.FindImage(self.m_closeBtn)

    self.m_inscriptionImgList = {
        inscriptionImg, inscriptionImg2, inscriptionImg3
    }

    self.m_randTime = 0
    self.m_intervalTime = 0.1
    self.m_alphaTime = TweenAlphaTime
    self.m_state = 0
end


function UIShenBingMingWenRandShowView:OnEnable(...)
    base.OnEnable(self, ...)

    _, self.m_shenbingData = ...
    if self.m_shenbingData then

        for i = 1, #self.m_inscriptionImgTranList do
            self.m_inscriptionImgTranList[i].gameObject:SetActive(false)
            GameUtility.SetLocalScale(self.m_inscriptionImgTranList[i], 1, 1, 1)
        end

        self.m_randTime = RandTime
        self.m_intervalTime = 0
        self.m_alphaTime = TweenAlphaTime
        self.m_state = 1
        self.m_mingqianScaleTime = MingQianScaleTime
        UIUtil.DoGraphicTweenAlpha(self.m_closeBtnImg, TweenAlphaTime, 0, 1, 0, 0)
    end
end

function UIShenBingMingWenRandShowView:Update()
    if self.m_state == 1 then
        self.m_alphaTime = self.m_alphaTime - Time.deltaTime
        if self.m_alphaTime <= 0 then
            self.m_state = 2
        end

    elseif self.m_state == 2 then
        local newMingwenList = self.m_shenbingData.m_tmp_new_mingwen
        if newMingwenList then
            for i = 1, #self.m_inscriptionImgTranList do
                local isShow = i <= #newMingwenList
                self.m_inscriptionImgTranList[i].gameObject:SetActive(isShow)
                if isShow then
                    self.m_inscriptionImgTranList[i].localScale = Vector3.one * 0.01
                    DOTweenShortcut.DOScale(self.m_inscriptionImgTranList[i], Vector3.one, ScaleTime)
                end
            end
        end
        self.m_state = 3

    elseif self.m_state == 3 then
        self.m_randTime = self.m_randTime - Time.deltaTime
        if self.m_randTime <= 0 then

            if not self.m_shenbingData then
                return
            end
    
            local mingwenList = self.m_shenbingData.m_tmp_new_mingwen
            if not mingwenList then
                return
            end

            for i, v in ipairs(mingwenList) do
                local mingwen = v
                local mingwenCfg = ConfigUtil.GetShenbingInscriptionCfgByID(mingwen.mingwen_id)
                if mingwenCfg then
				
                    self.m_inscriptionImgList[i]:SetAtlasSprite(math_ceil(mingwen.mingwen_id)..".png", true)
                    local trans = self.m_inscriptionImgList[i].transform

                    DOTweenShortcut.DOKill(trans, true)
                    local tweener = DOTweenShortcut.DOScale(trans, 1.5, 0.2)
                    local tweener2 = DOTweenShortcut.DOScale(trans, 0.01, 0.2)
                    local sequence = DOTween.NewSequence()
                    DOTweenSettings.Append(sequence, tweener)
                    DOTweenSettings.Append(sequence, tweener2)
                end
            end

            self.m_state = 4
            return
        end

        self.m_intervalTime = self.m_intervalTime - Time.deltaTime
        if self.m_intervalTime > 0 then
            return
        end
        self.m_intervalTime = 0.1
    
        if not self.m_shenbingData then
            return
        end

        local mingwenList = self.m_shenbingData.m_tmp_new_mingwen
        if not mingwenList then
            return
        end

        table_sort(mingwenList, function(l,r)
            local qualityL = ConfigUtil.GetShenbingInscriptionCfgByID(l.mingwen_id).quality
            local qualityR = ConfigUtil.GetShenbingInscriptionCfgByID(r.mingwen_id).quality
            
            if qualityL ~= qualityR then
                return qualityL < qualityR
            end
        end)
    
        for i, v in ipairs(mingwenList) do
            local mingwen = v
            local mingwenCfg = ConfigUtil.GetShenbingInscriptionCfgByID(mingwen.mingwen_id)
            if mingwenCfg then
                local shenbingInscriptionCfgList = ConfigUtil.GetShenbingInscriptionCfgListByQuality(mingwenCfg.quality)
                if shenbingInscriptionCfgList and #shenbingInscriptionCfgList > 0 then
                    if i <= #self.m_inscriptionImgTranList and self.m_inscriptionImgTranList[i].gameObject.activeSelf == true then
                        local index = math.random(1, #shenbingInscriptionCfgList)
                        self.m_inscriptionImgList[i]:SetAtlasSprite(math_ceil(shenbingInscriptionCfgList[index].id)..".png", true)
                    end
                end
            end
        end

    elseif self.m_state == 4 then
        self.m_mingqianScaleTime = self.m_mingqianScaleTime - Time.deltaTime
        if self.m_mingqianScaleTime < 0 then
            self.m_state = 5
        end

    elseif self.m_state == 5 then
        UIUtil.DoGraphicTweenAlpha(self.m_closeBtnImg, TweenAlphaTime, 1, 0.1, 0, 0)
        self.m_state = 6
        self.m_alphaTime = TweenAlphaTime

    elseif self.m_state == 6 then
        self.m_alphaTime = self.m_alphaTime - Time.deltaTime
        if self.m_alphaTime <= 0 then
            self:CloseSelf()
        end
    end
end


return UIShenBingMingWenRandShowView