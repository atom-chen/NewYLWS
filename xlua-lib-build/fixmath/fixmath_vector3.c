
#include "fixmath_vector3.h"

#ifdef __cplusplus
extern "C" {
#endif
#include <lualib.h>
#include <lauxlib.h>
#include <string.h>
#include "fixmath_acos.h"

#ifndef NULL
#define NULL 0
#endif


void FixVector3_add(FixVector3* p1, FixVector3* p2, FixVector3* pret)
{
    if (p1 && p2 && pret)
    {
        pret->x = fx_addx(p1->x, p2->x);
        pret->y = fx_addx(p1->y, p2->y);
        pret->z = fx_addx(p1->z, p2->z);
    }
}

void FixVector3_sub(FixVector3* p1, FixVector3* p2, FixVector3* pret)
{
    if (p1 && p2)
    {
        pret->x = fx_subx(p1->x, p2->x);
        pret->y = fx_subx(p1->y, p2->y);
        pret->z = fx_subx(p1->z, p2->z);
    }
}

void FixVector3_mul(FixVector3* p1, fixed_t factorx, FixVector3* pret)
{
    if (p1 && pret)
    {
        pret->x = fx_mulx(p1->x, factorx, V3_FRACT_LIMIT);
        pret->y = fx_mulx(p1->y, factorx, V3_FRACT_LIMIT);
        pret->z = fx_mulx(p1->z, factorx, V3_FRACT_LIMIT);
    }
}

void FixVector3_div(FixVector3* p1, fixed_t factorx, FixVector3* pret)
{
    if (p1 && pret)
    {
        pret->x = fx_divx(p1->x, factorx, V3_FRACT_LIMIT);
        pret->y = fx_divx(p1->y, factorx, V3_FRACT_LIMIT);
        pret->z = fx_divx(p1->z, factorx, V3_FRACT_LIMIT);
    }
}

fixed_t FixVector3_dot(FixVector3* p1, FixVector3* p2)
{
    if (p1 && p2)
    {
        return fx_addx(fx_addx(fx_mulx(p1->x, p2->x, V3_FRACT_LIMIT), fx_mulx(p1->y, p2->y, V3_FRACT_LIMIT)), fx_mulx(p1->z, p2->z, V3_FRACT_LIMIT));
    }
    return fx_dtox(0, V3_FRACT_LIMIT);
}

fixed_t FixVector3_dotxz(FixVector3* p1, FixVector3* p2)
{
    if (p1 && p2)
    {
        return fx_addx(fx_mulx(p1->x, p2->x, V3_FRACT_LIMIT), fx_mulx(p1->z, p2->z, V3_FRACT_LIMIT));
    }
    return fx_dtox(0, V3_FRACT_LIMIT);
}

fixed_t FixVector3_magnitude(FixVector3* p)
{
    if (p)
    {
       return fx_sqrtx(fx_addx(fx_addx(fx_mulx(p->x, p->x, V3_FRACT_LIMIT), fx_mulx(p->y, p->y, V3_FRACT_LIMIT)), fx_mulx(p->z, p->z, V3_FRACT_LIMIT)), V3_FRACT_LIMIT);
    }
    return fx_dtox(0, V3_FRACT_LIMIT);
}

fixed_t FixVector3_magnitude_2d(FixVector3* p)
{
    if (p)
    {
       return fx_sqrtx(fx_addx(fx_mulx(p->x, p->x, V3_FRACT_LIMIT), fx_mulx(p->z, p->z, V3_FRACT_LIMIT)), V3_FRACT_LIMIT);
    }
    return fx_dtox(0, V3_FRACT_LIMIT);
}

fixed_t FixVector3_sqr_magnitude(FixVector3* p)
{
    if (p)
    {
       return fx_addx(fx_addx(fx_mulx(p->x, p->x, V3_FRACT_LIMIT), fx_mulx(p->y, p->y, V3_FRACT_LIMIT)), fx_mulx(p->z, p->z, V3_FRACT_LIMIT));
    }
    return fx_dtox(0, V3_FRACT_LIMIT);
}

fixed_t FixVector3_sqr_magnitude_2d(FixVector3* p)
{
    if (p)
    {
       return fx_addx(fx_mulx(p->x, p->x, V3_FRACT_LIMIT), fx_mulx(p->z, p->z, V3_FRACT_LIMIT));
    }
    return fx_dtox(0, V3_FRACT_LIMIT);
}

fixed_t FixVector3_distance(FixVector3* p1, FixVector3* p2)
{
    if (p1 && p2)
    {
        FixVector3 s;
        FixVector3_sub(p2, p1, &s);
        return FixVector3_magnitude(&s);
    }
    return fx_dtox(0, V3_FRACT_LIMIT);
}

void FixVector3_normallize_to(FixVector3* p, FixVector3* pto, double clamp)
{
    if (p && pto)
    {
        fixed_t magn = FixVector3_magnitude(p);
        if (!FX_IS_ZERO(magn))
        {
            pto->x = fx_divx(p->x, magn, V3_FRACT_LIMIT);
            pto->y = fx_divx(p->y, magn, V3_FRACT_LIMIT);
            pto->z = fx_divx(p->z, magn, V3_FRACT_LIMIT);
        }
        else
        {
            pto->x = FX_ZERO;
            pto->y = FX_ZERO;
            pto->z = FX_ZERO;
        }
    }
}

void FixVector3_rotate_around_y_to(FixVector3* p, fixed_t xRadian, FixVector3* pto)
{
    if (p && pto)
    {
        pto->x = fx_addx(fx_mulx(p->z,  fx_sinx(xRadian, V3_FRACT_LIMIT), V3_FRACT_LIMIT), fx_mulx(p->x, fx_cosx(xRadian, V3_FRACT_LIMIT), V3_FRACT_LIMIT));
        pto->y = p->y;
        pto->z = fx_subx(fx_mulx(p->z,  fx_cosx(xRadian, V3_FRACT_LIMIT), V3_FRACT_LIMIT), fx_mulx(p->x, fx_sinx(xRadian, V3_FRACT_LIMIT), V3_FRACT_LIMIT));
    }
}

int FixVector3_is_in_rect(FixVector3* targetPos, double targetRadius, double rectWidthHalf, double rectHeightHalf, FixVector3* rectCenterPos, FixVector3* normalizedDir)
{
    if (NULL == targetPos || NULL == rectCenterPos || NULL == normalizedDir)
    {
        return 0;
    }
    //#define xtod(x) fx_xtod((x), V3_FRACT_LIMIT)
    fixed_t zero = fx_dtox(0, FRACT_LIMIT);
    FixVector3 normalizedVertDir;
    normalizedVertDir.x =  normalizedDir->z;
    normalizedVertDir.y =  zero;
    normalizedVertDir.z =  fx_subx(zero, normalizedDir->x);
    FixVector3 v;
    FixVector3_sub(targetPos, rectCenterPos, &v);
    v.y = zero;
    fixed_t vMagnitude = FixVector3_magnitude(&v);
    FixVector3 normalizedV;
    FixVector3_normallize_to(&v, &normalizedV, 1);

    //#define FX_ABS(x) ((x) < zero ) ? fx_subx(zero, (x)) : (x)
    fixed_t xTargetRadius = fx_dtox(targetRadius, V3_FRACT_LIMIT);
    fixed_t xRectHeightHalf = fx_dtox(rectHeightHalf, V3_FRACT_LIMIT);

    fixed_t xDirProject = fx_subx(FX_ABS(fx_mulx(FixVector3_dot(normalizedDir, &normalizedV), vMagnitude, V3_FRACT_LIMIT)), xTargetRadius);
    if (xDirProject > xRectHeightHalf)
    {
        return 0;
    }

    fixed_t xWidthHalf = fx_dtox(rectWidthHalf, V3_FRACT_LIMIT);
    fixed_t xVertDirProject = fx_subx(FX_ABS(fx_mulx(FixVector3_dot(&normalizedVertDir, &normalizedV), vMagnitude, V3_FRACT_LIMIT)), xTargetRadius);
    if (xVertDirProject > xWidthHalf)
    {
        return 0;
    }

    return 1;
}

int FixVector3_is_in_sector(FixVector3* srcPos, FixVector3* forward, double dis1, double dis2, double angle, FixVector3* tarPos)
{
    if (NULL == srcPos || NULL == forward || NULL == tarPos)
    {
        return 0;
    }
    FixVector3 targetDir;
    FixVector3_sub(tarPos, srcPos, &targetDir);
    fixed_t xTargetDis = FixVector3_sqr_magnitude(&targetDir);
    fixed_t xDis1 = fx_dtox(dis1, V3_FRACT_LIMIT);
    fixed_t xDis2 = fx_dtox(dis2, V3_FRACT_LIMIT);
    if (xTargetDis >= fx_mulx( xDis1, xDis1, V3_FRACT_LIMIT) && xTargetDis <= fx_mulx(xDis2, xDis2, V3_FRACT_LIMIT))
    {
        double r = FixVector3_angle_radian_d(&targetDir, forward);
        fixed_t xSectorAngle = fx_dtox(angle, V3_FRACT_LIMIT);
        if (fx_dtox(r, V3_FRACT_LIMIT) <= fx_mulx(fx_angle_to_radian(xSectorAngle) , fx_dtox(0.5f, V3_FRACT_LIMIT), V3_FRACT_LIMIT))
        {
            return 1;
        }
    }
    return 0;

}

int FixVector3_is_in_ring(FixVector3* center, double innerRadius, double outerRadius, FixVector3* tarPos, double targetRadius)
{
    if (NULL == center || NULL == tarPos)
    {
        return 0;
    } 
    fixed_t xInnerRadius = fx_dtox(innerRadius, V3_FRACT_LIMIT);
    fixed_t xOuterRadius = fx_dtox(outerRadius, V3_FRACT_LIMIT);
    fixed_t xTargetRadius = fx_dtox(targetRadius, V3_FRACT_LIMIT);

    FixVector3 targetDir;
    FixVector3_sub(tarPos, center, &targetDir);
    fixed_t xTargetDis = FixVector3_magnitude(&targetDir);
    if ((fx_addx(xTargetDis,xTargetRadius) >= xInnerRadius) && fx_subx(xTargetDis, xTargetRadius) <= xOuterRadius)
    {
        return 1;
    }
    return 0;
}

void FixVector3_crossto(FixVector3* p1, FixVector3* p2, FixVector3* pto)
{
    if (p1 && p2 && pto)
    {
        pto->x = fx_subx(fx_mulx(p1->y, p2->z, V3_FRACT_LIMIT), fx_mulx(p1->z, p2->y, V3_FRACT_LIMIT));
        pto->y = fx_subx(fx_mulx(p1->z, p2->x, V3_FRACT_LIMIT), fx_mulx(p1->x, p2->z, V3_FRACT_LIMIT));
        pto->z = fx_subx(fx_mulx(p1->x, p2->y, V3_FRACT_LIMIT), fx_mulx(p1->y, p2->x, V3_FRACT_LIMIT));
    }
}

double FixVector3_angle_radian_d(FixVector3* p1, FixVector3* p2)
{
    if (p1 && p2)
    {
        fixed_t m = fx_mulx(FixVector3_magnitude(p1), FixVector3_magnitude(p2), V3_FRACT_LIMIT);
        fixed_t d = FixVector3_dot(p1, p2);
        if (FX_IS_ZERO(m))
        {
            //TODO  notice error
            return 0;
        }
        double a = fx_xtod(fx_divx(d, m, V3_FRACT_LIMIT), V3_FRACT_LIMIT);
        return fx_acosd(a, V3_FRACT_LIMIT);
    }
    return 0;
}


int new_fix_vector3(lua_State* L)
{
    void* p = lua_newuserdata(L, sizeof(FixVector3));
    if (NULL == p)
    {
        luaL_error(L, "new_fix_vector3, lua_newuserdata mem error\n");
        return 0;
    }
    FixVector3* pv = (FixVector3*)(p);
    fixed_t xzero = fx_xtod(0, V3_FRACT_LIMIT);
    pv->x = xzero; pv->y = xzero; pv->z = xzero;
    int n = lua_gettop(L) - 1;
    if (n >= 1)
    {
        double d = luaL_checknumber(L, 1);
        pv->x = fx_dtox(d, V3_FRACT_LIMIT);
        if (n >= 2)
        {
            double d = luaL_checknumber(L, 2);
            pv->y = fx_dtox(d, V3_FRACT_LIMIT);
            if (n >= 3)
            {
                double d = luaL_checknumber(L, 3);
                pv->z = fx_dtox(d, V3_FRACT_LIMIT);
            }
        }
    }
    luaL_getmetatable(L, LUA_FIX_VECTOR3_MT);
    lua_setmetatable(L, -2);
    return 1;
}


static int luaapi_FixVector3_tostring(lua_State* L)
{
    FixVector3* p = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }
    char str[256] = {0};
    snprintf(str, sizeof(str), "{ x: %f, y: %f, z: %f}\n", fx_xtod(p->x, V3_FRACT_LIMIT), fx_xtod(p->y, V3_FRACT_LIMIT), fx_xtod(p->z, V3_FRACT_LIMIT));
    lua_pushstring(L, str);
    return 1;
}

