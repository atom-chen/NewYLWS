

local ItemDataClass = require "DataCenter.ItemData.ItemData"
local WuJiangDataClass = require "DataCenter.WuJiangData.WuJiangData"
local ShenbingDataClass = require "DataCenter.ShenBingData.ShenBingData"
local AwardData = BaseClass("AwardData")
local PBUtil = PBUtil
local CommonDefine = CommonDefine

function AwardData:__init(type)
    self.m_type = type
    self.m_itemData = nil
    self.m_wujiangData = nil
    self.m_shenbingData = nil
    self.m_zuoqiData = nil
end

function AwardData:GetAwardType()
    return self.m_type
end

function AwardData:CreateItem(itemID, itemCount)
    self.m_itemData = ItemDataClass.New(itemID, itemCount, false)
end

function AwardData:CreateWujiang(wujiangID, star, level)
    self.m_wujiangData = WuJiangDataClass.New()
    self.m_wujiangData.id = wujiangID
    self.m_wujiangData.star = star
    self.m_wujiangData.level = level
end

function AwardData:ParseFromPbObj(pb_obj)
    if pb_obj.award_type == CommonDefine.AWARD_TYPE_ITEM then
        self.m_itemData = PBUtil.ConvertOneItemToData(pb_obj.award_item)
    elseif pb_obj.award_type == CommonDefine.AWARD_TYPE_HERO then
        self.m_wujiangData = Player:GetInstance():GetWujiangMgr():ToWuJiangData(pb_obj.award_wujiang)
    elseif pb_obj.award_type == CommonDefine.AWARD_TYPE_SHENBING then
        self.m_shenbingData = Player:GetInstance():GetShenBingMgr():ParseToShenbingData(pb_obj.award_shenbing)
    elseif pb_obj.award_type == CommonDefine.AWARD_TYPE_ZUOQI then
        self.m_zuoqiData = Player:GetInstance():GetMountMgr():ParseToMountData(pb_obj.award_horse)
    end
end

function AwardData:GetItemData()
    return self.m_itemData
end

function AwardData:GetWujiangData()
    return self.m_wujiangData
end

function AwardData:GetShenbingData()
    return self.m_shenbingData
end

function AwardData:GetZuoqiData()
    return self.m_zuoqiData
end

return AwardData