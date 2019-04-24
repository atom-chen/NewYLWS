#include <string.h>
#include <math.h>
#include <stdlib.h>
#include "fixmath/fixmath.h"
#include "fixmath_vector3.h"
#include <lualib.h>
#include <lauxlib.h>

#define BLOCK_HEIGHT 2.0
#define BLOCK_NEGATIVE_HEIGHT -5.0

#define Dir_x       (1 << 0)
#define Dir_xz      (1 << 1)
#define Dir_z       (1 << 2)
#define Dir_nxz     (1 << 3)
#define Dir_nx      (1 << 4)
#define Dir_nxnz    (1 << 5)
#define Dir_nz      (1 << 6)
#define Dir_xnz     (1 << 7)

#define Sequential  0    //顺序遍历
#define NoSolution  2    //无解决方案
#define Infinity    0xfffffff

#ifndef NULL
#define NULL 0
#endif

#define ZERO(x) F_IS_ZERO(x)

#define LUA_PATHING_HANDLE_MT "PathingHandler_mt"

#ifndef bool
    #define bool int
#endif
#ifndef false
    #define false 0
#endif
#ifndef true
    #define true 1
#endif

typedef struct 
{
    double x; double y; double z;
    int c, r;
    char blocked;
    int neighbors;
} Cell;



typedef struct
{
    signed char c, r;
} CRPoint;



static const CRPoint Dir[8] =
{
    {1, 0},   // dir x
    {1, 1},   // dir xz
    {0, 1},   // dir z 
    {-1, 1},   // dir nxz
    {-1, 0},  // dir nx
    {-1, -1}, // dir nxnz
    {0, -1},  // dir nz
    {1, -1},  // dir xnz 
};

typedef struct
{
    double x;
    double y;
    double z;
} V3;

//typedef struct
//{
//    fixed_t x;
//    fixed_t y;
//    fixed_t z;
//} FxPosition;

typedef FixVector3 FxPosition;
typedef V3 Position;


typedef struct
{
    int pointNum;
    Position* points;
    V3* nomals;
}Area;

typedef struct 
{
    double originx;
    double originz;
    double cellSize;
    int c;  /// 对应x 
    int r;  /// 对应z
    Cell** cellMatrix;

    int battleAreaNum;
    Area* battleAreas;
} Matrix;

typedef struct Close
{
    Cell *cur;
    char vis;
    struct Close *from;
    double F, G;
    double H;
} Close;

// typedef struct CloseMark
// {
//     Close* curr;
//     struct CloseMark* next; 
// } CloseMark;

typedef struct //优先队列（Open表）
{
    int length;        //当前队列的长度
    Close** Array;    //评价结点的指针
} Open;

typedef struct PathingCtrlObj
{
    Matrix matrix;
    Open open;
    Close** close; 
    // CloseMark* closeMark;
    double srcX, srcZ, dstX, dstZ;    //起始点、终点
    int srcC, srcR, dstC, dstR;
    int cellnum;

    Position srcPos;
    Position dstPos;

    double baseMoveCost;
    double (*_H)(struct PathingCtrlObj* , int,int,int,int);
    double (*_G)(struct PathingCtrlObj* , int,int,int,int);
} PathingCtrlObj;

static int _hittest_in_area(bool bAll, Area* area, FxPosition* fxa, FxPosition* fxb, FxPosition* fxc, FxPosition* fxd, double *cx, double* cz, int* seg);
static void posintToFx(Position* p, FxPosition* px);


static int getCellFromXZ(Matrix* pMatrix, double x, double z, int* c, int* r)
{
    if (NULL == pMatrix || (pMatrix->cellSize <= 0))
    {
        return -1;
    }
    fixed_t xcellsize = FX_DTOX(pMatrix->cellSize);
    if (FX_IS_ZERO(xcellsize))
    {
        return -2;
    }
    fixed_t half_xcellsize = FX_DIVX(xcellsize, FX_DTOX(2));
    //printf("originx %f, originz %f, cellsize %f \n", pMatrix->originx, pMatrix->originz, pMatrix->cellSize);
    int _c = FX_XTOD(FX_DIVX(FX_ADDX(FX_SUBX(FX_DTOX(x), FX_DTOX(pMatrix->originx)), half_xcellsize), xcellsize));
    int _r = FX_XTOD(FX_DIVX(FX_ADDX(FX_SUBX(FX_DTOX(z), FX_DTOX(pMatrix->originz)), half_xcellsize), xcellsize));
    //printf("_c %d, _r %d \n", _c, _r);
    if (_c < 0) return -2;
    if (_r < 0) return -3;
    if (_c >= pMatrix->c) return -3;
    if (_r >= pMatrix->r) return -4;
    *c = _c;
    *r = _r;
    return 0;
}

static int getYFromXZ(Matrix* pMatrix, double x, double z, double* y)
{
    if (NULL == pMatrix || (pMatrix->cellSize <= 0))
    {
        return -1;
    }
    //printf("originx %f, originz %f, cellsize %f \n", pMatrix->originx, pMatrix->originz, pMatrix->cellSize);
    fixed_t xcellsize = FX_DTOX(pMatrix->cellSize);
    if (FX_IS_ZERO(xcellsize))
    {
        return -2;
    }
    fixed_t half_xcellsize = FX_DIVX(xcellsize, FX_DTOX(2));
    int _c = FX_XTOD(FX_DIVX(FX_ADDX(FX_SUBX(FX_DTOX(x), FX_DTOX(pMatrix->originx)), half_xcellsize), xcellsize));
    int _r = FX_XTOD(FX_DIVX(FX_ADDX(FX_SUBX(FX_DTOX(z), FX_DTOX(pMatrix->originz)), half_xcellsize), xcellsize));
    //printf("_c %d, _r %d \n", _c, _r);
    if (_c < 0) return -2;
    if (_r < 0) return -3;
    if (_c >= pMatrix->c) return -3;
    if (_r >= pMatrix->r) return -4;
    *y = pMatrix->cellMatrix[_c][_r].y;
    return 0;
}

static int getCrossDirToNeighbor(int c, int r, int _c, int _r)
{
    int dc = _c - c;
    int dr = _r - r;
    if (dc > 1 || dc < -1 || dr > 1 || dr < -1)
    {
        return -1;
    }
    if (dc == 1 && dr == 0) return Dir_x;
    if (dc == 1 && dr == 1) return Dir_xz;
    if (dc == 0 && dr == 1) return Dir_z;
    if (dc == -1 && dr == 1) return Dir_nxz;
    if (dc == -1 && dr == 0) return Dir_nx;
    if (dc == -1 && dr == -1) return Dir_nxnz;
    if (dc == 0 && dr == -1) return Dir_nz;
    if (dc == 1 && dr == -1) return Dir_xnz;
	return 0;
}

static int malloccellMatrix(Matrix* pMatrix)
{
    if (pMatrix->cellMatrix != NULL )
    {
        return -11;
    }
    if (pMatrix->c == 0 || pMatrix->r == 0)
    {
        return -12;
    }
    pMatrix->cellMatrix = (Cell**)malloc(pMatrix->c * sizeof(Cell*));
    if (pMatrix->cellMatrix == NULL )
    {
        return -13;
    }
    for (int i = 0; i < pMatrix->c; ++ i)
    {
        Cell* p = (Cell*)malloc(pMatrix->r * sizeof(Cell));
        if (p == NULL)
        {
            return -14;
        }
        memset(p, 0, pMatrix->r*sizeof(Cell));
        pMatrix->cellMatrix[i] = p;
    }
    return 0;
}