static int luaapi_FixVector3_add(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
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
    void* p = lua_newuserdata(L, sizeof(FixVector3));
    if (NULL == p)
    {
        luaL_error(L, "luaapi_FixVector3_add, lua_newuserdata mem error\n");
        return 0;
    }
    FixVector3* pret = (FixVector3*)(p);
    fixed_t xzero = fx_xtod(0, V3_FRACT_LIMIT);
    pret->x = xzero; pret->y = xzero; pret->z = xzero;
    luaL_getmetatable(L, LUA_FIX_VECTOR3_MT);
    lua_setmetatable(L, -2);
    FixVector3_add(p1, p2, pret);
    return 1;
}

static int luaapi_FixVector3_equal(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
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

    int ret = 0;
    if (p1->x == p2->x && p1->y == p2->y && p1->z == p2->z)
    {
        ret = 1;
    }
    lua_pushboolean(L, ret);
    return 1;
}

static int luaapi_FixVector3_get_xyz(lua_State* L)
{
    if (lua_gettop(L) < 1)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }
    lua_pushnumber(L, fx_xtod(p->x, V3_FRACT_LIMIT));
    lua_pushnumber(L, fx_xtod(p->y, V3_FRACT_LIMIT));
    lua_pushnumber(L, fx_xtod(p->z, V3_FRACT_LIMIT));
    return 3;
}

