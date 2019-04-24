
#ifndef FIX_VECTOR3_H
#define FIX_VECTOR3_H

#ifdef __cplusplus
extern "C" {
#endif

#include "fixmath.h"
#include <lualib.h>
#include <lauxlib.h>


#define LUA_FIX_VECTOR3_MT "FixVector3_mt"

typedef struct {
    fixed_t x;
    fixed_t y;
    fixed_t z;
} FixVector3;

extern fixed_t FixVector3_magnitude(FixVector3* p);
extern void FixVector3_sub(FixVector3* p1, FixVector3* p2, FixVector3* pret);
extern void FixVector3_crossto(FixVector3* p1, FixVector3* p2, FixVector3* pto);
extern double FixVector3_angle_radian_d(FixVector3* p1, FixVector3* p2);
extern void FixVector3_rotate_around_y_to(FixVector3* p, fixed_t xdigree, FixVector3* pto);
extern int new_fix_vector3(lua_State* L);
extern int init_fix_vector3_lua(lua_State* L);
extern void FixVector3_normallize_to(FixVector3* p, FixVector3* pto, double clamp);
extern int FixVector3_is_in_rect(FixVector3* targetPos, double targetRadius, double rectWidthHalf, double rectHeightHalf, FixVector3* rectCenterPos, FixVector3* normalizedDir);
extern int FixVector3_is_in_sector(FixVector3* srcPos, FixVector3* forward, double dis1, double dis2, double angle, FixVector3* tarPos);
extern int FixVector3_is_in_ring(FixVector3* center, double innerRadius, double outerRadius, FixVector3* tarPos, double targetRadius);
extern fixed_t FixVector3_distance(FixVector3* p1, FixVector3* p2);

#define V3_FRACT_LIMIT  FRACT_LIMIT


#ifdef __cplusplus
}
#endif

#endif //FIX_VECTOR3_H