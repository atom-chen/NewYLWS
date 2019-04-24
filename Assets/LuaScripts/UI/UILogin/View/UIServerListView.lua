local SERVER_GROUP_COUNT = 20
local table_insert = table.insert
local math_floor = math.floor
local ServerGroupItem = require "UI.UILogin.View.ServerGroupItem"
local ServerGroupPath = TheGameIds.ServerGroupItemPrefab
local ServerItem = require "UI.UILogin.View.ServerItem"
local ServerItemPath = TheGameIds.ServerItemPrefab
local ServerRoleItem = require "UI.UILogin.View.ServerRoleItem"
local ServerRoleItemPath = TheGameIds.ServerRoleItemPrefab


local UIServerListView = BaseClass("UIServerListView", UIBaseView)
local base = UIBaseView

function UIServerListView:OnCreate()
	base.OnCreate(self)

	self:InitVariable()
	self:InitView()
	self:HandleClick()
end

-- 初始化非UI变量
function UIServerListView:InitVariable()
	self.m_groupItemList = {}
	self.m_groupDataList = {}
	self.m_groupLoaderSeq = 0
	self.m_serverItemList = {}
	self.m_serverDataList = {}
	self.m_serverLoaderSeq = 0
	self.m_lastLoginDataList = nil
	self.m_lastLoginItemList = {}
	self.m_lastServerLoaderSeq = 0
	self.m_serverList = nil
	self.m_curServer = nil
	self.m_curSelectGroupIndex = 0
end

-- 初始化UI变量
function UIServerListView:InitView()
	self.m_leftTitleText, self.m_middleTitleText, self.m_huobaoText, self.m_liuchangText, self.m_weikaifuText,
	self.m_weihuText, self.m_rightTitleText = UIUtil.GetChildTexts(self.transform, {
		"leftRoot/titleText",
		"middleRoot/titleText",
		"middleRoot/statusRoot/huobao/huobaoText",
		"middleRoot/statusRoot/liuchang/liuchangText",
		"middleRoot/statusRoot/weikaifu/weikaifuText",
		"middleRoot/statusRoot/weihu/weihuText",
		"rightRoot/titleText",
    })
	self.m_leftTitleText.text = Language.GetString(4118)
	self.m_middleTitleText.text = Language.GetString(4120)
	self.m_huobaoText.text = Language.GetString(4111)
	self.m_liuchangText.text = Language.GetString(4110)
	self.m_weikaifuText.text = Language.GetString(4108)
	self.m_weihuText.text = Language.GetString(4109)
	self.m_rightTitleText.text = Language.GetString(4112)

    self.m_serverGroupRoot, self.m_closeBtn, self.m_serverRoot, self.m_roleRoot = UIUtil.GetChildRectTrans(self.transform, {
		"leftRoot/ServerGroupScrollView/Viewport/GroupItemContent",
		"closeBtn",
		"middleRoot/ServerScrollView/Viewport/ServerItemContent",
		"rightRoot/RoleScrollView/Viewport/ItemContent",
	})
	self.m_groupScrollView = self:AddComponent(LoopScrowView, "leftRoot/ServerGroupScrollView/Viewport/GroupItemContent", Bind(self, self.UpdateGroupItem))
	self.m_serverScrollView = self:AddComponent(LoopScrowView, "middleRoot/ServerScrollView/Viewport/ServerItemContent", Bind(self, self.UpdateServerItem))
	self.m_roleScrollView = self:AddComponent(LoopScrowView, "rightRoot/RoleScrollView/Viewport/ItemContent", Bind(self, self.UpdateRoleItem))
end

function UIServerListView:OnEnable(...)
	base.OnEnable(self, ...)
	local _, serverList, curServer, lastLoginServerList = ...
	self.m_serverList = serverList
	self.m_curServer = curServer
	self.m_lastLoginDataList = lastLoginServerList 
	self.m_curSelectGroupIndex = self:IndexOfGroup(self.m_curServer)
	self:UpdateView()
end

function UIServerListView:UpdateView()
	self:UpdateServerGroupView()
	self:UpdateServerView()
	self:UpdateRoleView()
end

function UIServerListView:UpdateServerGroupView()
	self:InitGroupData()
	if #self.m_groupItemList == 0 and self.m_groupLoaderSeq == 0 then
        self.m_groupLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_groupLoaderSeq, ServerGroupPath, #self.m_groupDataList, function(objs)
            self.m_groupLoaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local groupItem = ServerGroupItem.New(objs[i], self.m_serverGroupRoot, ServerGroupPath)
                    table_insert(self.m_groupItemList, groupItem)
                end

                self.m_groupScrollView:UpdateView(true, self.m_groupItemList, self.m_groupDataList)
            end
        end)
    else
        self.m_groupScrollView:UpdateView(true, self.m_groupItemList, self.m_groupDataList)
    end
end

function UIServerListView:UpdateGroupItem(item, realIndex)
	if item and realIndex > 0 and realIndex <= #self.m_groupDataList then
		local data = self.m_groupDataList[realIndex]
		item:SetData(data.index, self:GetStartServerIndex(data.index), self:GetEndServerIndex(data.index), data.index == self.m_curSelectGroupIndex)
	end
end

function UIServerListView:InitGroupData()
	self.m_groupDataList = {}
	local count = #self.m_serverList
	count = math_floor(count / SERVER_GROUP_COUNT)
	if count * SERVER_GROUP_COUNT < #self.m_serverList then
		count = count + 1
	end

	for i = count, 1, -1 do
		table_insert(self.m_groupDataList, {index = i})
	end
end

function UIServerListView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function UIServerListView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
end

