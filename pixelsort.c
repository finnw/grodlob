#include "yflood_common.h"
#include "libyflood.cdef"

#define MIX(x) \
    do { \
        x += 0x2907abf3a2a7701bU; \
        x ^= (x) >> 32; \
        x ^= (x) >> 19; \
        x *= 0x531d5c5d8d29753LU; \
        x ^= (x) >> 27; \
        x ^= (x) << 7; \
    } while (0)

void gen_pixels(const float *base,
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
            dst->x = (int16_t) x;
            dst->y = (int16_t) y;
            ++ dst;
        }
    }
}

int qs_compare_pixels(const void *pv1, const void *pv2)
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
        uint64_t hash1, hash2;
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