static int luaapi_FixVector3_set_xyz(lua_State* L)
{
    if (lua_gettop(L) < 1)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }

    int n = lua_gettop(L);
    if (n >= 2)
    {
        double d = luaL_checknumber(L, 2);
        p->x = fx_dtox(d, V3_FRACT_LIMIT);
        if (n >= 3)
        {
            double d = luaL_checknumber(L, 3);
            p->y = fx_dtox(d, V3_FRACT_LIMIT);
            if (n >= 4)
            {
                double d = luaL_checknumber(L, 4);
                p->z = fx_dtox(d, V3_FRACT_LIMIT);
            }
        }
    }
    return 0;
}


static int luaapi_FixVector3_add_from(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p1 == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }

    FixVector3* pfrom = (FixVector3*)(luaL_checkudata(L, 2, LUA_FIX_VECTOR3_MT));
    if (pfrom == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }

    FixVector3_add(p1, pfrom, p1);
    return 1;
}

static int luaapi_FixVector3_sub(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
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
    void* p = lua_newuserdata(L, sizeof(FixVector3));
    if (NULL == p)
    {
        luaL_error(L, "luaapi_FixVector3_sub, lua_newuserdata mem error\n");
        return 0;
    }
    FixVector3* pret = (FixVector3*)(p);
    fixed_t xzero = fx_xtod(0, V3_FRACT_LIMIT);
    pret->x = xzero; pret->y = xzero; pret->z = xzero;
    luaL_getmetatable(L, LUA_FIX_VECTOR3_MT);
    lua_setmetatable(L, -2);
    FixVector3_sub(p1, p2, pret);
    return 1;
}