static void freecellMatrix(Matrix* pMatrix)
{
    if (pMatrix->cellMatrix == NULL )
    {
        return;
    }
    if (pMatrix->c == 0 || pMatrix->r == 0)
    {
        return;
    }
    for (int i = 0; i < pMatrix->c; ++ i)
    {
        Cell* p = pMatrix->cellMatrix[i];
        if (p)
        {
            free(p);
            pMatrix->cellMatrix[i] = 0;
        }
    }
    if (pMatrix->battleAreas)
    {
        for (int i = 0; i < pMatrix->battleAreaNum; ++ i)
        {
            Area* a = &(pMatrix->battleAreas[i]);
            if (a->points)
            {
                free(a->points);
                a->points = 0;
                a->pointNum = 0;
            }
            if (a->nomals)
            {
                free(a->nomals);
                a->nomals = 0;
            }
        }
        free(pMatrix->battleAreas);
        pMatrix->battleAreas = 0;
    }
    pMatrix->battleAreaNum = 0;

    free(pMatrix->cellMatrix);
    pMatrix->cellMatrix = 0;
}

int loadcellMatrix(lua_State* L, Matrix* pMatrix)
{
    if (pMatrix == NULL) 
    {
        return 100;
    }
    if (pMatrix->cellMatrix != NULL)
    {
        return 101;
    }

    if (!lua_istable(L, -1)) 
    {
        luaL_error(L,"loadcellMatrix error! is not a table \n");
        return 3;
    }
    int columns, rows = 0;
    double cellSize = 0;
    if (lua_getfield(L, -1, "columns"))
    {
        columns = lua_tointeger(L, -1);
    }
    else
    {
        return 4;
    }
    lua_pop(L, 1);
    if (lua_getfield(L, -1, "rows"))
    {
        rows = lua_tointeger(L, -1);
    }
    else
    {
        return 5;
    }
    lua_pop(L, 1);
    if (lua_getfield(L, -1, "cellSize"))
    {
        cellSize = (double)(lua_tonumber(L, -1));
    }
    else
    {
        return 6;
    }
    lua_pop(L, 1);
    if (columns == 0 || rows == 0)
    {
        return 7;
    }


    pMatrix->c = columns;
    pMatrix->r = rows;
    pMatrix->cellSize = cellSize;

    if (lua_getfield(L, -1, "battleareas"))
    {
        if (!lua_istable(L, -1)) 
        {
            luaL_error(L,"error rects should be table\n");
            return 20;
        }

        lua_pushnil(L);

        int areaNum = lua_rawlen(L, -2);
        if (areaNum > 0)
        {
            pMatrix->battleAreaNum = areaNum;
            pMatrix->battleAreas = (Area*)malloc(pMatrix->battleAreaNum*sizeof(Area));
            memset(pMatrix->battleAreas, 0, pMatrix->battleAreaNum*sizeof(Area));
            int areaIndex = 0;
            while (lua_next(L, -2) != 0)
            {
                if (!lua_istable(L, -1) || !lua_isnumber(L, - 2))
                {
                    luaL_error(L,"error , battleareas key or value type error\n");
                    return 51;
                }
                if (areaIndex >= areaNum)
                {
                    luaL_error(L,"error , battleareas too many\n");
                    return 52;
                }
                lua_pushnil(L);
                int pointNum = lua_rawlen(L, -2);
                if (pointNum > 0)
                {
                    Area* curArea = &(pMatrix->battleAreas[areaIndex]);
                    curArea->pointNum = pointNum;
                    curArea->points = (Position*)malloc(pointNum*sizeof(Position));
                    curArea->nomals = (V3*)malloc(pointNum*sizeof(V3));
                    memset(curArea->points, 0, pointNum*sizeof(Position));
                    memset(curArea->nomals, 0, pointNum*sizeof(V3));
                    int i = 0;
                    while (lua_next(L, -2))
                    {
                        if (!lua_istable(L, -1))
                        {
                            luaL_error(L,"error , battleareas index %d , data error\n", areaIndex);
                            return 61;
                        }
                        if (i >= pointNum)
                        {
                            luaL_error(L,"error , points too many\n");
                            return 52;
                        }
                        Position* curPoint = &(curArea->points[i]);
                        if (lua_getfield(L, -1, "x"))
                        {
                            curPoint->x = lua_tonumber(L, -1);
                        }
                        lua_pop(L, 1);
                        if (lua_getfield(L, -1, "y"))
                        {
                            curPoint->y = lua_tonumber(L, -1);
                        }
                        lua_pop(L, 1);
                        if (lua_getfield(L, -1, "z"))
                        {
                            curPoint->z = lua_tonumber(L, -1);
                        }
                        lua_pop(L, 1);
                        ++ i;
                        lua_pop(L, 1);
                    }
                    ++ areaIndex;
                    lua_pop(L, 1);
                }
            }
        } 
        else 
        {
            lua_pop(L, 1);
        }

    }
    lua_pop(L, 1);

    int ret = malloccellMatrix(pMatrix);
    if (ret)
    {
        return ret;
    }
    if (lua_getfield(L, -1, "matrix"))
    {
        if (!lua_istable(L, -1)) 
        {
            luaL_error(L,"error matrix should be table\n");
            return 20;
        }
        pMatrix->cellMatrix[0][0].c = -1;
        double originx = 0.0, originz = 0.0;
        double curry = 0.0;
        int currb = 0;

        for (int c = 1; c <= columns; ++ c)
        {
            //lua_pushinteger(L, c);
            lua_rawgeti(L, -1, c);
            if (!lua_istable(L, -1))
            {
                luaL_error(L,"error , matrix key or value type error\n");
                return 21;
            }

            curry = 0;
            currb = 0;
            for (int r = 1; r <= rows; ++ r)
            {
                lua_rawgeti(L, -1, r);
                double x , y, z = 0.0; 
                int blocked = 0;
                if (lua_isnil(L, -1))
                {
                    if (r == 1)
                    {
                        luaL_error(L,"error , matrix column %d , must have first cell\n", c);
                        return 33;
                    }
                    x = FX_XTOD(FX_ADDX(FX_DTOX(originx), FX_MULX(FX_SUBX(FX_DTOX(c), FX_DTOX(1)), FX_DTOX(pMatrix->cellSize))));
                    y = curry;
                    z = FX_XTOD(FX_ADDX(FX_DTOX(originz), FX_MULX(FX_SUBX(FX_DTOX(r), FX_DTOX(1)), FX_DTOX(pMatrix->cellSize))));
                    blocked = currb;
                }
                else
                {
                    if (!lua_istable(L, -1))
                    {
                        luaL_error(L,"error , matrix column %d , data error\n", c);
                        return 31;
                    }
                    lua_rawgeti(L, -1, 1);
                    if (!lua_istable(L, -1))
                    {
                        return 40;
                    }
                    if (lua_getfield(L, -1, "x"))
                    {
                        x = lua_tonumber(L, -1);
                    }
                    else
                    {
                        x = FX_XTOD(FX_ADDX(FX_DTOX(originx), FX_MULX(FX_SUBX(FX_DTOX(c), FX_DTOX(1)), FX_DTOX(pMatrix->cellSize))));
                    }
                    lua_pop(L, 1);
                    if (lua_getfield(L, -1, "y"))
                    {
                        y = lua_tonumber(L, -1);
                        curry = y;
                    }
                    else
                    {
                        y = curry;
                    }
                    lua_pop(L, 1);
                    if (lua_getfield(L, -1, "z"))
                    {
                        z = lua_tonumber(L, -1);
                    }
                    else
                    {
                        z = FX_XTOD(FX_ADDX(FX_DTOX(originz), FX_MULX(FX_SUBX(FX_DTOX(r), FX_DTOX(1)), FX_DTOX(pMatrix->cellSize))));
                    }
                    lua_pop(L, 1);

                    lua_pop(L,1);

                    lua_rawgeti(L, -1, 2);
                    if (lua_isnil(L, -1))
                    {
                        blocked = currb;
                    }
                    else
                    {
                        blocked = lua_tointeger(L, -1);
                        currb = blocked;
                    }
                    lua_pop(L,1);
                }

                lua_pop(L,1);

                Cell* pCell = &(pMatrix->cellMatrix[c-1][r-1]);
                pCell->x = x;
                pCell->y = y;
                pCell->z = z;
                pCell->c = c - 1;
                pCell->r = r - 1;
                pCell->blocked = (char)blocked;

                /// cell 第一个必须要有, 这里不考虑没有的情况
                if (c == 1 && r == 1)
                {
                    originx = x;
                    originz = z;
                }
            }
            lua_pop(L, 1);
        }
        pMatrix->originx = originx;
        pMatrix->originz = originz;
    }
    lua_pop(L, 1);

    return 0;
}

