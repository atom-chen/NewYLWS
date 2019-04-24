local Language = Language
local UILogicUtil = UILogicUtil
local ConfigUtil = ConfigUtil
local CtlBattleInst = CtlBattleInst
local BattleWujiangItem = require("UI.UIBattle.View.BattleWujiangItem")
local BenchWujiangItem = BaseClass("BenchWujiangItem", BattleWujiangItem)
local base = BattleWujiangItem
local BattleEnum = BattleEnum

function BenchWujiangItem:SetData(wujiangData, viewBaseOrder)
    self.m_wujiangData = wujiangData
    self.m_viewBaseOrder = viewBaseOrder
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_wujiangData.wujiangID)
    if wujiangCfg then
        self.m_iconImage:SetAtlasSprite(wujiangCfg.sIcon)
        UILogicUtil.SetWuJiangFrame(self.m_frameImage, wujiangCfg.rare)
    end

    self:HideBloodAndNuqi()
end

function BenchWujiangItem:OnClick(go, x, y)
    if go.name == "icon" then
        local ctlbattle = CtlBattleInst
        if ctlbattle:IsPause() or ctlbattle:IsFramePause() then
            return
        end

        if not ctlbattle:IsInFight() then
            UILogicUtil.FloatAlert(Language.GetString(303))
            return
        end

        if not ctlbattle:GetLogic():CanReplaceWujiang() then
            return
        end
        
        local roleCfg = ConfigUtil.GetWujiangCfgByID(self.m_wujiangData.wujiangID)
        if roleCfg then
            ctlbattle:FramePause()
            ctlbattle:Pause(BattleEnum.PAUSEREASON_EVERY, 0)
            local content = string.format(Language.GetString(301), roleCfg.sName)
            UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(302),content, 
                                                Language.GetString(10), Bind(self, self.OnConfirm), Language.GetString(5), Bind(self, self.OnCancel))
        end
    end
end

function BenchWujiangItem:OnConfirm()
    FrameCmdFactory:GetInstance():ProductCommand(BattleEnum.FRAME_CMD_TYPE_CREATE_BENCH, self.m_wujiangData.wujiangID)
    CtlBattleInst:FrameResume()
    CtlBattleInst:Resume(BattleEnum.PAUSEREASON_EVERY)
end

function BenchWujiangItem:OnCancel()
    CtlBattleInst:FrameResume()
    CtlBattleInst:Resume(BattleEnum.PAUSEREASON_EVERY)
end

function BenchWujiangItem:OnDestroy()
    self:ShowBloodAndNuqi()

    base.OnDestroy(self)
end

function BenchWujiangItem:GetWujiangID()
    return self.m_wujiangData.wujiangID
end

return BenchWujiangItem