static int luaapi_FixVector3_sub_from(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
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
    FixVector3_sub(p1, p2, p1);
    lua_pushnil(L);
    return 1;
}

static int luaapi_FixVector3_mul(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p1 == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }
    if (!lua_isnumber(L,2))
    {
        luaL_error(L, "invalid arguments: index 2 , is not num\n");
        return 0;
    }
    double factor = luaL_checknumber(L, 2);

    void* p = lua_newuserdata(L, sizeof(FixVector3));
    if (NULL == p)
    {
        luaL_error(L, "luaapi_FixVector3_mul, lua_newuserdata mem error\n");
        return 0;
    }
    FixVector3* pret = (FixVector3*)(p);
    fixed_t xzero = fx_xtod(0, V3_FRACT_LIMIT);
    pret->x = xzero; pret->y = xzero; pret->z = xzero;
    luaL_getmetatable(L, LUA_FIX_VECTOR3_MT);
    lua_setmetatable(L, -2);
    FixVector3_mul(p1, fx_dtox(factor, V3_FRACT_LIMIT), pret);
    return 1;
}

static int luaapi_FixVector3_mul_from(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p1 == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }
    if (!lua_isnumber(L,2))
    {
        luaL_error(L, "invalid arguments: index 2 , is not num\n");
        return 0;
    }
    double factor = luaL_checknumber(L, 2);
    FixVector3_mul(p1, fx_dtox(factor, V3_FRACT_LIMIT), p1);
    lua_pushnil(L);
    return 1;
}


