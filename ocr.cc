#include <algorithm>
#include <cstddef>
#include <iostream>
#include <tesseract/baseapi.h>

typedef unsigned char uint8_t;
typedef unsigned int uint32_t;

extern "C"
{
#include "libyflood.cdef"
}

using namespace std;
using namespace tesseract;

struct ocr
{
    void *pBaseAPI;
};

namespace
{
    const char ALPHANUMERICS[] =
       "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    const uint32_t TERM_PROB_BITS = 0x7fc00000u;
}

extern "C"
{

int yf_ocr_new(const char *dataPath, HOCR *dst)
{
    TessBaseAPI *tess = new TessBaseAPI;
    tess->Init(dataPath, "eng", OEM_TESSERACT_ONLY);
    ocr *pOcr = new ocr;
    pOcr->pBaseAPI = reinterpret_cast<void *>(tess);
    *dst = pOcr;
    return 0;
}

int yf_ocr_read(HOCR ocr,
                const uint8_t *pixels,
                int16_t width, int16_t height,
                int32_t xStride, int32_t yStride,
                struct char_guess *guesses,
                int32_t guessCapacity)
{
    if (! pixels) return -500;
    if (xStride != 1) return -500;
    TessBaseAPI *tess = reinterpret_cast<TessBaseAPI *>(ocr->pBaseAPI);
    tess->Clear();
    tess->SetPageSegMode(PSM_SINGLE_CHAR);
    tess->SetVariable("tessedit_char_whitelist", ALPHANUMERICS);
    tess->SetImage(pixels, width, height, 1, yStride);
    char *utf8Text = tess->GetUTF8Text();
    char *cp = utf8Text;
    size_t nrOut = 0;
    while (*cp == '\n') ++ cp;
    if ('0' <= cp[0] && cp[0] <= 'z' &&
        (cp[1] == '\n' || cp[1] == '\0'))
    {
        guesses[nrOut].codePoint = cp[0];
        guesses[nrOut].prob = 0.01 * tess->MeanTextConf();
        ++ nrOut;
    }
    guesses[nrOut].codePoint = '\0';
    memcpy((void *)&guesses[nrOut].prob, (const void *)&TERM_PROB_BITS, 4);
    delete utf8Text;
    return 0;
}

int yf_ocr_free(HOCR ocr)
{
    if (ocr)
    {
        TessBaseAPI *tess = reinterpret_cast<TessBaseAPI *>(ocr->pBaseAPI);
        delete tess;
        ocr->pBaseAPI = 0;
    }
    delete ocr;
    return 0;
}

}
