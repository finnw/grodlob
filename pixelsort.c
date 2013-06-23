#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#ifdef _MSC_VER 
typedef __int64 l_int64;
typedef unsigned __int64 l_uint64;
#else
#include <stdint.h>
typedef int64_t l_int64;
typedef uint64_t l_uint64;
#endif

#include "leptonica/environ.h"
#include "leptonica/alltypes.h"
#include "leptonica/leptprotos.h"

#define tonumber(_)
#include "pixelsort_cdef.lua"

#define MIX(x) \
    do { \
        x += 0x2907abf3a2a7701bU; \
        x ^= (x) >> 32; \
        x ^= (x) >> 19; \
        x *= 0x531d5c5d8d29753LU; \
        x ^= (x) >> 27; \
        x ^= (x) << 7; \
    } while (0)

#define MIN(a, b) ((a)<(b)? (a): (b))
#define MAX(a, b) ((a)>(b)? (a): (b))

static void fold(struct wsGridCell *from, struct wsGridCell *to)
{
    to->mass += from->mass; from->mass = 0;
    to->xSum += from->xSum; from->xSum = 0;
    to->ySum += from->ySum; from->ySum = 0;
    to->minX = MIN(to->minX, from->minX); from->minX = 0x7fff;
    to->maxX = MAX(to->maxX, from->maxX); from->maxX = -0x8000;
    to->minY = MIN(to->minY, from->minY); from->minY = 0x7fff;
    to->maxY = MAX(to->maxY, from->maxY); from->maxX = -0x8000;
}

static struct wsGridCell *find(struct wsGridCell *p)
{
    struct wsGridCell *last = p;
    while (p != p->parent)
    {
        last->parent = p->parent;
        last = p;
        p = p->parent;
    }
    return p;
}

static void merge(struct wsGridCell *p, struct wsGridCell *q)
{
    p = find(p); q = find(q);
    if (p == q) return;
    if (p->rank < q->rank)
    {
        p->parent = q;
        fold(p, q);
    }
    else if (p->rank > q->rank)
    {
        q->parent = p;
        fold(q, p);
    }
    else
    {
        q->parent = p;
        fold(q, p);
        ++ p->rank;
    }
}

static void gen_pixels(const float *base,
                       ptrdiff_t width, ptrdiff_t height,
                       ptrdiff_t xStride, ptrdiff_t yStride,
                       struct pixel *buffer)
{
    float intensity;
    ptrdiff_t x, y;
    const float *rowBase;
    struct pixel *dst = buffer;

    for (y = 0; y != height; ++ y)
    {
        rowBase = &base[y * yStride];
        for (x = 0; x != width; ++ x)
        {
            intensity = rowBase[x * xStride];
            dst->intensity = intensity;
            dst->x = (l_int16) x;
            dst->y = (l_int16) y;
            ++ dst;
        }
    }
}

static void genGridCells(int width, int height,
                         struct wsGridCell *pgrid)
{
    int x, y;
    struct wsGridCell *cp;
    struct wsGridCell *rowBase;

    for (y = 0; y <= height; ++ y)
    {
        rowBase = &pgrid[y * width];
        for (x = 0; x <= width; ++ x)
        {
            cp = &rowBase[x];
            cp->visited = 0;
            cp->edge = 0;
            cp->rank = 0;
            cp->minX = cp->maxX = (l_int16)x;
            cp->minY = cp->maxY = (l_int16)y;
            cp->mass = 1;
            cp->parent = cp;
            cp->xSum = x;
            cp->ySum = y;
        }
    }
}