static int init_battlearea(Area* pArea)
{
    // 求出每条线段向内的法线
    if (NULL == pArea)
    {
        return -1;
    }

    FxPosition xm;
    int bxmsettted = 0;
    for (int i = 0; i < pArea->pointNum; ++ i)
    {
        Position* a = &(pArea->points[0]);
        Position* b = &(pArea->points[i]);
        FxPosition xa, xb;
        posintToFx(a, &xa);
        posintToFx(b, &xb);
        FixVector3_crossto(&xa, &xb, &xm);
        fixed_t magn = FixVector3_magnitude(&xm);
        if (magn > FX_ZERO)
        {
            bxmsettted = 1;
            break;
        }
    }
    //printf("xm (%f, %f, %f)\n", FX_XTOD(xm.x), FX_XTOD(xm.y), FX_XTOD(xm.z));
    if (bxmsettted == 0)
    {
        return -2;
    }
    for (int i = 0; i < pArea->pointNum; ++ i)
    {
        Position* a = &(pArea->points[i]);
        Position* b = 0;
        if (i == pArea->pointNum - 1)
        {
            b = &(pArea->points[0]);
        } 
        else
        {
            b = &(pArea->points[i + 1]);
        }
        FxPosition xa, xb, xab, xn;
        //printf("a (%f, %f, %f)\n", a->x,a->y,a->z);
        //printf("b (%f, %f, %f)\n", b->x,b->y,b->z);
        posintToFx(a, &xa);
        posintToFx(b, &xb);
        FixVector3_sub(&xb, &xa, &xab);
        //printf("xab (%f, %f, %f)\n", FX_XTOD(xab.x), FX_XTOD(xab.y), FX_XTOD(xab.z));
        
        FixVector3_crossto(&xm, &xab, &xn);
        //FixVector3_crossto(&xab, &xm, &xn);
        FixVector3 xnn;
        fixed_t magn = FixVector3_magnitude(&xn);

        //printf("-------------------(%f, %f, %f)\n", FX_XTOD(xn.x), FX_XTOD(xn.y), FX_XTOD(xn.z));
        while (magn > FX_DTOX(100))
        {
            //printf("magn is %f \n", FX_XTOD(magn));
            // 缩小一点
            magn = FX_DTOX(100);
            fixed_t factor = FX_DIVX(FX_DTOX(1), magn);
            xn.x = FX_MULX(xn.x, factor);
            xn.y = FX_MULX(xn.y, factor);
            xn.z = FX_MULX(xn.z, factor);
        }

        if (magn <= FX_DTOX(0.1))
        {
            //printf("magn is %f \n", FX_XTOD(magn));
            magn = FX_DTOX(0.1);
        }
        fixed_t factor = FX_DIVX(FX_DTOX(3), magn);

        //printf("get normal of %d is (%f, %f, %f) \n", i, FX_XTOD(xn.x), FX_XTOD(xn.y), FX_XTOD(xn.z));
        xnn.x = FX_MULX(xn.x, factor);
        xnn.y = FX_MULX(xn.y, factor);
        xnn.z = FX_MULX(xn.z, factor);
        //FixVector3_normallize_to(&xn, &xnn);
        //printf("get n normal of %d is (%f, %f, %f) \n", i, FX_XTOD(xnn.x), FX_XTOD(xnn.y), FX_XTOD(xnn.z));
        /// 求出了法线， 还需要判断是否向区域内
        FxPosition xmid;
        FxPosition xinf;
        const fixed_t nfx2 = FX_DTOX(2);
        const fixed_t ffxnear = FX_DTOX(0.1);
        const fixed_t nfxinf = FX_DTOX(99);
        xmid.x = FX_ADDX(FX_DIVX(FX_ADDX(xa.x, xb.x), nfx2), FX_MULX(xnn.x, ffxnear));
        xmid.y = FX_ADDX(FX_DIVX(FX_ADDX(xa.y, xb.y), nfx2), FX_MULX(xnn.y, ffxnear));
        xmid.z = FX_ADDX(FX_DIVX(FX_ADDX(xa.z, xb.z), nfx2), FX_MULX(xnn.z, ffxnear));

        xinf.x = FX_ADDX(xmid.x, FX_MULX(xnn.x, nfxinf));
        xinf.y = FX_ADDX(xmid.y, FX_MULX(xnn.y, nfxinf));
        xinf.z = FX_ADDX(xmid.z, FX_MULX(xnn.z, nfxinf));
        FixVector3 fxc, fxd;
        double cx = 0, cz = 0;
        int seg = -1;
        //printf(" xmid is (%f, %f, %f) \n", FX_XTOD(xmid.x), FX_XTOD(xmid.y), FX_XTOD(xmid.z));
        //printf(" xinf is (%f, %f, %f) \n", FX_XTOD(xinf.x), FX_XTOD(xinf.y), FX_XTOD(xinf.z));
        int hit_num = _hittest_in_area(false, pArea, &xmid, &xinf, &fxc, &fxd, &cx, &cz, &seg);
        if (hit_num%2 == 0 )
        {
            /// 交点数为偶数说明是向外的, 需要反转
            /// 结果用单位向量 
            xnn.x = FX_MULX(xnn.x, FX_DTOX(-1));
            xnn.y = FX_MULX(xnn.y, FX_DTOX(-1));
            xnn.z = FX_MULX(xnn.z, FX_DTOX(-1));
        }
        pArea->nomals[i].x = FX_XTOD(xnn.x);
        pArea->nomals[i].y = FX_XTOD(xnn.y);
        pArea->nomals[i].z = FX_XTOD(xnn.z);
        //printf(" ret is (%f, %f, %f) , cross (%f, %f) seg %d hit_num %d \n", FX_XTOD(xnn.x), FX_XTOD(xnn.y), FX_XTOD(xnn.z), cx, cz, seg, hit_num);
    }
    return 0;
}

//static int test_init_area()
//{
//    Area ar;
//    int pointNum = 3;
//    ar.pointNum = 3;
//    ar.points = (Position*)malloc(pointNum*sizeof(Position));
//    ar.nomals = (V3*)malloc(pointNum*sizeof(V3));
//    memset(ar.points, 0, pointNum*sizeof(Position));
//    memset(ar.nomals, 0, pointNum*sizeof(V3));
//    ar.points[0].x = 2;
//    ar.points[0].z = 2;
//    ar.points[1].x = 3;
//    ar.points[1].z = 3;
//    ar.points[2].x = 4;
//    ar.points[2].z = 2;
//    //printf("%d %d\n", FX_IMPL_DTOX(10, 10), FX_IMPL_ITOX(10, 10));
//    init_battlearea(&ar);
//	return 0;
//}

