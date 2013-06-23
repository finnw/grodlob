﻿tonumber(nil or--[[)/*]]require('ffi').cdef("/*"..[[*/

enum fillPixResult
{
    FPR_DONE,       // All pixels visited
    FPR_NEW,        // Pixel is a local maximum; New segment formed
    FPR_EXTENDED,   // A segment was extended by adding a pixel
    FPR_NEEDSMERGE  // Can continue if this pixel is marked as an edge or
                    // neighboring segments are merged
};

enum mergeResult
{
    MR_EDGE,        // Pixel should be retained as an edge
    MR_RETRY,       // Merge strategy has changed something; try again
    MR_SKIP,        // Don't modify this pixel; Advance to the next one
    MR_YIELD        // Defer to caller
};

struct pixel
{
    float intensity;
    l_int16 x, y;
};

struct wsGridCell
{
    l_int8 visited, edge, rank, unused1;
    l_int16 minX, maxX, minY, maxY;
    l_int32 mass;
    struct wsGridCell *parent;
    l_int64 xSum, ySum;
};

struct wshed
{
    void *clientDataPtr;
    int clientDataIntA, clientDataIntB;
    l_int64 clientDataInt64;
    int width, height, numPixels;
    int nextRank;
    struct pixel *queue;
    struct wsGridCell *pgrid;
    enum fillPixResult (*mergeStrategy)(struct wshed *self,
                                        struct wsGridCell *seg1,
                                        struct wsGridCell *seg2);
};

void grod_genSortedListFromFPix(FPIX *fpix, struct pixel *buffer);

enum fillPixResult fillImage(struct wshed *self,
                             struct wsGridCell **pixSeg,
                             struct wsGridCell *mergePair[2],
                             enum mergeResult const *pmr);

//]]))