static int qs_compare_pixels(const void *pv1, const void *pv2)
{
    const struct pixel *ppx1 = (const struct pixel *)pv1,
                       *ppx2 = (const struct pixel *)pv2;
    if (ppx1->intensity < ppx2->intensity)
    {
        return 1;
    }
    else if (ppx1->intensity > ppx2->intensity)
    {
        return -1;
    }
    else
    {
        l_uint64 hash1, hash2;
        memcpy(&hash1, ppx1, sizeof hash1);
        memcpy(&hash2, ppx2, sizeof hash2);
        MIX(hash1);
        MIX(hash2);
        if (hash1 < hash2)
        {
            return -1;
        }
        else if (hash1 > hash2)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
}

void grod_genSortedListFromFPix(FPIX *fpix, struct pixel *buffer)
{
    l_int32 width, height, wpl;
    fpixGetDimensions(fpix, &width, &height);
    wpl = fpixGetWpl(fpix);
    gen_pixels(fpixGetData(fpix), width, height, 1, wpl, buffer);
    qsort(buffer, width*height, sizeof (*buffer), qs_compare_pixels);
}

static enum fillPixResult fillPixel(struct wshed *self,
                                    struct wsGridCell **pixSeg,
                                    struct wsGridCell *mergePair[2])
{
    int x, y, dx, dy, nx, ny;
    struct wsGridCell *pgrow, *cp;
    struct wsGridCell *np = NULL, *uniqueNeighbor = NULL;
    const struct pixel *curPix = &self->queue[self->nextRank];

    cp = find(&self->pgrid[curPix->y * self->width + curPix->x]);
    for (dy=-1; dy<=1; ++ dy)
    {
        ny = curPix->y + dy;
        if (! (0 <= ny && ny < self->height)) continue;
        pgrow = &self->pgrid[ny * self->width];
        for (dx=-1; dx<=1; ++dx)
        {
            nx = curPix->x + dx;
            if (! (0 <= nx && nx < self->width)) continue;
            np = &pgrow[nx];
            if (dx == 0 && dy == 0 ||
                (! np->visited) ||
                np->edge)
            {
                continue;
            }
            np = find(np);
            if ((!uniqueNeighbor) || (uniqueNeighbor==np))
            {
                // No conflict (yet)
                uniqueNeighbor=np;
            }
            else
            {
                *pixSeg = cp;
                mergePair[0] = uniqueNeighbor;
                mergePair[1] = np;
                return FPR_NEEDSMERGE;
            }
        }
    }
    cp->visited = 1;
    *pixSeg = cp;
    mergePair[0] = NULL;
    mergePair[1] = NULL;
    if (uniqueNeighbor)
    {
        merge(uniqueNeighbor, cp);
        return FPR_EXTENDED;
    }
    else
    {
        return FPR_NEW;
    }
}

struct wshed *wshed_create(FPIX *fpix)
{
    struct wshed *self = calloc(1, sizeof (*self));
    memset(self, 0, sizeof (*self));
    self->fpix = fpixClone(fpix);
    fpixGetDimensions(self->fpix, &self->width, &self->height);
    self->numPixels = self->width * self->height;
    self->queue = calloc(self->numPixels, sizeof (*self->queue));
    grod_genSortedListFromFPix(self->fpix, self->queue);
    self->pgrid = calloc(self->numPixels, sizeof (*self->pgrid));
    genGridCells(self->width, self->height, self->pgrid);
    return self;
}

void wshed_free(struct wshed *self)
{
    free(self->pgrid);
    free(self->queue);
    fpixDestroy(&self->fpix);
    free(self);
}

enum fillPixResult wshed_fillImage(struct wshed *self,
                                   struct wsGridCell **pixSeg,
                                   struct wsGridCell *mergePair[2],
                                   enum mergeResult const *pmr)
{
    enum fillPixResult fpr = FPR_NEEDSMERGE;
    if (pmr) goto RESUME;
    for (;;)
    {
        fpr = fillPixel(self, pixSeg, mergePair);
        switch (fpr)
        {
        case FPR_NEEDSMERGE:
            if (self->mergeStrategy)
            {
                enum mergeResult mr =
                    (*self->mergeStrategy)(self, mergePair[0], mergePair[1]);
                pmr = &mr;
RESUME:
                switch (*pmr)
                {
                case MR_RETRY:
                    continue;
                case MR_EDGE:
                    (**pixSeg).visited = 1;
                    (**pixSeg).edge = 1;
                    goto ADVANCE;
                case MR_SKIP:
                    goto ADVANCE;
                case MR_YIELD:
                    break;
                }
            }
            return FPR_NEEDSMERGE;

        case FPR_NEW:
        case FPR_EXTENDED:
ADVANCE:
            ++ self->nextRank;
            if (self->nextRank >= self->numPixels)
            {
                return FPR_DONE;   
            }
            break;

        case FPR_DONE:
            fprintf(stderr, "FPR_DONE unexpected for single-pixel fill\n");
            abort();
            break;

        default:
            fprintf(stderr, "Invalid pixel fill result: %d\n", (int)fpr);
            abort();
            break;
        }
    }
}

