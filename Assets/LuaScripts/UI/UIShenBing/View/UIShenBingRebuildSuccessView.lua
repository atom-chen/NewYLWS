
local string_format = string.format
local talbe_insert = table.insert
local table_sort = table.sort

local ShenBingMgr = Player:GetInstance():GetShenBingMgr()
local WuJiangMgr = Player:GetInstance():GetWujiangMgr()
local ShenBingSuccessItem = require "UI.UIShenBing.View.ShenBingSuccessItem"
local GameObject = CS.UnityEngine.GameObject
local Language = Language
local UIUtil = UIUtil

local UIShenBingRebuildSuccessView = BaseClass("UIShenBingRebuildSuccessView", UIBaseView)
local base = UIBaseView

function UIShenBingRebuildSuccessView:OnCreate()
    base.OnCreate(self)
    local titleText, saveBtnText, laterBtnText, useNewBtnText
    titleText, saveBtnText, laterBtnText, useNewBtnText = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/titleImage/titleText",
        "BgRoot/ContentRoot/BtnGrid/SaveWornButton/Text",
        "BgRoot/ContentRoot/BtnGrid/LaterButton/Text",
        "BgRoot/ContentRoot/BtnGrid/UseNewButton/Text"
    })

    self.m_mingwenPrefab, self.m_saveWornBtn, self.m_laterBtn, self.m_useNewBtn, self.m_mingwenGridTr = UIUtil.GetChildTransforms(self.transform, {
        "BgRoot/ContentRoot/RebuildInfoPrefab",
        "BgRoot/ContentRoot/BtnGrid/SaveWornButton",
        "BgRoot/ContentRoot/BtnGrid/LaterButton",
        "BgRoot/ContentRoot/BtnGrid/UseNewButton",
        "BgRoot/ContentRoot/Grid"
    })

    self.m_mingwenPrefab =  self.m_mingwenPrefab.gameObject
    self.m_saveWornBtn = self.m_saveWornBtn.gameObject
    self.m_laterBtn = self.m_laterBtn.gameObject
    self.m_useNewBtn = self.m_useNewBtn.gameObject
    titleText.text = Language.GetString(2925)
    saveBtnText.text = Language.GetString(2926)
    laterBtnText.text = Language.GetString(2928)
    useNewBtnText.text = Language.GetString(2927)

    
    self.m_newMingwenList = {}
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_saveWornBtn, onClick)
    UIUtil.AddClickEvent(self.m_laterBtn, onClick)
    UIUtil.AddClickEvent(self.m_useNewBtn, onClick)
end

function UIShenBingRebuildSuccessView:OnClick(go)
    if go == self.m_saveWornBtn then
        WuJiangMgr:ReqConfirmShenBingRebuild(1, self.m_shenbingIndex)
        self:CloseSelf()

    elseif go == self.m_laterBtn then
        WuJiangMgr:ReqConfirmShenBingRebuild(0, self.m_shenbingIndex)
        self:CloseSelf()
        UIManagerInst:CloseWindow(UIWindowNames.UIShenBingRebuild)
        
    elseif go == self.m_useNewBtn then
        WuJiangMgr:ReqConfirmShenBingRebuild(2, self.m_shenbingIndex)
        self:CloseSelf()
    end
end

function UIShenBingRebuildSuccessView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_saveWornBtn)
    UIUtil.RemoveClickEvent(self.m_laterBtn)
    UIUtil.RemoveClickEvent(self.m_useNewBtn)
    base.OnDestroy(self)
end

function UIShenBingRebuildSuccessView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, shenbingData = ...
    if shenbingData then
        self.m_shenbingIndex = shenbingData.m_index or -1
        local newMingwenList = shenbingData.m_tmp_new_mingwen
        table_sort(newMingwenList, function(l,r)
            local qualityL = ConfigUtil.GetShenbingInscriptionCfgByID(l.mingwen_id).quality
            local qualityR = ConfigUtil.GetShenbingInscriptionCfgByID(r.mingwen_id).quality
            
            if qualityL ~= qualityR then
                return qualityL < qualityR
            end
        end)
        for i = 1, #newMingwenList do
            local item = self.m_newMingwenList[i]
            if not item then
                local go = GameObject.Instantiate(self.m_mingwenPrefab)
                item = ShenBingSuccessItem.New(go, self.m_mingwenGridTr)
                talbe_insert(self.m_newMingwenList, item)
            end
            item:SetData(shenbingData, newMingwenList[i])
        end
    end
end

function UIShenBingRebuildSuccessView:OnDisable()
    for i, v in ipairs(self.m_newMingwenList) do
        v:Delete()
    end
    self.m_newMingwenList = {}

    base.OnDisable(self)
end

return UIShenBingRebuildSuccessView