static int init_matrix(Matrix* pMatrix)
{
    if (pMatrix == NULL) {
        return -100;
    }
    for (int i = 0; i< pMatrix->battleAreaNum; ++ i)
    {
        //printf("init_battlearea %d \n", i);
        int ret = init_battlearea(&(pMatrix->battleAreas[i]));
        if (ret)
        {
            return 1000 + ret;
        }

    }
    if (pMatrix->cellMatrix == NULL || pMatrix->c <= 0 || pMatrix->r <= 0)
    {
        return -101;
    }
    Cell** cellMatrix = pMatrix->cellMatrix;
    for (int c = 0; c < pMatrix->c; ++c)
    {
        for (int r = 0; r < pMatrix->r; ++ r)
        {

            if (cellMatrix[c][r].blocked)
            {
                continue;
            }
            if (r > 0)
            {
                if (!cellMatrix[c][r-1].blocked)
                {
                    double deltaHeight = cellMatrix[c][r-1].y - cellMatrix[c][r].y;
                    if ( deltaHeight >= BLOCK_NEGATIVE_HEIGHT && deltaHeight <= BLOCK_HEIGHT)
                    {
                        cellMatrix[c][r].neighbors |= Dir_nz;
                    }
                    if ( (-deltaHeight) >= BLOCK_NEGATIVE_HEIGHT && (-deltaHeight) <= BLOCK_HEIGHT)
                    {
                        cellMatrix[c][r-1].neighbors |= Dir_z;
                    }
                }
                if (c > 0)
                {
                    if (!cellMatrix[c-1][r-1].blocked)
                    {
                        double deltaHeight = cellMatrix[c-1][r-1].y - cellMatrix[c][r].y;
                        if ( deltaHeight >= BLOCK_NEGATIVE_HEIGHT && deltaHeight <= BLOCK_HEIGHT)
                        {
                            cellMatrix[c][r].neighbors |= Dir_nxnz;
                        }
                        if ( (-deltaHeight) >= BLOCK_NEGATIVE_HEIGHT && (-deltaHeight) <= BLOCK_HEIGHT)
                        {
                            cellMatrix[c-1][r-1].neighbors |= Dir_xz;
                        }
                    }
                }
            }
            if (c > 0)
            {
                if (!cellMatrix[c-1][r].blocked)
                {
                    double deltaHeight = cellMatrix[c-1][r].y - cellMatrix[c][r].y;
                    if ( deltaHeight >= BLOCK_NEGATIVE_HEIGHT && deltaHeight <= BLOCK_HEIGHT)
                    {
                        cellMatrix[c][r].neighbors |= Dir_nx;
                    }
                    if ( (-deltaHeight) >= BLOCK_NEGATIVE_HEIGHT && (-deltaHeight) <= BLOCK_HEIGHT)
                    {
                        cellMatrix[c-1][r].neighbors |= Dir_x;
                    }
                }
                if (r < pMatrix->r - 1)
                {
                    if (!cellMatrix[c-1][r+1].blocked)
                    {
                        double deltaHeight = cellMatrix[c-1][r+1].y - cellMatrix[c][r].y;
                        if ( deltaHeight >= BLOCK_NEGATIVE_HEIGHT && deltaHeight <= BLOCK_HEIGHT)
                        {
                            cellMatrix[c][r].neighbors |= Dir_nxz;
                        }
                        if ( (-deltaHeight) >= BLOCK_NEGATIVE_HEIGHT && (-deltaHeight) <= BLOCK_HEIGHT)
                        {
                            cellMatrix[c-1][r+1].neighbors |= Dir_xnz;
                        }
                    }
                }
            }
        }
    }
	return 0;
}

static int mallocOpenAndClose(PathingCtrlObj* pCtrl)
{
    if (0 == pCtrl)
    {
        return -1;
    }
    if (pCtrl->matrix.c <= 0 || pCtrl->matrix.r <= 0)
    {
        return -2;
    }

    pCtrl->open.Array = (Close**)malloc((pCtrl->matrix.c*pCtrl->matrix.r) * sizeof(Close*));
    if (NULL == pCtrl->open.Array)
    {
        return -4;
    }
    pCtrl->close = (Close**)malloc(pCtrl->matrix.c * sizeof(Close*));
    if (NULL == pCtrl->close)
    {
        return -5;
    }
    for (int i = 0; i < pCtrl->matrix.c; ++ i)
    {
        pCtrl->close[i] = (Close*)malloc(pCtrl->matrix.r * sizeof(Close));
        if (NULL == pCtrl->close[i])
        {
            return -6;
        }
    }
    return 0;
}

static void initOpen(Open *q)
{
    q->length = 0;
}

static void initClose(PathingCtrlObj* pCtrl)
{
    for (int i = 0; i < pCtrl->matrix.c; ++ i)
    {
        for (int j = 0; j < pCtrl->matrix.r; ++ j)
        {
            pCtrl->close[i][j].cur = &(pCtrl->matrix.cellMatrix[i][j]);
            pCtrl->close[i][j].vis = pCtrl->matrix.cellMatrix[i][j].blocked;
            pCtrl->close[i][j].from = NULL;
            pCtrl->close[i][j].F = 0;
            pCtrl->close[i][j].G = 0;
            //pCtrl->close[i][j].H = abs(pCtrl->dstC - i) + abs(pCtrl->dstR - j);
            pCtrl->close[i][j].H = pCtrl->_H(pCtrl, i, j, pCtrl->dstC, pCtrl->dstR);
        }
    }

    pCtrl->close[pCtrl->srcC][pCtrl->srcR].F = pCtrl->close[pCtrl->srcC][pCtrl->srcR].H;
    pCtrl->close[pCtrl->dstC][pCtrl->dstR].G = Infinity;
}

void push(Open* op, Close** cls, int c, int r, double g)
{    //向优先队列（Open表）中添加元素
    Close *t;
    int i, mintag;
    cls[c][r].G = g;    //所添加节点的坐标
    cls[c][r].F = cls[c][r].G + cls[c][r].H;
    op->Array[op->length++] = &(cls[c][r]);
    mintag = op->length - 1;
    for (i = 0; i < op->length - 1; i++)
    {
        if (op->Array[i]->F < op->Array[mintag]->F)
        {
            mintag = i;
        }
    }
    t = op->Array[op->length - 1];
    op->Array[op->length - 1] = op->Array[mintag];
    op->Array[mintag] = t;    //将评价函数值最小节点置于队头
}

Close* shift(Open *q)
{
    return q->Array[--q->length];
}

static int is_c_r_valid(int c, int r, Matrix* pMatrix)
{
    if (c >= 0 && c < pMatrix->c)
    {
        if (r >= 0 && r < pMatrix->r)
        {
            return 1;
        }
    }
    return 0;
}

static double _ManhattanGetMoveCost(PathingCtrlObj* pCtrl, int curC, int curR, int dstC, int dstR)
{
    if (NULL == pCtrl) 
    {
        printf("_ManhattanGetMoveCost error pCtrl == NULL\n");
        return -1;
    }

    return sqrt((curC - dstC) * (curC - dstC) + (curR - dstR) * (curR - dstR));
}
static double _ManhattanGetHeuristic(PathingCtrlObj* pCtrl, int curC, int curR, int dstC, int dstR)
{
    if (NULL == pCtrl) 
    {
        printf("_ManhattanGetHeuristic error pCtrl == NULL\n");
        return -1;
    }
    if (curC == dstC && curR == dstR)
    {
        return 0;
    }

    return fabs(pCtrl->dstC - curC) + fabs(pCtrl->dstR - curR);
}

//static double _EuclideanGetMoveCost(PathingCtrlObj* pCtrl, int curC, int curR, int dstC, int dstR)
//{
//    if (NULL == pCtrl) 
//    {
//        printf("_EuclideanGetMoveCost error pCtrl == NULL\n");
//        return -1;
//    }
//    Cell* pCurCell = &(pCtrl->matrix.cellMatrix[curC][curR]);
//    Cell* pDstCell = &(pCtrl->matrix.cellMatrix[dstC][dstR]);

//    double dx = pCurCell->x - pDstCell->x;
//    double dy = pCurCell->y - pDstCell->y;
//    double dz = pCurCell->z - pDstCell->z;

//    return pCtrl->baseMoveCost*(sqrt(dx*dx + dy*dy + dz*dz));
//}
//static double _EuclideanGetHeuristic(PathingCtrlObj* pCtrl, int curC, int curR, int dstC, int dstR)
//{
//    if (NULL == pCtrl) 
//    {
//        printf("_EuclideanGetHeuristic error pCtrl == NULL\n");
//        return -1;
//    }
//    if (curC == dstC && curR == dstR)
//    {
//        return 0;
//    }
//    Cell* pCurCell = &(pCtrl->matrix.cellMatrix[curC][curR]);
//    Cell* pDstCell = &(pCtrl->matrix.cellMatrix[dstC][dstR]);

