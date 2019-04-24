#include <stdlib.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif
#include <lualib.h>
#include <lauxlib.h>
#ifdef __cplusplus
}
#endif
#include <string.h>

#ifdef _WIN32
#include "wtime.h"
#else
#include <sys/time.h>
#endif

#define LUA_WATCHER_MT "WatcherMt"

typedef struct stWatcher{
    uint64_t m_uiBegin;
    uint64_t m_uiEnd;
}stWatcher;

#define BASE_BUFF_LOGGER_LEN  1*1024*1024

typedef struct 
{
    char *content_ptr;
    int pos;
    int content_len;  
} stLogger;

static stLogger s_logger = {0, 0, 0};


static int SetBitAt(lua_State *L){
	if (lua_gettop(L) == 2 && lua_isnumber(L, 1) && lua_isnumber(L, 2)){
		unsigned int t1 = lua_tointeger(L, 1);
		unsigned int t2 = lua_tointeger(L, 2);
		unsigned int t = t1 | (1 << t2);
		lua_pushinteger(L, t);
		return 1;
	}

	luaL_error(L, "SetBitAt check arguments failed\n");
	return 0;
}

static int ClearBitAt(lua_State *L){
	if (lua_gettop(L) == 2 && lua_isnumber(L, 1) && lua_isnumber(L, 2)){
		unsigned int t1 = lua_tointeger(L, 1);
		unsigned int t2 = lua_tointeger(L, 2);
		unsigned int t = t1 & (~(1 << t2));
		lua_pushinteger(L, t);
		return 1;
	}
	luaL_error(L, "ClearBitAt check arguments failed\n");
	return 0;
}

//测试是否置上第N(lua_tonumber(L, 2))个位
static int IsBitSet(lua_State *L){
	if (lua_gettop(L) == 2 && lua_isnumber(L, 1) && lua_isnumber(L, 2)){
		unsigned int t1 = (unsigned int)lua_tointeger(L, 1);
		unsigned int t2 = (unsigned int)lua_tointeger(L, 2);
		unsigned int t = t1 & (1 << t2);
		lua_pushboolean(L, t != 0 ? 1 : 0);
		return 1;
	}

	luaL_error(L, "IsBitSet check arguments failed\n");
	return 0;
}

static int BitOr(lua_State *L){
	if (lua_gettop(L) == 2 && lua_isnumber(L, 1) && lua_isnumber(L, 2)){
		unsigned int t1 = (unsigned int)lua_tointeger(L, 1);
		unsigned int t2 = (unsigned int)lua_tointeger(L, 2);
		unsigned int t = t1 | t2;
		lua_pushinteger(L, t);
		return 1;
	}

	luaL_error(L, "BitOr check arguments failed\n");
	return 0;
}

static int BitAnd(lua_State *L){
	if (lua_gettop(L) == 2 && lua_isnumber(L, 1) && lua_isnumber(L, 2)){
		unsigned int t1 = (unsigned int)lua_tointeger(L, 1);
		unsigned int t2 = (unsigned int)lua_tointeger(L, 2);
		unsigned int t = t1 & t2;
		lua_pushinteger(L, t);
		return 1;
	}

	luaL_error(L, "BitAnd check arguments failed\n");
	return 0;
}

static int SplitString(lua_State *L)
{
	if (lua_gettop(L) < 2 || !lua_isstring(L, 1) || !lua_isstring(L, 2))
	{
		luaL_error(L, "SplitString getting params or param's type failed\n");
		return 0;
	}

	size_t szBufferLen = 0;
	const char* pcSrcBuffer = lua_tolstring(L, 1, &szBufferLen);
	size_t szDeLen = 0;
	const char* pcDelimiter = lua_tolstring(L, 2, &szDeLen);
	if (szDeLen <= 0)
	{
		luaL_error(L, "SplitString delimiter empty\n");
		return 0;
	}
	//printf("%s %d : %s %d\n", pcSrcBuffer, szBufferLen, pcDelimiter, szDeLen);
	int retnum = 0;
	int pos = 0;
	for (int i = 0; i < (int)szBufferLen;)
	{
		if (strncmp(pcSrcBuffer + i, pcDelimiter, szDeLen) == 0)
		{
			if (i - pos >= 0)
			{
				if (retnum == 0)
				{
					lua_newtable(L);
				}
				++retnum;
				lua_pushlstring(L, pcSrcBuffer + pos, i - pos);
				lua_rawseti(L, -2, retnum);
			}
			i += szDeLen;
			pos = i;
		}
		else
		{
			++i;
		}
	}
	if (pos < (int)szBufferLen)
	{
		if (retnum == 0)
		{
			lua_newtable(L);
		}
		++retnum;
		lua_pushlstring(L, pcSrcBuffer + pos, szBufferLen - pos);
		lua_rawseti(L, -2, retnum);
	}
	if (retnum > 0)
	{
		return 1;
	}
	return 0;
}

