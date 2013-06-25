local ffi = require 'ffi'

ffi.cdef [[

/* From <leptonica/environ.h> */

typedef int8_t   l_int8;
typedef uint8_t  l_uint8;
typedef int16_t  l_int16;
typedef uint16_t l_uint16;
typedef int32_t  l_int32;
typedef uint32_t l_uint32;
typedef int64_t  l_int64; // Non-standard
typedef uint64_t l_uint64; // Non-standard
typedef float    l_float32;
typedef double   l_float64;

enum {
    L_NOT_FOUND = 0,
    L_FOUND = 1
};

/* From <leptonica/pix.h> */

struct Pix
{
    l_uint32             w;           /* width in pixels                   */
    l_uint32             h;           /* height in pixels                  */
    l_uint32             d;           /* depth in bits                     */
    l_uint32             wpl;         /* 32-bit words/line                 */
    l_uint32             refcount;    /* reference count (1 if no clones)  */
    l_int32              xres;        /* image res (ppi) in x direction    */
                                      /* (use 0 if unknown)                */
    l_int32              yres;        /* image res (ppi) in y direction    */
                                      /* (use 0 if unknown)                */
    l_int32              informat;    /* input file format, IFF_*          */
    char                *text;        /* text string associated with pix   */
    struct PixColormap  *colormap;    /* colormap (may be null)            */
    l_uint32            *data;        /* the image data                    */
};
typedef struct Pix PIX;

struct PixColormap
{
    void            *array;     /* colormap table (array of RGBA_QUAD)     */
    l_int32          depth;     /* of pix (1, 2, 4 or 8 bpp)               */
    l_int32          nalloc;    /* number of color entries allocated       */
    l_int32          n;         /* number of color entries used            */
};
typedef struct PixColormap  PIXCMAP;

struct RGBA_Quad
{
    l_uint8     blue;
    l_uint8     green;
    l_uint8     red;
    l_uint8     reserved;
};
typedef struct RGBA_Quad  RGBA_QUAD;

enum {
    COLOR_RED = 0,
    COLOR_GREEN = 1,
    COLOR_BLUE = 2,
    L_ALPHA_CHANNEL = 3
};

static const l_int32  L_RED_SHIFT =
       8 * (sizeof(l_uint32) - 1 - COLOR_RED);           /* 24 */
static const l_int32  L_GREEN_SHIFT =
       8 * (sizeof(l_uint32) - 1 - COLOR_GREEN);         /* 16 */
static const l_int32  L_BLUE_SHIFT =
       8 * (sizeof(l_uint32) - 1 - COLOR_BLUE);          /*  8 */
static const l_int32  L_ALPHA_SHIFT =
       8 * (sizeof(l_uint32) - 1 - L_ALPHA_CHANNEL);     /*  0 */

enum {
    REMOVE_CMAP_TO_BINARY = 0,
    REMOVE_CMAP_TO_GRAYSCALE = 1,
    REMOVE_CMAP_TO_FULL_COLOR = 2,
    REMOVE_CMAP_BASED_ON_SRC = 3
};
static const int32_t PIX_SRC = 0xc << 1;
static const int32_t PIX_DST = 0xa << 1;
static const int32_t PIX_CLR = 0x0 << 1;
static const int32_t PIX_SET = 0xf << 1;

static const int32_t PIX_PAINT = PIX_SRC | PIX_DST;
static const int32_t PIX_MASK = PIX_SRC & PIX_DST;
static const int32_t PIX_XOR = PIX_SRC ^ PIX_DST;

struct Pixa
{
    l_int32             n;            /* number of Pix in ptr array        */
    l_int32             nalloc;       /* number of Pix ptrs allocated      */
    l_uint32            refcount;     /* reference count (1 if no clones)  */
    struct Pix        **pix;          /* the array of ptrs to pix          */
    struct Boxa        *boxa;         /* array of boxes                    */
};
typedef struct Pixa PIXA;

struct Pixaa
{
    l_int32             n;            /* number of Pixa in ptr array       */
    l_int32             nalloc;       /* number of Pixa ptrs allocated     */
    struct Pixa       **pixa;         /* array of ptrs to pixa             */
    struct Boxa        *boxa;         /* array of boxes                    */
};
typedef struct Pixaa PIXAA;

struct Box
{
    l_int32            x;
    l_int32            y;
    l_int32            w;
    l_int32            h;
    l_uint32           refcount;      /* reference count (1 if no clones)  */

};
typedef struct Box    BOX;

struct Boxa
{
    l_int32            n;             /* number of box in ptr array        */
    l_int32            nalloc;        /* number of box ptrs allocated      */
    l_uint32           refcount;      /* reference count (1 if no clones)  */
    struct Box       **box;           /* box ptr array                     */
};
typedef struct Boxa  BOXA;

struct Boxaa
{
    l_int32            n;             /* number of boxa in ptr array       */
    l_int32            nalloc;        /* number of boxa ptrs allocated     */
    struct Boxa      **boxa;          /* boxa ptr array                    */
};
typedef struct Boxaa  BOXAA;

struct Pta
{
    l_int32            n;             /* actual number of pts              */
    l_int32            nalloc;        /* size of allocated arrays          */
    l_int32            refcount;      /* reference count (1 if no clones)  */
    l_float32         *x, *y;         /* arrays of floats                  */
};
typedef struct Pta PTA;

struct Ptaa
{
    l_int32              n;           /* number of pta in ptr array        */
    l_int32              nalloc;      /* number of pta ptrs allocated      */
    struct Pta         **pta;         /* pta ptr array                     */
};
typedef struct Ptaa PTAA;

struct Pixacc
{
    l_int32             w;            /* array width                       */
    l_int32             h;            /* array height                      */
    l_int32             offset;       /* used to allow negative            */
                                      /* intermediate results              */
    struct Pix         *pix;          /* the 32 bit accumulator pix        */
};
typedef struct Pixacc PIXACC;

struct PixTiling
{
    struct Pix          *pix;         /* input pix (a clone)               */
    l_int32              nx;          /* number of tiles horizontally      */
    l_int32              ny;          /* number of tiles vertically        */
    l_int32              w;           /* tile width                        */
    l_int32              h;           /* tile height                       */
    l_int32              xoverlap;    /* overlap on left and right         */
    l_int32              yoverlap;    /* overlap on top and bottom         */
    l_int32              strip;       /* strip for paint; default is TRUE  */
};
typedef struct PixTiling PIXTILING;

struct FPix
{
    l_int32              w;           /* width in pixels                   */
    l_int32              h;           /* height in pixels                  */
    l_int32              wpl;         /* 32-bit words/line                 */
    l_int32              refcount;    /* reference count (1 if no clones)  */
    l_int32              xres;        /* image res (ppi) in x direction    */
                                      /* (use 0 if unknown)                */
    l_int32              yres;        /* image res (ppi) in y direction    */
                                      /* (use 0 if unknown)                */
    l_float32           *data;        /* the float image data              */
};
typedef struct FPix FPIX;

struct FPixa
{
    l_int32             n;            /* number of Pix in ptr array        */
    l_int32             nalloc;       /* number of Pix ptrs allocated      */
    l_uint32            refcount;     /* reference count (1 if no clones)  */
    struct FPix       **fpix;         /* the array of ptrs to fpix         */
};
typedef struct FPixa FPIXA;

struct DPix
{
    l_int32              w;           /* width in pixels                   */
    l_int32              h;           /* height in pixels                  */
    l_int32              wpl;         /* 32-bit words/line                 */
    l_int32              refcount;    /* reference count (1 if no clones)  */
    l_int32              xres;        /* image res (ppi) in x direction    */
                                      /* (use 0 if unknown)                */
    l_int32              yres;        /* image res (ppi) in y direction    */
                                      /* (use 0 if unknown)                */
    l_float64           *data;        /* the double image data             */
};
typedef struct DPix DPIX;

struct PixComp
{
    l_int32              w;           /* width in pixels                   */
    l_int32              h;           /* height in pixels                  */
    l_int32              d;           /* depth in bits                     */
    l_int32              xres;        /* image res (ppi) in x direction    */
                                      /*   (use 0 if unknown)              */
    l_int32              yres;        /* image res (ppi) in y direction    */
                                      /*   (use 0 if unknown)              */
    l_int32              comptype;    /* compressed format (IFF_TIFF_G4,   */
                                      /*   IFF_PNG, IFF_JFIF_JPEG)         */
    char                *text;        /* text string associated with pix   */
    l_int32              cmapflag;    /* flag (1 for cmap, 0 otherwise)    */
    l_uint8             *data;        /* the compressed image data         */
    size_t               size;        /* size of the data array            */
};
typedef struct PixComp PIXC;

struct PixaComp
{
    l_int32              n;           /* number of PixComp in ptr array    */
    l_int32              nalloc;      /* number of PixComp ptrs allocated  */
    struct PixComp     **pixc;        /* the array of ptrs to PixComp      */
    struct Boxa         *boxa;        /* array of boxes                    */
};
typedef struct PixaComp PIXAC;

enum {
    L_INSERT = 0,     /* stuff it in; no copy, clone or copy-clone    */
    L_COPY = 1,       /* make/use a copy of the object                */
    L_CLONE = 2,      /* make/use clone (ref count) of the object     */
    L_COPY_CLONE = 3  /* make a new object and fill with with clones  */
                      /* of each object in the array(s)               */
};
static const l_int32  L_NOCOPY = 0;  /* copyflag value in sarrayGetString() */

enum {
    L_SORT_INCREASING = 1,        /* sort in increasing order               */
    L_SORT_DECREASING = 2         /* sort in decreasing order               */
};

enum {
    L_SORT_BY_X = 3,              /* sort box or c.c. by horiz location     */
    L_SORT_BY_Y = 4,              /* sort box or c.c. by vert location      */
    L_SORT_BY_WIDTH = 5,          /* sort box or c.c. by width              */
    L_SORT_BY_HEIGHT = 6,         /* sort box or c.c. by height             */
    L_SORT_BY_MIN_DIMENSION = 7,  /* sort box or c.c. by min dimension      */
    L_SORT_BY_MAX_DIMENSION = 8,  /* sort box or c.c. by max dimension      */
    L_SORT_BY_PERIMETER = 9,      /* sort box or c.c. by perimeter          */
    L_SORT_BY_AREA = 10,          /* sort box or c.c. by area               */
    L_SORT_BY_ASPECT_RATIO = 11   /* sort box or c.c. by width/height ratio */
};

enum {
    L_BLEND_WITH_INVERSE = 1,     /* add some of src inverse to itself     */
    L_BLEND_TO_WHITE = 2,         /* shift src colors towards white        */
    L_BLEND_TO_BLACK = 3,         /* shift src colors towards black        */
    L_BLEND_GRAY = 4,             /* blend src directly with blender       */
    L_BLEND_GRAY_WITH_INVERSE = 5 /* add amount of src inverse to itself,  */
                                  /* based on blender pix value            */
};

enum {
    L_PAINT_LIGHT = 1,            /* colorize non-black pixels             */
    L_PAINT_DARK = 2              /* colorize non-white pixels             */
};

enum {
    L_SET_PIXELS = 1,             /* set all bits in each pixel to 1       */
    L_CLEAR_PIXELS = 2,           /* set all bits in each pixel to 0       */
    L_FLIP_PIXELS = 3             /* flip all bits in each pixel           */
};

enum {
    L_SELECT_WIDTH = 1,           /* width must satisfy constraint         */
    L_SELECT_HEIGHT = 2,          /* height must satisfy constraint        */
    L_SELECT_IF_EITHER = 3,       /* either width or height can satisfy    */
    L_SELECT_IF_BOTH = 4          /* both width and height must satisfy    */
};

enum {
    L_SELECT_IF_LT = 1,           /* save if value is less than threshold  */
    L_SELECT_IF_GT = 2,           /* save if value is more than threshold  */
    L_SELECT_IF_LTE = 3,          /* save if value is <= to the threshold  */
    L_SELECT_IF_GTE = 4           /* save if value is >= to the threshold  */
};

enum {
    L_SELECT_RED = 1,             /* use red component                     */
    L_SELECT_GREEN = 2,           /* use green component                   */
    L_SELECT_BLUE = 3,            /* use blue component                    */
    L_SELECT_MIN = 4,             /* use min color component               */
    L_SELECT_MAX = 5              /* use max color component               */
};

enum {
    L_ROTATE_AREA_MAP = 1,       /* use area map rotation, if possible     */
    L_ROTATE_SHEAR = 2,          /* use shear rotation                     */
    L_ROTATE_SAMPLING = 3        /* use sampling                           */
};

enum {
    L_BRING_IN_WHITE = 1,        /* bring in white pixels from the outside */
    L_BRING_IN_BLACK = 2         /* bring in black pixels from the outside */
};

enum {
    L_SHEAR_ABOUT_CORNER = 1,    /* shear image about UL corner            */
    L_SHEAR_ABOUT_CENTER = 2     /* shear image about center               */
};

enum {
    L_TR_SC_RO = 1,              /* translate, scale, rotate               */
    L_SC_RO_TR = 2,              /* scale, rotate, translate               */
    L_RO_TR_SC = 3,              /* rotate, translate, scale               */
    L_TR_RO_SC = 4,              /* translate, rotate, scale               */
    L_RO_SC_TR = 5,              /* rotate, scale, translate               */
    L_SC_TR_RO = 6               /* scale, translate, rotate               */
};

enum {
    L_FILL_WHITE = 1,           /* fill white pixels (e.g, in fg map)      */
    L_FILL_BLACK = 2            /* fill black pixels (e.g., in bg map)     */
};

enum {
    L_SET_WHITE = 1,           /* set pixels to white                      */
    L_SET_BLACK = 2            /* set pixels to black                      */
};

enum {
    DEFAULT_CLIP_LOWER_1 = 10,   /* dist to black with no prop; 1 bpp      */
    DEFAULT_CLIP_UPPER_1 = 10,   /* dist to black with no prop; 1 bpp      */
    DEFAULT_CLIP_LOWER_2 = 5,    /* dist to black with no prop; 2 bpp      */
    DEFAULT_CLIP_UPPER_2 = 5     /* dist to black with no prop; 2 bpp      */
};

enum {
    L_MANHATTAN_DISTANCE = 1,    /* L1 distance (e.g., in color space)     */
    L_EUCLIDEAN_DISTANCE = 2     /* L2 distance                            */
};

enum {
    L_MEAN_ABSVAL = 1,           /* average of abs values                  */
    L_MEDIAN_VAL = 2,            /* median value of set                    */
    L_MODE_VAL = 3,              /* mode value of set                      */
    L_MODE_COUNT = 4,            /* mode count of set                      */
    L_ROOT_MEAN_SQUARE = 5,      /* rms of values                          */
    L_STANDARD_DEVIATION = 6,    /* standard deviation from mean           */
    L_VARIANCE = 7               /* variance of values                     */
};

enum {
    L_CHOOSE_CONSECUTIVE = 1,    /* select 'n' consecutive                 */
    L_CHOOSE_SKIP_BY = 2         /* select at intervals of 'n'             */
};

enum {
    L_TEXT_ORIENT_UNKNOWN = 0,   /* low confidence on text orientation     */
    L_TEXT_ORIENT_UP = 1,        /* portrait, text rightside-up            */
    L_TEXT_ORIENT_LEFT = 2,      /* landscape, text up to left             */
    L_TEXT_ORIENT_DOWN = 3,      /* portrait, text upside-down             */
    L_TEXT_ORIENT_RIGHT = 4      /* landscape, text up to right            */
};

enum {
    L_HORIZONTAL_EDGES = 0,     /* filters for horizontal edges            */
    L_VERTICAL_EDGES = 1,       /* filters for vertical edges              */
    L_ALL_EDGES = 2             /* filters for all edges                   */
};

enum {
    L_HORIZONTAL_LINE = 0,     /* horizontal line                          */
    L_POS_SLOPE_LINE = 1,      /* 45 degree line with positive slope       */
    L_VERTICAL_LINE = 2,       /* vertical line                            */
    L_NEG_SLOPE_LINE = 3,      /* 45 degree line with negative slope       */
    L_OBLIQUE_LINE = 4         /* neither horizontal nor vertical */
};

enum {
    L_FROM_LEFT = 0,           /* scan from left                           */
    L_FROM_RIGHT = 1,          /* scan from right                          */
    L_FROM_TOP = 2,            /* scan from top                            */
    L_FROM_BOTTOM = 3          /* scan from bottom                         */
};

enum {
    L_WARP_TO_LEFT = 1,      /* increasing stretch or contraction to left  */
    L_WARP_TO_RIGHT = 2      /* increasing stretch or contraction to right */
};

enum {
    L_LINEAR_WARP = 1,       /* stretch or contraction grows linearly      */
    L_QUADRATIC_WARP = 2     /* stretch or contraction grows quadratically */
};

enum {
    L_INTERPOLATED = 1,      /* linear interpolation from src pixels       */
    L_SAMPLED = 2            /* nearest src pixel sampling only            */
};

enum {
    L_THIN_FG = 1,               /* thin foreground of 1 bpp image         */
    L_THIN_BG = 2                /* thin background of 1 bpp image         */
};

enum {
    L_HORIZONTAL_RUNS = 0,     /* determine runlengths of horizontal runs  */
    L_VERTICAL_RUNS = 1        /* determine runlengths of vertical runs    */
};

enum {
    L_SOBEL_EDGE = 1,          /* Sobel edge filter                        */
    L_TWO_SIDED_EDGE = 2       /* Two-sided edge filter                    */
};

enum {
    L_CLIP_TO_ZERO = 1,        /* Clip negative values to 0                */
    L_TAKE_ABSVAL = 2          /* Convert to positive using L_ABS()        */
};

enum {
    L_SUBPIXEL_ORDER_RGB = 1,   /* sensor order left-to-right RGB          */
    L_SUBPIXEL_ORDER_BGR = 2,   /* sensor order left-to-right BGR          */
    L_SUBPIXEL_ORDER_VRGB = 3,  /* sensor order top-to-bottom RGB          */
    L_SUBPIXEL_ORDER_VBGR = 4   /* sensor order top-to-bottom BGR          */
};

enum {
    L_LESS_THAN_ZERO = 1,      /* Choose values less than zero             */
    L_EQUAL_TO_ZERO = 2,       /* Choose values equal to zero              */
    L_GREATER_THAN_ZERO = 3    /* Choose values greater than zero          */
};

enum {
    L_HS_HISTO = 1,            /* Use hue-saturation histogram             */
    L_HV_HISTO = 2,            /* Use hue-value histogram                  */
    L_SV_HISTO = 3             /* Use saturation-value histogram           */
};

enum {
    L_INCLUDE_REGION = 1,      /* Use hue-saturation histogram             */
    L_EXCLUDE_REGION = 2       /* Use hue-value histogram                  */
};

enum {
    L_ADD_ABOVE = 1,           /* Add text above the image                 */
    L_ADD_AT_TOP = 2,          /* Add text over the top of the image       */
    L_ADD_AT_BOTTOM = 3,       /* Add text over the bottom of the image    */
    L_ADD_BELOW = 4            /* Add text below the image                 */
};

enum {
    L_DISPLAY_WITH_XV = 1,      /* Use xv with pixDisplay()                */
    L_DISPLAY_WITH_XLI = 2,     /* Use xli with pixDisplay()               */
    L_DISPLAY_WITH_XZGV = 3,    /* Use xzgv with pixDisplay()              */
    L_DISPLAY_WITH_IV = 4       /* Use irfvanview with pixDisplay()        */
};

/* From <leptonica/array.h> */

struct Numa
{
    l_int32          nalloc;    /* size of allocated number array      */
    l_int32          n;         /* number of numbers saved             */
    l_int32          refcount;  /* reference count (1 if no clones)    */
    l_float32        startx;    /* x value assigned to array[0]        */
    l_float32        delx;      /* change in x value as i --> i + 1    */
    l_float32       *array;     /* number array                        */
};
typedef struct Numa  NUMA;

struct Numaa
{
    l_int32          nalloc;    /* size of allocated ptr array          */
    l_int32          n;         /* number of Numa saved                 */
    struct Numa    **numa;      /* array of Numa                        */
};
typedef struct Numaa  NUMAA;

struct Numa2d
{
    l_int32          nrows;      /* number of rows allocated for ptr array  */
    l_int32          ncols;      /* number of cols allocated for ptr array  */
    l_int32          initsize;   /* initial size of each numa that is made  */
    struct Numa   ***numa;       /* 2D array of Numa                        */
};
typedef struct Numa2d  NUMA2D;

struct NumaHash
{
    l_int32          nbuckets;
    l_int32          initsize;   /* initial size of each numa that is made  */
    struct Numa    **numa;
};
typedef struct NumaHash NUMAHASH;

struct Sarray
{
    l_int32          nalloc;    /* size of allocated ptr array         */
    l_int32          n;         /* number of strings allocated         */
    l_int32          refcount;  /* reference count (1 if no clones)    */
    char           **array;     /* string array                        */
};
typedef struct Sarray SARRAY;

struct L_Bytea
{
    size_t           nalloc;    /* number of bytes allocated in data array  */
    size_t           size;      /* number of bytes presently used           */
    l_int32          refcount;  /* reference count (1 if no clones)         */
    l_uint8         *data;      /* data array                               */
};
typedef struct L_Bytea L_BYTEA;

enum {
    L_LINEAR_INTERP = 1,        /* linear     */
    L_QUADRATIC_INTERP = 2      /* quadratic  */
};

enum {
    L_EXTENDED_BORDER = 1,      /* extended with same value           */
    L_MIRRORED_BORDER = 2       /* mirrored                           */
};

/* From morph.h */

struct Sel
{
    l_int32       sy;          /* sel height                               */
    l_int32       sx;          /* sel width                                */
    l_int32       cy;          /* y location of sel origin                 */
    l_int32       cx;          /* x location of sel origin                 */
    l_int32     **data;        /* {0,1,2}; data[i][j] in [row][col] order  */
    char         *name;        /* used to find sel by name                 */
};
typedef struct Sel SEL;

struct Sela
{
    l_int32          n;         /* number of sel actually stored           */
    l_int32          nalloc;    /* size of allocated ptr array             */
    struct Sel     **sel;       /* sel ptr array                           */
};
typedef struct Sela SELA;

struct L_Kernel
{
    l_int32       sy;          /* kernel height                            */
    l_int32       sx;          /* kernel width                             */
    l_int32       cy;          /* y location of kernel origin              */
    l_int32       cx;          /* x location of kernel origin              */
    l_float32   **data;        /* data[i][j] in [row][col] order           */
};
typedef struct L_Kernel  L_KERNEL;

enum {
    SYMMETRIC_MORPH_BC = 0,
    ASYMMETRIC_MORPH_BC = 1
};

enum {
    SEL_DONT_CARE  = 0,
    SEL_HIT        = 1,
    SEL_MISS       = 2
};

enum {
    L_RUN_OFF = 0,
    L_RUN_ON  = 1
};

enum {
    L_HORIZ            = 1,
    L_VERT             = 2,
    L_BOTH_DIRECTIONS  = 3
};

enum {
    L_MORPH_DILATE    = 1,
    L_MORPH_ERODE     = 2,
    L_MORPH_OPEN      = 3,
    L_MORPH_CLOSE     = 4,
    L_MORPH_HMT       = 5
};

enum {
    L_LINEAR_SCALE  = 1,
    L_LOG_SCALE     = 2
};
enum {
    L_TOPHAT_WHITE = 0,
    L_TOPHAT_BLACK = 1
};

enum {
    L_ARITH_ADD       = 1,
    L_ARITH_SUBTRACT  = 2,
    L_ARITH_MULTIPLY  = 3,   /* on numas only */
    L_ARITH_DIVIDE    = 4,   /* on numas only */
    L_UNION           = 5,   /* on numas only */
    L_INTERSECTION    = 6,   /* on numas only */
    L_SUBTRACTION     = 7,   /* on numas only */
    L_EXCLUSIVE_OR    = 8    /* on numas only */
};

enum {
    L_CHOOSE_MIN = 1,           /* useful in a downscaling "erosion"  */
    L_CHOOSE_MAX = 2,           /* useful in a downscaling "dilation" */
    L_CHOOSE_MAX_MIN_DIFF = 3   /* useful in a downscaling contrast   */
};

enum {
    L_BOUNDARY_BG = 1,  /* assume bg outside image */
    L_BOUNDARY_FG = 2   /* assume fg outside image */
};

enum {
    L_COMPARE_XOR = 1,
    L_COMPARE_SUBTRACT = 2,
    L_COMPARE_ABS_DIFF = 3
};

enum {
    L_MAX_DIFF_FROM_AVERAGE_2 = 1,
    L_MAX_MIN_DIFF_FROM_2 = 2,
    L_MAX_DIFF = 3
};

static const l_int32  ADDED_BORDER = 32;   /* pixels, not bits */

/*
LEPT_DLL extern PIX * pixBackgroundNormSimple ( PIX *pixs, PIX *pixim, PIX *pixg );
LEPT_DLL extern PIX * pixBackgroundNorm ( PIX *pixs, PIX *pixim, PIX *pixg, l_int32 sx, l_int32 sy, l_int32 thresh, l_int32 mincount, l_int32 bgval, l_int32 smoothx, l_int32 smoothy );
LEPT_DLL extern PIX * pixBackgroundNormMorph ( PIX *pixs, PIX *pixim, l_int32 reduction, l_int32 size, l_int32 bgval );
LEPT_DLL extern l_int32 pixBackgroundNormGrayArray ( PIX *pixs, PIX *pixim, l_int32 sx, l_int32 sy, l_int32 thresh, l_int32 mincount, l_int32 bgval, l_int32 smoothx, l_int32 smoothy, PIX **ppixd );
LEPT_DLL extern l_int32 pixBackgroundNormRGBArrays ( PIX *pixs, PIX *pixim, PIX *pixg, l_int32 sx, l_int32 sy, l_int32 thresh, l_int32 mincount, l_int32 bgval, l_int32 smoothx, l_int32 smoothy, PIX **ppixr, PIX **ppixg, PIX **ppixb );
LEPT_DLL extern l_int32 pixBackgroundNormGrayArrayMorph ( PIX *pixs, PIX *pixim, l_int32 reduction, l_int32 size, l_int32 bgval, PIX **ppixd );
LEPT_DLL extern l_int32 pixBackgroundNormRGBArraysMorph ( PIX *pixs, PIX *pixim, l_int32 reduction, l_int32 size, l_int32 bgval, PIX **ppixr, PIX **ppixg, PIX **ppixb );
LEPT_DLL extern l_int32 pixGetBackgroundGrayMap ( PIX *pixs, PIX *pixim, l_int32 sx, l_int32 sy, l_int32 thresh, l_int32 mincount, PIX **ppixd );
LEPT_DLL extern l_int32 pixGetBackgroundRGBMap ( PIX *pixs, PIX *pixim, PIX *pixg, l_int32 sx, l_int32 sy, l_int32 thresh, l_int32 mincount, PIX **ppixmr, PIX **ppixmg, PIX **ppixmb );
LEPT_DLL extern l_int32 pixGetBackgroundGrayMapMorph ( PIX *pixs, PIX *pixim, l_int32 reduction, l_int32 size, PIX **ppixm );
LEPT_DLL extern l_int32 pixGetBackgroundRGBMapMorph ( PIX *pixs, PIX *pixim, l_int32 reduction, l_int32 size, PIX **ppixmr, PIX **ppixmg, PIX **ppixmb );
LEPT_DLL extern l_int32 pixFillMapHoles ( PIX *pix, l_int32 nx, l_int32 ny, l_int32 filltype );
LEPT_DLL extern PIX * pixExtendByReplication ( PIX *pixs, l_int32 addw, l_int32 addh );
LEPT_DLL extern l_int32 pixSmoothConnectedRegions ( PIX *pixs, PIX *pixm, l_int32 factor );
LEPT_DLL extern PIX * pixGetInvBackgroundMap ( PIX *pixs, l_int32 bgval, l_int32 smoothx, l_int32 smoothy );
LEPT_DLL extern PIX * pixApplyInvBackgroundGrayMap ( PIX *pixs, PIX *pixm, l_int32 sx, l_int32 sy );
LEPT_DLL extern PIX * pixApplyInvBackgroundRGBMap ( PIX *pixs, PIX *pixmr, PIX *pixmg, PIX *pixmb, l_int32 sx, l_int32 sy );
LEPT_DLL extern PIX * pixApplyVariableGrayMap ( PIX *pixs, PIX *pixg, l_int32 target );
LEPT_DLL extern PIX * pixGlobalNormRGB ( PIX *pixd, PIX *pixs, l_int32 rval, l_int32 gval, l_int32 bval, l_int32 mapval );
LEPT_DLL extern PIX * pixGlobalNormNoSatRGB ( PIX *pixd, PIX *pixs, l_int32 rval, l_int32 gval, l_int32 bval, l_int32 factor, l_float32 rank );
LEPT_DLL extern l_int32 pixThresholdSpreadNorm ( PIX *pixs, l_int32 filtertype, l_int32 edgethresh, l_int32 smoothx, l_int32 smoothy, l_float32 gamma, l_int32 minval, l_int32 maxval, l_int32 targetthresh, PIX **ppixth, PIX **ppixb, PIX **ppixd );
LEPT_DLL extern PIX * pixBackgroundNormFlex ( PIX *pixs, l_int32 sx, l_int32 sy, l_int32 smoothx, l_int32 smoothy, l_int32 delta );
LEPT_DLL extern PIX * pixContrastNorm ( PIX *pixd, PIX *pixs, l_int32 sx, l_int32 sy, l_int32 mindiff, l_int32 smoothx, l_int32 smoothy );
LEPT_DLL extern l_int32 pixMinMaxTiles ( PIX *pixs, l_int32 sx, l_int32 sy, l_int32 mindiff, l_int32 smoothx, l_int32 smoothy, PIX **ppixmin, PIX **ppixmax );
LEPT_DLL extern l_int32 pixSetLowContrast ( PIX *pixs1, PIX *pixs2, l_int32 mindiff );
LEPT_DLL extern PIX * pixLinearTRCTiled ( PIX *pixd, PIX *pixs, l_int32 sx, l_int32 sy, PIX *pixmin, PIX *pixmax );
LEPT_DLL extern PIX * pixAffineSampledPta ( PIX *pixs, PTA *ptad, PTA *ptas, l_int32 incolor );
LEPT_DLL extern PIX * pixAffineSampled ( PIX *pixs, l_float32 *vc, l_int32 incolor );
LEPT_DLL extern PIX * pixAffinePta ( PIX *pixs, PTA *ptad, PTA *ptas, l_int32 incolor );
LEPT_DLL extern PIX * pixAffine ( PIX *pixs, l_float32 *vc, l_int32 incolor );
LEPT_DLL extern PIX * pixAffinePtaColor ( PIX *pixs, PTA *ptad, PTA *ptas, l_uint32 colorval );
LEPT_DLL extern PIX * pixAffineColor ( PIX *pixs, l_float32 *vc, l_uint32 colorval );
LEPT_DLL extern PIX * pixAffinePtaGray ( PIX *pixs, PTA *ptad, PTA *ptas, l_uint8 grayval );
LEPT_DLL extern PIX * pixAffineGray ( PIX *pixs, l_float32 *vc, l_uint8 grayval );
LEPT_DLL extern PIX * pixAffinePtaWithAlpha ( PIX *pixs, PTA *ptad, PTA *ptas, PIX *pixg, l_float32 fract, l_int32 border );
LEPT_DLL extern PIX * pixAffinePtaGammaXform ( PIX *pixs, l_float32 gamma, PTA *ptad, PTA *ptas, l_float32 fract, l_int32 border );
LEPT_DLL extern l_int32 getAffineXformCoeffs ( PTA *ptas, PTA *ptad, l_float32 **pvc );
LEPT_DLL extern l_int32 affineInvertXform ( l_float32 *vc, l_float32 **pvci );
LEPT_DLL extern l_int32 affineXformSampledPt ( l_float32 *vc, l_int32 x, l_int32 y, l_int32 *pxp, l_int32 *pyp );
LEPT_DLL extern l_int32 affineXformPt ( l_float32 *vc, l_int32 x, l_int32 y, l_float32 *pxp, l_float32 *pyp );
LEPT_DLL extern l_int32 linearInterpolatePixelColor ( l_uint32 *datas, l_int32 wpls, l_int32 w, l_int32 h, l_float32 x, l_float32 y, l_uint32 colorval, l_uint32 *pval );
LEPT_DLL extern l_int32 linearInterpolatePixelGray ( l_uint32 *datas, l_int32 wpls, l_int32 w, l_int32 h, l_float32 x, l_float32 y, l_int32 grayval, l_int32 *pval );
LEPT_DLL extern l_int32 gaussjordan ( l_float32 **a, l_float32 *b, l_int32 n );
LEPT_DLL extern PIX * pixAffineSequential ( PIX *pixs, PTA *ptad, PTA *ptas, l_int32 bw, l_int32 bh );
LEPT_DLL extern l_float32 * createMatrix2dTranslate ( l_float32 transx, l_float32 transy );
LEPT_DLL extern l_float32 * createMatrix2dScale ( l_float32 scalex, l_float32 scaley );
LEPT_DLL extern l_float32 * createMatrix2dRotate ( l_float32 xc, l_float32 yc, l_float32 angle );
LEPT_DLL extern PTA * ptaTranslate ( PTA *ptas, l_float32 transx, l_float32 transy );
LEPT_DLL extern PTA * ptaScale ( PTA *ptas, l_float32 scalex, l_float32 scaley );
LEPT_DLL extern PTA * ptaRotate ( PTA *ptas, l_float32 xc, l_float32 yc, l_float32 angle );
LEPT_DLL extern BOXA * boxaTranslate ( BOXA *boxas, l_float32 transx, l_float32 transy );
LEPT_DLL extern BOXA * boxaScale ( BOXA *boxas, l_float32 scalex, l_float32 scaley );
LEPT_DLL extern BOXA * boxaRotate ( BOXA *boxas, l_float32 xc, l_float32 yc, l_float32 angle );
LEPT_DLL extern PTA * ptaAffineTransform ( PTA *ptas, l_float32 *mat );
LEPT_DLL extern BOXA * boxaAffineTransform ( BOXA *boxas, l_float32 *mat );
LEPT_DLL extern l_int32 l_productMatVec ( l_float32 *mat, l_float32 *vecs, l_float32 *vecd, l_int32 size );
LEPT_DLL extern l_int32 l_productMat2 ( l_float32 *mat1, l_float32 *mat2, l_float32 *matd, l_int32 size );
LEPT_DLL extern l_int32 l_productMat3 ( l_float32 *mat1, l_float32 *mat2, l_float32 *mat3, l_float32 *matd, l_int32 size );
LEPT_DLL extern l_int32 l_productMat4 ( l_float32 *mat1, l_float32 *mat2, l_float32 *mat3, l_float32 *mat4, l_float32 *matd, l_int32 size );
LEPT_DLL extern void addConstantGrayLow ( l_uint32 *data, l_int32 w, l_int32 h, l_int32 d, l_int32 wpl, l_int32 val );
LEPT_DLL extern void multConstantGrayLow ( l_uint32 *data, l_int32 w, l_int32 h, l_int32 d, l_int32 wpl, l_float32 val );
LEPT_DLL extern void addGrayLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 d, l_int32 wpld, l_uint32 *datas, l_int32 wpls );
LEPT_DLL extern void subtractGrayLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 d, l_int32 wpld, l_uint32 *datas, l_int32 wpls );
LEPT_DLL extern void thresholdToValueLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 d, l_int32 wpld, l_int32 threshval, l_int32 setval );
LEPT_DLL extern void finalAccumulateLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 d, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_uint32 offset );
LEPT_DLL extern void finalAccumulateThreshLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_uint32 offset, l_uint32 threshold );
LEPT_DLL extern void accumulateLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 d, l_int32 wpls, l_int32 op );
LEPT_DLL extern void multConstAccumulateLow ( l_uint32 *data, l_int32 w, l_int32 h, l_int32 wpl, l_float32 factor, l_uint32 offset );
LEPT_DLL extern void absDifferenceLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas1, l_uint32 *datas2, l_int32 d, l_int32 wpls );
LEPT_DLL extern l_int32 l_getDataBit ( void *line, l_int32 n );
LEPT_DLL extern void l_setDataBit ( void *line, l_int32 n );
LEPT_DLL extern void l_clearDataBit ( void *line, l_int32 n );
LEPT_DLL extern void l_setDataBitVal ( void *line, l_int32 n, l_int32 val );
LEPT_DLL extern l_int32 l_getDataDibit ( void *line, l_int32 n );
LEPT_DLL extern void l_setDataDibit ( void *line, l_int32 n, l_int32 val );
LEPT_DLL extern void l_clearDataDibit ( void *line, l_int32 n );
LEPT_DLL extern l_int32 l_getDataQbit ( void *line, l_int32 n );
LEPT_DLL extern void l_setDataQbit ( void *line, l_int32 n, l_int32 val );
LEPT_DLL extern void l_clearDataQbit ( void *line, l_int32 n );
LEPT_DLL extern l_int32 l_getDataByte ( void *line, l_int32 n );
LEPT_DLL extern void l_setDataByte ( void *line, l_int32 n, l_int32 val );
LEPT_DLL extern l_int32 l_getDataTwoBytes ( void *line, l_int32 n );
LEPT_DLL extern void l_setDataTwoBytes ( void *line, l_int32 n, l_int32 val );
LEPT_DLL extern l_int32 l_getDataFourBytes ( void *line, l_int32 n );
LEPT_DLL extern void l_setDataFourBytes ( void *line, l_int32 n, l_int32 val );
LEPT_DLL extern char * barcodeDispatchDecoder ( char *barstr, l_int32 format, l_int32 debugflag );
LEPT_DLL extern l_int32 barcodeFormatIsSupported ( l_int32 format );
LEPT_DLL extern NUMA * pixFindBaselines ( PIX *pixs, PTA **ppta, l_int32 debug );
LEPT_DLL extern PIX * pixDeskewLocal ( PIX *pixs, l_int32 nslices, l_int32 redsweep, l_int32 redsearch, l_float32 sweeprange, l_float32 sweepdelta, l_float32 minbsdelta );
LEPT_DLL extern l_int32 pixGetLocalSkewTransform ( PIX *pixs, l_int32 nslices, l_int32 redsweep, l_int32 redsearch, l_float32 sweeprange, l_float32 sweepdelta, l_float32 minbsdelta, PTA **pptas, PTA **pptad );
LEPT_DLL extern NUMA * pixGetLocalSkewAngles ( PIX *pixs, l_int32 nslices, l_int32 redsweep, l_int32 redsearch, l_float32 sweeprange, l_float32 sweepdelta, l_float32 minbsdelta, l_float32 *pa, l_float32 *pb );
LEPT_DLL extern BBUFFER * bbufferCreate ( l_uint8 *indata, l_int32 nalloc );
LEPT_DLL extern void bbufferDestroy ( BBUFFER **pbb );
LEPT_DLL extern l_uint8 * bbufferDestroyAndSaveData ( BBUFFER **pbb, size_t *pnbytes );
LEPT_DLL extern l_int32 bbufferRead ( BBUFFER *bb, l_uint8 *src, l_int32 nbytes );
LEPT_DLL extern l_int32 bbufferReadStream ( BBUFFER *bb, FILE *fp, l_int32 nbytes );
LEPT_DLL extern l_int32 bbufferExtendArray ( BBUFFER *bb, l_int32 nbytes );
LEPT_DLL extern l_int32 bbufferWrite ( BBUFFER *bb, l_uint8 *dest, size_t nbytes, size_t *pnout );
LEPT_DLL extern l_int32 bbufferWriteStream ( BBUFFER *bb, FILE *fp, size_t nbytes, size_t *pnout );
LEPT_DLL extern l_int32 bbufferBytesToWrite ( BBUFFER *bb, size_t *pnbytes );
LEPT_DLL extern PIX * pixBilinearSampledPta ( PIX *pixs, PTA *ptad, PTA *ptas, l_int32 incolor );
LEPT_DLL extern PIX * pixBilinearSampled ( PIX *pixs, l_float32 *vc, l_int32 incolor );
LEPT_DLL extern PIX * pixBilinearPta ( PIX *pixs, PTA *ptad, PTA *ptas, l_int32 incolor );
LEPT_DLL extern PIX * pixBilinear ( PIX *pixs, l_float32 *vc, l_int32 incolor );
LEPT_DLL extern PIX * pixBilinearPtaColor ( PIX *pixs, PTA *ptad, PTA *ptas, l_uint32 colorval );
LEPT_DLL extern PIX * pixBilinearColor ( PIX *pixs, l_float32 *vc, l_uint32 colorval );
LEPT_DLL extern PIX * pixBilinearPtaGray ( PIX *pixs, PTA *ptad, PTA *ptas, l_uint8 grayval );
LEPT_DLL extern PIX * pixBilinearGray ( PIX *pixs, l_float32 *vc, l_uint8 grayval );
LEPT_DLL extern PIX * pixBilinearPtaWithAlpha ( PIX *pixs, PTA *ptad, PTA *ptas, PIX *pixg, l_float32 fract, l_int32 border );
LEPT_DLL extern PIX * pixBilinearPtaGammaXform ( PIX *pixs, l_float32 gamma, PTA *ptad, PTA *ptas, l_float32 fract, l_int32 border );
LEPT_DLL extern l_int32 getBilinearXformCoeffs ( PTA *ptas, PTA *ptad, l_float32 **pvc );
LEPT_DLL extern l_int32 bilinearXformSampledPt ( l_float32 *vc, l_int32 x, l_int32 y, l_int32 *pxp, l_int32 *pyp );
LEPT_DLL extern l_int32 bilinearXformPt ( l_float32 *vc, l_int32 x, l_int32 y, l_float32 *pxp, l_float32 *pyp );
LEPT_DLL extern l_int32 pixOtsuAdaptiveThreshold ( PIX *pixs, l_int32 sx, l_int32 sy, l_int32 smoothx, l_int32 smoothy, l_float32 scorefract, PIX **ppixth, PIX **ppixd );
LEPT_DLL extern PIX * pixOtsuThreshOnBackgroundNorm ( PIX *pixs, PIX *pixim, l_int32 sx, l_int32 sy, l_int32 thresh, l_int32 mincount, l_int32 bgval, l_int32 smoothx, l_int32 smoothy, l_float32 scorefract, l_int32 *pthresh );
LEPT_DLL extern PIX * pixMaskedThreshOnBackgroundNorm ( PIX *pixs, PIX *pixim, l_int32 sx, l_int32 sy, l_int32 thresh, l_int32 mincount, l_int32 smoothx, l_int32 smoothy, l_float32 scorefract, l_int32 *pthresh );
LEPT_DLL extern l_int32 pixSauvolaBinarizeTiled ( PIX *pixs, l_int32 whsize, l_float32 factor, l_int32 nx, l_int32 ny, PIX **ppixth, PIX **ppixd );
LEPT_DLL extern l_int32 pixSauvolaBinarize ( PIX *pixs, l_int32 whsize, l_float32 factor, l_int32 addborder, PIX **ppixm, PIX **ppixsd, PIX **ppixth, PIX **ppixd );
LEPT_DLL extern PIX * pixSauvolaGetThreshold ( PIX *pixm, PIX *pixms, l_float32 factor, PIX **ppixsd );
LEPT_DLL extern PIX * pixApplyLocalThreshold ( PIX *pixs, PIX *pixth, l_int32 redfactor );
LEPT_DLL extern PIX * pixExpandBinaryReplicate ( PIX *pixs, l_int32 factor );
LEPT_DLL extern PIX * pixExpandBinaryPower2 ( PIX *pixs, l_int32 factor );
LEPT_DLL extern l_int32 expandBinaryPower2Low ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 ws, l_int32 hs, l_int32 wpls, l_int32 factor );
LEPT_DLL extern l_uint16 * makeExpandTab2x ( void );
LEPT_DLL extern l_uint32 * makeExpandTab4x ( void );
LEPT_DLL extern l_uint32 * makeExpandTab8x ( void );
LEPT_DLL extern PIX * pixReduceBinary2 ( PIX *pixs, l_uint8 *intab );
LEPT_DLL extern PIX * pixReduceRankBinaryCascade ( PIX *pixs, l_int32 level1, l_int32 level2, l_int32 level3, l_int32 level4 );
LEPT_DLL extern PIX * pixReduceRankBinary2 ( PIX *pixs, l_int32 level, l_uint8 *intab );
LEPT_DLL extern void reduceBinary2Low ( l_uint32 *datad, l_int32 wpld, l_uint32 *datas, l_int32 hs, l_int32 wpls, l_uint8 *tab );
LEPT_DLL extern void reduceRankBinary2Low ( l_uint32 *datad, l_int32 wpld, l_uint32 *datas, l_int32 hs, l_int32 wpls, l_uint8 *tab, l_int32 level );
LEPT_DLL extern l_uint8 * makeSubsampleTab2x ( void );
LEPT_DLL extern PIX * pixBlend ( PIX *pixs1, PIX *pixs2, l_int32 x, l_int32 y, l_float32 fract );
LEPT_DLL extern PIX * pixBlendMask ( PIX *pixd, PIX *pixs1, PIX *pixs2, l_int32 x, l_int32 y, l_float32 fract, l_int32 type );
LEPT_DLL extern PIX * pixBlendGray ( PIX *pixd, PIX *pixs1, PIX *pixs2, l_int32 x, l_int32 y, l_float32 fract, l_int32 type, l_int32 transparent, l_uint32 transpix );
LEPT_DLL extern PIX * pixBlendColor ( PIX *pixd, PIX *pixs1, PIX *pixs2, l_int32 x, l_int32 y, l_float32 fract, l_int32 transparent, l_uint32 transpix );
LEPT_DLL extern PIX * pixBlendColorByChannel ( PIX *pixd, PIX *pixs1, PIX *pixs2, l_int32 x, l_int32 y, l_float32 rfract, l_float32 gfract, l_float32 bfract, l_int32 transparent, l_uint32 transpix );
LEPT_DLL extern PIX * pixBlendGrayAdapt ( PIX *pixd, PIX *pixs1, PIX *pixs2, l_int32 x, l_int32 y, l_float32 fract, l_int32 shift );
LEPT_DLL extern PIX * pixFadeWithGray ( PIX *pixs, PIX *pixb, l_float32 factor, l_int32 type );
LEPT_DLL extern PIX * pixBlendHardLight ( PIX *pixd, PIX *pixs1, PIX *pixs2, l_int32 x, l_int32 y, l_float32 fract );
LEPT_DLL extern l_int32 pixBlendCmap ( PIX *pixs, PIX *pixb, l_int32 x, l_int32 y, l_int32 sindex );
LEPT_DLL extern PIX * pixBlendWithGrayMask ( PIX *pixs1, PIX *pixs2, PIX *pixg, l_int32 x, l_int32 y );
LEPT_DLL extern l_int32 pixColorGray ( PIX *pixs, BOX *box, l_int32 type, l_int32 thresh, l_int32 rval, l_int32 gval, l_int32 bval );
LEPT_DLL extern PIX * pixSnapColor ( PIX *pixd, PIX *pixs, l_uint32 srcval, l_uint32 dstval, l_int32 diff );
LEPT_DLL extern PIX * pixSnapColorCmap ( PIX *pixd, PIX *pixs, l_uint32 srcval, l_uint32 dstval, l_int32 diff );
LEPT_DLL extern PIX * pixLinearMapToTargetColor ( PIX *pixd, PIX *pixs, l_uint32 srcval, l_uint32 dstval );
LEPT_DLL extern l_int32 pixelLinearMapToTargetColor ( l_uint32 scolor, l_uint32 srcmap, l_uint32 dstmap, l_uint32 *pdcolor );
LEPT_DLL extern l_int32 pixelFractionalShift ( l_int32 rval, l_int32 gval, l_int32 bval, l_float32 fraction, l_uint32 *ppixel );
LEPT_DLL extern L_BMF * bmfCreate ( const char *dir, l_int32 size );
LEPT_DLL extern void bmfDestroy ( L_BMF **pbmf );
LEPT_DLL extern PIX * bmfGetPix ( L_BMF *bmf, char chr );
LEPT_DLL extern l_int32 bmfGetWidth ( L_BMF *bmf, char chr, l_int32 *pw );
LEPT_DLL extern l_int32 bmfGetBaseline ( L_BMF *bmf, char chr, l_int32 *pbaseline );
LEPT_DLL extern PIXA * pixaGetFont ( const char *dir, l_int32 size, l_int32 *pbl0, l_int32 *pbl1, l_int32 *pbl2 );
LEPT_DLL extern l_int32 pixaSaveFont ( const char *indir, const char *outdir, l_int32 size );
LEPT_DLL extern PIXA * pixaGenerateFont ( const char *dir, l_int32 size, l_int32 *pbl0, l_int32 *pbl1, l_int32 *pbl2 );
LEPT_DLL extern PIX * pixReadStreamBmp ( FILE *fp );
LEPT_DLL extern l_int32 pixWriteStreamBmp ( FILE *fp, PIX *pix );
LEPT_DLL extern PIX * pixReadMemBmp ( const l_uint8 *cdata, size_t size );
LEPT_DLL extern l_int32 pixWriteMemBmp ( l_uint8 **pdata, size_t *psize, PIX *pix );
LEPT_DLL extern BOX * boxCreate ( l_int32 x, l_int32 y, l_int32 w, l_int32 h );
LEPT_DLL extern BOX * boxCreateValid ( l_int32 x, l_int32 y, l_int32 w, l_int32 h );
LEPT_DLL extern BOX * boxCopy ( BOX *box );
LEPT_DLL extern BOX * boxClone ( BOX *box );
LEPT_DLL extern void boxDestroy ( BOX **pbox );
LEPT_DLL extern l_int32 boxGetGeometry ( BOX *box, l_int32 *px, l_int32 *py, l_int32 *pw, l_int32 *ph );
LEPT_DLL extern l_int32 boxSetGeometry ( BOX *box, l_int32 x, l_int32 y, l_int32 w, l_int32 h );
LEPT_DLL extern l_int32 boxGetRefcount ( BOX *box );
LEPT_DLL extern l_int32 boxChangeRefcount ( BOX *box, l_int32 delta );
LEPT_DLL extern BOXA * boxaCreate ( l_int32 n );
LEPT_DLL extern BOXA * boxaCopy ( BOXA *boxa, l_int32 copyflag );
LEPT_DLL extern void boxaDestroy ( BOXA **pboxa );
LEPT_DLL extern l_int32 boxaAddBox ( BOXA *boxa, BOX *box, l_int32 copyflag );
LEPT_DLL extern l_int32 boxaExtendArray ( BOXA *boxa );
LEPT_DLL extern l_int32 boxaExtendArrayToSize ( BOXA *boxa, l_int32 size );
LEPT_DLL extern l_int32 boxaGetCount ( BOXA *boxa );
LEPT_DLL extern l_int32 boxaGetValidCount ( BOXA *boxa );
LEPT_DLL extern BOX * boxaGetBox ( BOXA *boxa, l_int32 index, l_int32 accessflag );
LEPT_DLL extern BOX * boxaGetValidBox ( BOXA *boxa, l_int32 index, l_int32 accessflag );
LEPT_DLL extern l_int32 boxaGetBoxGeometry ( BOXA *boxa, l_int32 index, l_int32 *px, l_int32 *py, l_int32 *pw, l_int32 *ph );
LEPT_DLL extern l_int32 boxaReplaceBox ( BOXA *boxa, l_int32 index, BOX *box );
LEPT_DLL extern l_int32 boxaInsertBox ( BOXA *boxa, l_int32 index, BOX *box );
LEPT_DLL extern l_int32 boxaRemoveBox ( BOXA *boxa, l_int32 index );
LEPT_DLL extern l_int32 boxaInitFull ( BOXA *boxa, BOX *box );
LEPT_DLL extern l_int32 boxaClear ( BOXA *boxa );
LEPT_DLL extern BOXAA * boxaaCreate ( l_int32 n );
LEPT_DLL extern BOXAA * boxaaCopy ( BOXAA *baas, l_int32 copyflag );
LEPT_DLL extern void boxaaDestroy ( BOXAA **pbaa );
LEPT_DLL extern l_int32 boxaaAddBoxa ( BOXAA *baa, BOXA *ba, l_int32 copyflag );
LEPT_DLL extern l_int32 boxaaExtendArray ( BOXAA *baa );
LEPT_DLL extern l_int32 boxaaGetCount ( BOXAA *baa );
LEPT_DLL extern l_int32 boxaaGetBoxCount ( BOXAA *baa );
LEPT_DLL extern BOXA * boxaaGetBoxa ( BOXAA *baa, l_int32 index, l_int32 accessflag );
LEPT_DLL extern l_int32 boxaaReplaceBoxa ( BOXAA *baa, l_int32 index, BOXA *boxa );
LEPT_DLL extern l_int32 boxaaInsertBoxa ( BOXAA *baa, l_int32 index, BOXA *boxa );
LEPT_DLL extern l_int32 boxaaRemoveBoxa ( BOXAA *baa, l_int32 index );
LEPT_DLL extern l_int32 boxaaAddBox ( BOXAA *baa, l_int32 index, BOX *box, l_int32 accessflag );
LEPT_DLL extern BOXAA * boxaaRead ( const char *filename );
LEPT_DLL extern BOXAA * boxaaReadStream ( FILE *fp );
LEPT_DLL extern l_int32 boxaaWrite ( const char *filename, BOXAA *baa );
LEPT_DLL extern l_int32 boxaaWriteStream ( FILE *fp, BOXAA *baa );
LEPT_DLL extern BOXA * boxaRead ( const char *filename );
LEPT_DLL extern BOXA * boxaReadStream ( FILE *fp );
LEPT_DLL extern l_int32 boxaWrite ( const char *filename, BOXA *boxa );
LEPT_DLL extern l_int32 boxaWriteStream ( FILE *fp, BOXA *boxa );
LEPT_DLL extern l_int32 boxPrintStreamInfo ( FILE *fp, BOX *box );
LEPT_DLL extern l_int32 boxContains ( BOX *box1, BOX *box2, l_int32 *presult );
LEPT_DLL extern l_int32 boxIntersects ( BOX *box1, BOX *box2, l_int32 *presult );
LEPT_DLL extern BOXA * boxaContainedInBox ( BOXA *boxas, BOX *box );
LEPT_DLL extern BOXA * boxaIntersectsBox ( BOXA *boxas, BOX *box );
LEPT_DLL extern BOXA * boxaClipToBox ( BOXA *boxas, BOX *box );
LEPT_DLL extern BOXA * boxaCombineOverlaps ( BOXA *boxas );
LEPT_DLL extern BOX * boxOverlapRegion ( BOX *box1, BOX *box2 );
LEPT_DLL extern BOX * boxBoundingRegion ( BOX *box1, BOX *box2 );
LEPT_DLL extern l_int32 boxOverlapFraction ( BOX *box1, BOX *box2, l_float32 *pfract );
LEPT_DLL extern l_int32 boxContainsPt ( BOX *box, l_float32 x, l_float32 y, l_int32 *pcontains );
LEPT_DLL extern BOX * boxaGetNearestToPt ( BOXA *boxa, l_int32 x, l_int32 y );
LEPT_DLL extern l_int32 boxGetCenter ( BOX *box, l_float32 *pcx, l_float32 *pcy );
LEPT_DLL extern l_int32 boxIntersectByLine ( BOX *box, l_int32 x, l_int32 y, l_float32 slope, l_int32 *px1, l_int32 *py1, l_int32 *px2, l_int32 *py2, l_int32 *pn );
LEPT_DLL extern BOX * boxClipToRectangle ( BOX *box, l_int32 wi, l_int32 hi );
LEPT_DLL extern BOX * boxRelocateOneSide ( BOX *boxd, BOX *boxs, l_int32 loc, l_int32 sideflag );
LEPT_DLL extern BOX * boxAdjustSides ( BOX *boxd, BOX *boxs, l_int32 delleft, l_int32 delright, l_int32 deltop, l_int32 delbot );
LEPT_DLL extern l_int32 boxEqual ( BOX *box1, BOX *box2, l_int32 *psame );
LEPT_DLL extern l_int32 boxaEqual ( BOXA *boxa1, BOXA *boxa2, l_int32 maxdist, NUMA **pnaindex, l_int32 *psame );
LEPT_DLL extern l_int32 boxaJoin ( BOXA *boxad, BOXA *boxas, l_int32 istart, l_int32 iend );
LEPT_DLL extern l_int32 boxaGetExtent ( BOXA *boxa, l_int32 *pw, l_int32 *ph, BOX **pbox );
LEPT_DLL extern l_int32 boxaGetCoverage ( BOXA *boxa, l_int32 wc, l_int32 hc, l_int32 exactflag, l_float32 *pfract );
LEPT_DLL extern l_int32 boxaSizeRange ( BOXA *boxa, l_int32 *pminw, l_int32 *pminh, l_int32 *pmaxw, l_int32 *pmaxh );
LEPT_DLL extern l_int32 boxaLocationRange ( BOXA *boxa, l_int32 *pminx, l_int32 *pminy, l_int32 *pmaxx, l_int32 *pmaxy );
LEPT_DLL extern BOXA * boxaSelectBySize ( BOXA *boxas, l_int32 width, l_int32 height, l_int32 type, l_int32 relation, l_int32 *pchanged );
LEPT_DLL extern NUMA * boxaMakeSizeIndicator ( BOXA *boxa, l_int32 width, l_int32 height, l_int32 type, l_int32 relation );
LEPT_DLL extern BOXA * boxaSelectWithIndicator ( BOXA *boxas, NUMA *na, l_int32 *pchanged );
LEPT_DLL extern BOXA * boxaPermutePseudorandom ( BOXA *boxas );
LEPT_DLL extern BOXA * boxaPermuteRandom ( BOXA *boxad, BOXA *boxas );
LEPT_DLL extern l_int32 boxaSwapBoxes ( BOXA *boxa, l_int32 i, l_int32 j );
LEPT_DLL extern PTA * boxaConvertToPta ( BOXA *boxa, l_int32 ncorners );
LEPT_DLL extern BOXA * ptaConvertToBoxa ( PTA *pta, l_int32 ncorners );
LEPT_DLL extern BOXA * boxaTransform ( BOXA *boxas, l_int32 shiftx, l_int32 shifty, l_float32 scalex, l_float32 scaley );
LEPT_DLL extern BOX * boxTransform ( BOX *box, l_int32 shiftx, l_int32 shifty, l_float32 scalex, l_float32 scaley );
LEPT_DLL extern BOXA * boxaTransformOrdered ( BOXA *boxas, l_int32 shiftx, l_int32 shifty, l_float32 scalex, l_float32 scaley, l_int32 xcen, l_int32 ycen, l_float32 angle, l_int32 order );
LEPT_DLL extern BOX * boxTransformOrdered ( BOX *boxs, l_int32 shiftx, l_int32 shifty, l_float32 scalex, l_float32 scaley, l_int32 xcen, l_int32 ycen, l_float32 angle, l_int32 order );
LEPT_DLL extern BOXA * boxaRotateOrth ( BOXA *boxas, l_int32 w, l_int32 h, l_int32 rotation );
LEPT_DLL extern BOX * boxRotateOrth ( BOX *box, l_int32 w, l_int32 h, l_int32 rotation );
LEPT_DLL extern BOXA * boxaSort ( BOXA *boxas, l_int32 sorttype, l_int32 sortorder, NUMA **pnaindex );
LEPT_DLL extern BOXA * boxaBinSort ( BOXA *boxas, l_int32 sorttype, l_int32 sortorder, NUMA **pnaindex );
LEPT_DLL extern BOXA * boxaSortByIndex ( BOXA *boxas, NUMA *naindex );
LEPT_DLL extern BOXAA * boxaSort2d ( BOXA *boxas, NUMAA **pnaad, l_int32 delta1, l_int32 delta2, l_int32 minh1 );
LEPT_DLL extern BOXAA * boxaSort2dByIndex ( BOXA *boxas, NUMAA *naa );
LEPT_DLL extern BOX * boxaGetRankSize ( BOXA *boxa, l_float32 fract );
LEPT_DLL extern BOX * boxaGetMedian ( BOXA *boxa );
LEPT_DLL extern l_int32 boxaaGetExtent ( BOXAA *boxaa, l_int32 *pw, l_int32 *ph, BOX **pbox );
LEPT_DLL extern BOXA * boxaaFlattenToBoxa ( BOXAA *baa, NUMA **pnaindex, l_int32 copyflag );
LEPT_DLL extern l_int32 boxaaAlignBox ( BOXAA *baa, BOX *box, l_int32 delta, l_int32 *pindex );
LEPT_DLL extern PIX * pixMaskConnComp ( PIX *pixs, l_int32 connectivity, BOXA **pboxa );
LEPT_DLL extern PIX * pixMaskBoxa ( PIX *pixd, PIX *pixs, BOXA *boxa, l_int32 op );
LEPT_DLL extern PIX * pixPaintBoxa ( PIX *pixs, BOXA *boxa, l_uint32 val );
LEPT_DLL extern PIX * pixSetBlackOrWhiteBoxa ( PIX *pixs, BOXA *boxa, l_int32 op );
LEPT_DLL extern PIX * pixPaintBoxaRandom ( PIX *pixs, BOXA *boxa );
LEPT_DLL extern PIX * pixBlendBoxaRandom ( PIX *pixs, BOXA *boxa, l_float32 fract );
LEPT_DLL extern PIX * pixDrawBoxa ( PIX *pixs, BOXA *boxa, l_int32 width, l_uint32 val );
LEPT_DLL extern PIX * pixDrawBoxaRandom ( PIX *pixs, BOXA *boxa, l_int32 width );
LEPT_DLL extern PIX * boxaaDisplay ( BOXAA *boxaa, l_int32 linewba, l_int32 linewb, l_uint32 colorba, l_uint32 colorb, l_int32 w, l_int32 h );
LEPT_DLL extern BOXA * pixSplitIntoBoxa ( PIX *pixs, l_int32 minsum, l_int32 skipdist, l_int32 delta, l_int32 maxbg, l_int32 maxcomps, l_int32 remainder );
LEPT_DLL extern BOXA * pixSplitComponentIntoBoxa ( PIX *pix, BOX *box, l_int32 minsum, l_int32 skipdist, l_int32 delta, l_int32 maxbg, l_int32 maxcomps, l_int32 remainder );
LEPT_DLL extern L_BYTEA * l_byteaCreate ( size_t nbytes );
LEPT_DLL extern L_BYTEA * l_byteaInitFromMem ( l_uint8 *data, size_t size );
LEPT_DLL extern L_BYTEA * l_byteaInitFromFile ( const char *fname );
LEPT_DLL extern L_BYTEA * l_byteaInitFromStream ( FILE *fp );
LEPT_DLL extern L_BYTEA * l_byteaCopy ( L_BYTEA *bas, l_int32 copyflag );
LEPT_DLL extern void l_byteaDestroy ( L_BYTEA **pba );
LEPT_DLL extern size_t l_byteaGetSize ( L_BYTEA *ba );
LEPT_DLL extern l_uint8 * l_byteaGetData ( L_BYTEA *ba, size_t *psize );
LEPT_DLL extern l_uint8 * l_byteaCopyData ( L_BYTEA *ba, size_t *psize );
LEPT_DLL extern l_int32 l_byteaAppendData ( L_BYTEA *ba, l_uint8 *newdata, size_t newbytes );
LEPT_DLL extern l_int32 l_byteaAppendString ( L_BYTEA *ba, char *str );
LEPT_DLL extern l_int32 l_byteaExtendArrayToSize ( L_BYTEA *ba, size_t size );
LEPT_DLL extern l_int32 l_byteaJoin ( L_BYTEA *ba1, L_BYTEA **pba2 );
LEPT_DLL extern l_int32 l_byteaSplit ( L_BYTEA *ba1, size_t splitloc, L_BYTEA **pba2 );
LEPT_DLL extern l_int32 l_byteaFindEachSequence ( L_BYTEA *ba, l_uint8 *sequence, l_int32 seqlen, NUMA **pna );
LEPT_DLL extern l_int32 l_byteaWrite ( const char *fname, L_BYTEA *ba, size_t startloc, size_t endloc );
LEPT_DLL extern l_int32 l_byteaWriteStream ( FILE *fp, L_BYTEA *ba, size_t startloc, size_t endloc );
LEPT_DLL extern CCBORDA * ccbaCreate ( PIX *pixs, l_int32 n );
LEPT_DLL extern void ccbaDestroy ( CCBORDA **pccba );
LEPT_DLL extern CCBORD * ccbCreate ( PIX *pixs );
LEPT_DLL extern void ccbDestroy ( CCBORD **pccb );
LEPT_DLL extern l_int32 ccbaAddCcb ( CCBORDA *ccba, CCBORD *ccb );
LEPT_DLL extern l_int32 ccbaExtendArray ( CCBORDA *ccba );
LEPT_DLL extern l_int32 ccbaGetCount ( CCBORDA *ccba );
LEPT_DLL extern CCBORD * ccbaGetCcb ( CCBORDA *ccba, l_int32 index );
LEPT_DLL extern CCBORDA * pixGetAllCCBorders ( PIX *pixs );
LEPT_DLL extern CCBORD * pixGetCCBorders ( PIX *pixs, BOX *box );
LEPT_DLL extern PTAA * pixGetOuterBordersPtaa ( PIX *pixs );
LEPT_DLL extern PTA * pixGetOuterBorderPta ( PIX *pixs, BOX *box );
LEPT_DLL extern l_int32 pixGetOuterBorder ( CCBORD *ccb, PIX *pixs, BOX *box );
LEPT_DLL extern l_int32 pixGetHoleBorder ( CCBORD *ccb, PIX *pixs, BOX *box, l_int32 xs, l_int32 ys );
LEPT_DLL extern l_int32 findNextBorderPixel ( l_int32 w, l_int32 h, l_uint32 *data, l_int32 wpl, l_int32 px, l_int32 py, l_int32 *pqpos, l_int32 *pnpx, l_int32 *pnpy );
LEPT_DLL extern void locateOutsideSeedPixel ( l_int32 fpx, l_int32 fpy, l_int32 spx, l_int32 spy, l_int32 *pxs, l_int32 *pys );
LEPT_DLL extern l_int32 ccbaGenerateGlobalLocs ( CCBORDA *ccba );
LEPT_DLL extern l_int32 ccbaGenerateStepChains ( CCBORDA *ccba );
LEPT_DLL extern l_int32 ccbaStepChainsToPixCoords ( CCBORDA *ccba, l_int32 coordtype );
LEPT_DLL extern l_int32 ccbaGenerateSPGlobalLocs ( CCBORDA *ccba, l_int32 ptsflag );
LEPT_DLL extern l_int32 ccbaGenerateSinglePath ( CCBORDA *ccba );
LEPT_DLL extern PTA * getCutPathForHole ( PIX *pix, PTA *pta, BOX *boxinner, l_int32 *pdir, l_int32 *plen );
LEPT_DLL extern PIX * ccbaDisplayBorder ( CCBORDA *ccba );
LEPT_DLL extern PIX * ccbaDisplaySPBorder ( CCBORDA *ccba );
LEPT_DLL extern PIX * ccbaDisplayImage1 ( CCBORDA *ccba );
LEPT_DLL extern PIX * ccbaDisplayImage2 ( CCBORDA *ccba );
LEPT_DLL extern l_int32 ccbaWrite ( const char *filename, CCBORDA *ccba );
LEPT_DLL extern l_int32 ccbaWriteStream ( FILE *fp, CCBORDA *ccba );
LEPT_DLL extern CCBORDA * ccbaRead ( const char *filename );
LEPT_DLL extern CCBORDA * ccbaReadStream ( FILE *fp );
LEPT_DLL extern l_int32 ccbaWriteSVG ( const char *filename, CCBORDA *ccba );
LEPT_DLL extern char * ccbaWriteSVGString ( const char *filename, CCBORDA *ccba );
LEPT_DLL extern PIX * pixThin ( PIX *pixs, l_int32 type, l_int32 connectivity, l_int32 maxiters );
LEPT_DLL extern PIX * pixThinGeneral ( PIX *pixs, l_int32 type, SELA *sela, l_int32 maxiters );
LEPT_DLL extern PIX * pixThinExamples ( PIX *pixs, l_int32 type, l_int32 index, l_int32 maxiters, const char *selfile );
LEPT_DLL extern l_int32 jbCorrelation ( const char *dirin, l_float32 thresh, l_float32 weight, l_int32 components, const char *rootname, l_int32 firstpage, l_int32 npages, l_int32 renderflag );
LEPT_DLL extern l_int32 jbRankHaus ( const char *dirin, l_int32 size, l_float32 rank, l_int32 components, const char *rootname, l_int32 firstpage, l_int32 npages, l_int32 renderflag );
LEPT_DLL extern JBCLASSER * jbWordsInTextlines ( const char *dirin, l_int32 reduction, l_int32 maxwidth, l_int32 maxheight, l_float32 thresh, l_float32 weight, NUMA **pnatl, l_int32 firstpage, l_int32 npages );
LEPT_DLL extern l_int32 pixGetWordsInTextlines ( PIX *pixs, l_int32 reduction, l_int32 minwidth, l_int32 minheight, l_int32 maxwidth, l_int32 maxheight, BOXA **pboxad, PIXA **ppixad, NUMA **pnai );
LEPT_DLL extern l_int32 pixGetWordBoxesInTextlines ( PIX *pixs, l_int32 reduction, l_int32 minwidth, l_int32 minheight, l_int32 maxwidth, l_int32 maxheight, BOXA **pboxad, NUMA **pnai );
LEPT_DLL extern NUMAA * boxaExtractSortedPattern ( BOXA *boxa, NUMA *na );
LEPT_DLL extern l_int32 numaaCompareImagesByBoxes ( NUMAA *naa1, NUMAA *naa2, l_int32 nperline, l_int32 nreq, l_int32 maxshiftx, l_int32 maxshifty, l_int32 delx, l_int32 dely, l_int32 *psame, l_int32 debugflag );
LEPT_DLL extern l_int32 pixColorContent ( PIX *pixs, l_int32 rwhite, l_int32 gwhite, l_int32 bwhite, l_int32 mingray, PIX **ppixr, PIX **ppixg, PIX **ppixb );
LEPT_DLL extern PIX * pixColorMagnitude ( PIX *pixs, l_int32 rwhite, l_int32 gwhite, l_int32 bwhite, l_int32 type );
LEPT_DLL extern PIX * pixMaskOverColorPixels ( PIX *pixs, l_int32 threshdiff, l_int32 mindist );
LEPT_DLL extern l_int32 pixColorFraction ( PIX *pixs, l_int32 darkthresh, l_int32 lightthresh, l_int32 diffthresh, l_int32 factor, l_float32 *ppixfract, l_float32 *pcolorfract );
LEPT_DLL extern l_int32 pixNumSignificantGrayColors ( PIX *pixs, l_int32 darkthresh, l_int32 lightthresh, l_float32 minfract, l_int32 factor, l_int32 *pncolors );
LEPT_DLL extern l_int32 pixColorsForQuantization ( PIX *pixs, l_int32 thresh, l_int32 *pncolors, l_int32 *piscolor, l_int32 debug );
LEPT_DLL extern l_int32 pixNumColors ( PIX *pixs, l_int32 factor, l_int32 *pncolors );
LEPT_DLL extern PIXCMAP * pixcmapCreate ( l_int32 depth );
LEPT_DLL extern PIXCMAP * pixcmapCreateRandom ( l_int32 depth, l_int32 hasblack, l_int32 haswhite );
LEPT_DLL extern PIXCMAP * pixcmapCreateLinear ( l_int32 d, l_int32 nlevels );
LEPT_DLL extern PIXCMAP * pixcmapCopy ( PIXCMAP *cmaps );
LEPT_DLL extern void pixcmapDestroy ( PIXCMAP **pcmap );
LEPT_DLL extern l_int32 pixcmapAddColor ( PIXCMAP *cmap, l_int32 rval, l_int32 gval, l_int32 bval );
LEPT_DLL extern l_int32 pixcmapAddNewColor ( PIXCMAP *cmap, l_int32 rval, l_int32 gval, l_int32 bval, l_int32 *pindex );
LEPT_DLL extern l_int32 pixcmapAddNearestColor ( PIXCMAP *cmap, l_int32 rval, l_int32 gval, l_int32 bval, l_int32 *pindex );
LEPT_DLL extern l_int32 pixcmapUsableColor ( PIXCMAP *cmap, l_int32 rval, l_int32 gval, l_int32 bval, l_int32 *pusable );
LEPT_DLL extern l_int32 pixcmapAddBlackOrWhite ( PIXCMAP *cmap, l_int32 color, l_int32 *pindex );
LEPT_DLL extern l_int32 pixcmapSetBlackAndWhite ( PIXCMAP *cmap, l_int32 setblack, l_int32 setwhite );
LEPT_DLL extern l_int32 pixcmapGetCount ( PIXCMAP *cmap );
LEPT_DLL extern l_int32 pixcmapGetFreeCount ( PIXCMAP *cmap );
LEPT_DLL extern l_int32 pixcmapGetDepth ( PIXCMAP *cmap );
LEPT_DLL extern l_int32 pixcmapGetMinDepth ( PIXCMAP *cmap, l_int32 *pmindepth );
LEPT_DLL extern l_int32 pixcmapClear ( PIXCMAP *cmap );
LEPT_DLL extern l_int32 pixcmapGetColor ( PIXCMAP *cmap, l_int32 index, l_int32 *prval, l_int32 *pgval, l_int32 *pbval );
LEPT_DLL extern l_int32 pixcmapGetColor32 ( PIXCMAP *cmap, l_int32 index, l_uint32 *pval32 );
LEPT_DLL extern l_int32 pixcmapResetColor ( PIXCMAP *cmap, l_int32 index, l_int32 rval, l_int32 gval, l_int32 bval );
LEPT_DLL extern l_int32 pixcmapGetIndex ( PIXCMAP *cmap, l_int32 rval, l_int32 gval, l_int32 bval, l_int32 *pindex );
LEPT_DLL extern l_int32 pixcmapHasColor ( PIXCMAP *cmap, l_int32 *pcolor );
LEPT_DLL extern l_int32 pixcmapCountGrayColors ( PIXCMAP *cmap, l_int32 *pngray );
LEPT_DLL extern l_int32 pixcmapGetRankIntensity ( PIXCMAP *cmap, l_float32 rankval, l_int32 *pindex );
LEPT_DLL extern l_int32 pixcmapGetNearestIndex ( PIXCMAP *cmap, l_int32 rval, l_int32 gval, l_int32 bval, l_int32 *pindex );
LEPT_DLL extern l_int32 pixcmapGetNearestGrayIndex ( PIXCMAP *cmap, l_int32 val, l_int32 *pindex );
LEPT_DLL extern l_int32 pixcmapGetComponentRange ( PIXCMAP *cmap, l_int32 color, l_int32 *pminval, l_int32 *pmaxval );
LEPT_DLL extern l_int32 pixcmapGetExtremeValue ( PIXCMAP *cmap, l_int32 type, l_int32 *prval, l_int32 *pgval, l_int32 *pbval );
LEPT_DLL extern PIXCMAP * pixcmapGrayToColor ( l_uint32 color );
LEPT_DLL extern PIXCMAP * pixcmapColorToGray ( PIXCMAP *cmaps, l_float32 rwt, l_float32 gwt, l_float32 bwt );
LEPT_DLL extern PIXCMAP * pixcmapReadStream ( FILE *fp );
LEPT_DLL extern l_int32 pixcmapWriteStream ( FILE *fp, PIXCMAP *cmap );
LEPT_DLL extern l_int32 pixcmapToArrays ( PIXCMAP *cmap, l_int32 **prmap, l_int32 **pgmap, l_int32 **pbmap );
LEPT_DLL extern l_int32 pixcmapToRGBTable ( PIXCMAP *cmap, l_uint32 **ptab, l_int32 *pncolors );
LEPT_DLL extern l_int32 pixcmapSerializeToMemory ( PIXCMAP *cmap, l_int32 cpc, l_int32 *pncolors, l_uint8 **pdata, l_int32 *pnbytes );
LEPT_DLL extern PIXCMAP * pixcmapDeserializeFromMemory ( l_uint8 *data, l_int32 ncolors, l_int32 nbytes );
LEPT_DLL extern char * pixcmapConvertToHex ( l_uint8 *data, l_int32 nbytes, l_int32 ncolors );
LEPT_DLL extern l_int32 pixcmapGammaTRC ( PIXCMAP *cmap, l_float32 gamma, l_int32 minval, l_int32 maxval );
LEPT_DLL extern l_int32 pixcmapContrastTRC ( PIXCMAP *cmap, l_float32 factor );
LEPT_DLL extern l_int32 pixcmapShiftIntensity ( PIXCMAP *cmap, l_float32 fraction );
LEPT_DLL extern PIX * pixColorMorph ( PIX *pixs, l_int32 type, l_int32 hsize, l_int32 vsize );
LEPT_DLL extern PIX * pixOctreeColorQuant ( PIX *pixs, l_int32 colors, l_int32 ditherflag );
LEPT_DLL extern PIX * pixOctreeColorQuantGeneral ( PIX *pixs, l_int32 colors, l_int32 ditherflag, l_float32 validthresh, l_float32 colorthresh );
LEPT_DLL extern l_int32 makeRGBToIndexTables ( l_uint32 **prtab, l_uint32 **pgtab, l_uint32 **pbtab, l_int32 cqlevels );
LEPT_DLL extern void getOctcubeIndexFromRGB ( l_int32 rval, l_int32 gval, l_int32 bval, l_uint32 *rtab, l_uint32 *gtab, l_uint32 *btab, l_uint32 *pindex );
LEPT_DLL extern PIX * pixOctreeQuantByPopulation ( PIX *pixs, l_int32 level, l_int32 ditherflag );
LEPT_DLL extern PIX * pixOctreeQuantNumColors ( PIX *pixs, l_int32 maxcolors, l_int32 subsample );
LEPT_DLL extern PIX * pixOctcubeQuantMixedWithGray ( PIX *pixs, l_int32 depth, l_int32 graylevels, l_int32 delta );
LEPT_DLL extern PIX * pixFixedOctcubeQuant256 ( PIX *pixs, l_int32 ditherflag );
LEPT_DLL extern PIX * pixFewColorsOctcubeQuant1 ( PIX *pixs, l_int32 level );
LEPT_DLL extern PIX * pixFewColorsOctcubeQuant2 ( PIX *pixs, l_int32 level, NUMA *na, l_int32 ncolors, l_int32 *pnerrors );
LEPT_DLL extern PIX * pixFewColorsOctcubeQuantMixed ( PIX *pixs, l_int32 level, l_int32 darkthresh, l_int32 lightthresh, l_int32 diffthresh, l_float32 minfract, l_int32 maxspan );
LEPT_DLL extern PIX * pixFixedOctcubeQuantGenRGB ( PIX *pixs, l_int32 level );
LEPT_DLL extern PIX * pixQuantFromCmap ( PIX *pixs, PIXCMAP *cmap, l_int32 mindepth, l_int32 level, l_int32 metric );
LEPT_DLL extern PIX * pixOctcubeQuantFromCmap ( PIX *pixs, PIXCMAP *cmap, l_int32 mindepth, l_int32 level, l_int32 metric );
LEPT_DLL extern PIX * pixOctcubeQuantFromCmapLUT ( PIX *pixs, PIXCMAP *cmap, l_int32 mindepth, l_int32 *cmaptab, l_uint32 *rtab, l_uint32 *gtab, l_uint32 *btab );
LEPT_DLL extern NUMA * pixOctcubeHistogram ( PIX *pixs, l_int32 level, l_int32 *pncolors );
LEPT_DLL extern l_int32 * pixcmapToOctcubeLUT ( PIXCMAP *cmap, l_int32 level, l_int32 metric );
LEPT_DLL extern l_int32 pixRemoveUnusedColors ( PIX *pixs );
LEPT_DLL extern l_int32 pixNumberOccupiedOctcubes ( PIX *pix, l_int32 level, l_int32 mincount, l_float32 minfract, l_int32 *pncolors );
LEPT_DLL extern PIX * pixMedianCutQuant ( PIX *pixs, l_int32 ditherflag );
LEPT_DLL extern PIX * pixMedianCutQuantGeneral ( PIX *pixs, l_int32 ditherflag, l_int32 outdepth, l_int32 maxcolors, l_int32 sigbits, l_int32 maxsub, l_int32 checkbw );
LEPT_DLL extern PIX * pixMedianCutQuantMixed ( PIX *pixs, l_int32 ncolor, l_int32 ngray, l_int32 darkthresh, l_int32 lightthresh, l_int32 diffthresh );
LEPT_DLL extern PIX * pixFewColorsMedianCutQuantMixed ( PIX *pixs, l_int32 ncolor, l_int32 ngray, l_int32 maxncolors, l_int32 darkthresh, l_int32 lightthresh, l_int32 diffthresh );
LEPT_DLL extern l_int32 * pixMedianCutHisto ( PIX *pixs, l_int32 sigbits, l_int32 subsample );
LEPT_DLL extern PIX * pixColorSegment ( PIX *pixs, l_int32 maxdist, l_int32 maxcolors, l_int32 selsize, l_int32 finalcolors );
LEPT_DLL extern PIX * pixColorSegmentCluster ( PIX *pixs, l_int32 maxdist, l_int32 maxcolors );
LEPT_DLL extern l_int32 pixAssignToNearestColor ( PIX *pixd, PIX *pixs, PIX *pixm, l_int32 level, l_int32 *countarray );
LEPT_DLL extern l_int32 pixColorSegmentClean ( PIX *pixs, l_int32 selsize, l_int32 *countarray );
LEPT_DLL extern l_int32 pixColorSegmentRemoveColors ( PIX *pixd, PIX *pixs, l_int32 finalcolors );
*/
PIX *pixConvertRGBToHSV(PIX *pixd, PIX *pixs);
PIX *pixConvertHSVToRGB(PIX *pixd, PIX *pixs);
l_int32 convertRGBToHSV(l_int32 rval, l_int32 gval, l_int32 bval, l_int32 *phval, l_int32 *psval, l_int32 *pvval);
l_int32 convertHSVToRGB(l_int32 hval, l_int32 sval, l_int32 vval, l_int32 *prval, l_int32 *pgval, l_int32 *pbval);
l_int32 pixcmapConvertRGBToHSV(PIXCMAP *cmap);
l_int32 pixcmapConvertHSVToRGB(PIXCMAP *cmap);
PIX *pixConvertRGBToHue(PIX *pixs);
PIX *pixConvertRGBToSaturation(PIX *pixs);
PIX *pixConvertRGBToValue(PIX *pixs);
PIX * pixMakeRangeMaskHS ( PIX *pixs, l_int32 huecenter, l_int32 huehw, l_int32 satcenter, l_int32 sathw, l_int32 regionflag );
PIX * pixMakeRangeMaskHV ( PIX *pixs, l_int32 huecenter, l_int32 huehw, l_int32 valcenter, l_int32 valhw, l_int32 regionflag );
PIX * pixMakeRangeMaskSV ( PIX *pixs, l_int32 satcenter, l_int32 sathw, l_int32 valcenter, l_int32 valhw, l_int32 regionflag );
PIX * pixMakeHistoHS ( PIX *pixs, l_int32 factor, NUMA **pnahue, NUMA **pnasat );
PIX * pixMakeHistoHV ( PIX *pixs, l_int32 factor, NUMA **pnahue, NUMA **pnaval );
PIX * pixMakeHistoSV ( PIX *pixs, l_int32 factor, NUMA **pnasat, NUMA **pnaval );
l_int32 pixFindHistoPeaksHSV ( PIX *pixs, l_int32 type, l_int32 width, l_int32 height, l_int32 npeaks, l_float32 erasefactor, PTA **ppta, NUMA **pnatot, PIXA **ppixa );
/*
LEPT_DLL extern PIX * displayHSVColorRange ( l_int32 hval, l_int32 sval, l_int32 vval, l_int32 huehw, l_int32 sathw, l_int32 nsamp, l_int32 factor );
LEPT_DLL extern PIX * pixConvertRGBToYUV ( PIX *pixd, PIX *pixs );
LEPT_DLL extern PIX * pixConvertYUVToRGB ( PIX *pixd, PIX *pixs );
LEPT_DLL extern l_int32 convertRGBToYUV ( l_int32 rval, l_int32 gval, l_int32 bval, l_int32 *pyval, l_int32 *puval, l_int32 *pvval );
LEPT_DLL extern l_int32 convertYUVToRGB ( l_int32 yval, l_int32 uval, l_int32 vval, l_int32 *prval, l_int32 *pgval, l_int32 *pbval );
LEPT_DLL extern l_int32 pixcmapConvertRGBToYUV ( PIXCMAP *cmap );
LEPT_DLL extern l_int32 pixcmapConvertYUVToRGB ( PIXCMAP *cmap );
LEPT_DLL extern l_int32 pixEqual ( PIX *pix1, PIX *pix2, l_int32 *psame );
LEPT_DLL extern l_int32 pixEqualWithCmap ( PIX *pix1, PIX *pix2, l_int32 *psame );
LEPT_DLL extern l_int32 pixUsesCmapColor ( PIX *pixs, l_int32 *pcolor );
LEPT_DLL extern l_int32 pixCorrelationBinary ( PIX *pix1, PIX *pix2, l_float32 *pval );
LEPT_DLL extern PIX * pixDisplayDiffBinary ( PIX *pix1, PIX *pix2 );
LEPT_DLL extern l_int32 pixCompareBinary ( PIX *pix1, PIX *pix2, l_int32 comptype, l_float32 *pfract, PIX **ppixdiff );
LEPT_DLL extern l_int32 pixCompareGrayOrRGB ( PIX *pix1, PIX *pix2, l_int32 comptype, l_int32 plottype, l_int32 *psame, l_float32 *pdiff, l_float32 *prmsdiff, PIX **ppixdiff );
LEPT_DLL extern l_int32 pixCompareGray ( PIX *pix1, PIX *pix2, l_int32 comptype, l_int32 plottype, l_int32 *psame, l_float32 *pdiff, l_float32 *prmsdiff, PIX **ppixdiff );
LEPT_DLL extern l_int32 pixCompareRGB ( PIX *pix1, PIX *pix2, l_int32 comptype, l_int32 plottype, l_int32 *psame, l_float32 *pdiff, l_float32 *prmsdiff, PIX **ppixdiff );
LEPT_DLL extern l_int32 pixCompareTiled ( PIX *pix1, PIX *pix2, l_int32 sx, l_int32 sy, l_int32 type, PIX **ppixdiff );
LEPT_DLL extern NUMA * pixCompareRankDifference ( PIX *pix1, PIX *pix2, l_int32 factor );
*/
l_int32 pixTestForSimilarity ( PIX *pix1, PIX *pix2, l_int32 factor, l_int32 mindiff, l_float32 maxfract, l_float32 maxave, l_int32 *psimilar, l_int32 printstats );
l_int32 pixGetDifferenceStats ( PIX *pix1, PIX *pix2, l_int32 factor, l_int32 mindiff, l_float32 *pfractdiff, l_float32 *pavediff, l_int32 printstats );
/*
LEPT_DLL extern NUMA * pixGetDifferenceHistogram ( PIX *pix1, PIX *pix2, l_int32 factor );
LEPT_DLL extern l_int32 pixGetPSNR ( PIX *pix1, PIX *pix2, l_int32 factor, l_float32 *ppsnr );
LEPT_DLL extern BOXA * pixConnComp ( PIX *pixs, PIXA **ppixa, l_int32 connectivity );
LEPT_DLL extern BOXA * pixConnCompPixa ( PIX *pixs, PIXA **ppixa, l_int32 connectivity );
LEPT_DLL extern BOXA * pixConnCompBB ( PIX *pixs, l_int32 connectivity );
LEPT_DLL extern l_int32 pixCountConnComp ( PIX *pixs, l_int32 connectivity, l_int32 *pcount );
LEPT_DLL extern l_int32 nextOnPixelInRaster ( PIX *pixs, l_int32 xstart, l_int32 ystart, l_int32 *px, l_int32 *py );
LEPT_DLL extern l_int32 nextOnPixelInRasterLow ( l_uint32 *data, l_int32 w, l_int32 h, l_int32 wpl, l_int32 xstart, l_int32 ystart, l_int32 *px, l_int32 *py );
LEPT_DLL extern BOX * pixSeedfillBB ( PIX *pixs, L_STACK *lstack, l_int32 x, l_int32 y, l_int32 connectivity );
LEPT_DLL extern BOX * pixSeedfill4BB ( PIX *pixs, L_STACK *lstack, l_int32 x, l_int32 y );
LEPT_DLL extern BOX * pixSeedfill8BB ( PIX *pixs, L_STACK *lstack, l_int32 x, l_int32 y );
LEPT_DLL extern l_int32 pixSeedfill ( PIX *pixs, L_STACK *lstack, l_int32 x, l_int32 y, l_int32 connectivity );
LEPT_DLL extern l_int32 pixSeedfill4 ( PIX *pixs, L_STACK *lstack, l_int32 x, l_int32 y );
LEPT_DLL extern l_int32 pixSeedfill8 ( PIX *pixs, L_STACK *lstack, l_int32 x, l_int32 y );
LEPT_DLL extern l_int32 convertFilesTo1bpp ( const char *dirin, const char *substr, l_int32 upscaling, l_int32 thresh, l_int32 firstpage, l_int32 npages, const char *dirout, l_int32 outformat );
LEPT_DLL extern PIX * pixBlockconv ( PIX *pix, l_int32 wc, l_int32 hc );
LEPT_DLL extern PIX * pixBlockconvGray ( PIX *pixs, PIX *pixacc, l_int32 wc, l_int32 hc );
LEPT_DLL extern PIX * pixBlockconvAccum ( PIX *pixs );
LEPT_DLL extern PIX * pixBlockconvGrayUnnormalized ( PIX *pixs, l_int32 wc, l_int32 hc );
LEPT_DLL extern PIX * pixBlockconvTiled ( PIX *pix, l_int32 wc, l_int32 hc, l_int32 nx, l_int32 ny );
LEPT_DLL extern PIX * pixBlockconvGrayTile ( PIX *pixs, PIX *pixacc, l_int32 wc, l_int32 hc );
LEPT_DLL extern l_int32 pixWindowedStats ( PIX *pixs, l_int32 wc, l_int32 hc, l_int32 hasborder, PIX **ppixm, PIX **ppixms, FPIX **pfpixv, FPIX **pfpixrv );
LEPT_DLL extern PIX * pixWindowedMean ( PIX *pixs, l_int32 wc, l_int32 hc, l_int32 hasborder, l_int32 normflag );
LEPT_DLL extern PIX * pixWindowedMeanSquare ( PIX *pixs, l_int32 wc, l_int32 hc, l_int32 hasborder );
LEPT_DLL extern l_int32 pixWindowedVariance ( PIX *pixm, PIX *pixms, FPIX **pfpixv, FPIX **pfpixrv );
LEPT_DLL extern DPIX * pixMeanSquareAccum ( PIX *pixs );
LEPT_DLL extern PIX * pixBlockrank ( PIX *pixs, PIX *pixacc, l_int32 wc, l_int32 hc, l_float32 rank );
LEPT_DLL extern PIX * pixBlocksum ( PIX *pixs, PIX *pixacc, l_int32 wc, l_int32 hc );
LEPT_DLL extern PIX * pixCensusTransform ( PIX *pixs, l_int32 halfsize, PIX *pixacc );
LEPT_DLL extern PIX * pixConvolve ( PIX *pixs, L_KERNEL *kel, l_int32 outdepth, l_int32 normflag );
LEPT_DLL extern PIX * pixConvolveSep ( PIX *pixs, L_KERNEL *kelx, L_KERNEL *kely, l_int32 outdepth, l_int32 normflag );
LEPT_DLL extern PIX * pixConvolveRGB ( PIX *pixs, L_KERNEL *kel );
LEPT_DLL extern PIX * pixConvolveRGBSep ( PIX *pixs, L_KERNEL *kelx, L_KERNEL *kely );
LEPT_DLL extern FPIX * fpixConvolve ( FPIX *fpixs, L_KERNEL *kel, l_int32 normflag );
LEPT_DLL extern FPIX * fpixConvolveSep ( FPIX *fpixs, L_KERNEL *kelx, L_KERNEL *kely, l_int32 normflag );
LEPT_DLL extern void l_setConvolveSampling ( l_int32 xfact, l_int32 yfact );
LEPT_DLL extern void blockconvLow ( l_uint32 *data, l_int32 w, l_int32 h, l_int32 wpl, l_uint32 *dataa, l_int32 wpla, l_int32 wc, l_int32 hc );
LEPT_DLL extern void blockconvAccumLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 d, l_int32 wpls );
LEPT_DLL extern void blocksumLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpl, l_uint32 *dataa, l_int32 wpla, l_int32 wc, l_int32 hc );
LEPT_DLL extern l_float32 pixCorrelationScore ( PIX *pix1, PIX *pix2, l_int32 area1, l_int32 area2, l_float32 delx, l_float32 dely, l_int32 maxdiffw, l_int32 maxdiffh, l_int32 *tab );
LEPT_DLL extern l_int32 pixCorrelationScoreThresholded ( PIX *pix1, PIX *pix2, l_int32 area1, l_int32 area2, l_float32 delx, l_float32 dely, l_int32 maxdiffw, l_int32 maxdiffh, l_int32 *tab, l_int32 *downcount, l_float32 score_threshold );
LEPT_DLL extern l_float32 pixCorrelationScoreSimple ( PIX *pix1, PIX *pix2, l_int32 area1, l_int32 area2, l_float32 delx, l_float32 dely, l_int32 maxdiffw, l_int32 maxdiffh, l_int32 *tab );
LEPT_DLL extern L_DEWARP * dewarpCreate ( PIX *pixs, l_int32 pageno, l_int32 sampling, l_int32 minlines, l_int32 applyhoriz );
LEPT_DLL extern void dewarpDestroy ( L_DEWARP **pdew );
LEPT_DLL extern l_int32 dewarpBuildModel ( L_DEWARP *dew, l_int32 debugflag );
LEPT_DLL extern PTAA * pixGetTextlineCenters ( PIX *pixs, l_int32 debugflag );
LEPT_DLL extern PTA * pixGetMeanVerticals ( PIX *pixs, l_int32 x, l_int32 y );
LEPT_DLL extern PTAA * ptaaRemoveShortLines ( PIX *pixs, PTAA *ptaas, l_float32 fract, l_int32 debugflag );
LEPT_DLL extern FPIX * fpixBuildHorizontalDisparity ( FPIX *fpixv, l_float32 factor, l_int32 *pextraw );
LEPT_DLL extern FPIX * fpixSampledDisparity ( FPIX *fpixs, l_int32 sampling );
LEPT_DLL extern l_int32 dewarpApplyDisparity ( L_DEWARP *dew, PIX *pixs, l_int32 debugflag );
LEPT_DLL extern PIX * pixApplyVerticalDisparity ( PIX *pixs, FPIX *fpix );
LEPT_DLL extern PIX * pixApplyHorizontalDisparity ( PIX *pixs, FPIX *fpix, l_int32 extraw );
LEPT_DLL extern l_int32 dewarpMinimize ( L_DEWARP *dew );
LEPT_DLL extern l_int32 dewarpPopulateFullRes ( L_DEWARP *dew );
LEPT_DLL extern L_DEWARP * dewarpRead ( const char *filename );
LEPT_DLL extern L_DEWARP * dewarpReadStream ( FILE *fp );
LEPT_DLL extern l_int32 dewarpWrite ( const char *filename, L_DEWARP *dew );
LEPT_DLL extern l_int32 dewarpWriteStream ( FILE *fp, L_DEWARP *dew );
LEPT_DLL extern PIX * pixMorphDwa_2 ( PIX *pixd, PIX *pixs, l_int32 operation, char *selname );
LEPT_DLL extern PIX * pixFMorphopGen_2 ( PIX *pixd, PIX *pixs, l_int32 operation, char *selname );
LEPT_DLL extern l_int32 fmorphopgen_low_2 ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_int32 index );
LEPT_DLL extern PIX * pixSobelEdgeFilter ( PIX *pixs, l_int32 orientflag );
LEPT_DLL extern PIX * pixTwoSidedEdgeFilter ( PIX *pixs, l_int32 orientflag );
LEPT_DLL extern l_int32 pixMeasureEdgeSmoothness ( PIX *pixs, l_int32 side, l_int32 minjump, l_int32 minreversal, l_float32 *pjpl, l_float32 *pjspl, l_float32 *prpl, const char *debugfile );
LEPT_DLL extern NUMA * pixGetEdgeProfile ( PIX *pixs, l_int32 side, const char *debugfile );
LEPT_DLL extern l_int32 pixGetLastOffPixelInRun ( PIX *pixs, l_int32 x, l_int32 y, l_int32 direction, l_int32 *ploc );
LEPT_DLL extern l_int32 pixGetLastOnPixelInRun ( PIX *pixs, l_int32 x, l_int32 y, l_int32 direction, l_int32 *ploc );
LEPT_DLL extern PIX * pixGammaTRC ( PIX *pixd, PIX *pixs, l_float32 gamma, l_int32 minval, l_int32 maxval );
LEPT_DLL extern PIX * pixGammaTRCMasked ( PIX *pixd, PIX *pixs, PIX *pixm, l_float32 gamma, l_int32 minval, l_int32 maxval );
LEPT_DLL extern PIX * pixGammaTRCWithAlpha ( PIX *pixd, PIX *pixs, l_float32 gamma, l_int32 minval, l_int32 maxval );
LEPT_DLL extern NUMA * numaGammaTRC ( l_float32 gamma, l_int32 minval, l_int32 maxval );
LEPT_DLL extern PIX * pixContrastTRC ( PIX *pixd, PIX *pixs, l_float32 factor );
LEPT_DLL extern PIX * pixContrastTRCMasked ( PIX *pixd, PIX *pixs, PIX *pixm, l_float32 factor );
LEPT_DLL extern NUMA * numaContrastTRC ( l_float32 factor );
LEPT_DLL extern PIX * pixEqualizeTRC ( PIX *pixd, PIX *pixs, l_float32 fract, l_int32 factor );
LEPT_DLL extern NUMA * numaEqualizeTRC ( PIX *pix, l_float32 fract, l_int32 factor );
LEPT_DLL extern l_int32 pixTRCMap ( PIX *pixs, PIX *pixm, NUMA *na );
LEPT_DLL extern PIX * pixUnsharpMasking ( PIX *pixs, l_int32 halfwidth, l_float32 fract );
LEPT_DLL extern PIX * pixUnsharpMaskingGray ( PIX *pixs, l_int32 halfwidth, l_float32 fract );
LEPT_DLL extern PIX * pixUnsharpMaskingFast ( PIX *pixs, l_int32 halfwidth, l_float32 fract, l_int32 direction );
LEPT_DLL extern PIX * pixUnsharpMaskingGrayFast ( PIX *pixs, l_int32 halfwidth, l_float32 fract, l_int32 direction );
LEPT_DLL extern PIX * pixUnsharpMaskingGray1D ( PIX *pixs, l_int32 halfwidth, l_float32 fract, l_int32 direction );
LEPT_DLL extern PIX * pixUnsharpMaskingGray2D ( PIX *pixs, l_int32 halfwidth, l_float32 fract );
LEPT_DLL extern PIX * pixModifyHue ( PIX *pixd, PIX *pixs, l_float32 fract );
LEPT_DLL extern PIX * pixModifySaturation ( PIX *pixd, PIX *pixs, l_float32 fract );
LEPT_DLL extern l_int32 pixMeasureSaturation ( PIX *pixs, l_int32 factor, l_float32 *psat );
LEPT_DLL extern PIX * pixMultConstantColor ( PIX *pixs, l_float32 rfact, l_float32 gfact, l_float32 bfact );
LEPT_DLL extern PIX * pixMultMatrixColor ( PIX *pixs, L_KERNEL *kel );
LEPT_DLL extern PIX * pixHalfEdgeByBandpass ( PIX *pixs, l_int32 sm1h, l_int32 sm1v, l_int32 sm2h, l_int32 sm2v );
LEPT_DLL extern l_int32 fhmtautogen ( SELA *sela, l_int32 fileindex, const char *filename );
LEPT_DLL extern l_int32 fhmtautogen1 ( SELA *sela, l_int32 fileindex, const char *filename );
LEPT_DLL extern l_int32 fhmtautogen2 ( SELA *sela, l_int32 fileindex, const char *filename );
LEPT_DLL extern PIX * pixHMTDwa_1 ( PIX *pixd, PIX *pixs, char *selname );
LEPT_DLL extern PIX * pixFHMTGen_1 ( PIX *pixd, PIX *pixs, char *selname );
LEPT_DLL extern l_int32 fhmtgen_low_1 ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_int32 index );
LEPT_DLL extern l_int32 pixItalicWords ( PIX *pixs, BOXA *boxaw, PIX *pixw, BOXA **pboxa, l_int32 debugflag );
LEPT_DLL extern l_int32 pixOrientDetect ( PIX *pixs, l_float32 *pupconf, l_float32 *pleftconf, l_int32 mincount, l_int32 debug );
LEPT_DLL extern l_int32 makeOrientDecision ( l_float32 upconf, l_float32 leftconf, l_float32 minupconf, l_float32 minratio, l_int32 *porient, l_int32 debug );
LEPT_DLL extern l_int32 pixUpDownDetect ( PIX *pixs, l_float32 *pconf, l_int32 mincount, l_int32 debug );
LEPT_DLL extern l_int32 pixUpDownDetectGeneral ( PIX *pixs, l_float32 *pconf, l_int32 mincount, l_int32 npixels, l_int32 debug );
LEPT_DLL extern l_int32 pixOrientDetectDwa ( PIX *pixs, l_float32 *pupconf, l_float32 *pleftconf, l_int32 mincount, l_int32 debug );
LEPT_DLL extern l_int32 pixUpDownDetectDwa ( PIX *pixs, l_float32 *pconf, l_int32 mincount, l_int32 debug );
LEPT_DLL extern l_int32 pixUpDownDetectGeneralDwa ( PIX *pixs, l_float32 *pconf, l_int32 mincount, l_int32 npixels, l_int32 debug );
LEPT_DLL extern l_int32 pixMirrorDetect ( PIX *pixs, l_float32 *pconf, l_int32 mincount, l_int32 debug );
LEPT_DLL extern l_int32 pixMirrorDetectDwa ( PIX *pixs, l_float32 *pconf, l_int32 mincount, l_int32 debug );
LEPT_DLL extern PIX * pixFlipFHMTGen ( PIX *pixd, PIX *pixs, char *selname );
LEPT_DLL extern l_int32 fmorphautogen ( SELA *sela, l_int32 fileindex, const char *filename );
LEPT_DLL extern l_int32 fmorphautogen1 ( SELA *sela, l_int32 fileindex, const char *filename );
LEPT_DLL extern l_int32 fmorphautogen2 ( SELA *sela, l_int32 fileindex, const char *filename );
LEPT_DLL extern PIX * pixMorphDwa_1 ( PIX *pixd, PIX *pixs, l_int32 operation, char *selname );
LEPT_DLL extern PIX * pixFMorphopGen_1 ( PIX *pixd, PIX *pixs, l_int32 operation, char *selname );
LEPT_DLL extern l_int32 fmorphopgen_low_1 ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_int32 index );
*/
FPIX *fpixCreate(l_int32 width, l_int32 height);
FPIX *fpixCreateTemplate(FPIX *fpixs);
FPIX *fpixClone(FPIX *fpix);
FPIX *fpixCopy(FPIX *fpixd, FPIX *fpixs);
l_int32 fpixResizeImageData ( FPIX *fpixd, FPIX *fpixs );
void fpixDestroy(FPIX **pfpix);
l_int32 fpixGetDimensions(FPIX *fpix, l_int32 *pw, l_int32 *ph);
l_int32 fpixSetDimensions(FPIX *fpix, l_int32 w, l_int32 h);
l_int32 fpixGetWpl(FPIX *fpix);
l_int32 fpixSetWpl(FPIX *fpix, l_int32 wpl);
l_int32 fpixGetRefcount(FPIX *fpix );
l_int32 fpixChangeRefcount(FPIX *fpix, l_int32 delta );
l_int32 fpixGetResolution(FPIX *fpix, l_int32 *pxres, l_int32 *pyres);
l_int32 fpixSetResolution(FPIX *fpix, l_int32 xres, l_int32 yres);
l_int32 fpixCopyResolution(FPIX *fpixd, FPIX *fpixs);
l_float32 *fpixGetData(FPIX *fpix);
l_int32 fpixSetData ( FPIX *fpix, l_float32 *data );
l_int32 fpixGetPixel ( FPIX *fpix, l_int32 x, l_int32 y, l_float32 *pval );
l_int32 fpixSetPixel ( FPIX *fpix, l_int32 x, l_int32 y, l_float32 val );
/*
LEPT_DLL extern FPIXA * fpixaCreate ( l_int32 n );
LEPT_DLL extern FPIXA * fpixaCopy ( FPIXA *fpixa, l_int32 copyflag );
LEPT_DLL extern void fpixaDestroy ( FPIXA **pfpixa );
LEPT_DLL extern l_int32 fpixaAddFPix ( FPIXA *fpixa, FPIX *fpix, l_int32 copyflag );
LEPT_DLL extern l_int32 fpixaExtendArray ( FPIXA *fpixa );
LEPT_DLL extern l_int32 fpixaExtendArrayToSize ( FPIXA *fpixa, l_int32 size );
LEPT_DLL extern l_int32 fpixaGetCount ( FPIXA *fpixa );
LEPT_DLL extern l_int32 fpixaChangeRefcount ( FPIXA *fpixa, l_int32 delta );
LEPT_DLL extern FPIX * fpixaGetFPix ( FPIXA *fpixa, l_int32 index, l_int32 accesstype );
LEPT_DLL extern l_int32 fpixaGetFPixDimensions ( FPIXA *fpixa, l_int32 index, l_int32 *pw, l_int32 *ph );
LEPT_DLL extern l_int32 fpixaGetPixel ( FPIXA *fpixa, l_int32 index, l_int32 x, l_int32 y, l_float32 *pval );
LEPT_DLL extern l_int32 fpixaSetPixel ( FPIXA *fpixa, l_int32 index, l_int32 x, l_int32 y, l_float32 val );
LEPT_DLL extern DPIX * dpixCreate ( l_int32 width, l_int32 height );
LEPT_DLL extern DPIX * dpixCreateTemplate ( DPIX *dpixs );
LEPT_DLL extern DPIX * dpixClone ( DPIX *dpix );
LEPT_DLL extern DPIX * dpixCopy ( DPIX *dpixd, DPIX *dpixs );
LEPT_DLL extern l_int32 dpixResizeImageData ( DPIX *dpixd, DPIX *dpixs );
LEPT_DLL extern void dpixDestroy ( DPIX **pdpix );
LEPT_DLL extern l_int32 dpixGetDimensions ( DPIX *dpix, l_int32 *pw, l_int32 *ph );
LEPT_DLL extern l_int32 dpixSetDimensions ( DPIX *dpix, l_int32 w, l_int32 h );
LEPT_DLL extern l_int32 dpixGetWpl ( DPIX *dpix );
LEPT_DLL extern l_int32 dpixSetWpl ( DPIX *dpix, l_int32 wpl );
LEPT_DLL extern l_int32 dpixGetRefcount ( DPIX *dpix );
LEPT_DLL extern l_int32 dpixChangeRefcount ( DPIX *dpix, l_int32 delta );
LEPT_DLL extern l_int32 dpixGetResolution ( DPIX *dpix, l_int32 *pxres, l_int32 *pyres );
LEPT_DLL extern l_int32 dpixSetResolution ( DPIX *dpix, l_int32 xres, l_int32 yres );
LEPT_DLL extern l_int32 dpixCopyResolution ( DPIX *dpixd, DPIX *dpixs );
LEPT_DLL extern l_float64 * dpixGetData ( DPIX *dpix );
LEPT_DLL extern l_int32 dpixSetData ( DPIX *dpix, l_float64 *data );
LEPT_DLL extern l_int32 dpixGetPixel ( DPIX *dpix, l_int32 x, l_int32 y, l_float64 *pval );
LEPT_DLL extern l_int32 dpixSetPixel ( DPIX *dpix, l_int32 x, l_int32 y, l_float64 val );
LEPT_DLL extern FPIX * fpixRead ( const char *filename );
LEPT_DLL extern FPIX * fpixReadStream ( FILE *fp );
LEPT_DLL extern l_int32 fpixWrite ( const char *filename, FPIX *fpix );
LEPT_DLL extern l_int32 fpixWriteStream ( FILE *fp, FPIX *fpix );
LEPT_DLL extern FPIX * fpixEndianByteSwap ( FPIX *fpixd, FPIX *fpixs );
LEPT_DLL extern DPIX * dpixRead ( const char *filename );
LEPT_DLL extern DPIX * dpixReadStream ( FILE *fp );
LEPT_DLL extern l_int32 dpixWrite ( const char *filename, DPIX *dpix );
LEPT_DLL extern l_int32 dpixWriteStream ( FILE *fp, DPIX *dpix );
LEPT_DLL extern DPIX * dpixEndianByteSwap ( DPIX *dpixd, DPIX *dpixs );
LEPT_DLL extern l_int32 fpixPrintStream ( FILE *fp, FPIX *fpix, l_int32 factor );
*/
FPIX * pixConvertToFPix ( PIX *pixs, l_int32 ncomps );
PIX * fpixConvertToPix ( FPIX *fpixs, l_int32 outdepth, l_int32 negvals, l_int32 errorflag );
PIX * fpixDisplayMaxDynamicRange ( FPIX *fpixs );
DPIX * fpixConvertToDPix ( FPIX *fpix );
FPIX * dpixConvertToFPix ( DPIX *dpix );
l_int32 fpixGetMin(FPIX *fpix, l_float32 *pminval, l_int32 *pxminloc, l_int32 *pyminloc);
l_int32 fpixGetMax(FPIX *fpix, l_float32 *pmaxval, l_int32 *pxmaxloc, l_int32 *pymaxloc);
FPIX *fpixAddBorder(FPIX *fpixs, l_int32 left, l_int32 right, l_int32 top, l_int32 bot);
FPIX *fpixRemoveBorder(FPIX *fpixs, l_int32 left, l_int32 right, l_int32 top, l_int32 bot);
FPIX *fpixAddMirroredBorder(FPIX *fpixs, l_int32 left, l_int32 right, l_int32 top, l_int32 bot);
l_int32 fpixRasterop(FPIX *fpixd, l_int32 dx, l_int32 dy, l_int32 dw, l_int32 dh, FPIX *fpixs, l_int32 sx, l_int32 sy);
FPIX *fpixScaleByInteger(FPIX *fpixs, l_int32 factor);
DPIX *dpixScaleByInteger(DPIX *dpixs, l_int32 factor);
FPIX *fpixLinearCombination(FPIX *fpixd, FPIX *fpixs1, FPIX *fpixs2, l_float32 a, l_float32 b);
l_int32 fpixAddMultConstant(FPIX *fpix, l_float32 addc, l_float32 multc);
PIX *pixReadStreamGif(void *fp);
l_int32 pixWriteStreamGif(void *fp, PIX *pix);
PIX *pixReadMemGif(const l_uint8 *cdata, size_t size);
l_int32 pixWriteMemGif(l_uint8 **pdata, size_t *psize, PIX *pix);
//GPLOT *gplotCreate(const char *rootname, l_int32 outformat, const char *title, const char *xlabel, const char *ylabel);
//void gplotDestroy(GPLOT **pgplot);
//l_int32 gplotAddPlot(GPLOT *gplot, NUMA *nax, NUMA *nay, l_int32 plotstyle, const char *plottitle);
//l_int32 gplotSetScaling(GPLOT *gplot, l_int32 scaling);
//l_int32 gplotMakeOutput(GPLOT *gplot);
//l_int32 gplotGenCommandFile(GPLOT *gplot);
//l_int32 gplotGenDataFiles(GPLOT *gplot);
l_int32 gplotSimple1(NUMA *na, l_int32 outformat, const char *outroot, const char *title);
l_int32 gplotSimple2(NUMA *na1, NUMA *na2, l_int32 outformat, const char *outroot, const char *title);
l_int32 gplotSimpleN(NUMAA *naa, l_int32 outformat, const char *outroot, const char *title);
//GPLOT *gplotRead(const char *filename);
//l_int32 gplotWrite(const char *filename, GPLOT *gplot);

PTA *generatePtaLine(l_int32 x1, l_int32 y1, l_int32 x2, l_int32 y2);
PTA *generatePtaWideLine(l_int32 x1, l_int32 y1, l_int32 x2, l_int32 y2, l_int32 width);
PTA *generatePtaBox(BOX *box, l_int32 width);
PTA *generatePtaHashBox(BOX *box, l_int32 spacing, l_int32 width, l_int32 orient, l_int32 outline);
PTA *generatePtaBoxa(BOXA *boxa, l_int32 width, l_int32 removedups);
PTAA *generatePtaaBoxa(BOXA *boxa);
PTAA *generatePtaaHashBoxa(BOXA *boxa, l_int32 spacing, l_int32 width, l_int32 orient, l_int32 outline);
PTA *generatePtaPolyline(PTA *ptas, l_int32 width, l_int32 closeflag, l_int32 removedups);

/*
LEPT_DLL extern PTA *generatePtaFilledCircle(l_int32 radius);
LEPT_DLL extern PTA *generatePtaLineFromPt(l_int32 x, l_int32 y, l_float64 length, l_float64 radang);
LEPT_DLL extern l_int32 locatePtRadially(l_int32 xr, l_int32 yr, l_float64 dist, l_float64 radang, l_float64 *px, l_float64 *py);
LEPT_DLL extern l_int32 pixRenderPta(PIX *pix, PTA *pta, l_int32 op);
LEPT_DLL extern l_int32 pixRenderPtaArb(PIX *pix, PTA *pta, l_uint8 rval, l_uint8 gval, l_uint8 bval);
LEPT_DLL extern l_int32 pixRenderPtaBlend(PIX *pix, PTA *pta, l_uint8 rval, l_uint8 gval, l_uint8 bval, l_float32 fract);
LEPT_DLL extern l_int32 pixRenderLine(PIX *pix, l_int32 x1, l_int32 y1, l_int32 x2, l_int32 y2, l_int32 width, l_int32 op);
LEPT_DLL extern l_int32 pixRenderLineArb(PIX *pix, l_int32 x1, l_int32 y1, l_int32 x2, l_int32 y2, l_int32 width, l_uint8 rval, l_uint8 gval, l_uint8 bval);
LEPT_DLL extern l_int32 pixRenderLineBlend(PIX *pix, l_int32 x1, l_int32 y1, l_int32 x2, l_int32 y2, l_int32 width, l_uint8 rval, l_uint8 gval, l_uint8 bval, l_float32 fract);
LEPT_DLL extern l_int32 pixRenderBox(PIX *pix, BOX *box, l_int32 width, l_int32 op);
LEPT_DLL extern l_int32 pixRenderBoxArb(PIX *pix, BOX *box, l_int32 width, l_uint8 rval, l_uint8 gval, l_uint8 bval);
LEPT_DLL extern l_int32 pixRenderBoxBlend(PIX *pix, BOX *box, l_int32 width, l_uint8 rval, l_uint8 gval, l_uint8 bval, l_float32 fract);
LEPT_DLL extern l_int32 pixRenderHashBox(PIX *pix, BOX *box, l_int32 spacing, l_int32 width, l_int32 orient, l_int32 outline, l_int32 op);
LEPT_DLL extern l_int32 pixRenderHashBoxArb(PIX *pix, BOX *box, l_int32 spacing, l_int32 width, l_int32 orient, l_int32 outline, l_int32 rval, l_int32 gval, l_int32 bval);
LEPT_DLL extern l_int32 pixRenderHashBoxBlend(PIX *pix, BOX *box, l_int32 spacing, l_int32 width, l_int32 orient, l_int32 outline, l_int32 rval, l_int32 gval, l_int32 bval, l_float32 fract);
LEPT_DLL extern l_int32 pixRenderBoxa(PIX *pix, BOXA *boxa, l_int32 width, l_int32 op);
LEPT_DLL extern l_int32 pixRenderBoxaArb(PIX *pix, BOXA *boxa, l_int32 width, l_uint8 rval, l_uint8 gval, l_uint8 bval);
LEPT_DLL extern l_int32 pixRenderBoxaBlend(PIX *pix, BOXA *boxa, l_int32 width, l_uint8 rval, l_uint8 gval, l_uint8 bval, l_float32 fract, l_int32 removedups);
LEPT_DLL extern l_int32 pixRenderPolyline(PIX *pix, PTA *ptas, l_int32 width, l_int32 op, l_int32 closeflag);
LEPT_DLL extern l_int32 pixRenderPolylineArb(PIX *pix, PTA *ptas, l_int32 width, l_uint8 rval, l_uint8 gval, l_uint8 bval, l_int32 closeflag);
LEPT_DLL extern l_int32 pixRenderPolylineBlend(PIX *pix, PTA *ptas, l_int32 width, l_uint8 rval, l_uint8 gval, l_uint8 bval, l_float32 fract, l_int32 closeflag, l_int32 removedups);
LEPT_DLL extern PIX *pixRenderRandomCmapPtaa(PIX *pix, PTAA *ptaa, l_int32 polyflag, l_int32 width, l_int32 closeflag);
LEPT_DLL extern PIX *pixRenderContours(PIX *pixs, l_int32 startval, l_int32 incr, l_int32 outdepth);
LEPT_DLL extern PIX *fpixRenderContours(FPIX *fpixs, l_float32 startval, l_float32 incr, l_float32 proxim);
*/
PIX *pixErodeGray(PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixDilateGray(PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixOpenGray(PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixCloseGray(PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixErodeGray3(PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixDilateGray3(PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixOpenGray3(PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixCloseGray3(PIX *pixs, l_int32 hsize, l_int32 vsize);
void dilateGrayLow(l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_int32 size, l_int32 direction, l_uint8 *buffer, l_uint8 *maxarray);
void erodeGrayLow(l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_int32 size, l_int32 direction, l_uint8 *buffer, l_uint8 *minarray);
PIX *pixDitherToBinary(PIX *pixs);
PIX *pixDitherToBinarySpec(PIX *pixs, l_int32 lowerclip, l_int32 upperclip);
PIX *pixThresholdToBinary(PIX *pixs, l_int32 thresh);
PIX *pixVarThresholdToBinary(PIX *pixs, PIX *pixg);
PIX *pixDitherToBinaryLUT(PIX *pixs, l_int32 lowerclip, l_int32 upperclip);
PIX *pixGenerateMaskByValue(PIX *pixs, l_int32 val, l_int32 usecmap);
PIX *pixGenerateMaskByBand(PIX *pixs, l_int32 lower, l_int32 upper, l_int32 inband, l_int32 usecmap);
PIX *pixDitherTo2bpp(PIX *pixs, l_int32 cmapflag);
PIX *pixDitherTo2bppSpec(PIX *pixs, l_int32 lowerclip, l_int32 upperclip, l_int32 cmapflag);
PIX *pixThresholdTo2bpp(PIX *pixs, l_int32 nlevels, l_int32 cmapflag);
PIX *pixThresholdTo4bpp(PIX *pixs, l_int32 nlevels, l_int32 cmapflag);
PIX *pixThresholdOn8bpp(PIX *pixs, l_int32 nlevels, l_int32 cmapflag);
PIX *pixThresholdGrayArb(PIX *pixs, const char *edgevals, l_int32 outdepth, l_int32 use_average, l_int32 setblack, l_int32 setwhite);
l_int32 *makeGrayQuantIndexTable(l_int32 nlevels);
l_int32 *makeGrayQuantTargetTable(l_int32 nlevels, l_int32 depth);
l_int32 makeGrayQuantTableArb(NUMA *na, l_int32 outdepth, l_int32 **ptab, PIXCMAP **pcmap);
l_int32 makeGrayQuantColormapArb(PIX *pixs, l_int32 *tab, l_int32 outdepth, PIXCMAP **pcmap);
PIX *pixGenerateMaskByBand32(PIX *pixs, l_uint32 refval, l_int32 delm, l_int32 delp);
PIX *pixGenerateMaskByDiscr32(PIX *pixs, l_uint32 refval1, l_uint32 refval2, l_int32 distflag);
PIX *pixGrayQuantFromHisto(PIX *pixd, PIX *pixs, PIX *pixm, l_float32 minfract, l_int32 maxsize);
PIX *pixGrayQuantFromCmap(PIX *pixs, PIXCMAP *cmap, l_int32 mindepth);
void ditherToBinaryLow(l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_uint32 *bufs1, l_uint32 *bufs2, l_int32 lowerclip, l_int32 upperclip);
void ditherToBinaryLineLow(l_uint32 *lined, l_int32 w, l_uint32 *bufs1, l_uint32 *bufs2, l_int32 lowerclip, l_int32 upperclip, l_int32 lastlineflag);
void thresholdToBinaryLow(l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 d, l_int32 wpls, l_int32 thresh);
void thresholdToBinaryLineLow(l_uint32 *lined, l_int32 w, l_uint32 *lines, l_int32 d, l_int32 thresh);
void ditherToBinaryLUTLow(l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_uint32 *bufs1, l_uint32 *bufs2, l_int32 *tabval, l_int32 *tab38, l_int32 *tab14);
void ditherToBinaryLineLUTLow(l_uint32 *lined, l_int32 w, l_uint32 *bufs1, l_uint32 *bufs2, l_int32 *tabval, l_int32 *tab38, l_int32 *tab14, l_int32 lastlineflag);
l_int32 make8To1DitherTables(l_int32 **ptabval, l_int32 **ptab38, l_int32 **ptab14, l_int32 lowerclip, l_int32 upperclip);
void ditherTo2bppLow(l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_uint32 *bufs1, l_uint32 *bufs2, l_int32 *tabval, l_int32 *tab38, l_int32 *tab14);
void ditherTo2bppLineLow(l_uint32 *lined, l_int32 w, l_uint32 *bufs1, l_uint32 *bufs2, l_int32 *tabval, l_int32 *tab38, l_int32 *tab14, l_int32 lastlineflag);
l_int32 make8To2DitherTables(l_int32 **ptabval, l_int32 **ptab38, l_int32 **ptab14, l_int32 cliptoblack, l_int32 cliptowhite);
void thresholdTo2bppLow(l_uint32 *datad, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_int32 *tab);
void thresholdTo4bppLow(l_uint32 *datad, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_int32 *tab);
/*
LEPT_DLL extern L_HEAP *lheapCreate(l_int32 nalloc, l_int32 direction);
LEPT_DLL extern void lheapDestroy(L_HEAP **plh, l_int32 freeflag);
LEPT_DLL extern l_int32 lheapAdd(L_HEAP *lh, void *item);
LEPT_DLL extern l_int32 lheapExtendArray(L_HEAP *lh);
LEPT_DLL extern void *lheapRemove(L_HEAP *lh);
LEPT_DLL extern l_int32 lheapGetCount(L_HEAP *lh);
LEPT_DLL extern l_int32 lheapSwapUp(L_HEAP *lh, l_int32 index);
LEPT_DLL extern l_int32 lheapSwapDown(L_HEAP *lh);
LEPT_DLL extern l_int32 lheapSort(L_HEAP *lh);
LEPT_DLL extern l_int32 lheapSortStrictOrder(L_HEAP *lh);
LEPT_DLL extern l_int32 lheapPrint(FILE *fp, L_HEAP *lh);
LEPT_DLL extern JBCLASSER *jbRankHausInit(l_int32 components, l_int32 maxwidth, l_int32 maxheight, l_int32 size, l_float32 rank);
LEPT_DLL extern JBCLASSER *jbCorrelationInit(l_int32 components, l_int32 maxwidth, l_int32 maxheight, l_float32 thresh, l_float32 weightfactor);
LEPT_DLL extern JBCLASSER *jbCorrelationInitWithoutComponents(l_int32 components, l_int32 maxwidth, l_int32 maxheight, l_float32 thresh, l_float32 weightfactor);
LEPT_DLL extern l_int32 jbAddPages(JBCLASSER *classer, SARRAY *safiles);
LEPT_DLL extern l_int32 jbAddPage(JBCLASSER *classer, PIX *pixs);
LEPT_DLL extern l_int32 jbAddPageComponents(JBCLASSER *classer, PIX *pixs, BOXA *boxas, PIXA *pixas);
LEPT_DLL extern l_int32 jbClassifyRankHaus(JBCLASSER *classer, BOXA *boxa, PIXA *pixas);
LEPT_DLL extern l_int32 pixHaustest(PIX *pix1, PIX *pix2, PIX *pix3, PIX *pix4, l_float32 delx, l_float32 dely, l_int32 maxdiffw, l_int32 maxdiffh);
LEPT_DLL extern l_int32 pixRankHaustest(PIX *pix1, PIX *pix2, PIX *pix3, PIX *pix4, l_float32 delx, l_float32 dely, l_int32 maxdiffw, l_int32 maxdiffh, l_int32 area1, l_int32 area3, l_float32 rank, l_int32 *tab8);
LEPT_DLL extern l_int32 jbClassifyCorrelation(JBCLASSER *classer, BOXA *boxa, PIXA *pixas);
LEPT_DLL extern l_int32 jbGetComponents(PIX *pixs, l_int32 components, l_int32 maxwidth, l_int32 maxheight, BOXA **pboxad, PIXA **ppixad);
LEPT_DLL extern PIX *pixWordMaskByDilation(PIX *pixs, l_int32 maxsize, l_int32 *psize);
LEPT_DLL extern PIXA *jbAccumulateComposites(PIXAA *pixaa, NUMA **pna, PTA **pptat);
LEPT_DLL extern PIXA *jbTemplatesFromComposites(PIXA *pixac, NUMA *na);
LEPT_DLL extern JBCLASSER *jbClasserCreate(l_int32 method, l_int32 components);
LEPT_DLL extern void jbClasserDestroy(JBCLASSER **pclasser);
LEPT_DLL extern JBDATA *jbDataSave(JBCLASSER *classer);
LEPT_DLL extern void jbDataDestroy(JBDATA **pdata);
LEPT_DLL extern l_int32 jbDataWrite(const char *rootout, JBDATA *jbdata);
LEPT_DLL extern JBDATA *jbDataRead(const char *rootname);
LEPT_DLL extern PIXA *jbDataRender(JBDATA *data, l_int32 debugflag);
LEPT_DLL extern l_int32 jbGetULCorners(JBCLASSER *classer, PIX *pixs, BOXA *boxa);
LEPT_DLL extern l_int32 jbGetLLCorners(JBCLASSER *classer);
LEPT_DLL extern PIX *pixReadJpeg(const char *filename, l_int32 cmflag, l_int32 reduction, l_int32 *pnwarn);
LEPT_DLL extern PIX *pixReadStreamJpeg(FILE *fp, l_int32 cmflag, l_int32 reduction, l_int32 *pnwarn, l_int32 hint);
LEPT_DLL extern l_int32 readHeaderJpeg(const char *filename, l_int32 *pw, l_int32 *ph, l_int32 *pspp, l_int32 *pycck, l_int32 *pcmyk);
LEPT_DLL extern l_int32 freadHeaderJpeg(FILE *fp, l_int32 *pw, l_int32 *ph, l_int32 *pspp, l_int32 *pycck, l_int32 *pcmyk);
LEPT_DLL extern l_int32 fgetJpegResolution(FILE *fp, l_int32 *pxres, l_int32 *pyres);
LEPT_DLL extern l_int32 pixWriteJpeg(const char *filename, PIX *pix, l_int32 quality, l_int32 progressive);
LEPT_DLL extern l_int32 pixWriteStreamJpeg(FILE *fp, PIX *pix, l_int32 quality, l_int32 progressive);
LEPT_DLL extern PIX *pixReadMemJpeg(const l_uint8 *cdata, size_t size, l_int32 cmflag, l_int32 reduction, l_int32 *pnwarn, l_int32 hint);
LEPT_DLL extern l_int32 readHeaderMemJpeg(const l_uint8 *cdata, size_t size, l_int32 *pw, l_int32 *ph, l_int32 *pspp, l_int32 *pycck, l_int32 *pcmyk);
LEPT_DLL extern l_int32 pixWriteMemJpeg(l_uint8 **pdata, size_t *psize, PIX *pix, l_int32 quality, l_int32 progressive);
LEPT_DLL extern void l_jpegSetNoChromaSampling(l_int32 flag);
LEPT_DLL extern l_int32 extractJpegDataFromFile(const char *filein, l_uint8 **pdata, size_t *pnbytes, l_int32 *pw, l_int32 *ph, l_int32 *pbps, l_int32 *pspp);
LEPT_DLL extern l_int32 extractJpegDataFromArray(const void *data, size_t nbytes, l_int32 *pw, l_int32 *ph, l_int32 *pbps, l_int32 *pspp);
*/
L_KERNEL *kernelCreate(l_int32 height, l_int32 width);
void kernelDestroy(L_KERNEL **pkel);
L_KERNEL *kernelCopy(L_KERNEL *kels);
l_int32 kernelGetElement(L_KERNEL *kel, l_int32 row, l_int32 col, l_float32 *pval);
l_int32 kernelSetElement(L_KERNEL *kel, l_int32 row, l_int32 col, l_float32 val);
l_int32 kernelGetParameters(L_KERNEL *kel, l_int32 *psy, l_int32 *psx, l_int32 *pcy, l_int32 *pcx);
l_int32 kernelSetOrigin(L_KERNEL *kel, l_int32 cy, l_int32 cx);
l_int32 kernelGetSum(L_KERNEL *kel, l_float32 *psum);
l_int32 kernelGetMinMax(L_KERNEL *kel, l_float32 *pmin, l_float32 *pmax);
L_KERNEL *kernelNormalize(L_KERNEL *kels, l_float32 normsum);
L_KERNEL *kernelInvert(L_KERNEL *kels);
l_float32 **create2dFloatArray(l_int32 sy, l_int32 sx);
L_KERNEL *kernelRead(const char *fname);
L_KERNEL *kernelReadStream(void *fp);
l_int32 kernelWrite(const char *fname, L_KERNEL *kel);
l_int32 kernelWriteStream(void *fp, L_KERNEL *kel);
L_KERNEL *kernelCreateFromString(l_int32 h, l_int32 w, l_int32 cy, l_int32 cx, const char *kdata);
L_KERNEL *kernelCreateFromFile(const char *filename);
L_KERNEL *kernelCreateFromPix(PIX *pix, l_int32 cy, l_int32 cx);
PIX *kernelDisplayInPix(L_KERNEL *kel, l_int32 size, l_int32 gthick);
NUMA *parseStringForNumbers(const char *str, const char *seps);
L_KERNEL *makeFlatKernel(l_int32 height, l_int32 width, l_int32 cy, l_int32 cx);
L_KERNEL *makeGaussianKernel(l_int32 halfheight, l_int32 halfwidth, l_float32 stdev, l_float32 max);
l_int32 makeGaussianKernelSep(l_int32 halfheight, l_int32 halfwidth, l_float32 stdev, l_float32 max, L_KERNEL **pkelx, L_KERNEL **pkely);
L_KERNEL *makeDoGKernel(l_int32 halfheight, l_int32 halfwidth, l_float32 stdev, l_float32 ratio);
/*
LEPT_DLL extern char *getImagelibVersions();
LEPT_DLL extern void listDestroy(DLLIST **phead);
LEPT_DLL extern l_int32 listAddToHead(DLLIST **phead, void *data);
LEPT_DLL extern l_int32 listAddToTail(DLLIST **phead, DLLIST **ptail, void *data);
LEPT_DLL extern l_int32 listInsertBefore(DLLIST **phead, DLLIST *elem, void *data);
LEPT_DLL extern l_int32 listInsertAfter(DLLIST **phead, DLLIST *elem, void *data);
LEPT_DLL extern void *listRemoveElement(DLLIST **phead, DLLIST *elem);
LEPT_DLL extern void *listRemoveFromHead(DLLIST **phead);
LEPT_DLL extern void *listRemoveFromTail(DLLIST **phead, DLLIST **ptail);
LEPT_DLL extern DLLIST *listFindElement(DLLIST *head, void *data);
LEPT_DLL extern DLLIST *listFindTail(DLLIST *head);
LEPT_DLL extern l_int32 listGetCount(DLLIST *head);
LEPT_DLL extern l_int32 listReverse(DLLIST **phead);
LEPT_DLL extern l_int32 listJoin(DLLIST **phead1, DLLIST **phead2);
LEPT_DLL extern PIX *generateBinaryMaze(l_int32 w, l_int32 h, l_int32 xi, l_int32 yi, l_float32 wallps, l_float32 ranis);
LEPT_DLL extern PTA *pixSearchBinaryMaze(PIX *pixs, l_int32 xi, l_int32 yi, l_int32 xf, l_int32 yf, PIX **ppixd);
LEPT_DLL extern PTA *pixSearchGrayMaze(PIX *pixs, l_int32 xi, l_int32 yi, l_int32 xf, l_int32 yf, PIX **ppixd);
LEPT_DLL extern l_int32 pixFindLargestRectangle(PIX *pixs, l_int32 polarity, BOX **pbox, const char *debugfile);
*/
PIX *pixDilate(PIX *pixd, PIX *pixs, SEL *sel);
PIX *pixErode(PIX *pixd, PIX *pixs, SEL *sel);
PIX *pixHMT(PIX *pixd, PIX *pixs, SEL *sel);
PIX *pixOpen(PIX *pixd, PIX *pixs, SEL *sel);
PIX *pixClose(PIX *pixd, PIX *pixs, SEL *sel);
PIX *pixCloseSafe(PIX *pixd, PIX *pixs, SEL *sel);
PIX *pixOpenGeneralized(PIX *pixd, PIX *pixs, SEL *sel);
PIX *pixCloseGeneralized(PIX *pixd, PIX *pixs, SEL *sel);
PIX *pixDilateBrick(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixErodeBrick(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixOpenBrick(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixCloseBrick(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixCloseSafeBrick(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
l_int32 selectComposableSels(l_int32 size, l_int32 direction, SEL **psel1, SEL **psel2);
l_int32 selectComposableSizes(l_int32 size, l_int32 *pfactor1, l_int32 *pfactor2);
PIX *pixDilateCompBrick(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixErodeCompBrick(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixOpenCompBrick(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixCloseCompBrick(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixCloseSafeCompBrick(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
void resetMorphBoundaryCondition(l_int32 bc);
l_uint32 getMorphBorderPixelColor(l_int32 type, l_int32 depth);
PIX *pixExtractBoundary(PIX *pixs, l_int32 type);
PIX *pixMorphSequenceMasked(PIX *pixs, PIX *pixm, const char *sequence, l_int32 dispsep);
PIX *pixMorphSequenceByComponent(PIX *pixs, const char *sequence, l_int32 connectivity, l_int32 minw, l_int32 minh, BOXA **pboxa);
PIXA *pixaMorphSequenceByComponent(PIXA *pixas, const char *sequence, l_int32 minw, l_int32 minh);
PIX *pixMorphSequenceByRegion(PIX *pixs, PIX *pixm, const char *sequence, l_int32 connectivity, l_int32 minw, l_int32 minh, BOXA **pboxa);
PIXA *pixaMorphSequenceByRegion(PIX *pixs, PIXA *pixam, const char *sequence, l_int32 minw, l_int32 minh);
PIX *pixUnionOfMorphOps(PIX *pixs, SELA *sela, l_int32 type);
PIX *pixIntersectionOfMorphOps(PIX *pixs, SELA *sela, l_int32 type);
PIX *pixSelectiveConnCompFill(PIX *pixs, l_int32 connectivity, l_int32 minw, l_int32 minh);
l_int32 pixRemoveMatchedPattern(PIX *pixs, PIX *pixp, PIX *pixe, l_int32 x0, l_int32 y0, l_int32 dsize);
PIX *pixDisplayMatchedPattern(PIX *pixs, PIX *pixp, PIX *pixe, l_int32 x0, l_int32 y0, l_uint32 color, l_float32 scale, l_int32 nlevels);
PIX *pixSeedfillMorph(PIX *pixs, PIX *pixm, l_int32 connectivity);
NUMA *pixRunHistogramMorph(PIX *pixs, l_int32 runtype, l_int32 direction, l_int32 maxsize);
PIX *pixTophat(PIX *pixs, l_int32 hsize, l_int32 vsize, l_int32 type);
PIX *pixHDome(PIX *pixs, l_int32 height, l_int32 connectivity);
PIX *pixFastTophat(PIX *pixs, l_int32 xsize, l_int32 ysize, l_int32 type);
PIX *pixMorphGradient(PIX *pixs, l_int32 hsize, l_int32 vsize, l_int32 smoothing);
PTA *pixaCentroids(PIXA *pixa);
l_int32 pixCentroid(PIX *pix, l_int32 *centtab, l_int32 *sumtab, l_float32 *pxave, l_float32 *pyave);
PIX *pixDilateBrickDwa(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixErodeBrickDwa(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixOpenBrickDwa(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixCloseBrickDwa(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixDilateCompBrickDwa(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixErodeCompBrickDwa(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixOpenCompBrickDwa(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixCloseCompBrickDwa(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixDilateCompBrickExtendDwa(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixErodeCompBrickExtendDwa(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixOpenCompBrickExtendDwa(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
PIX *pixCloseCompBrickExtendDwa(PIX *pixd, PIX *pixs, l_int32 hsize, l_int32 vsize);
l_int32 getExtendedCompositeParameters(l_int32 size, l_int32 *pn, l_int32 *pextra, l_int32 *pactualsize);
PIX *pixMorphSequence(PIX *pixs, const char *sequence, l_int32 dispsep);
PIX *pixMorphCompSequence(PIX *pixs, const char *sequence, l_int32 dispsep);
PIX *pixMorphSequenceDwa(PIX *pixs, const char *sequence, l_int32 dispsep);
PIX *pixMorphCompSequenceDwa(PIX *pixs, const char *sequence, l_int32 dispsep);
l_int32 morphSequenceVerify(SARRAY *sa);
PIX *pixGrayMorphSequence(PIX *pixs, const char *sequence, l_int32 dispsep, l_int32 dispy);
PIX *pixColorMorphSequence(PIX *pixs, const char *sequence, l_int32 dispsep, l_int32 dispy);
NUMA *numaCreate(l_int32 n);
NUMA *numaCreateFromIArray(l_int32 *iarray, l_int32 size);
NUMA *numaCreateFromFArray(l_float32 *farray, l_int32 size, l_int32 copyflag);
void numaDestroy(NUMA **pna);
/*
LEPT_DLL extern NUMA *numaCopy(NUMA *na);
LEPT_DLL extern NUMA *numaClone(NUMA *na);
LEPT_DLL extern l_int32 numaEmpty(NUMA *na);
LEPT_DLL extern l_int32 numaAddNumber(NUMA *na, l_float32 val);
LEPT_DLL extern l_int32 numaExtendArray(NUMA *na);
LEPT_DLL extern l_int32 numaInsertNumber(NUMA *na, l_int32 index, l_float32 val);
LEPT_DLL extern l_int32 numaRemoveNumber(NUMA *na, l_int32 index);
LEPT_DLL extern l_int32 numaReplaceNumber(NUMA *na, l_int32 index, l_float32 val);
LEPT_DLL extern l_int32 numaGetCount(NUMA *na);
LEPT_DLL extern l_int32 numaSetCount(NUMA *na, l_int32 newcount);
LEPT_DLL extern l_int32 numaGetFValue(NUMA *na, l_int32 index, l_float32 *pval);
LEPT_DLL extern l_int32 numaGetIValue(NUMA *na, l_int32 index, l_int32 *pival);
LEPT_DLL extern l_int32 numaSetValue(NUMA *na, l_int32 index, l_float32 val);
LEPT_DLL extern l_int32 numaShiftValue(NUMA *na, l_int32 index, l_float32 diff);
LEPT_DLL extern l_int32 *numaGetIArray(NUMA *na);
LEPT_DLL extern l_float32 *numaGetFArray(NUMA *na, l_int32 copyflag);
LEPT_DLL extern l_int32 numaGetRefcount(NUMA *na);
LEPT_DLL extern l_int32 numaChangeRefcount(NUMA *na, l_int32 delta);
LEPT_DLL extern l_int32 numaGetXParameters(NUMA *na, l_float32 *pstartx, l_float32 *pdelx);
LEPT_DLL extern l_int32 numaSetXParameters(NUMA *na, l_float32 startx, l_float32 delx);
LEPT_DLL extern l_int32 numaCopyXParameters(NUMA *nad, NUMA *nas);
LEPT_DLL extern NUMA *numaRead(const char *filename);
LEPT_DLL extern NUMA *numaReadStream(FILE *fp);
LEPT_DLL extern l_int32 numaWrite(const char *filename, NUMA *na);
LEPT_DLL extern l_int32 numaWriteStream(FILE *fp, NUMA *na);
LEPT_DLL extern NUMAA *numaaCreate(l_int32 n);
LEPT_DLL extern void numaaDestroy(NUMAA **pnaa);
LEPT_DLL extern l_int32 numaaAddNuma(NUMAA *naa, NUMA *na, l_int32 copyflag);
LEPT_DLL extern l_int32 numaaExtendArray(NUMAA *naa);
LEPT_DLL extern l_int32 numaaGetCount(NUMAA *naa);
LEPT_DLL extern l_int32 numaaGetNumaCount(NUMAA *naa, l_int32 index);
LEPT_DLL extern l_int32 numaaGetNumberCount(NUMAA *naa);
LEPT_DLL extern NUMA ** numaaGetPtrArray(NUMAA *naa);
LEPT_DLL extern NUMA *numaaGetNuma(NUMAA *naa, l_int32 index, l_int32 accessflag);
LEPT_DLL extern l_int32 numaaReplaceNuma(NUMAA *naa, l_int32 index, NUMA *na);
LEPT_DLL extern l_int32 numaaGetValue(NUMAA *naa, l_int32 i, l_int32 j, l_float32 *pval);
LEPT_DLL extern l_int32 numaaAddNumber(NUMAA *naa, l_int32 index, l_float32 val);
LEPT_DLL extern NUMAA *numaaRead(const char *filename);
LEPT_DLL extern NUMAA *numaaReadStream(FILE *fp);
LEPT_DLL extern l_int32 numaaWrite(const char *filename, NUMAA *naa);
LEPT_DLL extern l_int32 numaaWriteStream(FILE *fp, NUMAA *naa);
LEPT_DLL extern NUMA2D *numa2dCreate(l_int32 nrows, l_int32 ncols, l_int32 initsize);
LEPT_DLL extern void numa2dDestroy(NUMA2D **pna2d);
LEPT_DLL extern l_int32 numa2dAddNumber(NUMA2D *na2d, l_int32 row, l_int32 col, l_float32 val);
LEPT_DLL extern l_int32 numa2dGetCount(NUMA2D *na2d, l_int32 row, l_int32 col);
LEPT_DLL extern NUMA *numa2dGetNuma(NUMA2D *na2d, l_int32 row, l_int32 col);
LEPT_DLL extern l_int32 numa2dGetFValue(NUMA2D *na2d, l_int32 row, l_int32 col, l_int32 index, l_float32 *pval);
LEPT_DLL extern l_int32 numa2dGetIValue(NUMA2D *na2d, l_int32 row, l_int32 col, l_int32 index, l_int32 *pval);
LEPT_DLL extern NUMAHASH *numaHashCreate(l_int32 nbuckets, l_int32 initsize);
LEPT_DLL extern void numaHashDestroy(NUMAHASH **pnahash);
LEPT_DLL extern NUMA *numaHashGetNuma(NUMAHASH *nahash, l_uint32 key);
LEPT_DLL extern l_int32 numaHashAdd(NUMAHASH *nahash, l_uint32 key, l_float32 value);
LEPT_DLL extern NUMA *numaArithOp(NUMA *nad, NUMA *na1, NUMA *na2, l_int32 op);
LEPT_DLL extern NUMA *numaLogicalOp(NUMA *nad, NUMA *na1, NUMA *na2, l_int32 op);
LEPT_DLL extern NUMA *numaInvert(NUMA *nad, NUMA *nas);
LEPT_DLL extern l_int32 numaGetMin(NUMA *na, l_float32 *pminval, l_int32 *piminloc);
LEPT_DLL extern l_int32 numaGetMax(NUMA *na, l_float32 *pmaxval, l_int32 *pimaxloc);
LEPT_DLL extern l_int32 numaGetSum(NUMA *na, l_float32 *psum);
LEPT_DLL extern NUMA *numaGetPartialSums(NUMA *na);
LEPT_DLL extern l_int32 numaGetSumOnInterval(NUMA *na, l_int32 first, l_int32 last, l_float32 *psum);
LEPT_DLL extern l_int32 numaHasOnlyIntegers(NUMA *na, l_int32 maxsamples, l_int32 *pallints);
LEPT_DLL extern NUMA *numaSubsample(NUMA *nas, l_int32 subfactor);
LEPT_DLL extern NUMA *numaMakeDelta(NUMA *nas);
LEPT_DLL extern NUMA *numaMakeSequence(l_float32 startval, l_float32 increment, l_int32 size);
LEPT_DLL extern NUMA *numaMakeConstant(l_float32 val, l_int32 size);
LEPT_DLL extern NUMA *numaAddBorder(NUMA *nas, l_int32 left, l_int32 right, l_float32 val);
LEPT_DLL extern NUMA *numaAddSpecifiedBorder(NUMA *nas, l_int32 left, l_int32 right, l_int32 type);
LEPT_DLL extern NUMA *numaRemoveBorder(NUMA *nas, l_int32 left, l_int32 right);
LEPT_DLL extern l_int32 numaGetNonzeroRange(NUMA *na, l_float32 eps, l_int32 *pfirst, l_int32 *plast);
LEPT_DLL extern l_int32 numaGetCountRelativeToZero(NUMA *na, l_int32 type, l_int32 *pcount);
LEPT_DLL extern NUMA *numaClipToInterval(NUMA *nas, l_int32 first, l_int32 last);
LEPT_DLL extern NUMA *numaMakeThresholdIndicator(NUMA *nas, l_float32 thresh, l_int32 type);
LEPT_DLL extern NUMA *numaUniformSampling(NUMA *nas, l_int32 nsamp);
LEPT_DLL extern NUMA *numaLowPassIntervals(NUMA *nas, l_float32 thresh, l_float32 maxn);
LEPT_DLL extern NUMA *numaThresholdEdges(NUMA *nas, l_float32 thresh1, l_float32 thresh2, l_float32 maxn);
LEPT_DLL extern l_int32 numaGetSpanValues(NUMA *na, l_int32 span, l_int32 *pstart, l_int32 *pend);
LEPT_DLL extern l_int32 numaGetEdgeValues(NUMA *na, l_int32 edge, l_int32 *pstart, l_int32 *pend, l_int32 *psign);
LEPT_DLL extern l_int32 numaInterpolateEqxVal(l_float32 startx, l_float32 deltax, NUMA *nay, l_int32 type, l_float32 xval, l_float32 *pyval);
LEPT_DLL extern l_int32 numaInterpolateArbxVal(NUMA *nax, NUMA *nay, l_int32 type, l_float32 xval, l_float32 *pyval);
LEPT_DLL extern l_int32 numaInterpolateEqxInterval(l_float32 startx, l_float32 deltax, NUMA *nasy, l_int32 type, l_float32 x0, l_float32 x1, l_int32 npts, NUMA **pnax, NUMA **pnay);
LEPT_DLL extern l_int32 numaInterpolateArbxInterval(NUMA *nax, NUMA *nay, l_int32 type, l_float32 x0, l_float32 x1, l_int32 npts, NUMA **pnadx, NUMA **pnady);
LEPT_DLL extern l_int32 numaFitMax(NUMA *na, l_float32 *pmaxval, NUMA *naloc, l_float32 *pmaxloc);
LEPT_DLL extern l_int32 numaDifferentiateInterval(NUMA *nax, NUMA *nay, l_float32 x0, l_float32 x1, l_int32 npts, NUMA **pnadx, NUMA **pnady);
LEPT_DLL extern l_int32 numaIntegrateInterval(NUMA *nax, NUMA *nay, l_float32 x0, l_float32 x1, l_int32 npts, l_float32 *psum);
LEPT_DLL extern NUMA *numaSort(NUMA *naout, NUMA *nain, l_int32 sortorder);
LEPT_DLL extern NUMA *numaGetSortIndex(NUMA *na, l_int32 sortorder);
LEPT_DLL extern NUMA *numaSortByIndex(NUMA *nas, NUMA *naindex);
LEPT_DLL extern l_int32 numaIsSorted(NUMA *nas, l_int32 sortorder, l_int32 *psorted);
LEPT_DLL extern l_int32 numaSortPair(NUMA *nax, NUMA *nay, l_int32 sortorder, NUMA **pnasx, NUMA **pnasy);
LEPT_DLL extern NUMA *numaPseudorandomSequence(l_int32 size, l_int32 seed);
LEPT_DLL extern NUMA *numaRandomPermutation(NUMA *nas, l_int32 seed);
LEPT_DLL extern l_int32 numaGetRankValue(NUMA *na, l_float32 fract, l_float32 *pval);
LEPT_DLL extern l_int32 numaGetMedian(NUMA *na, l_float32 *pval);
LEPT_DLL extern l_int32 numaGetMode(NUMA *na, l_float32 *pval, l_int32 *pcount);
LEPT_DLL extern l_int32 numaJoin(NUMA *nad, NUMA *nas, l_int32 istart, l_int32 iend);
LEPT_DLL extern NUMA *numaaFlattenToNuma(NUMAA *naa);
LEPT_DLL extern NUMA *numaErode(NUMA *nas, l_int32 size);
LEPT_DLL extern NUMA *numaDilate(NUMA *nas, l_int32 size);
LEPT_DLL extern NUMA *numaOpen(NUMA *nas, l_int32 size);
LEPT_DLL extern NUMA *numaClose(NUMA *nas, l_int32 size);
LEPT_DLL extern NUMA *numaTransform(NUMA *nas, l_float32 shift, l_float32 scale);
LEPT_DLL extern l_int32 numaWindowedStats(NUMA *nas, l_int32 wc, NUMA **pnam, NUMA **pnams, NUMA **pnav, NUMA **pnarv);
LEPT_DLL extern NUMA *numaWindowedMean(NUMA *nas, l_int32 wc);
LEPT_DLL extern NUMA *numaWindowedMeanSquare(NUMA *nas, l_int32 wc);
LEPT_DLL extern l_int32 numaWindowedVariance(NUMA *nam, NUMA *nams, NUMA **pnav, NUMA **pnarv);
LEPT_DLL extern NUMA *numaConvertToInt(NUMA *nas);
LEPT_DLL extern NUMA *numaMakeHistogram(NUMA *na, l_int32 maxbins, l_int32 *pbinsize, l_int32 *pbinstart);
LEPT_DLL extern NUMA *numaMakeHistogramAuto(NUMA *na, l_int32 maxbins);
LEPT_DLL extern NUMA *numaMakeHistogramClipped(NUMA *na, l_float32 binsize, l_float32 maxsize);
LEPT_DLL extern NUMA *numaRebinHistogram(NUMA *nas, l_int32 newsize);
LEPT_DLL extern NUMA *numaNormalizeHistogram(NUMA *nas, l_float32 area);
LEPT_DLL extern l_int32 numaGetStatsUsingHistogram(NUMA *na, l_int32 maxbins, l_float32 *pmin, l_float32 *pmax, l_float32 *pmean, l_float32 *pvariance, l_float32 *pmedian, l_float32 rank, l_float32 *prval, NUMA **phisto);
LEPT_DLL extern l_int32 numaGetHistogramStats(NUMA *nahisto, l_float32 startx, l_float32 deltax, l_float32 *pxmean, l_float32 *pxmedian, l_float32 *pxmode, l_float32 *pxvariance);
LEPT_DLL extern l_int32 numaGetHistogramStatsOnInterval(NUMA *nahisto, l_float32 startx, l_float32 deltax, l_int32 ifirst, l_int32 ilast, l_float32 *pxmean, l_float32 *pxmedian, l_float32 *pxmode, l_float32 *pxvariance);
LEPT_DLL extern l_int32 numaMakeRankFromHistogram(l_float32 startx, l_float32 deltax, NUMA *nasy, l_int32 npts, NUMA **pnax, NUMA **pnay);
LEPT_DLL extern l_int32 numaHistogramGetRankFromVal(NUMA *na, l_float32 rval, l_float32 *prank);
LEPT_DLL extern l_int32 numaHistogramGetValFromRank(NUMA *na, l_float32 rank, l_float32 *prval);
LEPT_DLL extern l_int32 numaDiscretizeRankAndIntensity(NUMA *na, l_int32 nbins, NUMA **pnarbin, NUMA **pnam, NUMA **pnar, NUMA **pnabb);
LEPT_DLL extern l_int32 numaGetRankBinValues(NUMA *na, l_int32 nbins, NUMA **pnarbin, NUMA **pnam);
LEPT_DLL extern l_int32 numaSplitDistribution(NUMA *na, l_float32 scorefract, l_int32 *psplitindex, l_float32 *pave1, l_float32 *pave2, l_float32 *pnum1, l_float32 *pnum2, NUMA **pnascore);
LEPT_DLL extern NUMA *numaFindPeaks(NUMA *nas, l_int32 nmax, l_float32 fract1, l_float32 fract2);
LEPT_DLL extern NUMA *numaFindExtrema(NUMA *nas, l_float32 delta);
LEPT_DLL extern l_int32 numaCountReversals(NUMA *nas, l_float32 minreversal, l_int32 *pnr, l_float32 *pnrpl);
LEPT_DLL extern l_int32 numaSelectCrossingThreshold(NUMA *nax, NUMA *nay, l_float32 estthresh, l_float32 *pbestthresh);
LEPT_DLL extern NUMA *numaCrossingsByThreshold(NUMA *nax, NUMA *nay, l_float32 thresh);
LEPT_DLL extern NUMA *numaCrossingsByPeaks(NUMA *nax, NUMA *nay, l_float32 delta);
LEPT_DLL extern l_int32 numaEvalBestHaarParameters(NUMA *nas, l_float32 relweight, l_int32 nwidth, l_int32 nshift, l_float32 minwidth, l_float32 maxwidth, l_float32 *pbestwidth, l_float32 *pbestshift, l_float32 *pbestscore);
LEPT_DLL extern l_int32 numaEvalHaarSum(NUMA *nas, l_float32 width, l_float32 shift, l_float32 relweight, l_float32 *pscore);
LEPT_DLL extern l_int32 pixGetRegionsBinary(PIX *pixs, PIX **ppixhm, PIX **ppixtm, PIX **ppixtb, l_int32 debug);
LEPT_DLL extern PIX *pixGenHalftoneMask(PIX *pixs, PIX **ppixtext, l_int32 *phtfound, l_int32 debug);
LEPT_DLL extern PIX *pixGenTextlineMask(PIX *pixs, PIX **ppixvws, l_int32 *ptlfound, l_int32 debug);
LEPT_DLL extern PIX *pixGenTextblockMask(PIX *pixs, PIX *pixvws, l_int32 debug);
LEPT_DLL extern l_int32 pixSetSelectCmap(PIX *pixs, BOX *box, l_int32 sindex, l_int32 rval, l_int32 gval, l_int32 bval);
LEPT_DLL extern l_int32 pixColorGrayCmap(PIX *pixs, BOX *box, l_int32 type, l_int32 rval, l_int32 gval, l_int32 bval);
LEPT_DLL extern l_int32 addColorizedGrayToCmap(PIXCMAP *cmap, l_int32 type, l_int32 rval, l_int32 gval, l_int32 bval, NUMA **pna);
LEPT_DLL extern l_int32 pixSetSelectMaskedCmap(PIX *pixs, PIX *pixm, l_int32 x, l_int32 y, l_int32 sindex, l_int32 rval, l_int32 gval, l_int32 bval);
LEPT_DLL extern l_int32 pixSetMaskedCmap(PIX *pixs, PIX *pixm, l_int32 x, l_int32 y, l_int32 rval, l_int32 gval, l_int32 bval);
LEPT_DLL extern char *parseForProtos(const char *filein, const char *prestring);
LEPT_DLL extern BOXA *boxaGetWhiteblocks(BOXA *boxas, BOX *box, l_int32 sortflag, l_int32 maxboxes, l_float32 maxoverlap, l_int32 maxperim, l_float32 fract, l_int32 maxpops);
LEPT_DLL extern BOXA *boxaPruneSortedOnOverlap(BOXA *boxas, l_float32 maxoverlap);
LEPT_DLL extern l_int32 convertFilesToPdf(const char *dirname, const char *substr, l_int32 res, l_float32 scalefactor, l_int32 quality, const char *title, const char *fileout);
LEPT_DLL extern l_int32 saConvertFilesToPdf(SARRAY *sa, l_int32 res, l_float32 scalefactor, l_int32 quality, const char *title, const char *fileout);
LEPT_DLL extern l_int32 saConvertFilesToPdfData(SARRAY *sa, l_int32 res, l_float32 scalefactor, l_int32 quality, const char *title, l_uint8 **pdata, size_t *pnbytes);
LEPT_DLL extern l_int32 selectDefaultPdfEncoding(PIX *pix, l_int32 *ptype);
LEPT_DLL extern l_int32 convertToPdf(const char *filein, l_int32 type, l_int32 quality, const char *fileout, l_int32 x, l_int32 y, l_int32 res, L_PDF_DATA **plpd, l_int32 position, const char *title);
LEPT_DLL extern l_int32 convertImageDataToPdf(l_uint8 *imdata, size_t size, l_int32 type, l_int32 quality, const char *fileout, l_int32 x, l_int32 y, l_int32 res, L_PDF_DATA **plpd, l_int32 position, const char *title);
LEPT_DLL extern l_int32 convertToPdfData(const char *filein, l_int32 type, l_int32 quality, l_uint8 **pdata, size_t *pnbytes, l_int32 x, l_int32 y, l_int32 res, L_PDF_DATA **plpd, l_int32 position, const char *title);
LEPT_DLL extern l_int32 convertImageDataToPdfData(l_uint8 *imdata, size_t size, l_int32 type, l_int32 quality, l_uint8 **pdata, size_t *pnbytes, l_int32 x, l_int32 y, l_int32 res, L_PDF_DATA **plpd, l_int32 position, const char *title);
LEPT_DLL extern l_int32 pixConvertToPdf(PIX *pix, l_int32 type, l_int32 quality, const char *fileout, l_int32 x, l_int32 y, l_int32 res, L_PDF_DATA **plpd, l_int32 position, const char *title);
LEPT_DLL extern l_int32 pixConvertToPdfData(PIX *pix, l_int32 type, l_int32 quality, l_uint8 **pdata, size_t *pnbytes, l_int32 x, l_int32 y, l_int32 res, L_PDF_DATA **plpd, l_int32 position, const char *title);
LEPT_DLL extern l_int32 pixWriteStreamPdf(FILE *fp, PIX *pix, l_int32 res, const char *title);
LEPT_DLL extern l_int32 convertSegmentedFilesToPdf(const char *dirname, const char *substr, l_int32 res, l_int32 type, l_int32 thresh, BOXAA *baa, l_int32 quality, l_float32 scalefactor, const char *title, const char *fileout);
LEPT_DLL extern l_int32 convertToPdfSegmented(const char *filein, l_int32 res, l_int32 type, l_int32 thresh, BOXA *boxa, l_int32 quality, l_float32 scalefactor, const char *fileout);
LEPT_DLL extern l_int32 pixConvertToPdfSegmented(PIX *pixs, l_int32 res, l_int32 type, l_int32 thresh, BOXA *boxa, l_int32 quality, l_float32 scalefactor, const char *fileout, const char *title);
LEPT_DLL extern l_int32 convertToPdfDataSegmented(const char *filein, l_int32 res, l_int32 type, l_int32 thresh, BOXA *boxa, l_int32 quality, l_float32 scalefactor, l_uint8 **pdata, size_t *pnbytes);
LEPT_DLL extern l_int32 pixConvertToPdfDataSegmented(PIX *pixs, l_int32 res, l_int32 type, l_int32 thresh, BOXA *boxa, l_int32 quality, l_float32 scalefactor, l_uint8 **pdata, size_t *pnbytes, const char *title);
LEPT_DLL extern l_int32 concatenatePdf(const char *dirname, const char *substr, const char *fileout);
LEPT_DLL extern l_int32 saConcatenatePdf(SARRAY *sa, const char *fileout);
LEPT_DLL extern l_int32 ptraConcatenatePdf(L_PTRA *pa, const char *fileout);
LEPT_DLL extern l_int32 concatenatePdfToData(const char *dirname, const char *substr, l_uint8 **pdata, size_t *pnbytes);
LEPT_DLL extern l_int32 saConcatenatePdfToData(SARRAY *sa, l_uint8 **pdata, size_t *pnbytes);
LEPT_DLL extern l_int32 ptraConcatenatePdfToData(L_PTRA *pa_data, SARRAY *sa, l_uint8 **pdata, size_t *pnbytes);
LEPT_DLL extern void l_pdfSetG4ImageMask(l_int32 flag);
LEPT_DLL extern void l_pdfSetDateAndVersion(l_int32 flag);

LEPT_DLL extern void setPixMemoryManager(void *((*allocator)(size_t)), void ((*deallocator)(void *)));
*/

PIX *pixCreate(l_int32 width, l_int32 height, l_int32 depth);
PIX *pixCreateNoInit(l_int32 width, l_int32 height, l_int32 depth);
PIX *pixCreateTemplate(PIX *pixs);
PIX *pixCreateTemplateNoInit(PIX *pixs);
PIX *pixCreateHeader(l_int32 width, l_int32 height, l_int32 depth);
PIX *pixClone(PIX *pixs);
void pixDestroy(PIX **ppix);
PIX *pixCopy(PIX *pixd, PIX *pixs);
l_int32 pixResizeImageData(PIX *pixd, PIX *pixs);
l_int32 pixCopyColormap(PIX *pixd, PIX *pixs);
l_int32 pixSizesEqual(PIX *pix1, PIX *pix2);
l_int32 pixTransferAllData(PIX *pixd, PIX **ppixs, l_int32 copytext, l_int32 copyformat);
l_int32 pixGetWidth(PIX *pix);
l_int32 pixSetWidth(PIX *pix, l_int32 width);
l_int32 pixGetHeight(PIX *pix);
l_int32 pixSetHeight(PIX *pix, l_int32 height);
l_int32 pixGetDepth(PIX *pix);
l_int32 pixSetDepth(PIX *pix, l_int32 depth);
l_int32 pixGetDimensions(PIX *pix, l_int32 *pw, l_int32 *ph, l_int32 *pd);
l_int32 pixSetDimensions(PIX *pix, l_int32 w, l_int32 h, l_int32 d);
l_int32 pixCopyDimensions(PIX *pixd, PIX *pixs);
l_int32 pixGetWpl(PIX *pix);
l_int32 pixSetWpl(PIX *pix, l_int32 wpl);
l_int32 pixGetRefcount(PIX *pix);
l_int32 pixChangeRefcount(PIX *pix, l_int32 delta);
l_int32 pixGetXRes(PIX *pix);
l_int32 pixSetXRes(PIX *pix, l_int32 res);
l_int32 pixGetYRes(PIX *pix);
l_int32 pixSetYRes(PIX *pix, l_int32 res);
l_int32 pixGetResolution(PIX *pix, l_int32 *pxres, l_int32 *pyres);
l_int32 pixSetResolution(PIX *pix, l_int32 xres, l_int32 yres);
l_int32 pixCopyResolution(PIX *pixd, PIX *pixs);
l_int32 pixScaleResolution(PIX *pix, l_float32 xscale, l_float32 yscale);
l_int32 pixGetInputFormat(PIX *pix);
l_int32 pixSetInputFormat(PIX *pix, l_int32 informat);
l_int32 pixCopyInputFormat(PIX *pixd, PIX *pixs);
char *pixGetText(PIX *pix);
l_int32 pixSetText(PIX *pix, const char *textstring);
l_int32 pixAddText(PIX *pix, const char *textstring);
l_int32 pixCopyText(PIX *pixd, PIX *pixs);
PIXCMAP *pixGetColormap(PIX *pix);
l_int32 pixSetColormap(PIX *pix, PIXCMAP *colormap);
l_int32 pixDestroyColormap(PIX *pix);
l_uint32 *pixGetData(PIX *pix);
l_int32 pixSetData(PIX *pix, l_uint32 *data);
l_uint32 *pixExtractData(PIX *pixs);
l_int32 pixFreeData(PIX *pix);
void ** pixGetLinePtrs(PIX *pix, l_int32 *psize);
l_int32 pixPrintStreamInfo(void *fp, PIX *pix, const char *text);
l_int32 pixGetPixel(PIX *pix, l_int32 x, l_int32 y, l_uint32 *pval);
l_int32 pixSetPixel(PIX *pix, l_int32 x, l_int32 y, l_uint32 val);
l_int32 pixGetRGBPixel(PIX *pix, l_int32 x, l_int32 y, l_int32 *prval, l_int32 *pgval, l_int32 *pbval);
l_int32 pixSetRGBPixel(PIX *pix, l_int32 x, l_int32 y, l_int32 rval, l_int32 gval, l_int32 bval);
/*
LEPT_DLL extern l_int32 pixGetRandomPixel(PIX *pix, l_uint32 *pval, l_int32 *px, l_int32 *py);
LEPT_DLL extern l_int32 pixClearPixel(PIX *pix, l_int32 x, l_int32 y);
LEPT_DLL extern l_int32 pixFlipPixel(PIX *pix, l_int32 x, l_int32 y);
LEPT_DLL extern void setPixelLow(l_uint32 *line, l_int32 x, l_int32 depth, l_uint32 val);
LEPT_DLL extern l_int32 pixClearAll(PIX *pix);
LEPT_DLL extern l_int32 pixSetAll(PIX *pix);
LEPT_DLL extern l_int32 pixSetAllArbitrary(PIX *pix, l_uint32 val);
LEPT_DLL extern l_int32 pixSetBlackOrWhite(PIX *pixs, l_int32 op);
LEPT_DLL extern l_int32 pixClearInRect(PIX *pix, BOX *box);
LEPT_DLL extern l_int32 pixSetInRect(PIX *pix, BOX *box);
LEPT_DLL extern l_int32 pixSetInRectArbitrary(PIX *pix, BOX *box, l_uint32 val);
LEPT_DLL extern l_int32 pixBlendInRect(PIX *pixs, BOX *box, l_uint32 val, l_float32 fract);
LEPT_DLL extern l_int32 pixSetPadBits(PIX *pix, l_int32 val);
LEPT_DLL extern l_int32 pixSetPadBitsBand(PIX *pix, l_int32 by, l_int32 bh, l_int32 val);
LEPT_DLL extern l_int32 pixSetOrClearBorder(PIX *pixs, l_int32 left, l_int32 right, l_int32 top, l_int32 bot, l_int32 op);
LEPT_DLL extern l_int32 pixSetBorderVal(PIX *pixs, l_int32 left, l_int32 right, l_int32 top, l_int32 bot, l_uint32 val);
LEPT_DLL extern l_int32 pixSetBorderRingVal(PIX *pixs, l_int32 dist, l_uint32 val);
LEPT_DLL extern l_int32 pixSetMirroredBorder(PIX *pixs, l_int32 left, l_int32 right, l_int32 top, l_int32 bot);
LEPT_DLL extern PIX *pixCopyBorder(PIX *pixd, PIX *pixs, l_int32 left, l_int32 right, l_int32 top, l_int32 bot);
LEPT_DLL extern PIX *pixAddBorder(PIX *pixs, l_int32 npix, l_uint32 val);
LEPT_DLL extern PIX *pixAddBlackBorder(PIX *pixs, l_int32 npix);
LEPT_DLL extern PIX *pixAddBorderGeneral(PIX *pixs, l_int32 left, l_int32 right, l_int32 top, l_int32 bot, l_uint32 val);
LEPT_DLL extern PIX *pixRemoveBorder(PIX *pixs, l_int32 npix);
LEPT_DLL extern PIX *pixRemoveBorderGeneral(PIX *pixs, l_int32 left, l_int32 right, l_int32 top, l_int32 bot);
LEPT_DLL extern PIX *pixAddMirroredBorder(PIX *pixs, l_int32 left, l_int32 right, l_int32 top, l_int32 bot);
LEPT_DLL extern PIX *pixAddRepeatedBorder(PIX *pixs, l_int32 left, l_int32 right, l_int32 top, l_int32 bot);
LEPT_DLL extern PIX *pixAddMixedBorder(PIX *pixs, l_int32 left, l_int32 right, l_int32 top, l_int32 bot);
LEPT_DLL extern PIX *pixCreateRGBImage(PIX *pixr, PIX *pixg, PIX *pixb);
LEPT_DLL extern PIX *pixGetRGBComponent(PIX *pixs, l_int32 color);
LEPT_DLL extern l_int32 pixSetRGBComponent(PIX *pixd, PIX *pixs, l_int32 color);
LEPT_DLL extern PIX *pixGetRGBComponentCmap(PIX *pixs, l_int32 color);
*/
l_int32 composeRGBPixel(l_int32 rval, l_int32 gval, l_int32 bval, l_uint32 *ppixel);
/*
LEPT_DLL extern void extractRGBValues(l_uint32 pixel, l_int32 *prval, l_int32 *pgval, l_int32 *pbval);
LEPT_DLL extern l_int32 extractMinMaxComponent(l_uint32 pixel, l_int32 type);
LEPT_DLL extern l_int32 pixGetRGBLine(PIX *pixs, l_int32 row, l_uint8 *bufr, l_uint8 *bufg, l_uint8 *bufb);
LEPT_DLL extern PIX *pixEndianByteSwapNew(PIX *pixs);
LEPT_DLL extern l_int32 pixEndianByteSwap(PIX *pixs);
LEPT_DLL extern l_int32 lineEndianByteSwap(l_uint32 *datad, l_uint32 *datas, l_int32 wpl);
LEPT_DLL extern PIX *pixEndianTwoByteSwapNew(PIX *pixs);
LEPT_DLL extern l_int32 pixEndianTwoByteSwap(PIX *pixs);
LEPT_DLL extern l_int32 pixGetRasterData(PIX *pixs, l_uint8 **pdata, size_t *pnbytes);
LEPT_DLL extern l_uint8 ** pixSetupByteProcessing(PIX *pix, l_int32 *pw, l_int32 *ph);
LEPT_DLL extern l_int32 pixCleanupByteProcessing(PIX *pix, l_uint8 **lineptrs);
*/
void l_setAlphaMaskBorder(l_float32 val1, l_float32 val2);
l_int32 pixSetMasked(PIX *pixd, PIX *pixm, l_uint32 val);
l_int32 pixSetMaskedGeneral(PIX *pixd, PIX *pixm, l_uint32 val, l_int32 x, l_int32 y);
l_int32 pixCombineMasked(PIX *pixd, PIX *pixs, PIX *pixm);
l_int32 pixCombineMaskedGeneral(PIX *pixd, PIX *pixs, PIX *pixm, l_int32 x, l_int32 y);
l_int32 pixPaintThroughMask(PIX *pixd, PIX *pixm, l_int32 x, l_int32 y, l_uint32 val);
l_int32 pixPaintSelfThroughMask(PIX *pixd, PIX *pixm, l_int32 x, l_int32 y, l_int32 tilesize, l_int32 searchdir);
PIX *pixMakeMaskFromLUT(PIX *pixs, l_int32 *tab);
PIX *pixSetUnderTransparency(PIX *pixs, l_uint32 val, l_int32 debugflag);
PIX *pixInvert(PIX *pixd, PIX *pixs);
PIX *pixOr(PIX *pixd, PIX *pixs1, PIX *pixs2);
PIX *pixAnd(PIX *pixd, PIX *pixs1, PIX *pixs2);
PIX *pixXor(PIX *pixd, PIX *pixs1, PIX *pixs2);
PIX *pixSubtract(PIX *pixd, PIX *pixs1, PIX *pixs2);
l_int32 pixZero(PIX *pix, l_int32 *pempty);
l_int32 pixCountPixels(PIX *pix, l_int32 *pcount, l_int32 *tab8);
NUMA *pixaCountPixels(PIXA *pixa);
l_int32 pixCountPixelsInRow(PIX *pix, l_int32 row, l_int32 *pcount, l_int32 *tab8);
NUMA *pixCountPixelsByRow(PIX *pix, l_int32 *tab8);
NUMA *pixCountPixelsByColumn(PIX *pix);
NUMA *pixSumPixelsByRow(PIX *pix, l_int32 *tab8);
NUMA *pixSumPixelsByColumn(PIX *pix);
l_int32 pixThresholdPixelSum(PIX *pix, l_int32 thresh, l_int32 *pabove, l_int32 *tab8);
l_int32 *makePixelSumTab8(void);
l_int32 *makePixelCentroidTab8(void);
l_int32 pixSumPixelValues(PIX *pix, BOX *box, l_float64 *psum);
PIX *pixMirroredTiling(PIX *pixs, l_int32 w, l_int32 h);
NUMA *pixGetGrayHistogram(PIX *pixs, l_int32 factor);
NUMA *pixGetGrayHistogramMasked(PIX *pixs, PIX *pixm, l_int32 x, l_int32 y, l_int32 factor);
l_int32 pixGetColorHistogram(PIX *pixs, l_int32 factor, NUMA **pnar, NUMA **pnag, NUMA **pnab);
l_int32 pixGetColorHistogramMasked(PIX *pixs, PIX *pixm, l_int32 x, l_int32 y, l_int32 factor, NUMA **pnar, NUMA **pnag, NUMA **pnab);
NUMA *pixGetCmapHistogram(PIX *pixs, l_int32 factor);
NUMA *pixGetCmapHistogramMasked(PIX *pixs, PIX *pixm, l_int32 x, l_int32 y, l_int32 factor);
l_int32 pixGetRankValueMaskedRGB(PIX *pixs, PIX *pixm, l_int32 x, l_int32 y, l_int32 factor, l_float32 rank, l_float32 *prval, l_float32 *pgval, l_float32 *pbval);
l_int32 pixGetRankValueMasked(PIX *pixs, PIX *pixm, l_int32 x, l_int32 y, l_int32 factor, l_float32 rank, l_float32 *pval, NUMA **pna);
l_int32 pixGetAverageMaskedRGB(PIX *pixs, PIX *pixm, l_int32 x, l_int32 y, l_int32 factor, l_int32 type, l_float32 *prval, l_float32 *pgval, l_float32 *pbval);
l_int32 pixGetAverageMasked(PIX *pixs, PIX *pixm, l_int32 x, l_int32 y, l_int32 factor, l_int32 type, l_float32 *pval);
l_int32 pixGetAverageTiledRGB(PIX *pixs, l_int32 sx, l_int32 sy, l_int32 type, PIX **ppixr, PIX **ppixg, PIX **ppixb);
PIX *pixGetAverageTiled(PIX *pixs, l_int32 sx, l_int32 sy, l_int32 type);
l_int32 pixRowStats(PIX *pixs, NUMA **pnamean, NUMA **pnamedian, NUMA **pnamode, NUMA **pnamodecount, NUMA **pnavar, NUMA **pnarootvar);
l_int32 pixColumnStats(PIX *pixs, NUMA **pnamean, NUMA **pnamedian, NUMA **pnamode, NUMA **pnamodecount, NUMA **pnavar, NUMA **pnarootvar);
l_int32 pixGetComponentRange(PIX *pixs, l_int32 factor, l_int32 color, l_int32 *pminval, l_int32 *pmaxval);
l_int32 pixGetExtremeValue(PIX *pixs, l_int32 factor, l_int32 type, l_int32 *prval, l_int32 *pgval, l_int32 *pbval, l_int32 *pgrayval);
l_int32 pixGetMaxValueInRect(PIX *pixs, BOX *box, l_uint32 *pmaxval, l_int32 *pxmax, l_int32 *pymax);
l_int32 pixGetBinnedComponentRange(PIX *pixs, l_int32 nbins, l_int32 factor, l_int32 color, l_int32 *pminval, l_int32 *pmaxval, l_uint32 **pcarray, l_int32 debugflag);
l_int32 pixGetRankColorArray(PIX *pixs, l_int32 nbins, l_int32 type, l_int32 factor, l_uint32 **pcarray, l_int32 debugflag);
l_int32 pixGetBinnedColor(PIX *pixs, PIX *pixg, l_int32 factor, l_int32 nbins, NUMA *nalut, l_uint32 **pcarray, l_int32 debugflag);
/*
LEPT_DLL extern PIX *pixDisplayColorArray(l_uint32 *carray, l_int32 ncolors, l_int32 side, l_int32 ncols, l_int32 textflag);
LEPT_DLL extern PIX *pixaGetAlignedStats(PIXA *pixa, l_int32 type, l_int32 nbins, l_int32 thresh);
LEPT_DLL extern l_int32 pixaExtractColumnFromEachPix(PIXA *pixa, l_int32 col, PIX *pixd);
LEPT_DLL extern l_int32 pixGetRowStats(PIX *pixs, l_int32 type, l_int32 nbins, l_int32 thresh, l_float32 *colvect);
LEPT_DLL extern l_int32 pixGetColumnStats(PIX *pixs, l_int32 type, l_int32 nbins, l_int32 thresh, l_float32 *rowvect);
LEPT_DLL extern l_int32 pixSetPixelColumn(PIX *pix, l_int32 col, l_float32 *colvect);
LEPT_DLL extern l_int32 pixThresholdForFgBg(PIX *pixs, l_int32 factor, l_int32 thresh, l_int32 *pfgval, l_int32 *pbgval);
LEPT_DLL extern l_int32 pixSplitDistributionFgBg(PIX *pixs, l_float32 scorefract, l_int32 factor, l_int32 *pthresh, l_int32 *pfgval, l_int32 *pbgval, l_int32 debugflag);
LEPT_DLL extern l_int32 pixaFindDimensions(PIXA *pixa, NUMA **pnaw, NUMA **pnah);
LEPT_DLL extern NUMA *pixaFindAreaPerimRatio(PIXA *pixa);
LEPT_DLL extern l_int32 pixFindAreaPerimRatio(PIX *pixs, l_int32 *tab, l_float32 *pfract);
LEPT_DLL extern NUMA *pixaFindPerimSizeRatio(PIXA *pixa);
LEPT_DLL extern l_int32 pixFindPerimSizeRatio(PIX *pixs, l_int32 *tab, l_float32 *pratio);
LEPT_DLL extern NUMA *pixaFindAreaFraction(PIXA *pixa);
LEPT_DLL extern l_int32 pixFindAreaFraction(PIX *pixs, l_int32 *tab, l_float32 *pfract);
LEPT_DLL extern NUMA *pixaFindWidthHeightRatio(PIXA *pixa);
LEPT_DLL extern NUMA *pixaFindWidthHeightProduct(PIXA *pixa);
LEPT_DLL extern l_int32 pixFindOverlapFraction(PIX *pixs1, PIX *pixs2, l_int32 x2, l_int32 y2, l_int32 *tab, l_float32 *pratio, l_int32 *pnoverlap);
LEPT_DLL extern BOXA *pixFindRectangleComps(PIX *pixs, l_int32 dist, l_int32 minw, l_int32 minh);
LEPT_DLL extern l_int32 pixConformsToRectangle(PIX *pixs, BOX *box, l_int32 dist, l_int32 *pconforms);
LEPT_DLL extern PIX *pixClipRectangle(PIX *pixs, BOX *box, BOX **pboxc);
LEPT_DLL extern PIX *pixClipMasked(PIX *pixs, PIX *pixm, l_int32 x, l_int32 y, l_uint32 outval);
LEPT_DLL extern PIX *pixResizeToMatch(PIX *pixs, PIX *pixt, l_int32 w, l_int32 h);
LEPT_DLL extern l_int32 pixClipToForeground(PIX *pixs, PIX **ppixd, BOX **pbox);
LEPT_DLL extern l_int32 pixClipBoxToForeground(PIX *pixs, BOX *boxs, PIX **ppixd, BOX **pboxd);
LEPT_DLL extern l_int32 pixScanForForeground(PIX *pixs, BOX *box, l_int32 scanflag, l_int32 *ploc);
LEPT_DLL extern l_int32 pixClipBoxToEdges(PIX *pixs, BOX *boxs, l_int32 lowthresh, l_int32 highthresh, l_int32 maxwidth, l_int32 factor, PIX **ppixd, BOX **pboxd);
LEPT_DLL extern l_int32 pixScanForEdge(PIX *pixs, BOX *box, l_int32 lowthresh, l_int32 highthresh, l_int32 maxwidth, l_int32 factor, l_int32 scanflag, l_int32 *ploc);
LEPT_DLL extern NUMA *pixExtractOnLine(PIX *pixs, l_int32 x1, l_int32 y1, l_int32 x2, l_int32 y2, l_int32 factor);
LEPT_DLL extern l_float32 pixAverageOnLine(PIX *pixs, l_int32 x1, l_int32 y1, l_int32 x2, l_int32 y2, l_int32 factor);
LEPT_DLL extern NUMA *pixAverageIntensityProfile(PIX *pixs, l_float32 fract, l_int32 dir, l_int32 first, l_int32 last, l_int32 factor1, l_int32 factor2);
LEPT_DLL extern NUMA *pixReversalProfile(PIX *pixs, l_float32 fract, l_int32 dir, l_int32 first, l_int32 last, l_int32 minreversal, l_int32 factor1, l_int32 factor2);
LEPT_DLL extern PIX *pixRankRowTransform(PIX *pixs);
LEPT_DLL extern PIX *pixRankColumnTransform(PIX *pixs);
LEPT_DLL extern PIXA *pixaCreate(l_int32 n);
LEPT_DLL extern PIXA *pixaCreateFromPix(PIX *pixs, l_int32 n, l_int32 cellw, l_int32 cellh);
LEPT_DLL extern PIXA *pixaCreateFromBoxa(PIX *pixs, BOXA *boxa, l_int32 *pcropwarn);
LEPT_DLL extern PIXA *pixaSplitPix(PIX *pixs, l_int32 nx, l_int32 ny, l_int32 borderwidth, l_uint32 bordercolor);
LEPT_DLL extern void pixaDestroy(PIXA **ppixa);
LEPT_DLL extern PIXA *pixaCopy(PIXA *pixa, l_int32 copyflag);
LEPT_DLL extern l_int32 pixaAddPix(PIXA *pixa, PIX *pix, l_int32 copyflag);
LEPT_DLL extern l_int32 pixaExtendArray(PIXA *pixa);
LEPT_DLL extern l_int32 pixaExtendArrayToSize(PIXA *pixa, l_int32 size);
LEPT_DLL extern l_int32 pixaAddBox(PIXA *pixa, BOX *box, l_int32 copyflag);
LEPT_DLL extern l_int32 pixaGetCount(PIXA *pixa);
LEPT_DLL extern l_int32 pixaChangeRefcount(PIXA *pixa, l_int32 delta);
LEPT_DLL extern PIX *pixaGetPix(PIXA *pixa, l_int32 index, l_int32 accesstype);
LEPT_DLL extern l_int32 pixaGetPixDimensions(PIXA *pixa, l_int32 index, l_int32 *pw, l_int32 *ph, l_int32 *pd);
LEPT_DLL extern BOXA *pixaGetBoxa(PIXA *pixa, l_int32 accesstype);
LEPT_DLL extern l_int32 pixaGetBoxaCount(PIXA *pixa);
LEPT_DLL extern BOX *pixaGetBox(PIXA *pixa, l_int32 index, l_int32 accesstype);
LEPT_DLL extern l_int32 pixaGetBoxGeometry(PIXA *pixa, l_int32 index, l_int32 *px, l_int32 *py, l_int32 *pw, l_int32 *ph);
LEPT_DLL extern PIX ** pixaGetPixArray(PIXA *pixa);
LEPT_DLL extern l_int32 pixaReplacePix(PIXA *pixa, l_int32 index, PIX *pix, BOX *box);
LEPT_DLL extern l_int32 pixaInsertPix(PIXA *pixa, l_int32 index, PIX *pixs, BOX *box);
LEPT_DLL extern l_int32 pixaRemovePix(PIXA *pixa, l_int32 index);
LEPT_DLL extern l_int32 pixaInitFull(PIXA *pixa, PIX *pix, BOX *box);
LEPT_DLL extern l_int32 pixaClear(PIXA *pixa);
LEPT_DLL extern l_int32 pixaJoin(PIXA *pixad, PIXA *pixas, l_int32 istart, l_int32 iend);
LEPT_DLL extern PIXAA *pixaaCreate(l_int32 n);
LEPT_DLL extern PIXAA *pixaaCreateFromPixa(PIXA *pixa, l_int32 n, l_int32 type, l_int32 copyflag);
LEPT_DLL extern void pixaaDestroy(PIXAA **ppixaa);
LEPT_DLL extern l_int32 pixaaAddPixa(PIXAA *pixaa, PIXA *pixa, l_int32 copyflag);
LEPT_DLL extern l_int32 pixaaExtendArray(PIXAA *pixaa);
LEPT_DLL extern l_int32 pixaaAddBox(PIXAA *pixaa, BOX *box, l_int32 copyflag);
LEPT_DLL extern l_int32 pixaaGetCount(PIXAA *pixaa);
LEPT_DLL extern PIXA *pixaaGetPixa(PIXAA *pixaa, l_int32 index, l_int32 accesstype);
LEPT_DLL extern BOXA *pixaaGetBoxa(PIXAA *pixaa, l_int32 accesstype);
LEPT_DLL extern PIXA *pixaRead(const char *filename);
LEPT_DLL extern PIXA *pixaReadStream(FILE *fp);
LEPT_DLL extern l_int32 pixaWrite(const char *filename, PIXA *pixa);
LEPT_DLL extern l_int32 pixaWriteStream(FILE *fp, PIXA *pixa);
LEPT_DLL extern PIXAA *pixaaRead(const char *filename);
LEPT_DLL extern PIXAA *pixaaReadStream(FILE *fp);
LEPT_DLL extern l_int32 pixaaWrite(const char *filename, PIXAA *pixaa);
LEPT_DLL extern l_int32 pixaaWriteStream(FILE *fp, PIXAA *pixaa);
LEPT_DLL extern PIXACC *pixaccCreate(l_int32 w, l_int32 h, l_int32 negflag);
LEPT_DLL extern PIXACC *pixaccCreateWithPix(PIX *pix, l_int32 negflag);
LEPT_DLL extern void pixaccDestroy(PIXACC **ppixacc);
LEPT_DLL extern PIX *pixaccFinal(PIXACC *pixacc, l_int32 outdepth);
LEPT_DLL extern PIX *pixaccGetPix(PIXACC *pixacc);
LEPT_DLL extern l_int32 pixaccGetOffset(PIXACC *pixacc);
LEPT_DLL extern l_int32 pixaccAdd(PIXACC *pixacc, PIX *pix);
LEPT_DLL extern l_int32 pixaccSubtract(PIXACC *pixacc, PIX *pix);
LEPT_DLL extern l_int32 pixaccMultConst(PIXACC *pixacc, l_float32 factor);
LEPT_DLL extern l_int32 pixaccMultConstAccumulate(PIXACC *pixacc, PIX *pix, l_float32 factor);
LEPT_DLL extern PIX *pixSelectBySize(PIX *pixs, l_int32 width, l_int32 height, l_int32 connectivity, l_int32 type, l_int32 relation, l_int32 *pchanged);
LEPT_DLL extern PIXA *pixaSelectBySize(PIXA *pixas, l_int32 width, l_int32 height, l_int32 type, l_int32 relation, l_int32 *pchanged);
LEPT_DLL extern PIX *pixSelectByAreaPerimRatio(PIX *pixs, l_float32 thresh, l_int32 connectivity, l_int32 type, l_int32 *pchanged);
LEPT_DLL extern PIXA *pixaSelectByAreaPerimRatio(PIXA *pixas, l_float32 thresh, l_int32 type, l_int32 *pchanged);
LEPT_DLL extern PIX *pixSelectByAreaFraction(PIX *pixs, l_float32 thresh, l_int32 connectivity, l_int32 type, l_int32 *pchanged);
LEPT_DLL extern PIXA *pixaSelectByAreaFraction(PIXA *pixas, l_float32 thresh, l_int32 type, l_int32 *pchanged);
LEPT_DLL extern PIX *pixSelectByWidthHeightRatio(PIX *pixs, l_float32 thresh, l_int32 connectivity, l_int32 type, l_int32 *pchanged);
LEPT_DLL extern PIXA *pixaSelectByWidthHeightRatio(PIXA *pixas, l_float32 thresh, l_int32 type, l_int32 *pchanged);
LEPT_DLL extern PIXA *pixaSelectWithIndicator(PIXA *pixas, NUMA *na, l_int32 *pchanged);
LEPT_DLL extern l_int32 pixRemoveWithIndicator(PIX *pixs, PIXA *pixa, NUMA *na);
LEPT_DLL extern l_int32 pixAddWithIndicator(PIX *pixs, PIXA *pixa, NUMA *na);
LEPT_DLL extern PIXA *pixaSort(PIXA *pixas, l_int32 sorttype, l_int32 sortorder, NUMA **pnaindex, l_int32 copyflag);
LEPT_DLL extern PIXA *pixaBinSort(PIXA *pixas, l_int32 sorttype, l_int32 sortorder, NUMA **pnaindex, l_int32 copyflag);
LEPT_DLL extern PIXA *pixaSortByIndex(PIXA *pixas, NUMA *naindex, l_int32 copyflag);
LEPT_DLL extern PIXAA *pixaSort2dByIndex(PIXA *pixas, NUMAA *naa, l_int32 copyflag);
LEPT_DLL extern PIXA *pixaAddBorderGeneral(PIXA *pixad, PIXA *pixas, l_int32 left, l_int32 right, l_int32 top, l_int32 bot, l_uint32 val);
LEPT_DLL extern PIXA *pixaaFlattenToPixa(PIXAA *pixaa, NUMA **pnaindex, l_int32 copyflag);
LEPT_DLL extern l_int32 pixaSizeRange(PIXA *pixa, l_int32 *pminw, l_int32 *pminh, l_int32 *pmaxw, l_int32 *pmaxh);
LEPT_DLL extern PIXA *pixaClipToPix(PIXA *pixas, PIX *pixs);
LEPT_DLL extern l_int32 pixaAnyColormaps(PIXA *pixa, l_int32 *phascmap);
LEPT_DLL extern l_int32 pixaGetDepthInfo(PIXA *pixa, l_int32 *pmaxdepth, l_int32 *psame);
LEPT_DLL extern l_int32 pixaEqual(PIXA *pixa1, PIXA *pixa2, l_int32 maxdist, NUMA **pnaindex, l_int32 *psame);
LEPT_DLL extern PIX *pixaDisplay(PIXA *pixa, l_int32 w, l_int32 h);
LEPT_DLL extern PIX *pixaDisplayOnColor(PIXA *pixa, l_int32 w, l_int32 h, l_uint32 bgcolor);
LEPT_DLL extern PIX *pixaDisplayRandomCmap(PIXA *pixa, l_int32 w, l_int32 h);
LEPT_DLL extern PIX *pixaDisplayOnLattice(PIXA *pixa, l_int32 xspace, l_int32 yspace);
LEPT_DLL extern PIX *pixaDisplayUnsplit(PIXA *pixa, l_int32 nx, l_int32 ny, l_int32 borderwidth, l_uint32 bordercolor);
LEPT_DLL extern PIX *pixaDisplayTiled(PIXA *pixa, l_int32 maxwidth, l_int32 background, l_int32 spacing);
LEPT_DLL extern PIX *pixaDisplayTiledInRows(PIXA *pixa, l_int32 outdepth, l_int32 maxwidth, l_float32 scalefactor, l_int32 background, l_int32 spacing, l_int32 border);
LEPT_DLL extern PIX *pixaDisplayTiledAndScaled(PIXA *pixa, l_int32 outdepth, l_int32 tilewidth, l_int32 ncols, l_int32 background, l_int32 spacing, l_int32 border);
LEPT_DLL extern PIX *pixaaDisplay(PIXAA *pixaa, l_int32 w, l_int32 h);
LEPT_DLL extern PIX *pixaaDisplayByPixa(PIXAA *pixaa, l_int32 xspace, l_int32 yspace, l_int32 maxw);
LEPT_DLL extern PIXA *pixaaDisplayTiledAndScaled(PIXAA *pixaa, l_int32 outdepth, l_int32 tilewidth, l_int32 ncols, l_int32 background, l_int32 spacing, l_int32 border);
LEPT_DLL extern l_int32 pmsCreate(size_t minsize, size_t smallest, NUMA *numalloc, const char *logfile);
LEPT_DLL extern void pmsDestroy();
LEPT_DLL extern void *pmsCustomAlloc(size_t nbytes);
LEPT_DLL extern void pmsCustomDealloc(void *data);
LEPT_DLL extern void *pmsGetAlloc(size_t nbytes);
LEPT_DLL extern l_int32 pmsGetLevelForAlloc(size_t nbytes, l_int32 *plevel);
LEPT_DLL extern l_int32 pmsGetLevelForDealloc(void *data, l_int32 *plevel);
LEPT_DLL extern void pmsLogInfo();
LEPT_DLL extern l_int32 pixAddConstantGray(PIX *pixs, l_int32 val);
LEPT_DLL extern l_int32 pixMultConstantGray(PIX *pixs, l_float32 val);
LEPT_DLL extern PIX *pixAddGray(PIX *pixd, PIX *pixs1, PIX *pixs2);
LEPT_DLL extern PIX *pixSubtractGray(PIX *pixd, PIX *pixs1, PIX *pixs2);
LEPT_DLL extern PIX *pixThresholdToValue(PIX *pixd, PIX *pixs, l_int32 threshval, l_int32 setval);
LEPT_DLL extern PIX *pixInitAccumulate(l_int32 w, l_int32 h, l_uint32 offset);
LEPT_DLL extern PIX *pixFinalAccumulate(PIX *pixs, l_uint32 offset, l_int32 depth);
LEPT_DLL extern PIX *pixFinalAccumulateThreshold(PIX *pixs, l_uint32 offset, l_uint32 threshold);
LEPT_DLL extern l_int32 pixAccumulate(PIX *pixd, PIX *pixs, l_int32 op);
LEPT_DLL extern l_int32 pixMultConstAccumulate(PIX *pixs, l_float32 factor, l_uint32 offset);
LEPT_DLL extern PIX *pixAbsDifference(PIX *pixs1, PIX *pixs2);
LEPT_DLL extern PIX *pixMinOrMax(PIX *pixd, PIX *pixs1, PIX *pixs2, l_int32 type);
LEPT_DLL extern PIX *pixMaxDynamicRange(PIX *pixs, l_int32 type);
LEPT_DLL extern l_float32 *makeLogBase2Tab(void);
LEPT_DLL extern l_float32 getLogBase2(l_int32 val, l_float32 *logtab);
LEPT_DLL extern PIXC *pixcompCreateFromPix(PIX *pix, l_int32 comptype);
LEPT_DLL extern PIXC *pixcompCreateFromString(l_uint8 *data, size_t size, l_int32 copyflag);
LEPT_DLL extern PIXC *pixcompCreateFromFile(const char *filename, l_int32 comptype);
LEPT_DLL extern void pixcompDestroy(PIXC **ppixc);
LEPT_DLL extern l_int32 pixcompGetDimensions(PIXC *pixc, l_int32 *pw, l_int32 *ph, l_int32 *pd);
LEPT_DLL extern l_int32 pixcompDetermineFormat(l_int32 comptype, l_int32 d, l_int32 cmapflag, l_int32 *pformat);
LEPT_DLL extern PIX *pixCreateFromPixcomp(PIXC *pixc);
LEPT_DLL extern PIXAC *pixacompCreate(l_int32 n);
LEPT_DLL extern PIXAC *pixacompCreateInitialized(l_int32 n, PIX *pix, l_int32 comptype);
LEPT_DLL extern PIXAC *pixacompCreateFromPixa(PIXA *pixa, l_int32 comptype, l_int32 accesstype);
LEPT_DLL extern PIXAC *pixacompCreateFromFiles(const char *dirname, const char *substr, l_int32 comptype);
LEPT_DLL extern PIXAC *pixacompCreateFromSA(SARRAY *sa, l_int32 comptype);
LEPT_DLL extern void pixacompDestroy(PIXAC **ppixac);
LEPT_DLL extern l_int32 pixacompAddPix(PIXAC *pixac, PIX *pix, l_int32 comptype);
LEPT_DLL extern l_int32 pixacompAddPixcomp(PIXAC *pixac, PIXC *pixc);
LEPT_DLL extern l_int32 pixacompExtendArray(PIXAC *pixac);
LEPT_DLL extern l_int32 pixacompReplacePix(PIXAC *pixac, l_int32 index, PIX *pix, l_int32 comptype);
LEPT_DLL extern l_int32 pixacompReplacePixcomp(PIXAC *pixac, l_int32 index, PIXC *pixc);
LEPT_DLL extern l_int32 pixacompAddBox(PIXAC *pixac, BOX *box, l_int32 copyflag);
LEPT_DLL extern l_int32 pixacompGetCount(PIXAC *pixac);
LEPT_DLL extern PIXC *pixacompGetPixcomp(PIXAC *pixac, l_int32 index);
LEPT_DLL extern PIX *pixacompGetPix(PIXAC *pixac, l_int32 index);
LEPT_DLL extern l_int32 pixacompGetPixDimensions(PIXAC *pixac, l_int32 index, l_int32 *pw, l_int32 *ph, l_int32 *pd);
LEPT_DLL extern BOXA *pixacompGetBoxa(PIXAC *pixac, l_int32 accesstype);
LEPT_DLL extern l_int32 pixacompGetBoxaCount(PIXAC *pixac);
LEPT_DLL extern BOX *pixacompGetBox(PIXAC *pixac, l_int32 index, l_int32 accesstype);
LEPT_DLL extern l_int32 pixacompGetBoxGeometry(PIXAC *pixac, l_int32 index, l_int32 *px, l_int32 *py, l_int32 *pw, l_int32 *ph);
LEPT_DLL extern PIXA *pixaCreateFromPixacomp(PIXAC *pixac, l_int32 accesstype);
LEPT_DLL extern PIXAC *pixacompRead(const char *filename);
LEPT_DLL extern PIXAC *pixacompReadStream(FILE *fp);
LEPT_DLL extern l_int32 pixacompWrite(const char *filename, PIXAC *pixac);
LEPT_DLL extern l_int32 pixacompWriteStream(FILE *fp, PIXAC *pixac);
LEPT_DLL extern l_int32 pixacompWriteStreamInfo(FILE *fp, PIXAC *pixac, const char *text);
LEPT_DLL extern l_int32 pixcompWriteStreamInfo(FILE *fp, PIXC *pixc, const char *text);
LEPT_DLL extern PIX *pixacompDisplayTiledAndScaled(PIXAC *pixac, l_int32 outdepth, l_int32 tilewidth, l_int32 ncols, l_int32 background, l_int32 spacing, l_int32 border);
LEPT_DLL extern PIX *pixThreshold8(PIX *pixs, l_int32 d, l_int32 nlevels, l_int32 cmapflag);
LEPT_DLL extern PIX *pixRemoveColormap(PIX *pixs, l_int32 type);
LEPT_DLL extern l_int32 pixAddGrayColormap8(PIX *pixs);
LEPT_DLL extern PIX *pixAddMinimalGrayColormap8(PIX *pixs);
LEPT_DLL extern PIX *pixConvertRGBToLuminance(PIX *pixs);
LEPT_DLL extern PIX *pixConvertRGBToGray(PIX *pixs, l_float32 rwt, l_float32 gwt, l_float32 bwt);
LEPT_DLL extern PIX *pixConvertRGBToGrayFast(PIX *pixs);
LEPT_DLL extern PIX *pixConvertRGBToGrayMinMax(PIX *pixs, l_int32 type);
LEPT_DLL extern PIX *pixConvertGrayToColormap(PIX *pixs);
LEPT_DLL extern PIX *pixConvertGrayToColormap8(PIX *pixs, l_int32 mindepth);
LEPT_DLL extern PIX *pixColorizeGray(PIX *pixs, l_uint32 color, l_int32 cmapflag);
LEPT_DLL extern PIX *pixConvertRGBToColormap(PIX *pixs, l_int32 ditherflag);
LEPT_DLL extern l_int32 pixQuantizeIfFewColors(PIX *pixs, l_int32 maxcolors, l_int32 mingraycolors, l_int32 octlevel, PIX **ppixd);
LEPT_DLL extern PIX *pixConvert16To8(PIX *pixs, l_int32 whichbyte);
LEPT_DLL extern PIX *pixConvertGrayToFalseColor(PIX *pixs, l_float32 gamma);
LEPT_DLL extern PIX *pixUnpackBinary(PIX *pixs, l_int32 depth, l_int32 invert);
LEPT_DLL extern PIX *pixConvert1To16(PIX *pixd, PIX *pixs, l_uint16 val0, l_uint16 val1);
LEPT_DLL extern PIX *pixConvert1To32(PIX *pixd, PIX *pixs, l_uint32 val0, l_uint32 val1);
LEPT_DLL extern PIX *pixConvert1To2Cmap(PIX *pixs);
LEPT_DLL extern PIX *pixConvert1To2(PIX *pixd, PIX *pixs, l_int32 val0, l_int32 val1);
LEPT_DLL extern PIX *pixConvert1To4Cmap(PIX *pixs);
LEPT_DLL extern PIX *pixConvert1To4(PIX *pixd, PIX *pixs, l_int32 val0, l_int32 val1);
LEPT_DLL extern PIX *pixConvert1To8(PIX *pixd, PIX *pixs, l_uint8 val0, l_uint8 val1);
LEPT_DLL extern PIX *pixConvert2To8(PIX *pixs, l_uint8 val0, l_uint8 val1, l_uint8 val2, l_uint8 val3, l_int32 cmapflag);
LEPT_DLL extern PIX *pixConvert4To8(PIX *pixs, l_int32 cmapflag);
LEPT_DLL extern PIX *pixConvert8To16(PIX *pixs, l_int32 leftshift);
LEPT_DLL extern PIX *pixConvertTo1(PIX *pixs, l_int32 threshold);
LEPT_DLL extern PIX *pixConvertTo1BySampling(PIX *pixs, l_int32 factor, l_int32 threshold);
LEPT_DLL extern PIX *pixConvertTo8(PIX *pixs, l_int32 cmapflag);
LEPT_DLL extern PIX *pixConvertTo8BySampling(PIX *pixs, l_int32 factor, l_int32 cmapflag);
LEPT_DLL extern PIX *pixConvertTo16(PIX *pixs);
LEPT_DLL extern PIX *pixConvertTo32(PIX *pixs);
LEPT_DLL extern PIX *pixConvertTo32BySampling(PIX *pixs, l_int32 factor);
LEPT_DLL extern PIX *pixConvert8To32(PIX *pixs);
LEPT_DLL extern PIX *pixConvertTo8Or32(PIX *pixs, l_int32 copyflag, l_int32 warnflag);
LEPT_DLL extern PIX *pixConvert24To32(PIX *pixs);
LEPT_DLL extern PIX *pixConvert32To24(PIX *pixs);
LEPT_DLL extern PIX *pixConvertLossless(PIX *pixs, l_int32 d);
LEPT_DLL extern PIX *pixConvertForPSWrap(PIX *pixs);
LEPT_DLL extern PIX *pixConvertToSubpixelRGB(PIX *pixs, l_float32 scalex, l_float32 scaley, l_int32 order);
LEPT_DLL extern PIX *pixConvertGrayToSubpixelRGB(PIX *pixs, l_float32 scalex, l_float32 scaley, l_int32 order);
LEPT_DLL extern PIX *pixConvertColorToSubpixelRGB(PIX *pixs, l_float32 scalex, l_float32 scaley, l_int32 order);
LEPT_DLL extern PIXTILING *pixTilingCreate(PIX *pixs, l_int32 nx, l_int32 ny, l_int32 w, l_int32 h, l_int32 xoverlap, l_int32 yoverlap);
LEPT_DLL extern void pixTilingDestroy(PIXTILING **ppt);
LEPT_DLL extern l_int32 pixTilingGetCount(PIXTILING *pt, l_int32 *pnx, l_int32 *pny);
LEPT_DLL extern l_int32 pixTilingGetSize(PIXTILING *pt, l_int32 *pw, l_int32 *ph);
LEPT_DLL extern PIX *pixTilingGetTile(PIXTILING *pt, l_int32 i, l_int32 j);
LEPT_DLL extern l_int32 pixTilingNoStripOnPaint(PIXTILING *pt);
LEPT_DLL extern l_int32 pixTilingPaintTile(PIX *pixd, l_int32 i, l_int32 j, PIX *pixs, PIXTILING *pt);
LEPT_DLL extern PIX *pixReadStreamPng(FILE *fp);
LEPT_DLL extern l_int32 readHeaderPng(const char *filename, l_int32 *pwidth, l_int32 *pheight, l_int32 *pbps, l_int32 *pspp, l_int32 *piscmap);
LEPT_DLL extern l_int32 freadHeaderPng(FILE *fp, l_int32 *pwidth, l_int32 *pheight, l_int32 *pbps, l_int32 *pspp, l_int32 *piscmap);
LEPT_DLL extern l_int32 sreadHeaderPng(const l_uint8 *data, l_int32 *pwidth, l_int32 *pheight, l_int32 *pbps, l_int32 *pspp, l_int32 *piscmap);
LEPT_DLL extern l_int32 fgetPngResolution(FILE *fp, l_int32 *pxres, l_int32 *pyres);
*/
l_int32 pixWritePng(const char *filename, PIX *pix, l_float32 gamma);
/*
LEPT_DLL extern l_int32 pixWriteStreamPng(FILE *fp, PIX *pix, l_float32 gamma);
LEPT_DLL extern PIX *pixReadRGBAPng(const char *filename);
LEPT_DLL extern l_int32 pixWriteRGBAPng(const char *filename, PIX *pix);
LEPT_DLL extern void l_pngSetStrip16To8(l_int32 flag);
LEPT_DLL extern void l_pngSetStripAlpha(l_int32 flag);
LEPT_DLL extern void l_pngSetWriteAlpha(l_int32 flag);
LEPT_DLL extern void l_pngSetZlibCompression(l_int32 val);
LEPT_DLL extern PIX *pixReadMemPng(const l_uint8 *cdata, size_t size);
LEPT_DLL extern l_int32 pixWriteMemPng(l_uint8 **pdata, size_t *psize, PIX *pix, l_float32 gamma);
LEPT_DLL extern PIX *pixReadStreamPnm(FILE *fp);
LEPT_DLL extern l_int32 readHeaderPnm(const char *filename, PIX **ppix, l_int32 *pwidth, l_int32 *pheight, l_int32 *pdepth, l_int32 *ptype, l_int32 *pbps, l_int32 *pspp);
LEPT_DLL extern l_int32 freadHeaderPnm(FILE *fp, PIX **ppix, l_int32 *pwidth, l_int32 *pheight, l_int32 *pdepth, l_int32 *ptype, l_int32 *pbps, l_int32 *pspp);
LEPT_DLL extern l_int32 pixWriteStreamPnm(FILE *fp, PIX *pix);
LEPT_DLL extern l_int32 pixWriteStreamAsciiPnm(FILE *fp, PIX *pix);
LEPT_DLL extern PIX *pixReadMemPnm(const l_uint8 *cdata, size_t size);
LEPT_DLL extern l_int32 sreadHeaderPnm(const l_uint8 *cdata, size_t size, l_int32 *pwidth, l_int32 *pheight, l_int32 *pdepth, l_int32 *ptype, l_int32 *pbps, l_int32 *pspp);
LEPT_DLL extern l_int32 pixWriteMemPnm(l_uint8 **pdata, size_t *psize, PIX *pix);
LEPT_DLL extern PIX *pixProjectiveSampledPta(PIX *pixs, PTA *ptad, PTA *ptas, l_int32 incolor);
LEPT_DLL extern PIX *pixProjectiveSampled(PIX *pixs, l_float32 *vc, l_int32 incolor);
LEPT_DLL extern PIX *pixProjectivePta(PIX *pixs, PTA *ptad, PTA *ptas, l_int32 incolor);
LEPT_DLL extern PIX *pixProjective(PIX *pixs, l_float32 *vc, l_int32 incolor);
LEPT_DLL extern PIX *pixProjectivePtaColor(PIX *pixs, PTA *ptad, PTA *ptas, l_uint32 colorval);
LEPT_DLL extern PIX *pixProjectiveColor(PIX *pixs, l_float32 *vc, l_uint32 colorval);
LEPT_DLL extern PIX *pixProjectivePtaGray(PIX *pixs, PTA *ptad, PTA *ptas, l_uint8 grayval);
LEPT_DLL extern PIX *pixProjectiveGray(PIX *pixs, l_float32 *vc, l_uint8 grayval);
LEPT_DLL extern PIX *pixProjectivePtaWithAlpha(PIX *pixs, PTA *ptad, PTA *ptas, PIX *pixg, l_float32 fract, l_int32 border);
LEPT_DLL extern PIX *pixProjectivePtaGammaXform(PIX *pixs, l_float32 gamma, PTA *ptad, PTA *ptas, l_float32 fract, l_int32 border);
LEPT_DLL extern l_int32 getProjectiveXformCoeffs(PTA *ptas, PTA *ptad, l_float32 **pvc);
LEPT_DLL extern l_int32 projectiveXformSampledPt(l_float32 *vc, l_int32 x, l_int32 y, l_int32 *pxp, l_int32 *pyp);
LEPT_DLL extern l_int32 projectiveXformPt(l_float32 *vc, l_int32 x, l_int32 y, l_float32 *pxp, l_float32 *pyp);
LEPT_DLL extern l_int32 convertFilesToPS(const char *dirin, const char *substr, l_int32 res, const char *fileout);
LEPT_DLL extern l_int32 sarrayConvertFilesToPS(SARRAY *sa, l_int32 res, const char *fileout);
LEPT_DLL extern l_int32 convertFilesFittedToPS(const char *dirin, const char *substr, l_float32 xpts, l_float32 ypts, const char *fileout);
LEPT_DLL extern l_int32 sarrayConvertFilesFittedToPS(SARRAY *sa, l_float32 xpts, l_float32 ypts, const char *fileout);
LEPT_DLL extern l_int32 writeImageCompressedToPSFile(const char *filein, const char *fileout, l_int32 res, l_int32 *pfirstfile, l_int32 *pindex);
LEPT_DLL extern l_int32 convertSegmentedPagesToPS(const char *pagedir, const char *pagestr, const char *maskdir, const char *maskstr, l_int32 numpre, l_int32 numpost, l_int32 maxnum, l_float32 textscale, l_float32 imagescale, l_int32 threshold, const char *fileout);
LEPT_DLL extern l_int32 pixWriteSegmentedPageToPS(PIX *pixs, PIX *pixm, l_float32 textscale, l_float32 imagescale, l_int32 threshold, l_int32 pageno, const char *fileout);
LEPT_DLL extern l_int32 pixWriteMixedToPS(PIX *pixb, PIX *pixc, l_float32 scale, l_int32 pageno, const char *fileout);
LEPT_DLL extern l_int32 convertToPSEmbed(const char *filein, const char *fileout, l_int32 level);
LEPT_DLL extern l_int32 pixaWriteCompressedToPS(PIXA *pixa, const char *fileout, l_int32 res, l_int32 level);
LEPT_DLL extern l_int32 pixWritePSEmbed(const char *filein, const char *fileout);
LEPT_DLL extern l_int32 pixWriteStreamPS(FILE *fp, PIX *pix, BOX *box, l_int32 res, l_float32 scale);
LEPT_DLL extern char *pixWriteStringPS(PIX *pixs, BOX *box, l_int32 res, l_float32 scale);
LEPT_DLL extern char *generateUncompressedPS(char *hexdata, l_int32 w, l_int32 h, l_int32 d, l_int32 psbpl, l_int32 bps, l_float32 xpt, l_float32 ypt, l_float32 wpt, l_float32 hpt, l_int32 boxflag);
LEPT_DLL extern void getScaledParametersPS(BOX *box, l_int32 wpix, l_int32 hpix, l_int32 res, l_float32 scale, l_float32 *pxpt, l_float32 *pypt, l_float32 *pwpt, l_float32 *phpt);
LEPT_DLL extern void convertByteToHexAscii(l_uint8 byteval, char *pnib1, char *pnib2);
LEPT_DLL extern l_int32 convertJpegToPSEmbed(const char *filein, const char *fileout);
LEPT_DLL extern l_int32 convertJpegToPS(const char *filein, const char *fileout, const char *operation, l_int32 x, l_int32 y, l_int32 res, l_float32 scale, l_int32 pageno, l_int32 endpage);
LEPT_DLL extern l_int32 convertJpegToPSString(const char *filein, char **poutstr, l_int32 *pnbytes, l_int32 x, l_int32 y, l_int32 res, l_float32 scale, l_int32 pageno, l_int32 endpage);
LEPT_DLL extern char *generateJpegPS(const char *filein, L_COMPRESSED_DATA *cid, l_float32 xpt, l_float32 ypt, l_float32 wpt, l_float32 hpt, l_int32 pageno, l_int32 endpage);
LEPT_DLL extern L_COMPRESSED_DATA *pixGenerateJpegData(PIX *pixs, l_int32 ascii85flag, l_int32 quality);
LEPT_DLL extern L_COMPRESSED_DATA *l_generateJpegData(const char *fname, l_int32 ascii85flag);
LEPT_DLL extern void compressed_dataDestroy(L_COMPRESSED_DATA **pcid);
LEPT_DLL extern l_int32 convertG4ToPSEmbed(const char *filein, const char *fileout);
LEPT_DLL extern l_int32 convertG4ToPS(const char *filein, const char *fileout, const char *operation, l_int32 x, l_int32 y, l_int32 res, l_float32 scale, l_int32 pageno, l_int32 maskflag, l_int32 endpage);
LEPT_DLL extern l_int32 convertG4ToPSString(const char *filein, char **poutstr, l_int32 *pnbytes, l_int32 x, l_int32 y, l_int32 res, l_float32 scale, l_int32 pageno, l_int32 maskflag, l_int32 endpage);
LEPT_DLL extern char *generateG4PS(const char *filein, L_COMPRESSED_DATA *cid, l_float32 xpt, l_float32 ypt, l_float32 wpt, l_float32 hpt, l_int32 maskflag, l_int32 pageno, l_int32 endpage);
LEPT_DLL extern L_COMPRESSED_DATA *pixGenerateG4Data(PIX *pixs, l_int32 ascii85flag);
LEPT_DLL extern L_COMPRESSED_DATA *l_generateG4Data(const char *fname, l_int32 ascii85flag);
LEPT_DLL extern l_int32 convertTiffMultipageToPS(const char *filein, const char *fileout, const char *tempfile, l_float32 fillfract);
LEPT_DLL extern l_int32 convertFlateToPSEmbed(const char *filein, const char *fileout);
LEPT_DLL extern l_int32 convertFlateToPS(const char *filein, const char *fileout, const char *operation, l_int32 x, l_int32 y, l_int32 res, l_float32 scale, l_int32 pageno, l_int32 endpage);
LEPT_DLL extern l_int32 convertFlateToPSString(const char *filein, char **poutstr, l_int32 *pnbytes, l_int32 x, l_int32 y, l_int32 res, l_float32 scale, l_int32 pageno, l_int32 endpage);
LEPT_DLL extern char *generateFlatePS(const char *filein, L_COMPRESSED_DATA *cid, l_float32 xpt, l_float32 ypt, l_float32 wpt, l_float32 hpt, l_int32 pageno, l_int32 endpage);
LEPT_DLL extern L_COMPRESSED_DATA *l_generateFlateData(const char *fname, l_int32 ascii85flag);
LEPT_DLL extern L_COMPRESSED_DATA *pixGenerateFlateData(PIX *pixs, l_int32 ascii85flag);
LEPT_DLL extern l_int32 pixWriteMemPS(l_uint8 **pdata, size_t *psize, PIX *pix, BOX *box, l_int32 res, l_float32 scale);
LEPT_DLL extern l_int32 getResLetterPage(l_int32 w, l_int32 h, l_float32 fillfract);
LEPT_DLL extern l_int32 getResA4Page(l_int32 w, l_int32 h, l_float32 fillfract);
LEPT_DLL extern char *encodeAscii85(l_uint8 *inarray, l_int32 insize, l_int32 *poutsize);
LEPT_DLL extern l_uint8 *decodeAscii85(char *ina, l_int32 insize, l_int32 *poutsize);
LEPT_DLL extern void l_psWriteBoundingBox(l_int32 flag);
*/
PTA *ptaCreate(l_int32 n);
//PTA *ptaCreateFromNuma(NUMA *nax, NUMA *nay);
void ptaDestroy(PTA **ppta);
PTA *ptaCopy(PTA *pta);
PTA *ptaClone(PTA *pta);
l_int32 ptaEmpty(PTA *pta);
l_int32 ptaAddPt(PTA *pta, l_float32 x, l_float32 y);
l_int32 ptaExtendArrays(PTA *pta);
l_int32 ptaGetRefcount(PTA *pta);
l_int32 ptaChangeRefcount(PTA *pta, l_int32 delta);
l_int32 ptaGetCount(PTA *pta);
l_int32 ptaGetPt(PTA *pta, l_int32 index, l_float32 *px, l_float32 *py);
l_int32 ptaGetIPt(PTA *pta, l_int32 index, l_int32 *px, l_int32 *py);
l_int32 ptaSetPt(PTA *pta, l_int32 index, l_float32 x, l_float32 y);
//l_int32 ptaGetArrays(PTA *pta, NUMA **pnax, NUMA **pnay);
/*
LEPT_DLL extern PTA *ptaRead(const char *filename);
LEPT_DLL extern PTA *ptaReadStream(FILE *fp);
LEPT_DLL extern l_int32 ptaWrite(const char *filename, PTA *pta, l_int32 type);
LEPT_DLL extern l_int32 ptaWriteStream(FILE *fp, PTA *pta, l_int32 type);
LEPT_DLL extern PTAA *ptaaCreate(l_int32 n);
LEPT_DLL extern void ptaaDestroy(PTAA **pptaa);
LEPT_DLL extern l_int32 ptaaAddPta(PTAA *ptaa, PTA *pta, l_int32 copyflag);
LEPT_DLL extern l_int32 ptaaExtendArray(PTAA *ptaa);
LEPT_DLL extern l_int32 ptaaGetCount(PTAA *ptaa);
LEPT_DLL extern PTA *ptaaGetPta(PTAA *ptaa, l_int32 index, l_int32 accessflag);
LEPT_DLL extern l_int32 ptaaGetPt(PTAA *ptaa, l_int32 ipta, l_int32 jpt, l_float32 *px, l_float32 *py);
LEPT_DLL extern PTAA *ptaaRead(const char *filename);
LEPT_DLL extern PTAA *ptaaReadStream(FILE *fp);
LEPT_DLL extern l_int32 ptaaWrite(const char *filename, PTAA *ptaa, l_int32 type);
LEPT_DLL extern l_int32 ptaaWriteStream(FILE *fp, PTAA *ptaa, l_int32 type);
LEPT_DLL extern PTA *ptaSubsample(PTA *ptas, l_int32 subfactor);
LEPT_DLL extern l_int32 ptaJoin(PTA *ptad, PTA *ptas, l_int32 istart, l_int32 iend);
LEPT_DLL extern PTA *ptaReverse(PTA *ptas, l_int32 type);
LEPT_DLL extern PTA *ptaCyclicPerm(PTA *ptas, l_int32 xs, l_int32 ys);
LEPT_DLL extern PTA *ptaSort(PTA *ptas, l_int32 sorttype, l_int32 sortorder, NUMA **pnaindex);
LEPT_DLL extern PTA *ptaRemoveDuplicates(PTA *ptas, l_uint32 factor);
LEPT_DLL extern PTAA *ptaaSortByIndex(PTAA *ptaas, NUMA *naindex);
LEPT_DLL extern BOX *ptaGetBoundingRegion(PTA *pta);
LEPT_DLL extern l_int32 ptaGetRange(PTA *pta, l_float32 *pminx, l_float32 *pmaxx, l_float32 *pminy, l_float32 *pmaxy);
LEPT_DLL extern PTA *ptaGetInsideBox(PTA *ptas, BOX *box);
LEPT_DLL extern PTA *pixFindCornerPixels(PIX *pixs);
LEPT_DLL extern l_int32 ptaContainsPt(PTA *pta, l_int32 x, l_int32 y);
LEPT_DLL extern l_int32 ptaTestIntersection(PTA *pta1, PTA *pta2);
LEPT_DLL extern PTA *ptaTransform(PTA *ptas, l_int32 shiftx, l_int32 shifty, l_float32 scalex, l_float32 scaley);
LEPT_DLL extern l_int32 ptaGetLinearLSF(PTA *pta, l_float32 *pa, l_float32 *pb, NUMA **pnafit);
LEPT_DLL extern l_int32 ptaGetQuadraticLSF(PTA *pta, l_float32 *pa, l_float32 *pb, l_float32 *pc, NUMA **pnafit);
LEPT_DLL extern l_int32 ptaGetCubicLSF(PTA *pta, l_float32 *pa, l_float32 *pb, l_float32 *pc, l_float32 *pd, NUMA **pnafit);
LEPT_DLL extern l_int32 ptaGetQuarticLSF(PTA *pta, l_float32 *pa, l_float32 *pb, l_float32 *pc, l_float32 *pd, l_float32 *pe, NUMA **pnafit);
LEPT_DLL extern l_int32 applyLinearFit(l_float32 a, l_float32 b, l_float32 x, l_float32 *py);
LEPT_DLL extern l_int32 applyQuadraticFit(l_float32 a, l_float32 b, l_float32 c, l_float32 x, l_float32 *py);
LEPT_DLL extern l_int32 applyCubicFit(l_float32 a, l_float32 b, l_float32 c, l_float32 d, l_float32 x, l_float32 *py);
LEPT_DLL extern l_int32 applyQuarticFit(l_float32 a, l_float32 b, l_float32 c, l_float32 d, l_float32 e, l_float32 x, l_float32 *py);
LEPT_DLL extern l_int32 pixPlotAlongPta(PIX *pixs, PTA *pta, l_int32 outformat, const char *title);
LEPT_DLL extern PTA *ptaGetPixelsFromPix(PIX *pixs, BOX *box);
LEPT_DLL extern PIX *pixGenerateFromPta(PTA *pta, l_int32 w, l_int32 h);
LEPT_DLL extern PTA *ptaGetBoundaryPixels(PIX *pixs, l_int32 type);
LEPT_DLL extern PTAA *ptaaGetBoundaryPixels(PIX *pixs, l_int32 type, l_int32 connectivity, BOXA **pboxa, PIXA **ppixa);
LEPT_DLL extern PIX *pixDisplayPta(PIX *pixd, PIX *pixs, PTA *pta);
LEPT_DLL extern PIX *pixDisplayPtaa(PIX *pixs, PTAA *ptaa);
LEPT_DLL extern L_PTRA *ptraCreate(l_int32 n);
LEPT_DLL extern void ptraDestroy(L_PTRA **ppa, l_int32 freeflag, l_int32 warnflag);
LEPT_DLL extern l_int32 ptraAdd(L_PTRA *pa, void *item);
LEPT_DLL extern l_int32 ptraExtendArray(L_PTRA *pa);
LEPT_DLL extern l_int32 ptraInsert(L_PTRA *pa, l_int32 index, void *item, l_int32 shiftflag);
LEPT_DLL extern void *ptraGetHandle(L_PTRA *pa, l_int32 index);
LEPT_DLL extern void *ptraRemove(L_PTRA *pa, l_int32 index, l_int32 flag);
LEPT_DLL extern void *ptraRemoveLast(L_PTRA *pa);
LEPT_DLL extern void *ptraReplace(L_PTRA *pa, l_int32 index, void *item, l_int32 freeflag);
LEPT_DLL extern l_int32 ptraSwap(L_PTRA *pa, l_int32 index1, l_int32 index2);
LEPT_DLL extern l_int32 ptraCompactArray(L_PTRA *pa);
LEPT_DLL extern l_int32 ptraReverse(L_PTRA *pa);
LEPT_DLL extern l_int32 ptraJoin(L_PTRA *pa1, L_PTRA *pa2);
LEPT_DLL extern l_int32 ptraGetMaxIndex(L_PTRA *pa, l_int32 *pmaxindex);
LEPT_DLL extern l_int32 ptraGetActualCount(L_PTRA *pa, l_int32 *pcount);
LEPT_DLL extern void *ptraGetPtrToItem(L_PTRA *pa, l_int32 index);
LEPT_DLL extern L_PTRAA *ptraaCreate(l_int32 n);
LEPT_DLL extern void ptraaDestroy(L_PTRAA **ppaa, l_int32 freeflag, l_int32 warnflag);
LEPT_DLL extern l_int32 ptraaGetSize(L_PTRAA *paa, l_int32 *psize);
LEPT_DLL extern l_int32 ptraaInsertPtra(L_PTRAA *paa, l_int32 index, L_PTRA *pa);
LEPT_DLL extern L_PTRA *ptraaGetPtra(L_PTRAA *paa, l_int32 index, l_int32 accessflag);
LEPT_DLL extern L_PTRA *ptraaFlattenToPtra(L_PTRAA *paa);
LEPT_DLL extern NUMA *numaGetBinSortIndex(NUMA *nas, l_int32 sortorder);
LEPT_DLL extern l_int32 pixQuadtreeMean(PIX *pixs, l_int32 nlevels, PIX *pix_ma, FPIXA **pfpixa);
LEPT_DLL extern l_int32 pixQuadtreeVariance(PIX *pixs, l_int32 nlevels, PIX *pix_ma, DPIX *dpix_msa, FPIXA **pfpixa_v, FPIXA **pfpixa_rv);
LEPT_DLL extern l_int32 pixMeanInRectangle(PIX *pixs, BOX *box, PIX *pixma, l_float32 *pval);
LEPT_DLL extern l_int32 pixVarianceInRectangle(PIX *pixs, BOX *box, PIX *pix_ma, DPIX *dpix_msa, l_float32 *pvar, l_float32 *prvar);
LEPT_DLL extern BOXAA *boxaaQuadtreeRegions(l_int32 w, l_int32 h, l_int32 nlevels);
LEPT_DLL extern l_int32 quadtreeGetParent(FPIXA *fpixa, l_int32 level, l_int32 x, l_int32 y, l_float32 *pval);
LEPT_DLL extern l_int32 quadtreeGetChildren(FPIXA *fpixa, l_int32 level, l_int32 x, l_int32 y, l_float32 *pval00, l_float32 *pval10, l_float32 *pval01, l_float32 *pval11);
LEPT_DLL extern l_int32 quadtreeMaxLevels(l_int32 w, l_int32 h);
LEPT_DLL extern PIX *fpixaDisplayQuadtree(FPIXA *fpixa, l_int32 factor);
LEPT_DLL extern L_QUEUE *lqueueCreate(l_int32 nalloc);
LEPT_DLL extern void lqueueDestroy(L_QUEUE **plq, l_int32 freeflag);
LEPT_DLL extern l_int32 lqueueAdd(L_QUEUE *lq, void *item);
LEPT_DLL extern l_int32 lqueueExtendArray(L_QUEUE *lq);
LEPT_DLL extern void *lqueueRemove(L_QUEUE *lq);
LEPT_DLL extern l_int32 lqueueGetCount(L_QUEUE *lq);
LEPT_DLL extern l_int32 lqueuePrint(FILE *fp, L_QUEUE *lq);
*/
PIX *pixRankFilter(PIX *pixs, l_int32 wf, l_int32 hf, l_float32 rank);
PIX *pixRankFilterRGB(PIX *pixs, l_int32 wf, l_int32 hf, l_float32 rank);
PIX *pixRankFilterGray(PIX *pixs, l_int32 wf, l_int32 hf, l_float32 rank);
PIX *pixMedianFilter(PIX *pixs, l_int32 wf, l_int32 hf);
/*
LEPT_DLL extern SARRAY *pixProcessBarcodes(PIX *pixs, l_int32 format, l_int32 method, SARRAY **psaw, l_int32 debugflag);
LEPT_DLL extern PIXA *pixExtractBarcodes(PIX *pixs, l_int32 debugflag);
LEPT_DLL extern SARRAY *pixReadBarcodes(PIXA *pixa, l_int32 format, l_int32 method, SARRAY **psaw, l_int32 debugflag);
LEPT_DLL extern NUMA *pixReadBarcodeWidths(PIX *pixs, l_int32 method, l_int32 debugflag);
LEPT_DLL extern BOXA *pixLocateBarcodes(PIX *pixs, l_int32 thresh, PIX **ppixb, PIX **ppixm);
LEPT_DLL extern PIX *pixDeskewBarcode(PIX *pixs, PIX *pixb, BOX *box, l_int32 margin, l_int32 threshold, l_float32 *pangle, l_float32 *pconf);
LEPT_DLL extern NUMA *pixExtractBarcodeWidths1(PIX *pixs, l_float32 thresh, l_float32 binfract, NUMA **pnaehist, NUMA **pnaohist, l_int32 debugflag);
LEPT_DLL extern NUMA *pixExtractBarcodeWidths2(PIX *pixs, l_float32 thresh, l_float32 *pwidth, NUMA **pnac, l_int32 debugflag);
LEPT_DLL extern NUMA *pixExtractBarcodeCrossings(PIX *pixs, l_float32 thresh, l_int32 debugflag);
LEPT_DLL extern NUMA *numaQuantizeCrossingsByWidth(NUMA *nas, l_float32 binfract, NUMA **pnaehist, NUMA **pnaohist, l_int32 debugflag);
LEPT_DLL extern NUMA *numaQuantizeCrossingsByWindow(NUMA *nas, l_float32 ratio, l_float32 *pwidth, l_float32 *pfirstloc, NUMA **pnac, l_int32 debugflag);
*/
PIXA *pixaReadFiles(const char *dirname, const char *substr);
//PIXA *pixaReadFilesSA(SARRAY *sa);
PIX *pixRead(const char *filename);
PIX *pixReadWithHint(const char *filename, l_int32 hint);
//PIX *pixReadIndexed(SARRAY *sa, l_int32 index);
PIX *pixReadStream(void *fp, l_int32 hint);
l_int32 pixReadHeader(const char *filename, l_int32 *pformat, l_int32 *pw, l_int32 *ph, l_int32 *pbps, l_int32 *pspp, l_int32 *piscmap);
l_int32 findFileFormat(const char *filename, l_int32 *pformat);
l_int32 findFileFormatStream(void *fp, l_int32 *pformat);
l_int32 findFileFormatBuffer(const l_uint8 *buf, l_int32 *pformat);
l_int32 fileFormatIsTiff(void *fp);
PIX *pixReadMem(const l_uint8 *data, size_t size);
l_int32 pixReadHeaderMem(const l_uint8 *data, size_t size, l_int32 *pformat, l_int32 *pw, l_int32 *ph, l_int32 *pbps, l_int32 *pspp, l_int32 *piscmap);
/*
LEPT_DLL extern l_int32 ioFormatTest(const char *filename);
LEPT_DLL extern l_int32 regTestSetup(l_int32 argc, char **argv, L_REGPARAMS **prp);
LEPT_DLL extern l_int32 regTestCleanup(L_REGPARAMS *rp);
LEPT_DLL extern l_int32 regTestComparePix(L_REGPARAMS *rp, PIX *pix1, PIX *pix2);
LEPT_DLL extern l_int32 regTestCompareSimilarPix(L_REGPARAMS *rp, PIX *pix1, PIX *pix2, l_int32 mindiff, l_float32 maxfract, l_int32 printstats);
LEPT_DLL extern l_int32 regTestCheckFile(L_REGPARAMS *rp, const char *localname);
LEPT_DLL extern l_int32 regTestCompareFiles(L_REGPARAMS *rp, l_int32 index1, l_int32 index2);
LEPT_DLL extern l_int32 regTestWritePixAndCheck(L_REGPARAMS *rp, PIX *pix, l_int32 format);
*/
l_int32 pixRasterop(PIX *pixd, l_int32 dx, l_int32 dy, l_int32 dw, l_int32 dh, l_int32 op, PIX *pixs, l_int32 sx, l_int32 sy);
/*
LEPT_DLL extern l_int32 pixRasteropVip(PIX *pixd, l_int32 bx, l_int32 bw, l_int32 vshift, l_int32 incolor);
LEPT_DLL extern l_int32 pixRasteropHip(PIX *pixd, l_int32 by, l_int32 bh, l_int32 hshift, l_int32 incolor);
LEPT_DLL extern PIX *pixTranslate(PIX *pixd, PIX *pixs, l_int32 hshift, l_int32 vshift, l_int32 incolor);
LEPT_DLL extern l_int32 pixRasteropIP(PIX *pixd, l_int32 hshift, l_int32 vshift, l_int32 incolor);
LEPT_DLL extern l_int32 pixRasteropFullImage(PIX *pixd, PIX *pixs, l_int32 op);
LEPT_DLL extern void rasteropVipLow(l_uint32 *data, l_int32 pixw, l_int32 pixh, l_int32 depth, l_int32 wpl, l_int32 x, l_int32 w, l_int32 shift);
LEPT_DLL extern void rasteropHipLow(l_uint32 *data, l_int32 pixh, l_int32 depth, l_int32 wpl, l_int32 y, l_int32 h, l_int32 shift);
LEPT_DLL extern void shiftDataHorizontalLow(l_uint32 *datad, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_int32 shift);
LEPT_DLL extern void rasteropUniLow(l_uint32 *datad, l_int32 dpixw, l_int32 dpixh, l_int32 depth, l_int32 dwpl, l_int32 dx, l_int32 dy, l_int32 dw, l_int32 dh, l_int32 op);
LEPT_DLL extern void rasteropLow(l_uint32 *datad, l_int32 dpixw, l_int32 dpixh, l_int32 depth, l_int32 dwpl, l_int32 dx, l_int32 dy, l_int32 dw, l_int32 dh, l_int32 op, l_uint32 *datas, l_int32 spixw, l_int32 spixh, l_int32 swpl, l_int32 sx, l_int32 sy);
*/
PIX *pixRotate(PIX *pixs, l_float32 angle, l_int32 type, l_int32 incolor, l_int32 width, l_int32 height);
PIX *pixEmbedForRotation(PIX *pixs, l_float32 angle, l_int32 incolor, l_int32 width, l_int32 height);
PIX *pixRotateBySampling(PIX *pixs, l_int32 xcen, l_int32 ycen, l_float32 angle, l_int32 incolor);
PIX *pixRotateBinaryNice(PIX *pixs, l_float32 angle, l_int32 incolor);
PIX *pixRotateWithAlpha(PIX *pixs, l_float32 angle, PIX *pixg, l_float32 fract);
PIX *pixRotateGammaXform(PIX *pixs, l_float32 gamma, l_float32 angle, l_float32 fract);
PIX *pixRotateAM(PIX *pixs, l_float32 angle, l_int32 incolor);
PIX *pixRotateAMColor(PIX *pixs, l_float32 angle, l_uint32 colorval);
PIX *pixRotateAMGray(PIX *pixs, l_float32 angle, l_uint8 grayval);
PIX *pixRotateAMCorner(PIX *pixs, l_float32 angle, l_int32 incolor);
PIX *pixRotateAMColorCorner(PIX *pixs, l_float32 angle, l_uint32 fillval);
PIX *pixRotateAMGrayCorner(PIX *pixs, l_float32 angle, l_uint8 grayval);
PIX *pixRotateAMColorFast(PIX *pixs, l_float32 angle, l_uint32 colorval);
/*
LEPT_DLL extern void rotateAMColorLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_float32 angle, l_uint32 colorval );
LEPT_DLL extern void rotateAMGrayLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_float32 angle, l_uint8 grayval );
LEPT_DLL extern void rotateAMColorCornerLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_float32 angle, l_uint32 colorval );
LEPT_DLL extern void rotateAMGrayCornerLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_float32 angle, l_uint8 grayval );
LEPT_DLL extern void rotateAMColorFastLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_float32 angle, l_uint32 colorval );
*/
PIX *pixRotateOrth ( PIX *pixs, l_int32 quads);
PIX *pixRotate180 ( PIX *pixd, PIX *pixs);
PIX *pixRotate90 ( PIX *pixs, l_int32 direction);
PIX *pixFlipLR ( PIX *pixd, PIX *pixs);
PIX *pixFlipTB ( PIX *pixd, PIX *pixs);
/*
LEPT_DLL extern void rotate90Low ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 d, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_int32 direction );
LEPT_DLL extern void flipLRLow ( l_uint32 *data, l_int32 w, l_int32 h, l_int32 d, l_int32 wpl, l_uint8 *tab, l_uint32 *buffer );
LEPT_DLL extern void flipTBLow ( l_uint32 *data, l_int32 h, l_int32 wpl, l_uint32 *buffer );
LEPT_DLL extern l_uint8 * makeReverseByteTab1 ( void );
LEPT_DLL extern l_uint8 * makeReverseByteTab2 ( void );
LEPT_DLL extern l_uint8 * makeReverseByteTab4 ( void );
LEPT_DLL extern PIX * pixRotateShear ( PIX *pixs, l_int32 xcen, l_int32 ycen, l_float32 angle, l_int32 incolor );
LEPT_DLL extern PIX * pixRotate2Shear ( PIX *pixs, l_int32 xcen, l_int32 ycen, l_float32 angle, l_int32 incolor );
LEPT_DLL extern PIX * pixRotate3Shear ( PIX *pixs, l_int32 xcen, l_int32 ycen, l_float32 angle, l_int32 incolor );
LEPT_DLL extern l_int32 pixRotateShearIP ( PIX *pixs, l_int32 xcen, l_int32 ycen, l_float32 angle, l_int32 incolor );
LEPT_DLL extern PIX * pixRotateShearCenter ( PIX *pixs, l_float32 angle, l_int32 incolor );
LEPT_DLL extern l_int32 pixRotateShearCenterIP ( PIX *pixs, l_float32 angle, l_int32 incolor );
LEPT_DLL extern PIX * pixRunlengthTransform ( PIX *pixs, l_int32 color, l_int32 direction, l_int32 depth );
LEPT_DLL extern l_int32 pixFindHorizontalRuns ( PIX *pix, l_int32 y, l_int32 *xstart, l_int32 *xend, l_int32 *pn );
LEPT_DLL extern l_int32 pixFindVerticalRuns ( PIX *pix, l_int32 x, l_int32 *ystart, l_int32 *yend, l_int32 *pn );
LEPT_DLL extern l_int32 runlengthMembershipOnLine ( l_int32 *buffer, l_int32 size, l_int32 depth, l_int32 *start, l_int32 *end, l_int32 n );
LEPT_DLL extern l_int32 * makeMSBitLocTab ( l_int32 bitval );
LEPT_DLL extern SARRAY * sarrayCreate ( l_int32 n );
LEPT_DLL extern SARRAY * sarrayCreateInitialized ( l_int32 n, char *initstr );
LEPT_DLL extern SARRAY * sarrayCreateWordsFromString ( const char *string );
LEPT_DLL extern SARRAY * sarrayCreateLinesFromString ( char *string, l_int32 blankflag );
LEPT_DLL extern void sarrayDestroy ( SARRAY **psa );
LEPT_DLL extern SARRAY * sarrayCopy ( SARRAY *sa );
LEPT_DLL extern SARRAY * sarrayClone ( SARRAY *sa );
LEPT_DLL extern l_int32 sarrayAddString ( SARRAY *sa, char *string, l_int32 copyflag );
LEPT_DLL extern l_int32 sarrayExtendArray ( SARRAY *sa );
LEPT_DLL extern char * sarrayRemoveString ( SARRAY *sa, l_int32 index );
LEPT_DLL extern l_int32 sarrayReplaceString ( SARRAY *sa, l_int32 index, char *newstr, l_int32 copyflag );
LEPT_DLL extern l_int32 sarrayClear ( SARRAY *sa );
LEPT_DLL extern l_int32 sarrayGetCount ( SARRAY *sa );
LEPT_DLL extern char ** sarrayGetArray ( SARRAY *sa, l_int32 *pnalloc, l_int32 *pn );
LEPT_DLL extern char * sarrayGetString ( SARRAY *sa, l_int32 index, l_int32 copyflag );
LEPT_DLL extern l_int32 sarrayGetRefcount ( SARRAY *sa );
LEPT_DLL extern l_int32 sarrayChangeRefcount ( SARRAY *sa, l_int32 delta );
LEPT_DLL extern char * sarrayToString ( SARRAY *sa, l_int32 addnlflag );
LEPT_DLL extern char * sarrayToStringRange ( SARRAY *sa, l_int32 first, l_int32 nstrings, l_int32 addnlflag );
LEPT_DLL extern l_int32 sarrayConcatenate ( SARRAY *sa1, SARRAY *sa2 );
LEPT_DLL extern l_int32 sarrayAppendRange ( SARRAY *sa1, SARRAY *sa2, l_int32 start, l_int32 end );
LEPT_DLL extern l_int32 sarrayPadToSameSize ( SARRAY *sa1, SARRAY *sa2, char *padstring );
LEPT_DLL extern SARRAY * sarrayConvertWordsToLines ( SARRAY *sa, l_int32 linesize );
LEPT_DLL extern l_int32 sarraySplitString ( SARRAY *sa, const char *str, const char *separators );
LEPT_DLL extern SARRAY * sarraySelectBySubstring ( SARRAY *sain, const char *substr );
LEPT_DLL extern SARRAY * sarraySelectByRange ( SARRAY *sain, l_int32 first, l_int32 last );
LEPT_DLL extern l_int32 sarrayParseRange ( SARRAY *sa, l_int32 start, l_int32 *pactualstart, l_int32 *pend, l_int32 *pnewstart, const char *substr, l_int32 loc );
LEPT_DLL extern SARRAY * sarraySort ( SARRAY *saout, SARRAY *sain, l_int32 sortorder );
LEPT_DLL extern l_int32 stringCompareLexical ( const char *str1, const char *str2 );
LEPT_DLL extern SARRAY * sarrayRead ( const char *filename );
LEPT_DLL extern SARRAY * sarrayReadStream ( FILE *fp );
LEPT_DLL extern l_int32 sarrayWrite ( const char *filename, SARRAY *sa );
LEPT_DLL extern l_int32 sarrayWriteStream ( FILE *fp, SARRAY *sa );
LEPT_DLL extern l_int32 sarrayAppend ( const char *filename, SARRAY *sa );
LEPT_DLL extern SARRAY * getNumberedPathnamesInDirectory ( const char *dirname, const char *substr, l_int32 numpre, l_int32 numpost, l_int32 maxnum );
LEPT_DLL extern SARRAY * getSortedPathnamesInDirectory ( const char *dirname, const char *substr, l_int32 firstpage, l_int32 npages );
LEPT_DLL extern SARRAY * getFilenamesInDirectory ( const char *dirname );
*/
PIX *pixScale ( PIX *pixs, l_float32 scalex, l_float32 scaley );
PIX *pixScaleToSize ( PIX *pixs, l_int32 wd, l_int32 hd );
PIX *pixScaleGeneral ( PIX *pixs, l_float32 scalex, l_float32 scaley, l_float32 sharpfract, l_int32 sharpwidth );
PIX *pixScaleLI ( PIX *pixs, l_float32 scalex, l_float32 scaley );
PIX *pixScaleColorLI ( PIX *pixs, l_float32 scalex, l_float32 scaley );
PIX *pixScaleColor2xLI ( PIX *pixs );
PIX *pixScaleColor4xLI ( PIX *pixs );
PIX *pixScaleGrayLI ( PIX *pixs, l_float32 scalex, l_float32 scaley );
PIX *pixScaleGray2xLI ( PIX *pixs );
PIX *pixScaleGray4xLI ( PIX *pixs );
PIX *pixScaleBySampling ( PIX *pixs, l_float32 scalex, l_float32 scaley );
PIX *pixScaleByIntSubsampling ( PIX *pixs, l_int32 factor );
PIX *pixScaleRGBToGrayFast ( PIX *pixs, l_int32 factor, l_int32 color );
PIX *pixScaleRGBToBinaryFast ( PIX *pixs, l_int32 factor, l_int32 thresh );
PIX *pixScaleGrayToBinaryFast ( PIX *pixs, l_int32 factor, l_int32 thresh );
PIX *pixScaleSmooth ( PIX *pix, l_float32 scalex, l_float32 scaley );
PIX *pixScaleRGBToGray2 ( PIX *pixs, l_float32 rwt, l_float32 gwt, l_float32 bwt );
PIX *pixScaleAreaMap ( PIX *pix, l_float32 scalex, l_float32 scaley );
PIX *pixScaleAreaMap2 ( PIX *pix );
PIX *pixScaleBinary ( PIX *pixs, l_float32 scalex, l_float32 scaley );
PIX *pixScaleToGray ( PIX *pixs, l_float32 scalefactor );
PIX *pixScaleToGrayFast ( PIX *pixs, l_float32 scalefactor );
PIX *pixScaleToGray2 ( PIX *pixs );
PIX *pixScaleToGray3 ( PIX *pixs );
PIX *pixScaleToGray4 ( PIX *pixs );
PIX *pixScaleToGray6 ( PIX *pixs );
PIX *pixScaleToGray8 ( PIX *pixs );
PIX *pixScaleToGray16 ( PIX *pixs );
PIX *pixScaleToGrayMipmap ( PIX *pixs, l_float32 scalefactor );
PIX *pixScaleMipmap ( PIX *pixs1, PIX *pixs2, l_float32 scale );
PIX *pixExpandReplicate ( PIX *pixs, l_int32 factor );
PIX *pixScaleGray2xLIThresh ( PIX *pixs, l_int32 thresh );
PIX *pixScaleGray2xLIDither ( PIX *pixs );
PIX *pixScaleGray4xLIThresh ( PIX *pixs, l_int32 thresh );
PIX *pixScaleGray4xLIDither ( PIX *pixs );
PIX *pixScaleGrayMinMax ( PIX *pixs, l_int32 xfact, l_int32 yfact, l_int32 type );
PIX *pixScaleGrayMinMax2 ( PIX *pixs, l_int32 type );
PIX *pixScaleGrayRankCascade ( PIX *pixs, l_int32 level1, l_int32 level2, l_int32 level3, l_int32 level4 );
PIX *pixScaleGrayRank2 ( PIX *pixs, l_int32 rank );
PIX *pixScaleWithAlpha ( PIX *pixs, l_float32 scalex, l_float32 scaley, PIX *pixg, l_float32 fract );
PIX *pixScaleGammaXform ( PIX *pixs, l_float32 gamma, l_float32 scalex, l_float32 scaley, l_float32 fract );
void scaleColorLILow ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 ws, l_int32 hs, l_int32 wpls );
void scaleGrayLILow ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 ws, l_int32 hs, l_int32 wpls );
void scaleColor2xLILow ( l_uint32 *datad, l_int32 wpld, l_uint32 *datas, l_int32 ws, l_int32 hs, l_int32 wpls );
void scaleColor2xLILineLow ( l_uint32 *lined, l_int32 wpld, l_uint32 *lines, l_int32 ws, l_int32 wpls, l_int32 lastlineflag );
void scaleGray2xLILow ( l_uint32 *datad, l_int32 wpld, l_uint32 *datas, l_int32 ws, l_int32 hs, l_int32 wpls );
void scaleGray2xLILineLow ( l_uint32 *lined, l_int32 wpld, l_uint32 *lines, l_int32 ws, l_int32 wpls, l_int32 lastlineflag );
void scaleGray4xLILow ( l_uint32 *datad, l_int32 wpld, l_uint32 *datas, l_int32 ws, l_int32 hs, l_int32 wpls );
void scaleGray4xLILineLow ( l_uint32 *lined, l_int32 wpld, l_uint32 *lines, l_int32 ws, l_int32 wpls, l_int32 lastlineflag );
l_int32 scaleBySamplingLow ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 ws, l_int32 hs, l_int32 d, l_int32 wpls );
l_int32 scaleSmoothLow ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 ws, l_int32 hs, l_int32 d, l_int32 wpls, l_int32 size );
void scaleRGBToGray2Low ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_float32 rwt, l_float32 gwt, l_float32 bwt );
void scaleColorAreaMapLow ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 ws, l_int32 hs, l_int32 wpls );
void scaleGrayAreaMapLow ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 ws, l_int32 hs, l_int32 wpls );
void scaleAreaMapLow2 ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 d, l_int32 wpls );
l_int32 scaleBinaryLow ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 ws, l_int32 hs, l_int32 wpls );
void scaleToGray2Low ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_uint32 *sumtab, l_uint8 *valtab );
l_uint32 * makeSumTabSG2 ( void );
l_uint8 * makeValTabSG2 ( void );
void scaleToGray3Low ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_uint32 *sumtab, l_uint8 *valtab );
l_uint32 * makeSumTabSG3 ( void );
l_uint8 * makeValTabSG3 ( void );
void scaleToGray4Low ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_uint32 *sumtab, l_uint8 *valtab );
l_uint32 * makeSumTabSG4 ( void );
l_uint8 * makeValTabSG4 ( void );
void scaleToGray6Low ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_int32 *tab8, l_uint8 *valtab );
l_uint8 * makeValTabSG6 ( void );
void scaleToGray8Low ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_int32 *tab8, l_uint8 *valtab );
l_uint8 * makeValTabSG8 ( void );
void scaleToGray16Low ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas, l_int32 wpls, l_int32 *tab8 );
l_int32 scaleMipmapLow ( l_uint32 *datad, l_int32 wd, l_int32 hd, l_int32 wpld, l_uint32 *datas1, l_int32 wpls1, l_uint32 *datas2, l_int32 wpls2, l_float32 red );
/*
LEPT_DLL extern PIX * pixSeedfillBinary ( PIX *pixd, PIX *pixs, PIX *pixm, l_int32 connectivity );
LEPT_DLL extern PIX * pixSeedfillBinaryRestricted ( PIX *pixd, PIX *pixs, PIX *pixm, l_int32 connectivity, l_int32 xmax, l_int32 ymax );
LEPT_DLL extern PIX * pixHolesByFilling ( PIX *pixs, l_int32 connectivity );
LEPT_DLL extern PIX * pixFillClosedBorders ( PIX *pixs, l_int32 connectivity );
LEPT_DLL extern PIX * pixExtractBorderConnComps ( PIX *pixs, l_int32 connectivity );
LEPT_DLL extern PIX * pixRemoveBorderConnComps ( PIX *pixs, l_int32 connectivity );
LEPT_DLL extern PIX * pixFillHolesToBoundingRect ( PIX *pixs, l_int32 minsize, l_float32 maxhfract, l_float32 minfgfract );
LEPT_DLL extern l_int32 pixSeedfillGray ( PIX *pixs, PIX *pixm, l_int32 connectivity );
LEPT_DLL extern l_int32 pixSeedfillGrayInv ( PIX *pixs, PIX *pixm, l_int32 connectivity );
LEPT_DLL extern l_int32 pixSeedfillGraySimple ( PIX *pixs, PIX *pixm, l_int32 connectivity );
LEPT_DLL extern l_int32 pixSeedfillGrayInvSimple ( PIX *pixs, PIX *pixm, l_int32 connectivity );
LEPT_DLL extern PIX * pixSeedfillGrayBasin ( PIX *pixb, PIX *pixm, l_int32 delta, l_int32 connectivity );
LEPT_DLL extern PIX * pixDistanceFunction ( PIX *pixs, l_int32 connectivity, l_int32 outdepth, l_int32 boundcond );
LEPT_DLL extern PIX * pixSeedspread ( PIX *pixs, l_int32 connectivity );
LEPT_DLL extern l_int32 pixLocalExtrema ( PIX *pixs, l_int32 maxmin, l_int32 minmax, PIX **ppixmin, PIX **ppixmax );
LEPT_DLL extern l_int32 pixSelectedLocalExtrema ( PIX *pixs, l_int32 mindist, PIX **ppixmin, PIX **ppixmax );
LEPT_DLL extern PIX * pixFindEqualValues ( PIX *pixs1, PIX *pixs2 );
LEPT_DLL extern PTA * pixSelectMinInConnComp ( PIX *pixs, PIX *pixm, NUMA **pnav );
LEPT_DLL extern PIX * pixRemoveSeededComponents ( PIX *pixd, PIX *pixs, PIX *pixm, l_int32 connectivity, l_int32 bordersize );
LEPT_DLL extern void seedfillBinaryLow ( l_uint32 *datas, l_int32 hs, l_int32 wpls, l_uint32 *datam, l_int32 hm, l_int32 wplm, l_int32 connectivity );
LEPT_DLL extern void seedfillGrayLow ( l_uint32 *datas, l_int32 w, l_int32 h, l_int32 wpls, l_uint32 *datam, l_int32 wplm, l_int32 connectivity );
LEPT_DLL extern void seedfillGrayInvLow ( l_uint32 *datas, l_int32 w, l_int32 h, l_int32 wpls, l_uint32 *datam, l_int32 wplm, l_int32 connectivity );
LEPT_DLL extern void seedfillGrayLowSimple ( l_uint32 *datas, l_int32 w, l_int32 h, l_int32 wpls, l_uint32 *datam, l_int32 wplm, l_int32 connectivity );
LEPT_DLL extern void seedfillGrayInvLowSimple ( l_uint32 *datas, l_int32 w, l_int32 h, l_int32 wpls, l_uint32 *datam, l_int32 wplm, l_int32 connectivity );
LEPT_DLL extern void distanceFunctionLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 d, l_int32 wpld, l_int32 connectivity );
LEPT_DLL extern void seedspreadLow ( l_uint32 *datad, l_int32 w, l_int32 h, l_int32 wpld, l_uint32 *datat, l_int32 wplt, l_int32 connectivity );
*/
SELA *selaCreate ( l_int32 n );
void selaDestroy ( SELA **psela );
SEL *selCreate ( l_int32 height, l_int32 width, const char *name );
void selDestroy ( SEL **psel );
SEL *selCopy ( SEL *sel );
SEL *selCreateBrick ( l_int32 h, l_int32 w, l_int32 cy, l_int32 cx, l_int32 type );
SEL *selCreateComb ( l_int32 factor1, l_int32 factor2, l_int32 direction );
l_int32 **create2dIntArray ( l_int32 sy, l_int32 sx );
l_int32 selaAddSel ( SELA *sela, SEL *sel, const char *selname, l_int32 copyflag );
l_int32 selaExtendArray ( SELA *sela );
l_int32 selaGetCount ( SELA *sela );
SEL *selaGetSel ( SELA *sela, l_int32 i );
char *selGetName ( SEL *sel );
l_int32 selSetName ( SEL *sel, const char *name );
l_int32 selaFindSelByName ( SELA *sela, const char *name, l_int32 *pindex, SEL **psel );
l_int32 selGetElement ( SEL *sel, l_int32 row, l_int32 col, l_int32 *ptype );
l_int32 selSetElement ( SEL *sel, l_int32 row, l_int32 col, l_int32 type );
l_int32 selGetParameters ( SEL *sel, l_int32 *psy, l_int32 *psx, l_int32 *pcy, l_int32 *pcx );
l_int32 selSetOrigin ( SEL *sel, l_int32 cy, l_int32 cx );
l_int32 selGetTypeAtOrigin ( SEL *sel, l_int32 *ptype );
char * selaGetBrickName ( SELA *sela, l_int32 hsize, l_int32 vsize );
char * selaGetCombName ( SELA *sela, l_int32 size, l_int32 direction );
l_int32 getCompositeParameters ( l_int32 size, l_int32 *psize1, l_int32 *psize2, char **pnameh1, char **pnameh2, char **pnamev1, char **pnamev2 );
SARRAY * selaGetSelnames ( SELA *sela );
l_int32 selFindMaxTranslations ( SEL *sel, l_int32 *pxp, l_int32 *pyp, l_int32 *pxn, l_int32 *pyn );
SEL * selRotateOrth ( SEL *sel, l_int32 quads );
SELA * selaRead ( const char *fname );
SELA * selaReadStream ( void *fp );
SEL * selRead ( const char *fname );
SEL * selReadStream ( void *fp );
l_int32 selaWrite ( const char *fname, SELA *sela );
l_int32 selaWriteStream ( void *fp, SELA *sela );
l_int32 selWrite ( const char *fname, SEL *sel );
l_int32 selWriteStream ( void *fp, SEL *sel );
SEL * selCreateFromString ( const char *text, l_int32 h, l_int32 w, const char *name );
/*
LEPT_DLL extern char * selPrintToString ( SEL *sel );
LEPT_DLL extern SELA * selaCreateFromFile ( const char *filename );
LEPT_DLL extern SEL * selCreateFromPta ( PTA *pta, l_int32 cy, l_int32 cx, const char *name );
LEPT_DLL extern SEL * selCreateFromPix ( PIX *pix, l_int32 cy, l_int32 cx, const char *name );
LEPT_DLL extern SEL * selReadFromColorImage ( const char *pathname );
LEPT_DLL extern SEL * selCreateFromColorPix ( PIX *pixs, char *selname );
LEPT_DLL extern PIX * selDisplayInPix ( SEL *sel, l_int32 size, l_int32 gthick );
LEPT_DLL extern PIX * selaDisplayInPix ( SELA *sela, l_int32 size, l_int32 gthick, l_int32 spacing, l_int32 ncols );
LEPT_DLL extern SELA * selaAddBasic ( SELA *sela );
LEPT_DLL extern SELA * selaAddHitMiss ( SELA *sela );
LEPT_DLL extern SELA * selaAddDwaLinear ( SELA *sela );
LEPT_DLL extern SELA * selaAddDwaCombs ( SELA *sela );
LEPT_DLL extern SELA * selaAddCrossJunctions ( SELA *sela, l_float32 hlsize, l_float32 mdist, l_int32 norient, l_int32 debugflag );
LEPT_DLL extern SELA * selaAddTJunctions ( SELA *sela, l_float32 hlsize, l_float32 mdist, l_int32 norient, l_int32 debugflag );
LEPT_DLL extern SEL * pixGenerateSelWithRuns ( PIX *pixs, l_int32 nhlines, l_int32 nvlines, l_int32 distance, l_int32 minlength, l_int32 toppix, l_int32 botpix, l_int32 leftpix, l_int32 rightpix, PIX **ppixe );
LEPT_DLL extern SEL * pixGenerateSelRandom ( PIX *pixs, l_float32 hitfract, l_float32 missfract, l_int32 distance, l_int32 toppix, l_int32 botpix, l_int32 leftpix, l_int32 rightpix, PIX **ppixe );
LEPT_DLL extern SEL * pixGenerateSelBoundary ( PIX *pixs, l_int32 hitdist, l_int32 missdist, l_int32 hitskip, l_int32 missskip, l_int32 topflag, l_int32 botflag, l_int32 leftflag, l_int32 rightflag, PIX **ppixe );
LEPT_DLL extern NUMA * pixGetRunCentersOnLine ( PIX *pixs, l_int32 x, l_int32 y, l_int32 minlength );
LEPT_DLL extern NUMA * pixGetRunsOnLine ( PIX *pixs, l_int32 x1, l_int32 y1, l_int32 x2, l_int32 y2 );
LEPT_DLL extern PTA * pixSubsampleBoundaryPixels ( PIX *pixs, l_int32 skip );
LEPT_DLL extern l_int32 adjacentOnPixelInRaster ( PIX *pixs, l_int32 x, l_int32 y, l_int32 *pxa, l_int32 *pya );
LEPT_DLL extern PIX * pixDisplayHitMissSel ( PIX *pixs, SEL *sel, l_int32 scalefactor, l_uint32 hitcolor, l_uint32 misscolor );
LEPT_DLL extern PIX * pixHShear ( PIX *pixd, PIX *pixs, l_int32 liney, l_float32 radang, l_int32 incolor );
LEPT_DLL extern PIX * pixVShear ( PIX *pixd, PIX *pixs, l_int32 linex, l_float32 radang, l_int32 incolor );
LEPT_DLL extern PIX * pixHShearCorner ( PIX *pixd, PIX *pixs, l_float32 radang, l_int32 incolor );
LEPT_DLL extern PIX * pixVShearCorner ( PIX *pixd, PIX *pixs, l_float32 radang, l_int32 incolor );
LEPT_DLL extern PIX * pixHShearCenter ( PIX *pixd, PIX *pixs, l_float32 radang, l_int32 incolor );
LEPT_DLL extern PIX * pixVShearCenter ( PIX *pixd, PIX *pixs, l_float32 radang, l_int32 incolor );
LEPT_DLL extern l_int32 pixHShearIP ( PIX *pixs, l_int32 liney, l_float32 radang, l_int32 incolor );
LEPT_DLL extern l_int32 pixVShearIP ( PIX *pixs, l_int32 linex, l_float32 radang, l_int32 incolor );
LEPT_DLL extern PIX * pixHShearLI ( PIX *pixs, l_int32 liney, l_float32 radang, l_int32 incolor );
LEPT_DLL extern PIX * pixVShearLI ( PIX *pixs, l_int32 linex, l_float32 radang, l_int32 incolor );
LEPT_DLL extern PIX * pixDeskew ( PIX *pixs, l_int32 redsearch );
LEPT_DLL extern PIX * pixFindSkewAndDeskew ( PIX *pixs, l_int32 redsearch, l_float32 *pangle, l_float32 *pconf );
LEPT_DLL extern PIX * pixDeskewGeneral ( PIX *pixs, l_int32 redsweep, l_float32 sweeprange, l_float32 sweepdelta, l_int32 redsearch, l_int32 thresh, l_float32 *pangle, l_float32 *pconf );
LEPT_DLL extern l_int32 pixFindSkew ( PIX *pixs, l_float32 *pangle, l_float32 *pconf );
LEPT_DLL extern l_int32 pixFindSkewSweep ( PIX *pixs, l_float32 *pangle, l_int32 reduction, l_float32 sweeprange, l_float32 sweepdelta );
LEPT_DLL extern l_int32 pixFindSkewSweepAndSearch ( PIX *pixs, l_float32 *pangle, l_float32 *pconf, l_int32 redsweep, l_int32 redsearch, l_float32 sweeprange, l_float32 sweepdelta, l_float32 minbsdelta );
LEPT_DLL extern l_int32 pixFindSkewSweepAndSearchScore ( PIX *pixs, l_float32 *pangle, l_float32 *pconf, l_float32 *pendscore, l_int32 redsweep, l_int32 redsearch, l_float32 sweepcenter, l_float32 sweeprange, l_float32 sweepdelta, l_float32 minbsdelta );
LEPT_DLL extern l_int32 pixFindSkewSweepAndSearchScorePivot ( PIX *pixs, l_float32 *pangle, l_float32 *pconf, l_float32 *pendscore, l_int32 redsweep, l_int32 redsearch, l_float32 sweepcenter, l_float32 sweeprange, l_float32 sweepdelta, l_float32 minbsdelta, l_int32 pivot );
LEPT_DLL extern l_int32 pixFindSkewOrthogonalRange ( PIX *pixs, l_float32 *pangle, l_float32 *pconf, l_int32 redsweep, l_int32 redsearch, l_float32 sweeprange, l_float32 sweepdelta, l_float32 minbsdelta, l_float32 confprior );
LEPT_DLL extern l_int32 pixFindDifferentialSquareSum ( PIX *pixs, l_float32 *psum );
LEPT_DLL extern l_int32 pixFindNormalizedSquareSum ( PIX *pixs, l_float32 *phratio, l_float32 *pvratio, l_float32 *pfract );
LEPT_DLL extern PIX * pixReadStreamSpix ( FILE *fp );
LEPT_DLL extern l_int32 readHeaderSpix ( const char *filename, l_int32 *pwidth, l_int32 *pheight, l_int32 *pbps, l_int32 *pspp, l_int32 *piscmap );
LEPT_DLL extern l_int32 freadHeaderSpix ( FILE *fp, l_int32 *pwidth, l_int32 *pheight, l_int32 *pbps, l_int32 *pspp, l_int32 *piscmap );
LEPT_DLL extern l_int32 sreadHeaderSpix ( const l_uint32 *data, l_int32 *pwidth, l_int32 *pheight, l_int32 *pbps, l_int32 *pspp, l_int32 *piscmap );
LEPT_DLL extern l_int32 pixWriteStreamSpix ( FILE *fp, PIX *pix );
LEPT_DLL extern PIX * pixReadMemSpix ( const l_uint8 *data, size_t size );
LEPT_DLL extern l_int32 pixWriteMemSpix ( l_uint8 **pdata, size_t *psize, PIX *pix );
LEPT_DLL extern l_int32 pixSerializeToMemory ( PIX *pixs, l_uint32 **pdata, size_t *pnbytes );
LEPT_DLL extern PIX * pixDeserializeFromMemory ( const l_uint32 *data, size_t nbytes );
LEPT_DLL extern L_STACK * lstackCreate ( l_int32 nalloc );
LEPT_DLL extern void lstackDestroy ( L_STACK **plstack, l_int32 freeflag );
LEPT_DLL extern l_int32 lstackAdd ( L_STACK *lstack, void *item );
LEPT_DLL extern void * lstackRemove ( L_STACK *lstack );
LEPT_DLL extern l_int32 lstackExtendArray ( L_STACK *lstack );
LEPT_DLL extern l_int32 lstackGetCount ( L_STACK *lstack );
LEPT_DLL extern l_int32 lstackPrint ( FILE *fp, L_STACK *lstack );
LEPT_DLL extern l_int32 * sudokuReadFile ( const char *filename );
LEPT_DLL extern l_int32 * sudokuReadString ( const char *str );
LEPT_DLL extern L_SUDOKU * sudokuCreate ( l_int32 *array );
LEPT_DLL extern void sudokuDestroy ( L_SUDOKU **psud );
LEPT_DLL extern l_int32 sudokuSolve ( L_SUDOKU *sud );
LEPT_DLL extern l_int32 sudokuTestUniqueness ( l_int32 *array, l_int32 *punique );
LEPT_DLL extern L_SUDOKU * sudokuGenerate ( l_int32 *array, l_int32 seed, l_int32 minelems, l_int32 maxtries );
LEPT_DLL extern l_int32 sudokuOutput ( L_SUDOKU *sud, l_int32 arraytype );
LEPT_DLL extern PIX * pixAddSingleTextblock ( PIX *pixs, L_BMF *bmf, const char *textstr, l_uint32 val, l_int32 location, l_int32 *poverflow );
LEPT_DLL extern l_int32 pixSetTextblock ( PIX *pixs, L_BMF *bmf, const char *textstr, l_uint32 val, l_int32 x0, l_int32 y0, l_int32 wtext, l_int32 firstindent, l_int32 *poverflow );
LEPT_DLL extern l_int32 pixSetTextline ( PIX *pixs, L_BMF *bmf, const char *textstr, l_uint32 val, l_int32 x0, l_int32 y0, l_int32 *pwidth, l_int32 *poverflow );
LEPT_DLL extern SARRAY * bmfGetLineStrings ( L_BMF *bmf, const char *textstr, l_int32 maxw, l_int32 firstindent, l_int32 *ph );
LEPT_DLL extern NUMA * bmfGetWordWidths ( L_BMF *bmf, const char *textstr, SARRAY *sa );
LEPT_DLL extern l_int32 bmfGetStringWidth ( L_BMF *bmf, const char *textstr, l_int32 *pw );
LEPT_DLL extern SARRAY * splitStringToParagraphs ( char *textstr, l_int32 splitflag );
LEPT_DLL extern PIX * pixReadTiff ( const char *filename, l_int32 n );
LEPT_DLL extern PIX * pixReadStreamTiff ( FILE *fp, l_int32 n );
LEPT_DLL extern l_int32 pixWriteTiff ( const char *filename, PIX *pix, l_int32 comptype, const char *modestring );
LEPT_DLL extern l_int32 pixWriteTiffCustom ( const char *filename, PIX *pix, l_int32 comptype, const char *modestring, NUMA *natags, SARRAY *savals, SARRAY *satypes, NUMA *nasizes );
LEPT_DLL extern l_int32 pixWriteStreamTiff ( FILE *fp, PIX *pix, l_int32 comptype );
LEPT_DLL extern PIXA * pixaReadMultipageTiff ( const char *filename );
LEPT_DLL extern l_int32 writeMultipageTiff ( const char *dirin, const char *substr, const char *fileout );
LEPT_DLL extern l_int32 writeMultipageTiffSA ( SARRAY *sa, const char *fileout );
LEPT_DLL extern l_int32 fprintTiffInfo ( FILE *fpout, const char *tiffile );
LEPT_DLL extern l_int32 tiffGetCount ( FILE *fp, l_int32 *pn );
LEPT_DLL extern l_int32 getTiffResolution ( FILE *fp, l_int32 *pxres, l_int32 *pyres );
LEPT_DLL extern l_int32 readHeaderTiff ( const char *filename, l_int32 n, l_int32 *pwidth, l_int32 *pheight, l_int32 *pbps, l_int32 *pspp, l_int32 *pres, l_int32 *pcmap, l_int32 *pformat );
LEPT_DLL extern l_int32 freadHeaderTiff ( FILE *fp, l_int32 n, l_int32 *pwidth, l_int32 *pheight, l_int32 *pbps, l_int32 *pspp, l_int32 *pres, l_int32 *pcmap, l_int32 *pformat );
LEPT_DLL extern l_int32 readHeaderMemTiff ( const l_uint8 *cdata, size_t size, l_int32 n, l_int32 *pwidth, l_int32 *pheight, l_int32 *pbps, l_int32 *pspp, l_int32 *pres, l_int32 *pcmap, l_int32 *pformat );
LEPT_DLL extern l_int32 findTiffCompression ( FILE *fp, l_int32 *pcomptype );
LEPT_DLL extern l_int32 extractG4DataFromFile ( const char *filein, l_uint8 **pdata, size_t *pnbytes, l_int32 *pw, l_int32 *ph, l_int32 *pminisblack );
LEPT_DLL extern PIX * pixReadMemTiff ( const l_uint8 *cdata, size_t size, l_int32 n );
LEPT_DLL extern l_int32 pixWriteMemTiff ( l_uint8 **pdata, size_t *psize, PIX *pix, l_int32 comptype );
LEPT_DLL extern l_int32 pixWriteMemTiffCustom ( l_uint8 **pdata, size_t *psize, PIX *pix, l_int32 comptype, NUMA *natags, SARRAY *savals, SARRAY *satypes, NUMA *nasizes );
LEPT_DLL extern l_int32 returnErrorInt ( const char *msg, const char *procname, l_int32 ival );
LEPT_DLL extern l_float32 returnErrorFloat ( const char *msg, const char *procname, l_float32 fval );
LEPT_DLL extern void * returnErrorPtr ( const char *msg, const char *procname, void *pval );
LEPT_DLL extern void l_error ( const char *msg, const char *procname );
LEPT_DLL extern void l_errorString ( const char *msg, const char *procname, const char *str );
LEPT_DLL extern void l_errorInt ( const char *msg, const char *procname, l_int32 ival );
LEPT_DLL extern void l_errorFloat ( const char *msg, const char *procname, l_float32 fval );
LEPT_DLL extern void l_warning ( const char *msg, const char *procname );
LEPT_DLL extern void l_warningString ( const char *msg, const char *procname, const char *str );
LEPT_DLL extern void l_warningInt ( const char *msg, const char *procname, l_int32 ival );
LEPT_DLL extern void l_warningInt2 ( const char *msg, const char *procname, l_int32 ival1, l_int32 ival2 );
LEPT_DLL extern void l_warningFloat ( const char *msg, const char *procname, l_float32 fval );
LEPT_DLL extern void l_warningFloat2 ( const char *msg, const char *procname, l_float32 fval1, l_float32 fval2 );
LEPT_DLL extern void l_info ( const char *msg, const char *procname );
LEPT_DLL extern void l_infoString ( const char *msg, const char *procname, const char *str );
LEPT_DLL extern void l_infoInt ( const char *msg, const char *procname, l_int32 ival );
LEPT_DLL extern void l_infoInt2 ( const char *msg, const char *procname, l_int32 ival1, l_int32 ival2 );
LEPT_DLL extern void l_infoFloat ( const char *msg, const char *procname, l_float32 fval );
LEPT_DLL extern void l_infoFloat2 ( const char *msg, const char *procname, l_float32 fval1, l_float32 fval2 );
LEPT_DLL extern char * stringNew ( const char *src );
LEPT_DLL extern l_int32 stringCopy ( char *dest, const char *src, l_int32 n );
LEPT_DLL extern l_int32 stringReplace ( char **pdest, const char *src );
LEPT_DLL extern l_int32 stringLength ( const char *src, size_t size );
LEPT_DLL extern l_int32 stringCat ( char *dest, size_t size, const char *src );
LEPT_DLL extern char * stringJoin ( const char *src1, const char *src2 );
LEPT_DLL extern char * stringReverse ( const char *src );
LEPT_DLL extern char * strtokSafe ( char *cstr, const char *seps, char **psaveptr );
LEPT_DLL extern l_int32 stringSplitOnToken ( char *cstr, const char *seps, char **phead, char **ptail );
LEPT_DLL extern char * stringRemoveChars ( const char *src, const char *remchars );
LEPT_DLL extern l_int32 stringFindSubstr ( const char *src, const char *sub, l_int32 *ploc );
LEPT_DLL extern char * stringReplaceSubstr ( const char *src, const char *sub1, const char *sub2, l_int32 *pfound, l_int32 *ploc );
LEPT_DLL extern char * stringReplaceEachSubstr ( const char *src, const char *sub1, const char *sub2, l_int32 *pcount );
LEPT_DLL extern NUMA * arrayFindEachSequence ( const l_uint8 *data, l_int32 datalen, const l_uint8 *sequence, l_int32 seqlen );
LEPT_DLL extern l_int32 arrayFindSequence ( const l_uint8 *data, l_int32 datalen, const l_uint8 *sequence, l_int32 seqlen, l_int32 *poffset, l_int32 *pfound );
LEPT_DLL extern void * reallocNew ( void **pindata, l_int32 oldsize, l_int32 newsize );
LEPT_DLL extern l_uint8 * l_binaryRead ( const char *filename, size_t *pnbytes );
LEPT_DLL extern l_uint8 * l_binaryReadStream ( FILE *fp, size_t *pnbytes );
LEPT_DLL extern l_int32 l_binaryWrite ( const char *filename, const char *operation, void *data, size_t nbytes );
LEPT_DLL extern size_t nbytesInFile ( const char *filename );
LEPT_DLL extern size_t fnbytesInFile ( FILE *fp );
LEPT_DLL extern l_uint8 * l_binaryCopy ( l_uint8 *datas, size_t size );
LEPT_DLL extern l_int32 fileCopy ( const char *srcfile, const char *newfile );
LEPT_DLL extern l_int32 fileConcatenate ( const char *srcfile, const char *destfile );
LEPT_DLL extern l_int32 fileAppendString ( const char *filename, const char *str );
LEPT_DLL extern l_int32 filesAreIdentical ( const char *fname1, const char *fname2, l_int32 *psame );
LEPT_DLL extern l_uint16 convertOnLittleEnd16 ( l_uint16 shortin );
LEPT_DLL extern l_uint16 convertOnBigEnd16 ( l_uint16 shortin );
LEPT_DLL extern l_uint32 convertOnLittleEnd32 ( l_uint32 wordin );
LEPT_DLL extern l_uint32 convertOnBigEnd32 ( l_uint32 wordin );
LEPT_DLL extern FILE * fopenReadStream ( const char *filename );
LEPT_DLL extern FILE * fopenWriteStream ( const char *filename, const char *modestring );
LEPT_DLL extern FILE * lept_fopen ( const char *filename, const char *mode );
LEPT_DLL extern l_int32 lept_fclose ( FILE *fp );
LEPT_DLL extern void * lept_calloc ( size_t nmemb, size_t size );
LEPT_DLL extern void lept_free ( void *ptr );
LEPT_DLL extern l_int32 lept_mkdir ( const char *subdir );
LEPT_DLL extern l_int32 lept_rmdir ( const char *subdir );
LEPT_DLL extern l_int32 lept_rm ( const char *subdir, const char *filename );
LEPT_DLL extern l_int32 lept_mv ( const char *srcfile, const char *newfile );
LEPT_DLL extern l_int32 lept_cp ( const char *srcfile, const char *newfile );
LEPT_DLL extern l_int32 splitPathAtDirectory ( const char *pathname, char **pdir, char **ptail );
LEPT_DLL extern l_int32 splitPathAtExtension ( const char *pathname, char **pbasename, char **pextension );
LEPT_DLL extern char * pathJoin ( const char *dir, const char *fname );
LEPT_DLL extern char * genPathname ( const char *dir, const char *fname );
LEPT_DLL extern char * genTempFilename ( const char *dir, const char *tail, l_int32 usetime, l_int32 usepid );
LEPT_DLL extern l_int32 extractNumberFromFilename ( const char *fname, l_int32 numpre, l_int32 numpost );
LEPT_DLL extern l_int32 genRandomIntegerInRange ( l_int32 range, l_int32 seed, l_int32 *pval );
LEPT_DLL extern char * getLeptonicaVersion (  );
LEPT_DLL extern void startTimer ( void );
LEPT_DLL extern l_float32 stopTimer ( void );
LEPT_DLL extern L_TIMER startTimerNested ( void );
LEPT_DLL extern l_float32 stopTimerNested ( L_TIMER rusage_start );
LEPT_DLL extern void l_getCurrentTime ( l_int32 *sec, l_int32 *usec );
LEPT_DLL extern char * l_getFormattedDate (  );
LEPT_DLL extern l_uint8 * arrayRead ( const char *fname, l_int32 *pnbytes );
LEPT_DLL extern l_uint8 * arrayReadStream ( FILE *fp, l_int32 *pnbytes );
LEPT_DLL extern l_int32 pixHtmlViewer ( const char *dirin, const char *dirout, const char *rootname, l_int32 thumbwidth, l_int32 viewwidth, l_int32 copyorig );
LEPT_DLL extern PIX * pixSimpleCaptcha ( PIX *pixs, l_int32 border, l_int32 nterms, l_uint32 seed, l_uint32 color, l_int32 cmapflag );
LEPT_DLL extern PIX * pixRandomHarmonicWarp ( PIX *pixs, l_float32 xmag, l_float32 ymag, l_float32 xfreq, l_float32 yfreq, l_int32 nx, l_int32 ny, l_uint32 seed, l_int32 grayval );
LEPT_DLL extern PIX * pixWarpStereoscopic ( PIX *pixs, l_int32 zbend, l_int32 zshiftt, l_int32 zshiftb, l_int32 ybendt, l_int32 ybendb, l_int32 redleft );
LEPT_DLL extern PIX * pixStretchHorizontal ( PIX *pixs, l_int32 dir, l_int32 type, l_int32 hmax, l_int32 operation, l_int32 incolor );
LEPT_DLL extern PIX * pixStretchHorizontalSampled ( PIX *pixs, l_int32 dir, l_int32 type, l_int32 hmax, l_int32 incolor );
LEPT_DLL extern PIX * pixStretchHorizontalLI ( PIX *pixs, l_int32 dir, l_int32 type, l_int32 hmax, l_int32 incolor );
LEPT_DLL extern PIX * pixQuadraticVShear ( PIX *pixs, l_int32 dir, l_int32 vmaxt, l_int32 vmaxb, l_int32 operation, l_int32 incolor );
LEPT_DLL extern PIX * pixQuadraticVShearSampled ( PIX *pixs, l_int32 dir, l_int32 vmaxt, l_int32 vmaxb, l_int32 incolor );
LEPT_DLL extern PIX * pixQuadraticVShearLI ( PIX *pixs, l_int32 dir, l_int32 vmaxt, l_int32 vmaxb, l_int32 incolor );
LEPT_DLL extern PIX * pixStereoFromPair ( PIX *pix1, PIX *pix2, l_float32 rwt, l_float32 gwt, l_float32 bwt );
LEPT_DLL extern L_WSHED * wshedCreate ( PIX *pixs, PIX *pixm, l_int32 mindepth, l_int32 debugflag );
LEPT_DLL extern void wshedDestroy ( L_WSHED **pwshed );
LEPT_DLL extern l_int32 wshedApply ( L_WSHED *wshed );
LEPT_DLL extern l_int32 wshedBasins ( L_WSHED *wshed, PIXA **ppixa, NUMA **pnalevels );
LEPT_DLL extern PIX * wshedRenderFill ( L_WSHED *wshed );
LEPT_DLL extern PIX * wshedRenderColors ( L_WSHED *wshed );
LEPT_DLL extern PIX * pixReadStreamWebP ( FILE *fp );
LEPT_DLL extern l_int32 readHeaderWebP ( const char *filename, l_int32 *pwidth, l_int32 *pheight );
LEPT_DLL extern l_int32 pixWriteWebP ( const char *filename, PIX *pixs, l_int32 quality );
LEPT_DLL extern l_int32 pixWriteStreamWebP ( FILE *fp, PIX *pixs, l_int32 quality );
LEPT_DLL extern l_int32 pixWriteWebPwithTargetPSNR ( const char *filename, PIX *pixs, l_float64 target_psnr, l_int32 *pquality );
LEPT_DLL extern l_int32 pixaWriteFiles ( const char *rootname, PIXA *pixa, l_int32 format );
LEPT_DLL extern l_int32 pixWrite ( const char *filename, PIX *pix, l_int32 format );
LEPT_DLL extern l_int32 pixWriteStream ( FILE *fp, PIX *pix, l_int32 format );
LEPT_DLL extern l_int32 pixWriteImpliedFormat ( const char *filename, PIX *pix, l_int32 quality, l_int32 progressive );
LEPT_DLL extern l_int32 pixWriteTempfile ( const char *dir, const char *tail, PIX *pix, l_int32 format, char **pfilename );
LEPT_DLL extern l_int32 pixChooseOutputFormat ( PIX *pix );
LEPT_DLL extern l_int32 getImpliedFileFormat ( const char *filename );
LEPT_DLL extern const char * getFormatExtension ( l_int32 format );
LEPT_DLL extern l_int32 pixWriteMem ( l_uint8 **pdata, size_t *psize, PIX *pix, l_int32 format );
LEPT_DLL extern l_int32 pixDisplay ( PIX *pixs, l_int32 x, l_int32 y );
LEPT_DLL extern l_int32 pixDisplayWithTitle ( PIX *pixs, l_int32 x, l_int32 y, const char *title, l_int32 dispflag );
LEPT_DLL extern l_int32 pixDisplayMultiple ( const char *filepattern );
LEPT_DLL extern l_int32 pixDisplayWrite ( PIX *pixs, l_int32 reduction );
LEPT_DLL extern l_int32 pixDisplayWriteFormat ( PIX *pixs, l_int32 reduction, l_int32 format );
LEPT_DLL extern l_int32 pixSaveTiled ( PIX *pixs, PIXA *pixa, l_int32 reduction, l_int32 newrow, l_int32 space, l_int32 dp );
LEPT_DLL extern l_int32 pixSaveTiledOutline ( PIX *pixs, PIXA *pixa, l_int32 reduction, l_int32 newrow, l_int32 space, l_int32 linewidth, l_int32 dp );
LEPT_DLL extern l_int32 pixSaveTiledWithText ( PIX *pixs, PIXA *pixa, l_int32 outwidth, l_int32 newrow, l_int32 space, l_int32 linewidth, L_BMF *bmf, const char *textstr, l_uint32 val, l_int32 location );
LEPT_DLL extern void l_chooseDisplayProg ( l_int32 selection );
LEPT_DLL extern l_uint8 * zlibCompress ( l_uint8 *datain, size_t nin, size_t *pnout );
LEPT_DLL extern l_uint8 * zlibUncompress ( l_uint8 *datain, size_t nin, size_t *pnout );
*/

]]

local lib
if not pcall(function()
  -- Win32 debug
  lib = ffi.load 'liblept168d'
end) and not pcall(function()
  -- Win32 release
  lib = ffi.load 'liblept168'
end) and not pcall(function()
  -- MacPorts
  lib = ffi.load '/opt/local/lib/liblept.dylib'
end) then
  -- Generic
  lib = ffi.load 'lept'
end

local iLiblept = {}

local liblept = {}

liblept.L_RED_WEIGHT = 0.3
liblept.L_GREEN_WEIGHT = 0.5
liblept.L_BLUE_WEIGHT = 0.2

function liblept.PIX_NOT(op)
  return bit.bxor(op, 0x1e)
end

ffi.cdef([[
  static const int32_t PIX_SUBTRACT = $;
]], bit.band(lib.PIX_DST, liblept.PIX_NOT(lib.PIX_SRC)))

iLiblept.__index = lib

setmetatable(liblept, iLiblept)

return liblept
