local UIBattleMainView = require("UI.UIBattle.View.UIBattleMainView")
local UIBattleGuildWarRobMainView = BaseClass("UIBattleGuildWarRobMainView", UIBattleMainView)
local base = UIBattleMainView

local ConfigUtil = ConfigUtil
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTweenExtensions = CS.DOTween.DOTweenExtensions
local Vector3 = Vector3

function UIBattleGuildWarRobMainView:OnCreate()
	base.OnCreate(self)

    self.m_guildWarRivalInfoRoot, self.m_guildWarKillInfoRoot,
    self.m_killInfoGridTrans, self.m_killInfoTextTran, self.m_killInfoText2Tran = UIUtil.GetChildTransforms(self.transform, {
		"TopRightContainer/GuildWarRivalInfo",
        "topMiddleContainer/GuildWarKillInfo",
        "topMiddleContainer/GuildWarKillInfo/Bg/Grid",
        "topMiddleContainer/GuildWarKillInfo/Bg/Grid/KillInfoText",
        "topMiddleContainer/GuildWarKillInfo/Bg/Grid/KillInfoText2",
	})
	
    self.m_guildWarRivalInfoRoot.gameObject:SetActive(true)
    self.m_guildWarKillInfoRoot = self.m_guildWarKillInfoRoot.gameObject
    
    self.m_rivalNameText, self.m_rivalGuildNameText, self.m_killInfoText, self.m_killInfoText2 = UIUtil.GetChildTexts(self.transform, {
        "TopRightContainer/GuildWarRivalInfo/RivalNameText",
        "TopRightContainer/GuildWarRivalInfo/RivalGuildNameText",
        "topMiddleContainer/GuildWarKillInfo/Bg/Grid/KillInfoText",
        "topMiddleContainer/GuildWarKillInfo/Bg/Grid/KillInfoText2",
    })

    self.m_rivalUserTitleImage = self:AddComponent(UIImage, "TopRightContainer/GuildWarRivalInfo/RivalNameText/RivalUserTitleImage", AtlasConfig.DynamicLoad)
    self.m_rivalGuildIconImage = self:AddComponent(UIImage, "TopRightContainer/GuildWarRivalInfo/RivalGuildNameText/GuildIconItem/GuildIconImage", AtlasConfig.DynamicLoad)

    self.m_showFightNewsDeltaTime = 1
    self.m_fightNewsList = {}
    self.m_killTextIndex = 0
end

function UIBattleGuildWarRobMainView:OnEnable(...)
	base.OnEnable(self, ...)
     
end

function UIBattleGuildWarRobMainView:Update()
    base.Update(self)

    if self.m_showFightNewsDeltaTime > 0 then
        self.m_showFightNewsDeltaTime = self.m_showFightNewsDeltaTime - Time.deltaTime
        return 
    end

    if #self.m_fightNewsList > 0 then
        self.m_showFightNewsDeltaTime = 1

        if not self.m_guildWarKillInfoRoot.activeSelf then
            self.m_guildWarKillInfoRoot:SetActive(true)
        end

        local news = self.m_fightNewsList[1]
        table_remove(self.m_fightNewsList, 1)

        self.m_killTextIndex = self.m_killTextIndex + 1

        local killInfoText = self.m_killTextIndex % 2 > 0 and self.m_killInfoText or self.m_killInfoText2
        killInfoText.text = news
        

        local pos = self.m_killInfoGridTrans.localPosition
        if self.m_killTextIndex > 1 then
            local tweenner = DOTweenShortcut.DOLocalMoveY(self.m_killInfoGridTrans, pos.y + 47, 0.9)
            DOTweenSettings.OnComplete(tweenner, function()
                local killTextIndex = self.m_killTextIndex + 1
        local killInfoTextTran = killTextIndex % 2 > 0 and self.m_killInfoTextTran or self.m_killInfoText2Tran
        killInfoTextTran.localPosition = Vector3.New(killInfoTextTran.localPosition.x, killInfoTextTran.localPosition.y - 94, 0)
            end)
        end
    end
end

function UIBattleGuildWarRobMainView:OnAddListener()
	base.OnAddListener(self)
	
	-- self:AddUIListener(UIMessageNames., self.)
end

function UIBattleGuildWarRobMainView:OnRemoveListener()
	base.OnRemoveListener(self)
	
	-- self:RemoveUIListener(UIMessageNames., self.)
end




return UIBattleGuildWarRobMainView