static int luaapi_FixVector3_div(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p1 == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }
    if (!lua_isnumber(L,2))
    {
        luaL_error(L, "invalid arguments: index 2 , is not num\n");
        return 0;
    }
    double factor = luaL_checknumber(L, 2);

    void* p = lua_newuserdata(L, sizeof(FixVector3));
    if (NULL == p)
    {
        luaL_error(L, "luaapi_FixVector3_mul, lua_newuserdata mem error\n");
        return 0;
    }
    FixVector3* pret = (FixVector3*)(p);
    fixed_t xzero = fx_xtod(0, V3_FRACT_LIMIT);
    pret->x = xzero; pret->y = xzero; pret->z = xzero;
    luaL_getmetatable(L, LUA_FIX_VECTOR3_MT);
    lua_setmetatable(L, -2);
    fixed_t xfactor = fx_dtox(factor, V3_FRACT_LIMIT);
    if (FX_IS_ZERO(xfactor))
    {
        luaL_error(L, "luaapi_FixVector3_div, div zero\n");
        return 0;
    }
    FixVector3_div(p1, xfactor, pret);
    return 1;
}

static int luaapi_FixVector3_div_from(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p1 == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }
    if (!lua_isnumber(L,2))
    {
        luaL_error(L, "invalid arguments: index 2 , is not num\n");
        return 0;
    }
    double factor = luaL_checknumber(L, 2);
    fixed_t xfactor = fx_dtox(factor, V3_FRACT_LIMIT);
    if (FX_IS_ZERO(xfactor))
    {
        luaL_error(L, "luaapi_FixVector3_div_from, div zero\n");
        return 0;
    }
    FixVector3_div(p1, xfactor, p1);
    return 0;
}

static int luaapi_FixVector3_dot(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
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
    lua_pushnumber(L, fx_xtod(FixVector3_dot(p1, p2), V3_FRACT_LIMIT));
    return 1;
}

//static int luaapi_FixVector3_dotxz(lua_State* L)
//{
//    if (lua_gettop(L) < 2)
//    {
//        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
//        return 0;
//    }
//    FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
//    if (p1 == NULL)
//    {
//        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
//        return 0;
//    }

//    FixVector3* p2 = (FixVector3*)(luaL_checkudata(L, 2, LUA_FIX_VECTOR3_MT));
//    if (p2 == NULL)
//    {
//        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
//        return 0;
//    }
//    lua_pushnumber(L, fx_xtod(FixVector3_dotxz(p1, p2), V3_FRACT_LIMIT));
//    return 1;
//}

static int luaapi_FixVector3_crossto(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
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

    void* p = lua_newuserdata(L, sizeof(FixVector3));
    if (NULL == p)
    {
        luaL_error(L, "luaapi_FixVector3_crossto, lua_newuserdata mem error\n");
        return 0;
    }
    FixVector3* pret = (FixVector3*)(p);
    fixed_t xzero = fx_xtod(0, V3_FRACT_LIMIT);
    pret->x = xzero; pret->y = xzero; pret->z = xzero;
    luaL_getmetatable(L, LUA_FIX_VECTOR3_MT);
    lua_setmetatable(L, -2);
    FixVector3_crossto(p1, p2, pret);
    return 1;
}

