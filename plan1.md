* Read & decode the jpeg image
* Separate H, V edge detection (convolve with Sobel kernels)
* Sum squares of convolved gradients across each input row
  * Treat vertical edges (horizontal kernel) as real 
  * Treat horizontal edges (vertical kernel) as imaginary
* Pad then STFT the results (ensure window function is zero at borders)
* Infer line spacing (peak power in frequency domain), base/cap/mean lines
  (IM peaks in time domain)

* Perform Canny edge detection
* Build HoG (weighted towards noncentral pixels.)  Find its peaks.
* Remember edge paths

* Denoise text background
  * Split into lines first
  * Pick random edge path points, follow them in a random direction for a random distance
  * Try to classify these subpaths, based on how likely they are to be useful + simple glyph paths
    * Model them as straight lines and conic sections (modelling as Bezier
      curves is probably not feasible in our timeframe.)
  * Build semi-random decision trees that partition the text area into light &
    dark areas.  Limit depth (3? 4?)
  * Reclassify pixels based on majority vote of these trees

* Look for evidence of the oval
  * Long horizontal lines 
  * Thin lines
  * Lines outside em-square
  * Curves outside em-square, aligned with each other and facing a piece of text (esp. a hashtag)
