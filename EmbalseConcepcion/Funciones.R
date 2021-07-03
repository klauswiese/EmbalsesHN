#NDWI Normalized Difference Water Index
#McFeeters, 1996
NDWI <- function (img){
  ndwi <- img$expression(
    expression = '(GREEN-NIR)/(GREEN+NIR)', opt_map = list(
      NIR = img$select("B8"),
      GREEN = img$select("B3")))
  return(ndwi)
}

#OTSU algorithm
#Automatic thresholding
#K. Wiese 23 de abril 2019
#https://stackoverflow.com/questions/51116495/auto-thresholding-on-r-raster-object
##################################################################################

#Librerias
library(raster)

#Algoritmo
OTSU <- function(X){#X es una raster
  range <- range(X[])  # Los rangos de valores van de 0 a 1
  levels <- 256L
  breaks <- seq(range[1], range[2], length.out = levels + 1)
  h <- hist.default(X[], breaks = breaks, plot = FALSE)
  counts <- as.double(h$counts)
  mids <- as.double(h$mids)
  len <- length(counts)
  w1 <- cumsum(counts)
  w2 <- w1[len] + counts - w1
  cm <- counts * mids
  m1 <- cumsum(cm)
  m2 <- m1[len] + cm - m1
  var <- w1 * w2 * (m2/w2 - m1/w1)^2
  maxi <- which(var == max(var, na.rm = TRUE))
  otsu <- (mids[maxi[1]] + mids[maxi[length(maxi)]])/2
  return(otsu)
}