static int NewWatcher(lua_State *L){
    stWatcher* p = (stWatcher*)lua_newuserdata(L, sizeof(stWatcher));
    p->m_uiBegin = 0;
    p->m_uiEnd = 0;
    luaL_getmetatable(L, LUA_WATCHER_MT);
    lua_setmetatable(L, -2);
    return 1;
}

static int watcher_begin(lua_State *L){
    if (lua_gettop(L) < 1 || !lua_isuserdata(L, 1))
    {
        return 0;
    }
    stWatcher* pWatcher = (stWatcher*)(luaL_checkudata(L, 1, LUA_WATCHER_MT));
    struct timeval stBegin;
	gettimeofday(&stBegin,NULL);
	pWatcher->m_uiBegin = stBegin.tv_sec * 1000 * 1000 + stBegin.tv_usec;
    return 0;
}

static int watcher_end(lua_State *L){
    if (lua_gettop(L) < 1 || !lua_isuserdata(L, 1))
    {
        return 0;
    }
    stWatcher* pWatcher = (stWatcher*)(luaL_checkudata(L, 1, LUA_WATCHER_MT));
    struct timeval stEnd;
	gettimeofday(&stEnd,NULL);
	pWatcher->m_uiEnd = stEnd.tv_sec * 1000 * 1000 + stEnd.tv_usec;
    lua_pushinteger(L, pWatcher->m_uiEnd - pWatcher->m_uiBegin);
    return 1;
}

static luaL_Reg lua_watcher_lib[] = {
    { "Begin", watcher_begin },
    { "End", watcher_end},
    //{ "__gc", watcher_gc},
    { NULL, NULL }
};

static int enlarge_content(stLogger* plogger, int len)
{
    if (plogger == 0 || len == 0) return -13;
    int enlarge_len = BASE_BUFF_LOGGER_LEN;
    if (len > enlarge_len)
    {
        enlarge_len = ((int)(len/enlarge_len) + 1)* BASE_BUFF_LOGGER_LEN;
    }

    char* new_content_ptr = (char*)malloc(plogger->content_len + enlarge_len);
    if (new_content_ptr == 0)
    {
        return -11;
    }

    if (plogger->content_ptr)
    {
        memcpy(new_content_ptr, plogger->content_ptr, plogger->pos);
        free(plogger->content_ptr);
        plogger->content_ptr = 0;
    }
    plogger->content_ptr = new_content_ptr;
    plogger->content_len = plogger->content_len + enlarge_len;
    // printf("enlarge_content %d %d %d\n", plogger->content_len, plogger->pos, len);
    return 0;
}

static int logger_append(lua_State* L) 
{
    int n = lua_gettop(L);

    for (int i = 1; i <= n; ++ i )
    {
        size_t len = 0;
        const char* str_ptr = luaL_tolstring(L, i, &len);
        if (str_ptr)
        {
            if (s_logger.pos + (int)len >= s_logger.content_len)
            {
                if (enlarge_content(&s_logger, (int)len) != 0) 
                {
                    // printf("enlarge_content error \n");
                    return 0;
                }
            }
            char* curr = s_logger.content_ptr + s_logger.pos;
            strncpy(curr, str_ptr, len);
            s_logger.pos += (int)len;
        }
    }
	return 0;
}

static int logger_flush(lua_State*L)
{
    if (s_logger.content_ptr == 0)
    {
        return 0;
    }
    lua_pushlstring(L, s_logger.content_ptr, s_logger.pos);
    lua_pushinteger(L, s_logger.pos);

    s_logger.content_ptr[0] = '\0';
    s_logger.pos = 0;
    return 2;
}


static luaL_Reg lua_lib[] = {
	{ "SetBitAt", SetBitAt },
	{ "ClearBitAt", ClearBitAt },
	{ "IsBitSet", IsBitSet },
	{ "BitOr", BitOr },
	{ "BitAnd", BitAnd },
	{ "NewWatcher", NewWatcher },
	{ "SplitString", SplitString},
	{ "AppendToLogger", logger_append},
	{ "FlushLogger", logger_flush},
	//{ "MD5", MD5 },
	{ NULL, NULL }
};

#ifdef __cplusplus
extern "C" {
#endif
LUALIB_API int luaopen_cutil(lua_State* L)
{
    luaL_newlib(L, lua_lib);
    lua_setglobal(L, "CUtil");
    lua_settop(L, 0);

    luaL_newmetatable(L, LUA_WATCHER_MT);
	lua_pushstring(L, "__index");
	lua_pushvalue(L, -2);
	lua_settable(L, -3);
	luaL_setfuncs(L, lua_watcher_lib, 0);
    lua_pop(L, 1);

    return 1;
}
#ifdef __cplusplus
}
#endif
