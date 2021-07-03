#Código para delimitar embalse Concepcion, Honduras
#K. Wiese
#Julio 2 2021

# Librerias 
library(rgee)
library(sf)
library(raster)
source("Funciones.R")

# Inicializar conexión con GEE
ee_Initialize(email = 'klauswiesengine@gmail.com', drive = TRUE)

#Límites Área Piloto
AOI <- "data/AOIConcepcion" %>% #"SHP/Olancho.shp"
  st_read(quiet = TRUE) %>% 
  sf_as_ee()

# Visualizar extent Área de Interés
extAOI <- AOI$geometry()$bounds()

# Sentinel 2
#Compuesto Sentinel 2
S2 <- ee$ImageCollection('COPERNICUS/S2_SR')$
  filterDate('2021-02-09','2021-02-11')$
  filterBounds(extAOI)$
  filterMetadata('CLOUDY_PIXEL_PERCENTAGE','less_than',20)$median()$
  clip(extAOI)$divide(10000)$select(c("B3","B4","B8"))

#NDWI
S2ndwi <- NDWI(S2)$float()
#S2ndwi <- S2$normalizedDifference(c('B8','B4'))$rename("S2ndwi")$float()

#Visualizar datos
Map$centerObject(extAOI,zoom=14)
Map$addLayer(
  eeObject = extAOI,
  name = "Área de Interés"
)   +
  Map$addLayer(
    eeObject = S2,
    visParams = list(
      bands = c("B8", "B4", "B3"),
      max = 0.4
    ),
    name = "Vegetación Infraroja S2"
  ) +
  Map$addLayer(
    eeObject = S2ndwi,
    visParams = list(
      max = 1,
      min = -1
    ),
    name = "Índice NDWI S2"
  )  
  
#Descargar ïndice NDWI
NDWIconce <- ee_as_raster(S2ndwi$clip(extAOI), scale=10)

#Graficar índice
plot(NDWIconce)

#Algoritmo de OTSU
Umbral <- OTSU(NDWIconce)

#Embalse
Embalse <- NDWIconce < Umbral
NombreRaster <- "EmbalseConcepcion.grd"
writeRaster(Embalse, filename = paste0("./resultados/", NombreRaster), overwrite=TRUE)

#Poligonizar con gdal, mucho más rápido y eficiente que rasterToPolygon de raster
NombreVector <- "EmbalseConcepcion.gpkg"
system(paste0('gdal_polygonize.py ', 
              "./resultados/", NombreRaster, 
              ' \"./resultados/"', NombreVector, ' \ -b  1 -f "GPKG" DN'))

#Graficar resultado
Econce <- dplyr::filter(st_read("resultados/EmbalseConcepcion.gpkg", 
                                quiet = TRUE), 
                        DN == 1) %>%
  sf_as_ee()

#Visualizar datos
Map$centerObject(extAOI,zoom=14)
  Map$addLayer(
    eeObject = S2,
    visParams = list(
      bands = c("B8", "B4", "B3"),
      max = 0.4
    ),
    name = "Vegetación Infraroja S2"
  ) +
 Map$addLayer(
     eeObject = Econce,
     name = "Embalse La Concepción",
     visParams = list(
       color = "blue"
     )
  )  
  
sessionInfo()
