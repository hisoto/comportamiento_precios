# README


## Inflación general, subyacente y no subyacente

Este repositorio contiene los códigos para automatizar la descarga de
las series de tiempo del índice Nacional de Precios al Consumidor, y sus
desagregaciones, para hacer el reporte sobre el comportamiento de los
precios.

El índice de precios al consumidor en April de 2026 registro un valor de
145.831, por su parte los índices subyacente y no subyacente tuvieron un
valor de 144.991329 y 148.2610956, respectivamente.

<img src="README_files/figure-commonmark/unnamed-chunk-2-1.svg"
style="width:100.0%" />

La inflación anual para el INPC general, subyacente y no subyacente fue
de 4.45%, 4.26% y 5.08%, respectivamente. Por su parte, las variaciones
mensuales fueron de 0.2%, 0.31% y -0.18%, respectivamente.

| Variable      | Fecha      |    Valor | Variación anual (%) | Variación mensual (%) |
|:--------------|:-----------|---------:|--------------------:|----------------------:|
| INPC          | 2026-04-01 | 145.8310 |            4.448503 |             0.1971912 |
| No subyacente | 2026-04-01 | 148.2611 |            5.081228 |            -0.1789713 |
| Subyacente    | 2026-04-01 | 144.9913 |            4.261182 |             0.3098724 |

INPC, subyacente y no subyacente al mes de interés

Dentro de la inflación subyacente, el componente de Servicios tuvo una
variación anual de 4.52% y el de Mercancías de 3.99%. Por su parte,
dentro del componente no subyacente, los productos agropecuarios
tuvieron una variación anual de 7.98% y los energéticos y tarifas
autorizadas de 2.8%.

| Variable | Fecha | Valor | Variación anual (%) | Variación mensual (%) |
|:---|:---|---:|---:|---:|
| No subyacente - Agropecuarios | 2026-04-01 | 171.8883 | 7.977537 | 0.8626310 |
| No subyacente - Energéticos y tarifas autorizadas | 2026-04-01 | 131.1316 | 2.795867 | -1.0261202 |
| Subyacente - Mercancias | 2026-04-01 | 151.3459 | 3.988192 | 0.3080357 |
| Subyacente - Servicios | 2026-04-01 | 137.9919 | 4.521679 | 0.3116161 |

Componentes del INPC al mes de interés

<img src="README_files/figure-commonmark/unnamed-chunk-5-1.svg"
style="width:100.0%" />

------------------------------------------------------------------------

## Canasta de consumo mínimo

La inflación de los productos de la canasta básica fue de 4.63% anual y
0.29% mensual. La diferencia en puntos porcentuales entre la inflación
general y la de la canasta de consumo mínimo fue de -0.18 puntos
porcentuales anual y -0.09 puntos porcentuales mensual.

<img src="README_files/figure-commonmark/unnamed-chunk-6-1.svg"
style="width:100.0%" />

## Productos básicos

En esta sección se analiza el comportamiento de cinco productos básico:
Tortilla, Frijol, Huevo, Leche y Carne de res. En April de 2026, la
variación anual de estos productos fue de 1.89% para la tortilla,
-10.98% para el frijol, -17.81% para el huevo, 7.19% para la leche y
8.12% para la carne de res. Por su parte, las variaciones mensuales
fueron de 0.4% para la tortilla, -1.15% para el frijol, -3.48% para el
huevo, 0.32% para la leche y 0.14% para la carne de res.

| Variable  |   Fecha    |   Valor | Variación anual (%) | Variación mensual (%) |
|:----------|:----------:|--------:|--------------------:|----------------------:|
| Carne res | 2026-04-01 | 171.327 |            8.123442 |             0.1437915 |
| Frijol    | 2026-04-01 | 146.784 |          -10.976874 |            -1.1515617 |
| Huevo     | 2026-04-01 | 157.916 |          -17.805595 |            -3.4784575 |
| INPC      | 2026-04-01 | 145.831 |            4.448503 |             0.1971912 |
| Leche     | 2026-04-01 | 171.679 |            7.187498 |             0.3167053 |
| Tortilla  | 2026-04-01 | 160.819 |            1.886063 |             0.4014334 |