static int luaapi_FixVector3_magnitude(lua_State* L)
{
    if (lua_gettop(L) < 1)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p1 == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }

    lua_pushnumber(L, fx_xtod(FixVector3_magnitude(p1), V3_FRACT_LIMIT));
    return 1;
}

static int luaapi_FixVector3_magnitude_2d(lua_State* L)
{
    if (lua_gettop(L) < 1)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p1 == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }

    lua_pushnumber(L, fx_xtod(FixVector3_magnitude_2d(p1), V3_FRACT_LIMIT));
    return 1;
}

static int luaapi_FixVector3_sqr_magnitude(lua_State* L)
{
    if (lua_gettop(L) < 1)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p1 == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }

    lua_pushnumber(L, fx_xtod(FixVector3_sqr_magnitude(p1), V3_FRACT_LIMIT));
    return 1;
}

static int luaapi_FixVector3_sqr_magnitude_2d(lua_State* L)
{
    if (lua_gettop(L) < 1)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p1 == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }

    lua_pushnumber(L, fx_xtod(FixVector3_sqr_magnitude_2d(p1), V3_FRACT_LIMIT));
    return 1;
}

static int luaapi_FixVector3_sqr_iszero(lua_State* L)
{
    if (lua_gettop(L) < 1)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p1 == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }

    if (FX_IS_ZERO(p1->x) && FX_IS_ZERO(p1->y) && FX_IS_ZERO(p1->z))
    {
        lua_pushboolean(L, 1);
        return 1;
    }
    lua_pushboolean(L, 0);
    return 1;
}

static int luaapi_FixVector3_clone(lua_State* L)
{
    if (lua_gettop(L) < 1)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p1 = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p1 == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }

    void* p = lua_newuserdata(L, sizeof(FixVector3));
    if (NULL == p)
    {
        luaL_error(L, "luaapi_FixVector3_clone, lua_newuserdata mem error\n");
        return 0;
    }
    FixVector3* pret = (FixVector3*)(p);
    pret->x = p1->x; pret->y = p1->y; pret->z = p1->z;
    luaL_getmetatable(L, LUA_FIX_VECTOR3_MT);
    lua_setmetatable(L, -2);
    return 1;
}

static int luaapi_FixVector3_copyto(lua_State* L)
{
    if (lua_gettop(L) < 1)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
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

    p2->x = p1->x; p2->y = p1->y; p2->z = p1->z;
    luaL_getmetatable(L, LUA_FIX_VECTOR3_MT);
    lua_setmetatable(L, -2);
    return 1;
}

static int luaapi_FixVector3_get(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }
    const char *pcFieldName = luaL_checkstring(L, 2);
    if (pcFieldName == NULL)
    {
        luaL_error(L, "invalid arguments:%d , no field name\n", lua_gettop(L));
        return 0;
    }
    if (strcmp(pcFieldName , "x") == 0)
    {
        lua_pushnumber(L, fx_xtod(p->x, V3_FRACT_LIMIT));
        return 1;
    }
    if (strcmp(pcFieldName , "y") == 0)
    {
        lua_pushnumber(L, fx_xtod(p->y, V3_FRACT_LIMIT));
        return 1;
    }
    if (strcmp(pcFieldName , "z") == 0)
    {
        lua_pushnumber(L, fx_xtod(p->z, V3_FRACT_LIMIT));
        return 1;
    }

    if (strcmp(pcFieldName , "GetXYZ") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_get_xyz);
        return 1;
    }
    if (strcmp(pcFieldName , "SetXYZ") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_set_xyz);
        return 1;
    }
    if (strcmp(pcFieldName , "Add") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_add_from);
        return 1;
    }
    if (strcmp(pcFieldName , "Sub") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_sub_from);
        return 1;
    }
    if (strcmp(pcFieldName , "Mul") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_mul_from);
        return 1;
    }
    if (strcmp(pcFieldName , "Div") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_div_from);
        return 1;
    }
    if (strcmp(pcFieldName , "Dot") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_dot);
        return 1;
    }
    //if (strcmp(pcFieldName , "dotxz") == 0)
    //{
    //    lua_pushcfunction(L, luaapi_FixVector3_dotxz);
    //    return 1;
    //}
    if (strcmp(pcFieldName , "CrossTo") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_crossto);
        return 1;
    }

    if (strcmp(pcFieldName , "Clone") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_clone);
        return 1;
    }

    if (strcmp(pcFieldName , "CopyTo") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_copyto);
        return 1;
    }

    if (strcmp(pcFieldName , "Magnitude") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_magnitude);
        return 1;
    }

    if (strcmp(pcFieldName , "Magnitude2D") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_magnitude_2d);
        return 1;
    }

    if (strcmp(pcFieldName , "SqrMagnitude") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_sqr_magnitude);
        return 1;
    }

    if (strcmp(pcFieldName , "SqrMagnitude2D") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_sqr_magnitude_2d);
        return 1;
    }

    if (strcmp(pcFieldName , "IsZero") == 0)
    {
        lua_pushcfunction(L, luaapi_FixVector3_sqr_iszero);
        return 1;
    }
    return 0;
}

