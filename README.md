# EmbalsesHN

Delimitación de cuerpos de agua, primera prueba para la delimitación de los embalses de Honduras. La delimitación usa el [NDWI](https://en.wikipedia.org/wiki/Normalized_difference_water_index) y calcula el umbral del índice para separar agua de suelo o vegetación usando el algoritmo de [OTSU](https://en.wikipedia.org/wiki/Otsu%27s_method).

Todo esta escrito en R, el acceso a la colección de imágenes Sentinel-2 es usando [GEE](https://earthengine.google.com/) a través del increible paquete [RGEE](https://csaybar.github.io/rgee-examples/) de [Cesar Aybar](https://csaybar.github.io/). 

# Embalse La Concepción Tegucigalpa, Honduras

## Imagen de febrero 2021 composición B8/B4/B3

![](imagenes/uno.png?raw=true)

## Imagen de febrero 2021 composición B8/B4/B3 con delimitación superpuesta

![](imagenes/dos.png?raw=true)