function UIServerListView:OnDisable()
	UIGameObjectLoader:GetInstance():CancelLoad(self.m_groupLoaderSeq)
    self.m_groupLoaderSeq = 0

    for _,item in pairs(self.m_groupItemList) do
        item:Delete()
    end
	self.m_groupItemList = {}
	self.m_groupDataList = {}
	
	self:RecycleServerItem()

	UIGameObjectLoader:GetInstance():CancelLoad(self.m_lastServerLoaderSeq)
	self.m_lastServerLoaderSeq = 0
	for _,item in pairs(self.m_lastLoginItemList) do
		item:Delete()
	end
	self.m_lastLoginItemList = {}
	self.m_lastLoginDataList = {}

    base.OnDisable(self)
end

function UIServerListView:RecycleServerItem()
	UIGameObjectLoader:GetInstance():CancelLoad(self.m_serverLoaderSeq)
    self.m_serverLoaderSeq = 0

    for _,item in pairs(self.m_serverItemList) do
        item:Delete()
    end
	self.m_serverItemList = {}
	self.m_serverDataList = {}
end

function UIServerListView:OnClick(go, x, y)
    local name = go.name
	if name == "closeBtn" then
		self:CloseSelf()
    end
end

function UIServerListView:OnDestroy()
    self:RemoveEvent()
	
	base.OnDestroy(self)
end

function UIServerListView:IndexOfGroup(value)
	local indexOfAll = 0
    for i = 1, #self.m_serverList do
        if self.m_serverList[i] == value then 
			indexOfAll = i 
			break
		end
	end
	local index = math_floor(indexOfAll / SERVER_GROUP_COUNT)
	if index * SERVER_GROUP_COUNT < indexOfAll then
		index = index + 1
	end
	return index
end

function UIServerListView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
	self:AddUIListener(UIMessageNames.MN_LOGIN_SELECT_SERVER_GROUP, self.OnSelectServerGroup)
	self:AddUIListener(UIMessageNames.MN_LOGIN_SELECT_SERVER, self.OnSelectServer)
end

function UIServerListView:OnRemoveListener()
	base.OnRemoveListener(self)
    -- UI消息注销
	self:RemoveUIListener(UIMessageNames.MN_LOGIN_SELECT_SERVER_GROUP, self.OnSelectServerGroup)
	self:RemoveUIListener(UIMessageNames.MN_LOGIN_SELECT_SERVER, self.OnSelectServer)
end

function UIServerListView:OnSelectServerGroup(index)
	self.m_curSelectGroupIndex = index
	for i,item in pairs(self.m_groupItemList) do
		local data = self.m_groupDataList[i]
		item:SetData(data.index, self:GetStartServerIndex(data.index), self:GetEndServerIndex(data.index), data.index == self.m_curSelectGroupIndex)
    end
	self:UpdateServerView()
end

function UIServerListView:UpdateServerView()
	self:RecycleServerItem()
	self:InitServerData()
	self.m_serverLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
	UIGameObjectLoader:GetInstance():GetGameObjects(self.m_serverLoaderSeq, ServerItemPath, #self.m_serverDataList, function(objs)
		self.m_serverLoaderSeq = 0
		if objs then
			for i = 1, #objs do
				local serverItem = ServerItem.New(objs[i], self.m_serverRoot, ServerItemPath)
				table_insert(self.m_serverItemList, serverItem)
			end

			self.m_serverScrollView:UpdateView(true, self.m_serverItemList, self.m_serverDataList)
		end
	end)
end

function UIServerListView:UpdateServerItem(item, realIndex)
	if item and realIndex > 0 and realIndex <= #self.m_serverDataList then
		local data = self.m_serverDataList[realIndex]
		item:SetData(data, self.m_curServer == data)
	end
end

function UIServerListView:InitServerData()
	self.m_serverDataList = {}
	local endIndex = self:GetEndServerIndex(self.m_curSelectGroupIndex)
	if endIndex > #self.m_serverList then
		endIndex = #self.m_serverList
	end

	local startIndex = self:GetStartServerIndex(self.m_curSelectGroupIndex)
	for i = endIndex, startIndex, -1 do
		table_insert(self.m_serverDataList, self.m_serverList[i])
	end
end

function UIServerListView:GetStartServerIndex(groupIndex)
	return (groupIndex - 1) * SERVER_GROUP_COUNT + 1
end

function UIServerListView:GetEndServerIndex(groupIndex)
	return groupIndex * SERVER_GROUP_COUNT
end

function UIServerListView:UpdateRoleView()
	if #self.m_lastLoginDataList <= 0 then
		return
	end
	if #self.m_lastLoginItemList == 0 and self.m_lastServerLoaderSeq == 0 then
        self.m_lastServerLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_lastServerLoaderSeq, ServerRoleItemPath, #self.m_lastLoginDataList, function(objs)
            self.m_lastServerLoaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local serverRoleItem = ServerRoleItem.New(objs[i], self.m_roleRoot, ServerRoleItemPath)
                    table_insert(self.m_lastLoginItemList, serverRoleItem)
                end

                self.m_roleScrollView:UpdateView(true, self.m_lastLoginItemList, self.m_lastLoginDataList)
            end
        end)
    else
        self.m_roleScrollView:UpdateView(true, self.m_lastLoginItemList, self.m_lastLoginDataList)
    end
end

function UIServerListView:UpdateRoleItem(item, realIndex)
	if item and realIndex > 0 and realIndex <= #self.m_lastLoginDataList then
		local data = self.m_lastLoginDataList[realIndex]
		item:SetData(data)
	end
end

function UIServerListView:OnSelectServer(serverData)
	self:CloseSelf()
end

return UIServerListView