INPC, tortilla, frijol, huevo, leche y carne de res al mes de interés

<img src="README_files/figure-commonmark/unnamed-chunk-8-1.svg"
style="width:100.0%" />

## Inflación por Ciudad

La inflación promedio en las ciudades de la Zona Libre de la Frontera
Norte (ZLFN) fue de 3.41.

<img src="README_files/figure-commonmark/unnamed-chunk-10-1.svg"
style="width:100.0%" />

| Ciudad | Fecha | Valor | Variación anual (%) | Variación mensual (%) |
|:---|:---|---:|---:|---:|
| Chetumal, Q.R. | 2026-04-01 | 146.592 | 6.230706 | -0.4333356 |
| Atlacomulco, Méx. | 2026-04-01 | 147.401 | 5.870988 | 0.1487954 |
| Tepatitlán, Jal. | 2026-04-01 | 153.721 | 5.826185 | 0.7742232 |
| Oaxaca, Oax. | 2026-04-01 | 152.500 | 5.575055 | 0.4115226 |
| Cancún, Q. Roo. | 2026-04-01 | 146.591 | 5.480122 | -0.4570024 |
| Tuxtla Gutiérrez, Chis. | 2026-04-01 | 146.781 | 5.423400 | 0.1918089 |
| Jacona, Mich. | 2026-04-01 | 153.212 | 5.211402 | 0.5308294 |
| Campeche, Camp. | 2026-04-01 | 150.457 | 5.099297 | -0.4841622 |
| Tehuantepec, Oax. | 2026-04-01 | 154.377 | 5.011938 | -0.2687460 |
| Guadalajara, Jal. | 2026-04-01 | 148.242 | 4.938202 | 0.7201968 |
| San Luis Potosí, S.L.P. | 2026-04-01 | 148.833 | 4.861449 | 0.4461032 |
| Área Met. de la CDMX | 2026-04-01 | 142.733 | 4.838959 | 0.2817357 |
| Tepic, Nay. | 2026-04-01 | 147.189 | 4.824271 | 0.2349432 |
| Colima, Col. | 2026-04-01 | 147.849 | 4.814332 | 0.3829311 |
| Iguala, Gro. | 2026-04-01 | 145.538 | 4.778223 | -0.2843381 |
| Veracruz, Ver. | 2026-04-01 | 144.522 | 4.748858 | -0.0781277 |
| San Andrés Tuxtla, Ver. | 2026-04-01 | 149.572 | 4.721763 | -0.2008367 |
| Querétaro, Qro. | 2026-04-01 | 145.444 | 4.664585 | 0.4745884 |
| Tulancingo, Hgo. | 2026-04-01 | 143.655 | 4.659041 | 0.0000000 |
| Izúcar de Matamoros, Pue. | 2026-04-01 | 144.465 | 4.623373 | 0.4694346 |
| Durango, Dgo. | 2026-04-01 | 148.805 | 4.611026 | 0.7338158 |
| Cortazar, Gto. | 2026-04-01 | 143.896 | 4.523927 | 0.4720011 |
| León, Gto. | 2026-04-01 | 142.955 | 4.515313 | 0.3721257 |
| Córdoba, Ver. | 2026-04-01 | 151.321 | 4.477478 | 0.6612252 |
| Nacional | 2026-04-01 | 145.831 | 4.448503 | 0.1971912 |
| Torreón, Coah. | 2026-04-01 | 149.366 | 4.434221 | -0.4969623 |
| Coatzacoalcos, Ver. | 2026-04-01 | 143.902 | 4.419821 | -0.6647568 |
| Pachuca, Hgo. | 2026-04-01 | 146.431 | 4.415320 | 0.3185673 |
| Aguascalientes, Ags. | 2026-04-01 | 146.592 | 4.411744 | 0.1208893 |
| Matamoros, Tamps. | 2026-04-01 | 151.752 | 4.324153 | 0.7749776 |
| Tapachula, Chis. | 2026-04-01 | 151.947 | 4.314783 | 0.4973709 |
| Mérida, Yuc. | 2026-04-01 | 151.784 | 4.312448 | -0.5764293 |
| Puebla, Pue. | 2026-04-01 | 147.550 | 4.277829 | 0.2336861 |
| Chihuahua, Chih. | 2026-04-01 | 144.225 | 4.254766 | 0.7038271 |
| Zacatecas, Zac. | 2026-04-01 | 145.176 | 4.186821 | 0.6538032 |
| Morelia, Mich. | 2026-04-01 | 146.144 | 4.160905 | 0.4032784 |
| Cd. Jiménez, Chih. | 2026-04-01 | 145.001 | 4.158406 | 0.8857008 |
| Acapulco, Gro. | 2026-04-01 | 148.926 | 4.137502 | 0.8778704 |
| Esperanza, Son. | 2026-04-01 | 144.797 | 4.008878 | 0.3750277 |
| Monclova, Coah. | 2026-04-01 | 140.340 | 3.934769 | -0.8113762 |
| Toluca, Edo. de Méx. | 2026-04-01 | 139.448 | 3.934590 | -0.3052726 |
| Tampico, Tamps. | 2026-04-01 | 139.914 | 3.834594 | -0.5649958 |
| Cuernavaca, Mor. | 2026-04-01 | 145.042 | 3.800874 | 0.0482852 |
| Monterrey, N.L. | 2026-04-01 | 142.780 | 3.749455 | -0.4441593 |
| Culiacán, Sin. | 2026-04-01 | 149.841 | 3.718445 | 0.5867071 |
| Saltillo, Coah. | 2026-04-01 | 144.048 | 3.715224 | 0.3972734 |
| Villahermosa, Tab. | 2026-04-01 | 140.029 | 3.670662 | -1.7416199 |
| Huatabampo, Son. | 2026-04-01 | 148.219 | 3.585181 | 0.0438733 |
| Cd. Juárez, Chih. | 2026-04-01 | 144.553 | 3.581384 | 0.4866079 |
| Hermosillo, Son. | 2026-04-01 | 143.810 | 3.546099 | 0.3586981 |
| Fresnillo, Zac. | 2026-04-01 | 149.975 | 3.538143 | 0.6077722 |
| Mexicali, B.C. | 2026-04-01 | 145.919 | 3.526833 | 0.4059754 |
| Tlaxcala, Tlax. | 2026-04-01 | 144.118 | 3.371157 | -0.0291343 |
| Cd. Acuña, Coah. | 2026-04-01 | 143.616 | 3.264402 | -1.8694654 |
| La Paz, B.C.S. | 2026-04-01 | 140.384 | 2.987265 | 0.3574390 |
| Tijuana, B.C. | 2026-04-01 | 147.779 | 2.369803 | 0.4773010 |

Inflación por ciudad al mes de interés

## índice Nacional de Precios al Productor

El INPP registró una variación anual de 1.96% y una variación mensual de
-0.15% en April de 2026.

Por grupos de actividad económica, el INPP primarias, el INPP
secundarias sin petróleo y el INPP terciarias tuvieron una variación
anual de -3.94%, 1.25%, y 3.98%, respectivamente. Las variaciones
mensuales para el INPP primarias, el INPP secundarias sin petróleo y el
INPP terciarias fueron de -1.51%, -0.21% y 0.14%, respectivamente.

<img src="README_files/figure-commonmark/unnamed-chunk-12-1.svg"
style="width:100.0%" />

El INPP de bienes finales tuvo una variación anual de 2.33% y una
variación mensual de 0.01%. Por su parte, el INPP intermedios tuvo una
variación anual de 1.05% y una variación mensual de -0.55%.

<img src="README_files/figure-commonmark/unnamed-chunk-13-1.svg"
style="width:100.0%" />
