
local string_format = string.format
local table_insert = table.insert
local math_min = math.min
local tonumber = tonumber
local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local Language = Language
local CommonDefine = CommonDefine
local GameObject = CS.UnityEngine.GameObject
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local FuliMgr = Player:GetInstance():GetFuliMgr()

local QiandaoItemClass = require "UI.UIFuli.View.QiandaoItem"
local QiandaoItemPrefab = "UI/Prefabs/Fuli/QiandaoItem.prefab"


local DetailQiandaoHelper = BaseClass("DetailQiandaoHelper")

function DetailQiandaoHelper:__init(fuliTr, fuliView)
    self.m_fuliView = fuliView

    self.m_titleText, self.m_countText = UIUtil.GetChildTexts(fuliTr, {
        "Container/Fuli/bg/RightContainer/Qiandao/Title/Text",
        "Container/Fuli/bg/RightContainer/Qiandao/QiandaoCountText",
    })

    self.m_qiandaoTr, self.m_qiandaoContentTr
    = UIUtil.GetChildTransforms(fuliTr, {
        "Container/Fuli/bg/RightContainer/Qiandao",
        "Container/Fuli/bg/RightContainer/Qiandao/ItemScrollView/Viewport/ItemContent"
    })

    self.m_qiandaoGo = self.m_qiandaoTr.gameObject
    
    self.m_qiandaoItemList = {}

    for i = 0, self.m_qiandaoContentTr.childCount - 1 do
        local qiandaoItem = QiandaoItemClass.New(self.m_qiandaoContentTr:GetChild(i).gameObject, self.m_qiandaoContentTr)
        qiandaoItem:OnCreate()
        table_insert(self.m_qiandaoItemList, {item = qiandaoItem, go = self.m_qiandaoContentTr:GetChild(i).gameObject})
    end
end

function DetailQiandaoHelper:__delete()
    self.m_fuliView = nil
    self.m_qiandaoItemList = {}
    self:Close()
end

function DetailQiandaoHelper:Close()
    self.m_qiandaoGo:SetActive(false)
end

function DetailQiandaoHelper:UpdateInfo(isReset)
    local oneFuli = self.m_fuliView:GetOneFuli()
    if not oneFuli then
        return
    end

    self.m_qiandaoGo:SetActive(true)
    self.m_titleText.text = self.m_fuliView:GetTitleName()
    local qiandaoDays = 0
    for i, v in ipairs(oneFuli.entry_list) do
        local qiandaoItem = self.m_qiandaoItemList[i].item
        self.m_qiandaoItemList[i].go:SetActive(true)
        qiandaoItem:UpdateData(v.award_list[1], v.e_param1, v.index, v.status, self.m_fuliView:GetFuliId())
        if v.status == 2 then
            qiandaoDays = qiandaoDays + 1
        end
    end
    self.m_countText.text = string_format(Language.GetString(3432), qiandaoDays)
    for i, v in ipairs(self.m_qiandaoItemList) do
        if i > #oneFuli.entry_list then
            v.go:SetActive(false)
        end
    end

end


-- function DetailQiandaoHelper:Update()
--     if not self.m_delayCreateItem then
--         return
--     end

--     local oneFuli = self.m_fuliView:GetOneFuli()
--     if not oneFuli then
--         return
--     end

--     local CreateItemCount = #oneFuli.entry_list
--     if self.m_crateCountRecord < CreateItemCount then
--         if #self.m_qiandaoItemList < CreateItemCount then
--             local seq = UIGameObjectLoaderInstance:PrepareOneSeq()
--             self.m_seqList[seq] = true
--             UIGameObjectLoaderInstance:GetGameObject(seq, QiandaoItemPrefab, function(obj, seq)
--                 self.m_seqList[seq] = nil
--                 if not IsNull(obj) then
--                     local qiandaoItem = QiandaoItemClass.New(obj, self.m_qiandaoContentTr, QiandaoItemPrefab)
--                     table_insert(self.m_qiandaoItemList, qiandaoItem)

--                     local dataIndex = self.m_crateCountRecord + 1
--                     local v = oneFuli.entry_list[dataIndex]
--                     qiandaoItem:UpdateData(v.award_list[1], v.e_param1, v.index, v.status, self.m_fuliView:GetFuliId())
                    
--                 end
--             end, seq)
--         end
--         self.m_crateCountRecord = self.m_crateCountRecord + 1
--         if self.m_crateCountRecord >= CreateItemCount then
--             self.m_delayCreateItem = false
--             UIManagerInst:SetUIEnable(true)
--         end
--     end
-- end


return DetailQiandaoHelper