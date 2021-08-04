#Código para delimitar embalse Concepción, Honduras
#K. Wiese
#Julio 2 2021

# Librerias 
library(rgee)
library(sf)
library(raster)
source("Funciones.R")

# 0. Inicializar conexión con GEE ----
ee_Initialize(email = 'yourmail@gmail.com', drive = TRUE)

# 1. cargar datos ----
# 1.1 área de interés
AOI <- "data/AOIConcepcion" %>%
  st_read(quiet = TRUE) %>% 
  sf_as_ee()

# 1.2 calcular extent de área de interés ----
extAOI <- AOI$geometry()$bounds()

# 1.3 colección sentinel-2 ----
S2 <- ee$ImageCollection('COPERNICUS/S2_SR')$
  filterDate('2021-02-09','2021-02-11')$
  filterBounds(extAOI)$
  filterMetadata('CLOUDY_PIXEL_PERCENTAGE','less_than',20)$median()$
  clip(extAOI)$divide(10000)$select(c("B3","B4","B8"))

# 1.4 calcular NDWI ----
S2ndwi <- NDWI(S2)$float()

# 2 visualizar datos ----
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
  
# 3. descargar índice NDWI ----
NDWIconce <- ee_as_raster(S2ndwi$clip(extAOI), scale=10)

# 3.1 graficar índice ----
plot(NDWIconce)

# 4. aplicar algoritmo de OTSU ----
Umbral <- OTSU(NDWIconce)

# 5. aplicar el umbral para el índice
Embalse <- NDWIconce < Umbral

# 6. guardar imagen binarizada ----
NombreRaster <- "EmbalseConcepcion.grd"
writeRaster(Embalse, filename = paste0("./resultados/", NombreRaster), overwrite=TRUE)

# 7. Poligonizar con gdal ---- 
#mucho más rápido y eficiente que rasterToPolygon de raster
NombreVector <- "EmbalseConcepcion.gpkg"
system(paste0('gdal_polygonize.py ', 
              "./resultados/", NombreRaster, 
              ' \"./resultados/"', NombreVector, ' \ -b  1 -f "GPKG" DN'))

# 8. graficar resultado ----
Econce <- dplyr::filter(st_read("resultados/EmbalseConcepcion.gpkg", 
                                quiet = TRUE), 
                        DN == 1) %>%
  sf_as_ee()

# 8.1 visualizar datos ----
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
  
# 9. información de la sesión
sessionInfo()

# R version 4.0.5 (2021-03-31)
# Platform: x86_64-pc-linux-gnu (64-bit)
# Running under: Ubuntu 20.04.2 LTS
# 
# Matrix products: default
# BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.9.0
# LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.9.0
# 
# locale:
#   [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=es_HN.UTF-8       
# [4] LC_COLLATE=en_US.UTF-8     LC_MONETARY=es_HN.UTF-8    LC_MESSAGES=en_US.UTF-8   
# [7] LC_PAPER=es_HN.UTF-8       LC_NAME=C                  LC_ADDRESS=C              
# [10] LC_TELEPHONE=C             LC_MEASUREMENT=es_HN.UTF-8 LC_IDENTIFICATION=C       
# 
# attached base packages:
#   [1] stats     graphics  grDevices utils     datasets  methods   base     
# 
# other attached packages:
#   [1] raster_3.4-13 sp_1.4-5      sf_1.0-0      rgee_1.0.8   
# 
# loaded via a namespace (and not attached):
#   [1] Rcpp_1.0.6              lattice_0.20-44         leaflet.providers_1.9.0
# [4] png_0.1-7               class_7.3-19            ps_1.6.0               
# [7] assertthat_0.2.1        digest_0.6.27           utf8_1.2.1             
# [10] V8_3.4.0                R6_2.5.0                e1071_1.7-7            
# [13] httr_1.4.2              geojson_0.3.4           pillar_1.6.1           
# [16] rlang_0.4.11            lazyeval_0.2.2          curl_4.3.2             
# [19] rstudioapi_0.13         geojsonio_0.9.4         Matrix_1.3-3           
# [22] reticulate_1.20         rgdal_1.5-23            googledrive_1.0.1      
# [25] jqr_1.2.0               foreign_0.8-81          htmlwidgets_1.5.3      
# [28] proxy_0.4-26            compiler_4.0.5          base64enc_0.1-3        
# [31] pkgconfig_2.0.3         askpass_1.1             rgeos_0.5-5            
# [34] htmltools_0.5.1.1       openssl_1.4.4           tidyselect_1.1.1       
# [37] tibble_3.1.2            httpcode_0.3.0          codetools_0.2-18       
# [40] fansi_0.5.0             crayon_1.4.1            dplyr_1.0.7            
# [43] rappdirs_0.3.3          crul_1.0.0              grid_4.0.5             
# [46] lwgeom_0.2-6            jsonlite_1.7.2          lifecycle_1.0.0        
# [49] DBI_1.1.1               magrittr_2.0.1          units_0.7-2            
# [52] KernSmooth_2.23-20      cli_2.5.0               fs_1.5.0               
# [55] leaflet_2.0.4.1         ellipsis_0.3.2          generics_0.1.0         
# [58] vctrs_0.3.8             geojsonsf_2.0.1         tools_4.0.5            
# [61] leafem_0.1.6            glue_1.4.2              purrr_0.3.4            
# [64] crosstalk_1.1.1         rsconnect_0.8.16        parallel_4.0.5         
# [67] abind_1.4-5             processx_3.5.2          yaml_2.2.1             
# [70] terra_1.3-4             gargle_0.5.0            stars_0.5-3            
# [73] maptools_1.1-1          classInt_0.4-3
