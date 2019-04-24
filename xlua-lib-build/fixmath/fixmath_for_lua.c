//#include <stdio.h>
//#include <stdlib.h>
//#include <time.h>
//#include <string>
//#include <string.h>
//#include <iostream>

#ifdef __cplusplus
extern "C"
{
#endif
#include <lualib.h>
#include <lauxlib.h>
//#include "fix_vector3.h"
#ifdef __cplusplus
}
#endif

#include "fixmath.h"
#include "fixmath_vector3.h"
#include "fixmath_acos.h"

#ifndef NULL
#define NULL 0
#endif

#define FRACT_LIMIT_HD 12
//using namespace std;

static int fx_lua_num2fx(lua_State* L) 
{
    double d = luaL_checknumber(L, 1);
    fixed_t ret = fx_dtox(d, FRACT_LIMIT);
    lua_pushnumber(L, ret);
    return 1;
}

static int fx_lua_sqrt(lua_State* L) 
{
    double d = luaL_checknumber(L, 1);
    double ret = fx_xtod(fx_sqrtx(fx_dtox(d, FRACT_LIMIT), FRACT_LIMIT), FRACT_LIMIT);
    lua_pushnumber(L, ret);
    return 1;
}

static int fx_lua_sqrti(lua_State* L) 
{
    double d = luaL_checknumber(L, 1);
    int ret = fx_xtoi(fx_sqrtx(fx_dtox(d, FRACT_LIMIT), FRACT_LIMIT), FRACT_LIMIT);
    lua_pushinteger(L, ret);
    return 1;
}

static int fx_lua_pow(lua_State* L) 
{
    if (lua_gettop(L) >= 2)
    {
        double a = luaL_checknumber(L, 1);
        double b = luaL_checknumber(L, 2);
        double ret = fx_xtod(fx_powx(fx_dtox(a, FRACT_LIMIT), FRACT_LIMIT, fx_dtox(b, FRACT_LIMIT), FRACT_LIMIT), FRACT_LIMIT);
        lua_pushnumber(L, ret);
        return 1;
    }
    luaL_error(L, "pow checked parameters num failed!\n");
    return 0;
}