//    double dx = pCurCell->x - pDstCell->x;
//    double dy = pCurCell->y - pDstCell->y;
//    double dz = pCurCell->z - pDstCell->z;

//    return pCtrl->baseMoveCost*(sqrt(dx*dx + dy*dy + dz*dz));
//    //abs(pCtrl->dstC - i) + abs(pCtrl->dstR - j)
//}

static int _hasBarrier(Cell* p1, Cell* p2, PathingCtrlObj* pCtrl)
{
    double dx = p2->x - p1->x;
    double dz = p2->z - p1->z;
    if (dx == 0 && dz == 0)
    {
        return 0;
    }
    double cellSize = pCtrl->matrix.cellSize;
    double movex, movez = 0;
    if (dx == 0)
    {
        movex = 0;
        movez = cellSize*((dz > 0)?1:-1);
    } 
    else if (dz == 0)
    {
        movex = cellSize * ((dx > 0)?1:-1);
        movez = 0;
    }
    else 
    {
        movex = cellSize * ((dx > 0)?1:-1);
        movez = cellSize * (dz/dx);
        double absmovez = ((movez > 0) ? movez : -movez);
        if ( absmovez > cellSize)
        {
            movez = cellSize*((dz > 0)?1:-1);
            movex = cellSize * dx/dz;
            double absmovex = (movex > 0) ? movex : -movex;
            movex = absmovex*((dx > 0)?1:-1);
        }
        else
        {
            movez = absmovez*((dz > 0)?1:-1);
        }
    }
    double x = p1->x,z = p1->z;
    int c = p1->c, r = p1->r;
    //printf("movex %f movez %f, abs(movez) %f, cellSize %f, pCtrl->matrix.cellSize %f\n", movex, movez, abs(movez), cellSize, pCtrl->matrix.cellSize);
    //printf("start c %d, r %d,  x %f, z %f \n", c, r, x, z);
    while(((c >= p1->c && c <= p2->c) || (c >= p2->c && c <= p1->c)) && 
            ((r >= p1->r && r <= p2->r) || (r >= p2->r && r <= p1->r)))
    {
        x = x + movex;
        z = z + movez;
        int _c , _r = 0;
        if (getCellFromXZ(&(pCtrl->matrix), x, z, &_c, &_r))
        {
            printf("out map\n");
            return 1;
        }
        if (_c == c && _r == r)
        {
            //printf("...\n");
            continue;
        }
        if (!(((_c >= p1->c && _c <= p2->c) || (_c >= p2->c && _c <= p1->c)) && 
            ((_r >= p1->r && _r <= p2->r) || (_r >= p2->r && _r <= p1->r))))
        {
            break;
        }
        int dir = getCrossDirToNeighbor(c, r, _c, _r);
        if (getCrossDirToNeighbor(c, r, _c, _r) < 0)
        {
            printf("error %d %d , %d %d not neighbors\n", c, r, _c, _r);
            return -1;
        }
        Cell* last = &(pCtrl->matrix.cellMatrix[c][r]);
        if (!(last->neighbors & dir))
        {
            return 1;
        }

        c = _c;
        r = _r;
    }

    return 0;
}



int pathing_astar(PathingCtrlObj* pCtrl)
{
    if (!is_c_r_valid(pCtrl->srcC, pCtrl->srcR, &(pCtrl->matrix)) ||
        !is_c_r_valid(pCtrl->dstC, pCtrl->dstR, &(pCtrl->matrix)))
    {
        return -1;
    }
    initOpen(&(pCtrl->open));
    initClose(pCtrl);
    int srcC = pCtrl->srcC;
    int srcR = pCtrl->srcR;
    //int dstC = pCtrl->dstC;
    //int dstR = pCtrl->dstR;
    int curC, curR;
    int neighborC, neighborR;
    double neighborG;
    Close** close = pCtrl->close;
    Open* op = &(pCtrl->open);

    close[srcC][srcR].vis = 1;
    push(op, close, srcC, srcR, 0);
    Close* p;
    int i;
    while(op->length)
    {
        p = shift(op);
        curC = p->cur->c;
        curR = p->cur->r;
        if (p->H == 0)
        {
            return Sequential;
        }
        for (i = 0; i < 8; i++)
        {
            if (! (p->cur->neighbors & (1 << i)))
            {
                continue;
            }
            neighborC = curC + Dir[i].c;
            neighborR = curR + Dir[i].r;
            if (is_c_r_valid(neighborC, neighborR, &(pCtrl->matrix)))
            {
                if (!close[neighborC][neighborR].vis)
                {
                    close[neighborC][neighborR].vis = 1;
                    close[neighborC][neighborR].from = p;
                    //neighborG = p->G + sqrt((curC - neighborC) * (curC - neighborC) + (curR - neighborR) * (curR - neighborR));
                    neighborG = p->G + pCtrl->_G(pCtrl, curC, curR, neighborC, neighborR);
                    push(op, close, neighborC, neighborR, neighborG);
                }
            }
        }
    }
    return NoSolution;
}

void print_matrix(Matrix* m)
{
    if (NULL == m)
    {
        return;
    }
    for (int i = 0; i < m->c; ++ i)
    {
        for (int j = 0; j < m->r; ++ j)
        {
            //Cell* cell = &(m->cellMatrix[i][j]);
        }
    }
}

static int betweenX(fixed_t a, fixed_t X0, fixed_t X1)  
{  
    fixed_t temp1 = FX_SUBX(a, X0);  
    fixed_t temp2 = FX_SUBX(a, X1);  
    
    if ( ( temp1 <= FX_DTOX(0) && temp2 >= FX_DTOX(0)) || ( temp2 <= FX_DTOX(0) && temp1 >= FX_DTOX(0)) )  
    {  
        return 1;  
    }  
    else  
    {  
        return 0;  
    }  
}  
  
static void posintToFx(Position* p, FxPosition* px)
{
    px->x = FX_DTOX(p->x);
    px->y = FX_DTOX(p->y);
    px->z = FX_DTOX(p->z);
}

// p1 p2 为对角线， p3, p4 为对角线 的两个矩形是否相交
static int diagRectCrossX(FxPosition* p1, FxPosition* p2, FxPosition* p3, FxPosition* p4)
{
    fixed_t xsublen = FX_ADDX(FX_ABS(FX_SUBX(p1->x, p2->x)), FX_ABS(FX_SUBX(p3->x, p4->x)));
    fixed_t zsbulen = FX_ADDX(FX_ABS(FX_SUBX(p1->z, p2->z)), FX_ABS(FX_SUBX(p3->z, p4->z)));
    fixed_t corexlen = FX_ABS(FX_SUBX(FX_ADDX(p1->x, p2->x), FX_ADDX(p3->x, p4->x))); 
    fixed_t corezlen = FX_ABS(FX_SUBX(FX_ADDX(p1->z, p2->z), FX_ADDX(p3->z, p4->z)));
    if ((corexlen <= xsublen) && (corezlen <= zsbulen))
    {
        return 1;
    }
    return 0;
}

//#define DBG_PRINT
#ifdef DBG_PRINT
lua_State* gLuaState = NULL;
void print_in_lua(const char *str, ...) {
    lua_State* L = gLuaState;
    if (L == NULL)
    {
        return;
    }
	lua_getglobal(L, "print");
	lua_pushstring(L, str);
	lua_call(L, 1, 0);
}
#define dbglog print_in_lua
#else
#define dbglog 
#endif