static int luaapi_FixVector3_set(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    FixVector3* p = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    if (p == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }
    const char *pcFieldName = luaL_checkstring(L, 2);
    if (pcFieldName == NULL)
    {
        luaL_error(L, "invalid arguments:%d , no field name\n", lua_gettop(L));
        return 0;
    }
    if (strcmp(pcFieldName , "x") == 0)
    {
        double d = luaL_checknumber(L, 3);
        p->x = fx_dtox(d, V3_FRACT_LIMIT);
        lua_pushnumber(L, 1);
        return 1;
    }
    if (strcmp(pcFieldName , "y") == 0)
    {
        double d = luaL_checknumber(L, 3);
        p->y = fx_dtox(d, V3_FRACT_LIMIT);
        lua_pushnumber(L, 1);
        return 1;
    }
    if (strcmp(pcFieldName , "z") == 0)
    {
        double d = luaL_checknumber(L, 3);
        p->z = fx_dtox(d, V3_FRACT_LIMIT);
        lua_pushnumber(L, 1);
        return 1;
    }

    return 0;
}

static int luaapi_FixVector3_gc(lua_State* L)
{
    //FixVector3* p = (FixVector3*)(luaL_checkudata(L, 1, LUA_FIX_VECTOR3_MT));
    //if (p == NULL)
    //{
    //    luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
    //    return 0;
    //}
    //printf("__gc %x \n", (unsigned long)(p));
    //delete p;
    return 0;
}

int init_fix_vector3_lua(lua_State* L)
{
    luaL_newmetatable(L, LUA_FIX_VECTOR3_MT);
    lua_pushstring(L, "__newindex");
	lua_pushcfunction(L, luaapi_FixVector3_set);
	lua_settable(L, -3);
    lua_pushstring(L, "__index");
    lua_pushcfunction(L, luaapi_FixVector3_get);
	lua_settable(L, -3);
    lua_pushstring(L, "__tostring");
    lua_pushcfunction(L, luaapi_FixVector3_tostring);
	lua_settable(L, -3);
    lua_pushstring(L, "__add");
    lua_pushcfunction(L, luaapi_FixVector3_add);
	lua_settable(L, -3);
    lua_pushstring(L, "__sub");
    lua_pushcfunction(L, luaapi_FixVector3_sub);
	lua_settable(L, -3);
    lua_pushstring(L, "__mul");
    lua_pushcfunction(L, luaapi_FixVector3_mul);
	lua_settable(L, -3);
    lua_pushstring(L, "__div");
    lua_pushcfunction(L, luaapi_FixVector3_div);
	lua_settable(L, -3);
    lua_pushstring(L, "__eq");
    lua_pushcfunction(L, luaapi_FixVector3_equal);
	lua_settable(L, -3);

	lua_pushstring(L, "__gc");
	lua_pushcfunction(L, luaapi_FixVector3_gc);
	lua_settable(L, -3);

	lua_pop(L, 1);	//matetable->LUA_FIX_VECTOR3_MT
	return 0;
}

#ifdef __cplusplus
}
#endif