static int fx_lua_add(lua_State* L) 
{
    if (lua_gettop(L) >= 2)
    {
        double a = luaL_checknumber(L, 1);
        double b = luaL_checknumber(L, 2);
        double ret = fx_xtod(fx_addx(fx_dtox(a, FRACT_LIMIT), fx_dtox(b, FRACT_LIMIT)), FRACT_LIMIT);
        lua_pushnumber(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_sub(lua_State* L) 
{
    if (lua_gettop(L) >= 2)
    {
        double a = luaL_checknumber(L, 1);
        double b = luaL_checknumber(L, 2);
        double ret = fx_xtod(fx_subx(fx_dtox(a, FRACT_LIMIT), fx_dtox(b, FRACT_LIMIT)), FRACT_LIMIT);
        lua_pushnumber(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_mul(lua_State* L) 
{
    if (lua_gettop(L) >= 2)
    {
        double a = luaL_checknumber(L, 1);
        double b = luaL_checknumber(L, 2);
        double ret = 0;
        ret = fx_xtod(fx_mulx(fx_dtox(a, FRACT_LIMIT), fx_dtox(b, FRACT_LIMIT), FRACT_LIMIT), FRACT_LIMIT);
        lua_pushnumber(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_muli(lua_State* L) 
{
    if (lua_gettop(L) >= 2)
    {
        double a = luaL_checknumber(L, 1);
        double b = luaL_checknumber(L, 2);
        int ret = 0;
        ret = fx_xtoi(fx_mulx(fx_dtox(a, FRACT_LIMIT), fx_dtox(b, FRACT_LIMIT), FRACT_LIMIT), FRACT_LIMIT);
        lua_pushinteger(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_mul_hd(lua_State* L) 
{
    if (lua_gettop(L) >= 2)
    {
        double a = luaL_checknumber(L, 1);
        double b = luaL_checknumber(L, 2);
        double ret = 0;
        ret = fx_xtod(fx_mulx(fx_dtox(a, FRACT_LIMIT_HD), fx_dtox(b, FRACT_LIMIT_HD), FRACT_LIMIT_HD), FRACT_LIMIT_HD);
        lua_pushnumber(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_exp(lua_State* L) 
{
    if (lua_gettop(L) >= 1)
    {
        double a = luaL_checknumber(L, 1);
        double ret = 0;
        ret = fx_xtod(fx_expx(fx_dtox(a, FRACT_LIMIT), FRACT_LIMIT), FRACT_LIMIT);
        lua_pushnumber(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_exp2(lua_State* L) 
{
    if (lua_gettop(L) >= 1)
    {
        double a = luaL_checknumber(L, 1);
        double ret = 0;
        ret = fx_xtod(fx_exp2x(fx_dtox(a, FRACT_LIMIT), FRACT_LIMIT), FRACT_LIMIT);
        lua_pushnumber(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_exp10(lua_State* L) 
{
    if (lua_gettop(L) >= 1)
    {
        double a = luaL_checknumber(L, 1);
        double ret = 0;
        ret = fx_xtod(fx_exp10x(fx_dtox(a, FRACT_LIMIT), FRACT_LIMIT), FRACT_LIMIT);
        lua_pushnumber(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_floor(lua_State* L) 
{
    if (lua_gettop(L) >= 1)
    {
        double a = luaL_checknumber(L, 1);
        int ret = 0;
        ret = fx_floorx(fx_dtox(a, FRACT_LIMIT), FRACT_LIMIT);
        lua_pushinteger(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_abs(lua_State* L) 
{
    if (lua_gettop(L) >= 1)
    {
        double a = luaL_checknumber(L, 1);
        if (a >= 0)
        {
            lua_pushnumber(L, a);
        }
        else
        {
            double ret = fx_xtod(fx_subx(fx_dtox(0, FRACT_LIMIT), fx_dtox(a, FRACT_LIMIT)), FRACT_LIMIT);
            lua_pushnumber(L, ret);
        }
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_ceil(lua_State* L) 
{
    if (lua_gettop(L) >= 1)
    {
        double a = luaL_checknumber(L, 1);
        int ret = 0;
        ret = fx_ceilx(fx_dtox(a, FRACT_LIMIT), FRACT_LIMIT);
        lua_pushinteger(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_round(lua_State* L) 
{
    if (lua_gettop(L) >= 1)
    {
        double a = luaL_checknumber(L, 1);
        int ret = 0;
        ret = fx_roundx(fx_dtox(a, FRACT_LIMIT), FRACT_LIMIT);
        lua_pushinteger(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}
static int fx_lua_div(lua_State* L) 
{
    if (lua_gettop(L) >= 2)
    {
        double a = luaL_checknumber(L, 1);
        double b = luaL_checknumber(L, 2);
        if (F_IS_ZERO(b))
        {
            luaL_error(L, "dividend is near zero !! \n");
            return 0;
        }
        double ret = 0;
        ret = fx_xtod(fx_divx(fx_dtox(a, FRACT_LIMIT), fx_dtox(b, FRACT_LIMIT), FRACT_LIMIT), FRACT_LIMIT);
        lua_pushnumber(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_divi(lua_State* L) 
{
    if (lua_gettop(L) >= 2)
    {
        double a = luaL_checknumber(L, 1);
        double b = luaL_checknumber(L, 2);
        if (F_IS_ZERO(b))
        {
            luaL_error(L, "dividend is near zero !! \n");
            return 0;
        }
        int ret = 0;
        ret = fx_xtoi(fx_divx(fx_dtox(a, FRACT_LIMIT), fx_dtox(b, FRACT_LIMIT), FRACT_LIMIT), FRACT_LIMIT);
        lua_pushinteger(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_mod(lua_State* L) 
{
    if (lua_gettop(L) >= 2)
    {
        int a = luaL_checkinteger(L, 1);
        int b = luaL_checkinteger(L, 2);
        if (F_IS_ZERO(b))
        {
            luaL_error(L, "dividend is near zero !! \n");
            return 0;
        }
        //TODO 未实现
        int ret = a%b;
        //ret = fx_xtod(fx_divx(fx_dtox(a, FRACT_LIMIT), fx_dtox(b, FRACT_LIMIT), FRACT_LIMIT), FRACT_LIMIT);
        lua_pushinteger(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_sin(lua_State* L) 
{
    if (lua_gettop(L) >= 1)
    {
        double a = luaL_checknumber(L, 1);
        double ret = 0;
        ret = fx_xtod(fx_sinx(fx_angle_to_radian(fx_dtox(a, FRACT_LIMIT)), FRACT_LIMIT), FRACT_LIMIT);
        lua_pushnumber(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}
static int fx_lua_cos(lua_State* L) 
{
    if (lua_gettop(L) >= 1)
    {
        double a = luaL_checknumber(L, 1);
        double ret = 0;
        ret = fx_xtod(fx_cosx(fx_angle_to_radian(fx_dtox(a, FRACT_LIMIT)), FRACT_LIMIT), FRACT_LIMIT);
        lua_pushnumber(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_acos(lua_State* L) 
{
    if (lua_gettop(L) >= 1)
    {
        double a = luaL_checknumber(L, 1);
        if (a > 1.0)
        {
            luaL_error(L, "fx_lua_acos args %f error!\n", a);
            return 0;
        }
        else if (a < -1.0)
        {
            luaL_error(L, "fx_lua_acos args %f error!\n", a);
            return 0;
        }
        double ret = 0;
        ret = fx_xtod(fx_radian_to_angle(fx_dtox(fx_acosd(a, FRACT_LIMIT), FRACT_LIMIT)), FRACT_LIMIT);
        //ret = fx_acosd(a, FRACT_LIMIT);
        lua_pushnumber(L, ret);
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_cmp(lua_State* L) 
{
    if (lua_gettop(L) >= 2)
    {
        double a = luaL_checknumber(L, 1);
        double b = luaL_checknumber(L, 2);
        fixed_t xa = fx_dtox(a, FRACT_LIMIT);
        fixed_t xb = fx_dtox(b, FRACT_LIMIT);
        if (xa > xb)
        {
            lua_pushinteger(L, 1);
        }
        else if (xa == xb)
        {
            lua_pushinteger(L, 0);
        }
        else if (xa < xb)
        {
            lua_pushinteger(L, -1);
        }
        return 1;
    }
    luaL_error(L, "add checked parameters num failed!\n");
    return 0;
}

static int fx_lua_iszero(lua_State* L) 
{
    if (lua_gettop(L) >= 1)
    {
        double a = luaL_checknumber(L, 1);
        int ret = 0;
        if (F_IS_ZERO(a))
        {
            ret = 1;
        }
        lua_pushboolean(L, ret);
        return 1;
    }
    luaL_error(L, "fx_lua_iszero checked parameters num failed!\n");
    return 0;
}

//static int fx_lua_angle_r_between_vetor3(lua_State* L)
//{
//    if (lua_gettop(L) >= 2)
//    {
//        FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
//        if (p1 == NULL)
//        {
//            luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
//            return 0;
//        }

//        FixVector3* p2 = (FixVector3*)(luaL_checkudata(L, 2, LUA_FIX_VECTOR3_MT));
//        if (p2 == NULL)
//        {
//            luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
//            return 0;
//        }
//        lua_pushnumber(L, FixVector3_angle_radian_d(p1,p2));
//        return 1;
//    }
//    return 0;
//}

static int fx_lua_angle_between_vetor3(lua_State* L)
{
    if (lua_gettop(L) >= 2)
    {
        FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
        if (p1 == NULL)
        {
            luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
            return 0;
        }

        FixVector3* p2 = (FixVector3*)(luaL_checkudata(L, 2, LUA_FIX_VECTOR3_MT));
        if (p2 == NULL)
        {
            luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
            return 0;
        }
        double rd = FixVector3_angle_radian_d(p1,p2);
        double a = fx_xtod(fx_divx(fx_mulx(fx_dtox(rd, FRACT_LIMIT), fx_dtox(180, FRACT_LIMIT), FRACT_LIMIT), fx_dtox(3.1416, FRACT_LIMIT), FRACT_LIMIT), FRACT_LIMIT);
        lua_pushnumber(L, a);
        return 1;
    }
    return 0;
}

static int fx_lua_normalize_vetor3(lua_State* L)
{
    if (lua_gettop(L) >= 1)
    {
        FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
        if (p1 == NULL)
        {
            luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
            return 0;
        }
        double clamp = 0;
        if (lua_gettop(L) >= 2)
        {
            clamp = luaL_checknumber(L, 2);
        }

        void* p = lua_newuserdata(L, sizeof(FixVector3));
        if (NULL == p)
        {
            luaL_error(L, "fx_lua_normalize_vetor3, lua_newuserdata mem error\n");
            return 0;
        }


        if (clamp <= 0) clamp = 1.0f;

        FixVector3* pret = (FixVector3*)(p);
        FixVector3_normallize_to(p1, pret, clamp);
        luaL_getmetatable(L, LUA_FIX_VECTOR3_MT);
        lua_setmetatable(L, -2);
        return 1;
    }
    return 0;
}

static int fx_lua_rotate_vetor3_around_y(lua_State* L)
{
    if (lua_gettop(L) >= 2)
    {
        FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
        if (p1 == NULL)
        {
            luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
            return 0;
        }

        double angle  = luaL_checknumber(L, 2);

        void* p = lua_newuserdata(L, sizeof(FixVector3));
        if (NULL == p)
        {
            luaL_error(L, "fx_lua_rotate_vetor3_around_y, lua_newuserdata mem error\n");
            return 0;
        }
        FixVector3* pret = (FixVector3*)(p);
        FixVector3_rotate_around_y_to(p1, fx_angle_to_radian(fx_dtox(angle, FRACT_LIMIT)), pret);
        luaL_getmetatable(L, LUA_FIX_VECTOR3_MT);
        lua_setmetatable(L, -2);
        return 1;
    }
    luaL_error(L, "invalid arguments:%d \n", lua_gettop(L));
    return 0;
}


static int fx_lua_vetor3_distance(lua_State* L)
{
    if (lua_gettop(L) >= 2)
    {
        FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
        if (p1 == NULL)
        {
            luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
            return 0;
        }
        FixVector3* p2 = (FixVector3*)(luaL_checkudata(L, 2, LUA_FIX_VECTOR3_MT));
        if (p2 == NULL)
        {
            luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
            return 0;
        }
        fixed_t ret = FixVector3_distance(p1, p2);
        lua_pushnumber(L, fx_xtod(ret, FRACT_LIMIT));
        return 1;
    }
    luaL_error(L, "invalid arguments:%d \n", lua_gettop(L));
    return 0;
}

static int fx_lua_pos_is_in_rect(lua_State* L)
{
    if (lua_gettop(L) >= 6)
    {
        FixVector3* pos = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
        if (pos == NULL)
        {
            luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
            return 0;
        }
        double targetRadius = luaL_checknumber(L, 2);
        double rectWidthHalf = luaL_checknumber(L, 3);
        double rectHeightHalf = luaL_checknumber(L, 4);
        FixVector3* centerPos = (FixVector3*)(luaL_checkudata(L, 5, LUA_FIX_VECTOR3_MT));
        if (centerPos  == NULL)
        {
            luaL_error(L, "invalid arguments:5 , empty data\n");
            return 0;
        }

        FixVector3* normalizedDir = (FixVector3*)(luaL_checkudata(L, 6, LUA_FIX_VECTOR3_MT));
        if (normalizedDir  == NULL)
        {
            luaL_error(L, "invalid arguments:6 , empty data\n");
            return 0;
        }
        if (FixVector3_is_in_rect(pos, targetRadius, rectWidthHalf, rectHeightHalf, centerPos, normalizedDir))
        {
            lua_pushboolean(L, 1);
        }
        else
        {
            lua_pushboolean(L, 0);
        }
        return 1;
    }
    return 0;
}

static int fx_lua_pos_is_in_sector(lua_State* L)
{
    if (lua_gettop(L) >= 6)
    {
        FixVector3* pos = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
        if (pos == NULL)
        {
            luaL_error(L, "invalid arguments:1 , empty data\n");
            return 0;
        }
        FixVector3* forward = (FixVector3*)(luaL_checkudata(L, 2, LUA_FIX_VECTOR3_MT));
        if (forward == NULL)
        {
            luaL_error(L, "invalid arguments:2 , empty data\n");
            return 0;
        }
        double dis1 = luaL_checknumber(L, 3);
        double dis2 = luaL_checknumber(L, 4);
        double angle = luaL_checknumber(L, 5);

        FixVector3* pos2 = (FixVector3*)(luaL_checkudata(L, 6, LUA_FIX_VECTOR3_MT));
        if (pos2  == NULL)
        {
            luaL_error(L, "invalid arguments:6 , empty data\n");
            return 0;
        }

        if (FixVector3_is_in_sector(pos, forward, dis1, dis2, angle, pos2))
        {
            lua_pushboolean(L, 1);
        }
        else
        {
            lua_pushboolean(L, 0);
        }
        return 1;

    }
    return 0;
}

static int fx_lua_pos_is_in_ring(lua_State* L)
{
    if (lua_gettop(L) >= 5)
    {
        FixVector3* center = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
        if (center == NULL)
        {
            luaL_error(L, "invalid arguments:1 , empty data\n");
            return 0;
        }
        double innerRadius = luaL_checknumber(L, 2);
        double outerRadius = luaL_checknumber(L, 3);
        FixVector3* tarPos = (FixVector3*)(luaL_checkudata(L, 4, LUA_FIX_VECTOR3_MT));
        if (tarPos == NULL)
        {
            luaL_error(L, "invalid arguments:2 , empty data\n");
            return 0;
        }

        double targetRadius = luaL_checknumber(L, 5);
        if (FixVector3_is_in_ring(center, innerRadius, outerRadius, tarPos, targetRadius))
        {
            lua_pushboolean(L, 1);
        }
        else
        {
            lua_pushboolean(L, 0);
        }
        return 1;
    }
    return 0;
}

static luaL_Reg fixmath_lua_lib[] = 
{
	{ "num2fx", fx_lua_num2fx},
	{ "sqrt", fx_lua_sqrt },
	{ "sqrti", fx_lua_sqrti },
	{ "pow", fx_lua_pow },
	{ "add", fx_lua_add },
	{ "sub", fx_lua_sub },
	{ "mul", fx_lua_mul },
	{ "muli", fx_lua_muli },
	{ "mul_hd", fx_lua_mul_hd },
	{ "exp", fx_lua_exp },
	{ "exp2", fx_lua_exp2 },
	{ "exp10", fx_lua_exp10 },
	{ "floor", fx_lua_floor },
	{ "round", fx_lua_round },
	{ "ceil", fx_lua_ceil },
	{ "abs", fx_lua_abs },
	{ "div", fx_lua_div },
	{ "divi", fx_lua_divi },
	{ "sin", fx_lua_sin },
	{ "cos", fx_lua_cos },
	{ "acos", fx_lua_acos },
	{ "cmp", fx_lua_cmp },
	{ "IsZero", fx_lua_iszero },
	{ "mod", fx_lua_mod },
    { "NewFixVector3", new_fix_vector3},
    { "Vector3Angle", fx_lua_angle_between_vetor3},
    //{ "Vector3AngleR", fx_lua_angle_r_between_vetor3},
    { "Vector3Normalize", fx_lua_normalize_vetor3},
    { "Vector3RotateAroundY", fx_lua_rotate_vetor3_around_y},
    { "Vector3Distance", fx_lua_vetor3_distance},
    { "IsInRect", fx_lua_pos_is_in_rect},
    { "IsInSector", fx_lua_pos_is_in_sector},
    { "IsInRing", fx_lua_pos_is_in_ring},
	{ NULL, NULL }
};

#ifdef __cplusplus
extern "C" {
#endif
LUALIB_API int luaopen_fixmath(lua_State* L)
{
    //lua_newtable(L);
    //luaL_setfuncs(L, fixmath_lua_lib, 0);
    luaL_newlib(L, fixmath_lua_lib);
    lua_setglobal(L, "FixMath");
    init_fix_vector3_lua(L);
    lua_settop(L, 0);
    return 1;
}
#ifdef __cplusplus
}
#endif

