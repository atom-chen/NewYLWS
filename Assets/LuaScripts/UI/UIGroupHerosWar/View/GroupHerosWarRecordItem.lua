
local table_insert = table.insert
local math_ceil = math.ceil
local string_format = string.format
local GameObject = CS.UnityEngine.GameObject
local UIUtil = UIUtil
local AtlasConfig = AtlasConfig
local ConfigUtil = ConfigUtil
local ImageConfig = ImageConfig
local Language = Language
local VIDEO_TYPE = VIDEO_TYPE

local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local UserItemPrefab = TheGameIds.UserItemPrefab
local UserItemClass = require("UI.UIUser.UserItem")
local VideoMgr = Player:GetInstance():GetVideoMgr()

local GroupHerosWarRecordItem = BaseClass("GroupHerosWarRecordItem", UIBaseItem)
local base = UIBaseItem

function GroupHerosWarRecordItem:OnCreate()
    base.OnCreate(self)
    local btnText

    self.m_userNameText, self.m_guildNameText, self.m_serverNameText,
    self.m_addScoreText, self.m_reduceScoreText, self.m_dateText, btnText 
    = UIUtil.GetChildTexts(self.transform, {
        "UserName",
        "GuildName",
        "ServerName",
        "AddScoreText",
        "ReduceScoreText",
        "Layout/DateText",
        "Layout/CheckBtn/Text",
    })

    self.m_checkBtn, self.m_userItemTr = UIUtil.GetChildTransforms(self.transform, {
        "Layout/CheckBtn",
        "UserItemPos",
    })

    self.m_resultImg = UIUtil.AddComponent(UIImage, self, "ResultImg", AtlasConfig.DynamicLoad)
    btnText.text =  Language.GetString(3982)

    self.m_userItem = nil
    self.m_seq = 0
    self.m_videoId = 0

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_checkBtn.gameObject, onClick)
end

function GroupHerosWarRecordItem:OnClick(go)
    if go.name == "CheckBtn" then
        VideoMgr:ReqVideo(self.m_videoId, VIDEO_TYPE.CROSS_SERVER_KINGDOMWAR)
    end
end

function GroupHerosWarRecordItem:UpdateData(data)

    self.m_videoId = data.video_id
    if data.battle_result == 1 then
        self.m_resultImg:SetAtlasSprite("jtzb9.png", false)
        self.m_reduceScoreText.text = math_ceil(data.score_chg)
        self.m_addScoreText.text = ""
    elseif data.battle_result == 0 then
        self.m_resultImg:SetAtlasSprite("jtzb8.png", false)
        self.m_addScoreText.text = string_format("+%d", math_ceil(data.score_chg))
        self.m_reduceScoreText.text = ""
    end

    if not self.m_userItem then
        if self.m_seq == 0 then
            self.m_seq = UIGameObjectLoaderInst:PrepareOneSeq()
            UIGameObjectLoaderInst:GetGameObject(self.m_seq, UserItemPrefab, function(obj)
                self.m_seq = 0
                if not obj then
                    return
                end
                self.m_userItem = UserItemClass.New(obj, self.m_userItemTr, UserItemPrefab)
                self.m_userItem:UpdateData(data.user_brief.use_icon.icon, data.user_brief.use_icon.icon_box, data.user_brief.level)
            end)
        end
    else
        self.m_userItem:UpdateData(data.user_brief.use_icon.icon, data.user_brief.use_icon.icon_box, data.user_brief.level)
    end
    self.m_userNameText.text = data.user_brief.name
    self.m_guildNameText.text = data.user_brief.guild_name == "" and Language.GetString(3983) or data.user_brief.guild_name
    self.m_serverNameText.text = data.user_brief.dist_name
    self.m_dateText.text = os.date("%m-%d", data.time)
    if not self.m_videoId or self.m_videoId == "" then
        self.m_checkBtn.gameObject:SetActive(false)
    else
        self.m_checkBtn.gameObject:SetActive(true)
    end
end

function GroupHerosWarRecordItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_checkBtn.gameObject)
    UIGameObjectLoaderInst:CancelLoad(self.m_seq)
    self.m_seq = 0

    if self.m_userItem then
        self.m_userItem:Delete()
        self.m_userItem = nil
    end

    base.OnDestroy(self)
end

return GroupHerosWarRecordItem