// 判断两条直线段是否有交点，有则计算交点的坐标  
// p1,p2是直线一的端点坐标  
// p3,p4是直线二的端点坐标  
static int detectIntersectX(FxPosition* p1, FxPosition* p2, FxPosition* p3, FxPosition* p4, fixed_t* cx, fixed_t* cz)  
{
    fixed_t line_x, line_z;
    fixed_t shift_back = FX_DTOX(0.4);
    fixed_t sub12x = FX_SUBX(p1->x, p2->x);
    fixed_t sub34x = FX_SUBX(p3->x, p4->x);
    if (FX_IS_ZERO(sub12x) && FX_IS_ZERO(sub34x))
    {
        return 0;
    }
    else if (!diagRectCrossX(p1, p2, p3, p4))
    {
        return 0;
    }
    else if (FX_IS_ZERO(sub12x)) //如果直线段p1p2垂直与x轴  
    {  
        if (betweenX(p1->x,p3->x,p4->x))  
        {  
            fixed_t k = FX_DIVX(FX_SUBX(p4->z, p3->z),FX_SUBX(p4->x,p3->x));  
            line_x = p1->x;  
            line_z = FX_ADDX(FX_MULX(k, FX_SUBX(line_x,p3->x)), p3->z);  


            if (betweenX(line_z,p1->z,p2->z))  
            {  
                fixed_t deltaz = FX_SUBX(line_z, p1->z);
                if (!FX_IS_ZERO(deltaz))
                {
                    line_z = FX_SUBX(line_z, FX_MULX(FX_DTOX((deltaz > FX_ZERO) ? 1 : -1), shift_back));
                }
                *cx = line_x;
                *cz = line_z;
                return 1;  
            }  
            else  
            {  
                return 0;  
            }  
        }  
        else   
        {  
            return 0;  
        }  
    }  
    else if (FX_IS_ZERO(sub34x)) //如果直线段p3p4 垂直于x轴  
    {
        if (betweenX(p3->x , p1->x, p2->x))
        {
            fixed_t k1 = FX_DIVX(FX_SUBX(p2->z, p1->z),FX_SUBX(p2->x,p1->x));
            line_x = p3->x;  
            line_z = FX_ADDX(FX_MULX(k1, FX_SUBX(line_x,p1->x)), p1->z);
            if (betweenX(line_z,p3->z,p4->z))  
            {  
                fixed_t deltaz = FX_SUBX(line_z, p3->z);
                if (!FX_IS_ZERO(deltaz))
                {
                    line_z = FX_SUBX(line_z, FX_MULX(FX_DTOX((deltaz > FX_ZERO) ? 1 : -1), shift_back));
                }
                *cx = line_x;
                *cz = line_z;
                return 1;  
            }  
            else  
            {  
                return 0;  
            }  
        }  
        else   
        {  
            return 0;  
        }  
    }  
    else  
    {  
        fixed_t k1 = FX_DIVX(FX_SUBX(p2->z, p1->z),FX_SUBX(p2->x,p1->x));   
        fixed_t k2 = FX_DIVX(FX_SUBX(p4->z, p3->z),FX_SUBX(p4->x,p3->x));  
  
        if (FX_IS_ZERO(FX_SUBX(k1,k2)))  
        {  
            return 0;  
        }  
        else   
        {  
            line_x = FX_DIVX(FX_SUBX(FX_SUBX(p3->z , p1->z) , FX_SUBX(FX_MULX(k2,p3->x) , FX_MULX(k1,p1->x))), FX_SUBX(k1,k2));  
            line_z = FX_ADDX(FX_MULX(k1,(FX_SUBX(line_x,p1->x))),p1->z);  
        }  
  
        if (betweenX(line_x,p1->x,p2->x)&&betweenX(line_x,p3->x,p4->x))  
        {  
            fixed_t deltax = FX_SUBX(line_x, p1->x);
            fixed_t deltaz = FX_SUBX(line_z, p1->z);
            fixed_t shift_x = FX_ZERO;
            if (!FX_IS_ZERO(deltax))
            {
                shift_x = FX_MULX(FX_DTOX((deltax > FX_ZERO) ? 1 : -1), shift_back);
                line_x = FX_SUBX(line_x, shift_x);
            }
            if (!FX_IS_ZERO(deltaz))
            {

                line_z = FX_SUBX(line_z, FX_MULX(k1, shift_x));
                if (!betweenX(line_z, p1->z, p2->z))
                {
                    line_x = p1->x;
                    line_z = p1->z;
                }
            }
            *cx = line_x;
            *cz = line_z;
            return 1;  
        }  
        else   
        {  
            return 0;  
        }  
    }  
    return 0;
}

static bool check_shiftout_block(Matrix* pMatrix, int* c, int* r, int destC, int destR)
{
    if (!is_c_r_valid(*c, *r, pMatrix))
    {
        return false;
    }
    Cell* pSrcCell = &(pMatrix->cellMatrix[*c][*r]);   
    if (!(pSrcCell->blocked))
    {
        return false;
    }
    int currC = *c;
    int currR = *r;
    Cell* pFoundCell = NULL;
    int range = 0;
    while (pFoundCell == NULL)
    {
        range ++;
        bool inRange = false;
        for ( int dc = -range; dc <= range; ++ dc)
        {
            for (int dr = -range; dr < range; ++ dr)
            {
                if ((dc > -range && dc < range ) && (dr < -range && dr < range))
                {
                    /// 已经检查过了
                }
                else
                {
                    int neighborC = currC + dc;
                    int neighborR = currR + dr;
                    if (is_c_r_valid(neighborC, neighborR, pMatrix))
                    {
                        Cell* pCell = &(pMatrix->cellMatrix[neighborC][neighborR]);
                        if (pCell && !(pCell->blocked))
                        {
                            if (pFoundCell == NULL)
                            {
                                pFoundCell = pCell;
                            }
                            else
                            {
                                if (abs(destC - neighborC) + abs(destR - neighborR) < abs(destC - pCell->c) + abs(destR - pCell->r))
                                {
                                    pFoundCell = pCell;
                                }
                            }
                        }
                        inRange = true;
                    }
                }
            }
        }
        if (!inRange)
        {
            break;
        }
    }
    if (pFoundCell)
    {
        //printf("src point %d %d is blocked shift out to %d %d\n", *c, *r, pFoundCell->c, pFoundCell->r);
        *c = pFoundCell->c;
        *r = pFoundCell->r;
        return true;
    }
    return false;
}

