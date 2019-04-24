local table_insert = table.insert
local table_remove = table.remove
local string_format = string.format
local Utils = Utils
local Vector3 = Vector3
local Quaternion = Quaternion
local CommonDefine = CommonDefine
local PreloadHelper = PreloadHelper
local Shader = CS.UnityEngine.Shader
local Type_Renderer = typeof(CS.UnityEngine.Renderer)
local FlyCurve = CS.FlyCurve
local GameUtility = CS.GameUtility

local ScaleSize = Vector3.New(2, 2, 2)
local Rotation = Quaternion.Euler(-90, 150, 0)

local BaseBattleLogicComponent = require "GameLogic.Battle.Component.BaseBattleLogicComponent"
local InscriptionCopyLogicComponent = BaseClass("InscriptionCopyLogicComponent", BaseBattleLogicComponent)
  
local BaoxiangPath = "Effect/Prefab/Battle/baoxiang.prefab"


local PrefabMap = {
    [CommonDefine.MingQian_SubType_Tiao] = "Models/MaJiang/yitiao.prefab",
    [CommonDefine.MingQian_SubType_Tong] = "Models/MaJiang/yibing.prefab",
    [CommonDefine.MingQian_SubType_Wan] = "Models/MaJiang/yiwan.prefab",
    [CommonDefine.MingQian_SubType_Dong] = "Models/MaJiang/dong.prefab",
    [CommonDefine.MingQian_SubType_Nan] = "Models/MaJiang/nan.prefab",
    [CommonDefine.MingQian_SubType_Xi] = "Models/MaJiang/xi.prefab",
    [CommonDefine.MingQian_SubType_Bei] = "Models/MaJiang/bei.prefab",
    [CommonDefine.MingQian_SubType_Zhong] = "Models/MaJiang/hongzhong.prefab",
    [CommonDefine.MingQian_SubType_Fa] = "Models/MaJiang/fa.prefab",
    [CommonDefine.MingQian_SubType_Bai] = "Models/MaJiang/baiban.prefab",
}

function InscriptionCopyLogicComponent:__init(copyLogic)
    self.m_boxList = {}
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.INSCRIPTIONCOPY_RSP_FINISH_INSCRIPTIONCOPY, Bind(self, self.RspBattleFinish))
end

function InscriptionCopyLogicComponent:__delete()
    HallConnector:GetInstance():ClearHandler(MsgIDDefine.INSCRIPTIONCOPY_RSP_FINISH_INSCRIPTIONCOPY)

    for i = 1, #self.m_boxList do
        local v = self.m_boxList[i]
        local go, pos, t = v[1], v[2], v[3]
        GameObjectPoolInst:RecycleGameObject(BaoxiangPath, go)  
    end
    self.m_boxList = nil
end
  
function InscriptionCopyLogicComponent:ShowBattleUI()
    UIManagerInst:OpenWindow(UIWindowNames.UIBattleInscriptionMain)
    BaseBattleLogicComponent.ShowBloodUI(self)
end

function InscriptionCopyLogicComponent:ReqBattleFinish(copyID, playerWin)
    local msg_id = MsgIDDefine.INSCRIPTIONCOPY_REQ_FINISH_INSCRIPTIONCOPY
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = copyID
    msg.finish_result = self.m_logic:GetBattleResult()

    local frameCmdList = CtlBattleInst:GetFrameCmdList()

    PBUtil.ConvertCmdListToProto(msg.battle_info.cmd_list, frameCmdList)
    self:GenerateResultInfoProto(msg.battle_result)
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function InscriptionCopyLogicComponent:RspBattleFinish(msg_obj)
	local result = msg_obj.result
	if result ~= 0 then
		Logger.LogError('InscriptionCopyLogicComponent failed: '.. result)
		return
    end

    local isEqual = self:CompareBattleResult(msg_obj.battle_result)
    if not isEqual then
        Logger.LogError("Do not sync, report frame data to server")
        self:ReqReportFrameData()
    end

    local finish_result = msg_obj.finish_result

    UIManagerInst:CloseWindow(UIWindowNames.UIBattleInscriptionMain)
    UIManagerInst:OpenWindow(UIWindowNames.UIInscriptionSettlement, msg_obj)
end


function InscriptionCopyLogicComponent:GetDropPrefabPath(dropType)
    return PrefabMap[dropType]
end

function InscriptionCopyLogicComponent:Drop(aroundPos, dropType, count)
    local path = self:GetDropPrefabPath(dropType)
    if not path then
        return
    end

    local diePos = Vector3.New(aroundPos.x, aroundPos.y, aroundPos.z)
    GameObjectPoolInst:GetGameObjectAsync2(path, count, function(objs)
        if not objs then
            return
        end

        local randPos = Utils.RandPos
        local RandomBetween = Utils.RandomBetween

        for i = 1, #objs do
            local p = randPos(diePos, -2, 2)
            p.y = p.y + RandomBetween(10, 50) / 1000 --0.01 ~ 0.05
    
            local jumpPoint = (p - diePos) / 2
            jumpPoint.y = jumpPoint.y + 1

            local inst = objs[i]
            local trans = inst.transform
            trans.localRotation = Rotation
            trans.localScale = ScaleSize

            FlyCurve.Begin(inst, diePos, jumpPoint, p, 0.4)
            GameUtility.SetShadowHeight(inst, diePos.y, 0.06)

            table_insert(self.m_boxList, { inst, diePos, dropType })
        end
    end)
end

function InscriptionCopyLogicComponent:Pick(dropType, pickCount, score)
    -- dropType类型的, 飘起pickCount个

    local count = 0
    local pickedList = {}
    local path = self:GetDropPrefabPath(dropType)

    for i = #self.m_boxList, 1, -1 do
        local v = self.m_boxList[i]
        local go, pos, t = v[1], v[2], v[3]

        if t == dropType then
            count = count + 1
            table_insert(pickedList, v)

            GameObjectPoolInst:RecycleGameObject(path, go)     
            table_remove(self.m_boxList, i)
        end

        if count >= pickCount then
            break
        end
    end

    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_PICK_BOX, pickedList, score)
end

function InscriptionCopyLogicComponent:PrepareBossOut()
end

return InscriptionCopyLogicComponent