static int luaapi_pathing_handler_FindPath(lua_State* L)
{
    if (lua_gettop(L) < 7)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    PathingCtrlObj* pObj = (PathingCtrlObj*)luaL_checkudata(L, 1, LUA_PATHING_HANDLE_MT);
    if (pObj == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }

    pObj->dstPos.z = luaL_checknumber(L, -1);
    pObj->dstPos.y = luaL_checknumber(L, -2);
    pObj->dstPos.x = luaL_checknumber(L, -3);
    pObj->srcPos.z = luaL_checknumber(L, -4);
    pObj->srcPos.y = luaL_checknumber(L, -5);
    pObj->srcPos.x = luaL_checknumber(L, -6);
    //printf("luaapi_pathing_handler_FindPath (%f, %f, %f) --> (%f, %f, %f)\n", pObj->srcPos.x, pObj->srcPos.y, pObj->srcPos.z, pObj->dstPos.x, pObj->dstPos.y, pObj->dstPos.z );


    /// Position to cell
    int ret = getCellFromXZ(&(pObj->matrix), pObj->srcPos.x, pObj->srcPos.z, &(pObj->srcC), &(pObj->srcR));
    if (ret)
    {
        luaL_error(L, "src pos (%f, %f, %f) error %d, origin (%f, %f) \n", pObj->srcPos.x, pObj->srcPos.y, pObj->srcPos.z,ret, pObj->matrix.originx, pObj->matrix.originz);
        return 0;
    }
    ret = getCellFromXZ(&(pObj->matrix), pObj->dstPos.x, pObj->dstPos.z, &(pObj->dstC), &(pObj->dstR));
    if (ret)
    {
        luaL_error(L, "dst pos (%f, %f, %f) error %d, origin (%f, %f) \n", pObj->dstPos.x, pObj->dstPos.y, pObj->dstPos.z, ret, pObj->matrix.originx, pObj->matrix.originz);
        return 0;
    }
    bool bShiftSrc = false;
    bShiftSrc = check_shiftout_block(&(pObj->matrix), &(pObj->srcC), &(pObj->srcR), pObj->dstC, pObj->dstR);

    /// find path
    ret = pathing_astar(pObj);
    //printf("pathing_astar ret %d \n", ret);
    if (ret == Sequential)
    {
        Close** close = pObj->close;
        Close *p, *t, *q = NULL;
        p = &(close[pObj->dstC][pObj->dstR]);

        // 转置
        while(p)
        {
            t = p->from;
            p->from = q;
            q = p;
            p = t;
        }
        if (q)
        {
            close[pObj->srcC][pObj->srcR].from = q->from;
        }

        // 直线合并
        p = &(close[pObj->srcC][pObj->srcR]);
        while(p)
        {
            Close* p1 = p->from;
            if (p1 == NULL) break; 
            Close* p2 = p1->from;
            if (p2 == NULL) break;
            if ((p->cur->c) - (p1->cur->c) == (p1->cur->c) - (p2->cur->c)
                && (p->cur->r) - (p1->cur->r) == (p1->cur->r) - (p2->cur->r))
            {
                p->from = p2;
            }
            else
            {
                p = p1;
            }
        }
        // 消除拐点
        p = &(close[pObj->srcC][pObj->srcR]);
        while(p)
        {
            Close* p1 = p->from;
            if (p1 == NULL) break; 
            Close* p2 = p1->from;
            if (p2 == NULL) break;
            if (_hasBarrier(p->cur, p2->cur, pObj))
            {
                p = p1;
            }
            else
            {
                p->from = p2;
            }

        }

        lua_newtable(L);
        int index = 0;
        p = &(close[pObj->srcC][pObj->srcR]);
        while(p)
        {
            lua_Number x, y, z = 0.0;

            if (index == 0)
            {
                index ++;
                if (bShiftSrc)
                {
                    Cell* pCell = &(pObj->matrix.cellMatrix[pObj->srcC][pObj->srcR]);
                    x = pCell->x;
                    y = pCell->y;
                    z = pCell->z;
                }
                else
                {
                    if (NULL == p->from)
                    {
                        x = pObj->dstPos.x;
                        y = pObj->dstPos.y;
                        z = pObj->dstPos.z;

                    }
                    else
                    {
                        p = p->from;
                        continue;
                    }
                }
                //x = pObj->srcPos.x;
                //y = pObj->srcPos.y;
                //z = pObj->srcPos.z;
            }
            else if (NULL == p->from)
            {
                x = pObj->dstPos.x;
                y = pObj->dstPos.y;
                z = pObj->dstPos.z;
            }
            else
            {
                x = p->cur->x;
                y = p->cur->y;
                z = p->cur->z;
            }

            lua_pushnumber(L, index);
            lua_newtable(L);

            lua_pushstring(L, "x");
            lua_pushnumber(L, x);
            lua_settable(L,-3);
            lua_pushstring(L, "y");
            lua_pushnumber(L, y);
            lua_settable(L,-3);
            lua_pushstring(L, "z");
            lua_pushnumber(L, z);
            lua_settable(L,-3);

            lua_settable(L,-3);
            p = p->from;
            if (index > 0)
            {
                index ++;
            }
        }
        return 1;
    }
    return 0;
}

static int _hittest_in_area(bool bAll, Area* area, FxPosition* fxa, FxPosition* fxb, FxPosition* fxc, FxPosition* fxd, double *cx, double* cz, int* seg)
{
    if (NULL == area->points)
    {
        return 0;
    }
    fixed_t xcx, xcz;
    int num = 0;
    for (int j = 0; j < area->pointNum; ++ j)
    {
        if (j !=  area->pointNum - 1)
        {

            posintToFx(&(area->points[j]), fxc);
            posintToFx(&(area->points[j + 1]), fxd);
            
            //if (detectIntersect(&a, &b, &(area->points[j]), &(area->points[j + 1]), &cx, &cz))
            if (detectIntersectX(fxa, fxb, fxc, fxd, &xcx, &xcz))
            {
                *cx = FX_XTOD(xcx);
                *cz = FX_XTOD(xcz);
                if (seg != 0)
                {
                    *seg = j;
                }
                if (bAll)
                {
                    num += 1;
                }
                else
                {
                    return 1;
                }
            }
        }
        else
        {
            posintToFx(&(area->points[j]), fxc);
            posintToFx(&(area->points[0]), fxd);

            //if (detectIntersect(&a, &b, &(area->points[j]), &(area->points[0]), &cx, &cz))
            if (detectIntersectX(fxa, fxb, fxc, fxd, &xcx, &xcz))
            {
                *cx = FX_XTOD(xcx);
                *cz = FX_XTOD(xcz);
                if (seg != 0)
                {
                    *seg = j;
                }
                if (bAll)
                {
                    num += 1;
                }
                else
                {
                    return 1;
                }
            }

        }
    }
    return num;
}
static int luaapi_pathing_handler_HitTest(lua_State* L)
{

    if (lua_gettop(L) < 7)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    PathingCtrlObj* pObj = (PathingCtrlObj*)luaL_checkudata(L, 1, LUA_PATHING_HANDLE_MT);
    if (pObj == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }
    Position a, b;
    a.x = luaL_checknumber(L, 2);
    a.y = luaL_checknumber(L, 3);
    a.z = luaL_checknumber(L, 4);
    b.x = luaL_checknumber(L, 5);
    b.y = luaL_checknumber(L, 6);
    b.z = luaL_checknumber(L, 7);
    //printf("%f %f %f -- %f %f %f\n", a.x, a.y, a.z, b.x, b.y, b.z);

    Matrix* pMatrix = &(pObj->matrix);

    FxPosition fxa, fxb, fxc, fxd;
    posintToFx(&a, &fxa);
    posintToFx(&b, &fxb);

    int iArea = 0;
    if (lua_gettop(L) == 8)
    {
        iArea = luaL_checkinteger(L, 8);
        if (iArea > pMatrix->battleAreaNum || iArea < 0)
        {
            luaL_error(L, "error area index %d, battleAreaNum %d\n", iArea, pMatrix->battleAreaNum);
            return 0;
        }
        if (iArea > 0)
        {
            Area* area = &(pMatrix->battleAreas[iArea - 1]);
            double cx, cz = 0;
            int seg = -1;
            if (_hittest_in_area(false, area, &fxa, &fxb, &fxc, &fxd, &cx, &cz, &seg))
            {
                lua_newtable(L);
                lua_pushstring(L, "x");
                lua_pushnumber(L, cx);
                lua_settable(L,-3);
                lua_pushstring(L, "y");
                lua_pushnumber(L, 0);
                lua_settable(L,-3);
                lua_pushstring(L, "z");
                lua_pushnumber(L, cz);
                lua_settable(L,-3);

                if (seg >= 0)
                {
                    lua_newtable(L);
                    lua_pushstring(L, "x");
                    lua_pushnumber(L, area->nomals[seg].x);
                    lua_settable(L,-3);
                    lua_pushstring(L, "y");
                    lua_pushnumber(L, 0);
                    lua_settable(L,-3);
                    lua_pushstring(L, "z");
                    lua_pushnumber(L, area->nomals[seg].z);
                    lua_settable(L,-3);
                }
                return 2;
            }
        }
    }


    for (int i = 0; i < pMatrix->battleAreaNum; ++ i)
    {
        if (NULL == pMatrix->battleAreas)
        {
            luaL_error(L, "area %d not alloced \n", i);
            return 0;
        }
        Area* area = &(pMatrix->battleAreas[i]);
        if (NULL == area->points)
        {
            luaL_error(L, "area %d points not alloced \n", i);
            return 0;
        }
        double cx, cz = 0;
        int seg = -1;
        if (_hittest_in_area(false, area, &fxa, &fxb, &fxc, &fxd, &cx, &cz, &seg))
        {
            lua_newtable(L);
            lua_pushstring(L, "x");
            lua_pushnumber(L, cx);
            lua_settable(L,-3);
            lua_pushstring(L, "y");
            lua_pushnumber(L, 0);
            lua_settable(L,-3);
            lua_pushstring(L, "z");
            lua_pushnumber(L, cz);
            lua_settable(L,-3);

            if (seg >= 0)
            {
                lua_newtable(L);
                lua_pushstring(L, "x");
                lua_pushnumber(L, area->nomals[seg].x);
                lua_settable(L,-3);
                lua_pushstring(L, "y");
                lua_pushnumber(L, 0);
                lua_settable(L,-3);
                lua_pushstring(L, "z");
                lua_pushnumber(L, area->nomals[seg].z);
                lua_settable(L,-3);
            }
            return 2;
        }

    }
    return 0;
}

static int luaapi_pathing_handler_GetYByXZ(lua_State* L)
{
    if (lua_gettop(L) < 3)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    PathingCtrlObj* pObj = (PathingCtrlObj*)luaL_checkudata(L, 1, LUA_PATHING_HANDLE_MT);
    if (pObj == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }
    double x = luaL_checknumber(L, 2);
    double z = luaL_checknumber(L, 3);    
    double y = 0;
    if (getYFromXZ(&(pObj->matrix), x, z, &y))
    {
        return 0;
    }
    lua_pushnumber(L, y);
    return 1;
}

static int luaapi_pathing_handler_testGetCell(lua_State* L)
{
    if (lua_gettop(L) < 3)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    PathingCtrlObj* pObj = (PathingCtrlObj*)luaL_checkudata(L, 1, LUA_PATHING_HANDLE_MT);
    if (pObj == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }
    int c = luaL_checkinteger(L, 2);
    int r = luaL_checkinteger(L, 3);
    Matrix* pMatrix = &(pObj->matrix);
    //print_matrix(pMatrix);
    if (c >= 0 && r >= 0 && c < pMatrix->c && r < pMatrix->r)
    {
        Cell* pCell = &(pMatrix->cellMatrix[c][r]);
        lua_newtable(L);
        lua_pushstring(L, "x");
        lua_pushnumber(L, pCell->x);
        lua_settable(L,-3);
        lua_pushstring(L, "y");
        lua_pushnumber(L, pCell->y);
        lua_settable(L,-3);
        lua_pushstring(L, "z");
        lua_pushnumber(L, pCell->z);
        lua_settable(L,-3);
        lua_pushstring(L, "b");
        lua_pushinteger(L, pCell->blocked);
        lua_settable(L,-3);
        return 1;
    }
    return 0;

}

static int luaapi_get_pathing_handler(lua_State* L)
{
    if (lua_gettop(L) < 1)
    {
        luaL_error(L, "luaapi_get_pathing_handler error arg num %d\n", lua_gettop(L));
        return 0;
    }
    //luaL_checktype(L, -1, LUA_TTABLE);
    if (!lua_istable(L, -1)) {
        luaL_error(L,"luaapi_get_pathing_handler error! is not a table \n");
        return 0;
    }


    PathingCtrlObj* p = (PathingCtrlObj*)lua_newuserdata(L, sizeof(PathingCtrlObj));
    if (NULL == p)
    {
        luaL_error(L, "luaapi_get_pathing_handler, lua_newuserdata mem error\n");
        return 0;
    }
    memset(p, 0, sizeof(PathingCtrlObj));
    lua_insert(L, - 2);
    int ret = loadcellMatrix(L, &(p->matrix));
    if (ret)
    {
        luaL_error(L, "luaapi_get_pathing_handler, loadcellMatrix error %d\n", ret);
        return 0;
    }
    ret = init_matrix(&(p->matrix));
    if (ret)
    {
        luaL_error(L, "luaapi_get_pathing_handler, init_matrix error %d\n", ret);
        return 0;
    }
    ret = mallocOpenAndClose(p);
    if (ret)
    {
        luaL_error(L, "luaapi_get_pathing_handler, mallocOpenAndClose error %d\n", ret);
        return 0;
    }
    //p->_H = _EuclideanGetHeuristic;
    //p->_G = _EuclideanGetMoveCost;
    p->_H = _ManhattanGetHeuristic;
    p->_G = _ManhattanGetMoveCost;
    p->baseMoveCost = 1;
    lua_insert(L,-2);
    luaL_getmetatable(L, LUA_PATHING_HANDLE_MT);
    lua_setmetatable(L, -2);
    return 1;    
}

static int luaapi_pathing_handler_get(lua_State* L)
{
    if (lua_gettop(L) < 2)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    // PathingCtrlObj* p = (PathingCtrlObj*)(luaL_checkudata(L, 1, LUA_PATHING_HANDLE_MT));
    // if (p == NULL)
    // {
    //     luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
    //     return 0;
    // }

    const char *pcFieldName = luaL_checkstring(L, 2);
    if (pcFieldName == NULL)
    {
        luaL_error(L, "invalid arguments:%d , no field name\n", lua_gettop(L));
        return 0;
    }

    if (strcmp(pcFieldName , "FindPath") == 0)
    {
        lua_pushcfunction(L, luaapi_pathing_handler_FindPath);
        return 1;
    }

    if (strcmp(pcFieldName , "HitTest") == 0)  /// 传入两点的线段，与地图中的墙的碰撞检测，返回碰撞点
    {
        lua_pushcfunction(L, luaapi_pathing_handler_HitTest);
        return 1;
    }

    if (strcmp(pcFieldName , "GetYByXZ") == 0)  
    {
        lua_pushcfunction(L, luaapi_pathing_handler_GetYByXZ);
        return 1;
    }
    if (strcmp(pcFieldName , "testGetCell") == 0)  
    {
        lua_pushcfunction(L, luaapi_pathing_handler_testGetCell);
        return 1;
    }

    return 0;
}

static int luaapi_pathing_handler_gc(lua_State* L)
{
    //printf("luaapi_pathing_handler_gc\n");
    if (lua_gettop(L) < 1)
    {
        luaL_error(L, "invalid arguments:%d\n", lua_gettop(L));
        return 0;
    }
    PathingCtrlObj* p = (PathingCtrlObj*)luaL_checkudata(L, 1, LUA_PATHING_HANDLE_MT);
    if (p == NULL)
    {
        luaL_error(L, "invalid arguments:%d , empty data\n", lua_gettop(L));
        return 0;
    }
    Matrix* pMatrix = &(p->matrix);
	freecellMatrix(pMatrix);
    
    if (p->open.Array) 
    {
        free(p->open.Array);
        p->open.Array = NULL;
    }
    if (p->close)
    {
        for (int i = 0; i < p->matrix.c; ++ i)
        {
            if (p->close[i])
            {
                free(p->close[i]);
                p->close[i] = NULL;
            }
        }
        free(p->close);
        p->close = NULL;
    }

    pMatrix->c = 0;
    pMatrix->r = 0;
    return 0;
}

static int init_pathing_handler_lua(lua_State* L)
{
    #ifdef DBG_PRINT
        gLuaState = L;
    #endif

    luaL_newmetatable(L, LUA_PATHING_HANDLE_MT);
    lua_pushstring(L, "__index");
    lua_pushcfunction(L, luaapi_pathing_handler_get);
	lua_settable(L, -3);

	lua_pushstring(L, "__gc");
	lua_pushcfunction(L, luaapi_pathing_handler_gc);
	lua_settable(L, -3);

	lua_pop(L, 1);	//matetable->LUA_PATHING_HANDLE_MT
	return 0;
}

static luaL_Reg pathing_lua_lib[] = 
{
    {"GetPathingHandler", luaapi_get_pathing_handler},

    {NULL, NULL}
};

#ifdef __cplusplus
extern "C" {
#endif
LUALIB_API int luaopen_pathing(lua_State* L)
{
    //lua_newtable(L);
    //luaL_setfuncs(L, fixmath_lua_lib, 0);
    luaL_newlib(L, pathing_lua_lib);
    lua_setglobal(L, "Pathing");
    init_pathing_handler_lua(L);
    lua_settop(L, 0);
    return 1;
}
#ifdef __cplusplus
}
#endif