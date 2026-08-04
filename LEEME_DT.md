# Comportamiento de precios — cómo correrlo

Genera las gráficas y el cuadro de la sección **Comportamiento de los precios** del informe
mensual de la Dirección Técnica, más el `inpc.csv` del que dependen otros proyectos.

Contacto: Héctor Iván Soto Parra — CAEL, CONASAMI.

---

## La primera vez en esta computadora

1. Abrir **`comportamiento_precios.Rproj`** (Positron o RStudio). Esto ancla las rutas.

2. Correr una sola vez:

   ```
   Rscript rscripts/000_requisitos.R
   ```

   Instala los paquetes y revisa lo que falla callado al cambiar de equipo:

   - **La tipografía Noto Sans.** Si falta, las gráficas se generan igual pero con otra
     letra, fuera del canon DT 2026, y solo avisan con un *warning*.
   - **La carpeta compartida de la DT.** Si no aparece, las copias externas se omiten.
   - **`data/inpc.csv`.** Con ese archivo en disco el pipeline corre sin tocar internet.

**No hay credenciales que configurar.** Este proyecto no usa la API del INEGI con token:
descarga del portal público de índices de precios.

---

## Cada mes

1. **Editar dos líneas** al inicio de `Master_informe.R`:

   ```r
   anio_interes <- 2026L
   mes_interes  <- 6L
   ```

2. **Decidir si hay que re-descargar.** En la misma sección:

   ```r
   correr_datos <- FALSE   # TRUE = bajar del INEGI (~1-2 min)
   ```

   Ponerlo en `TRUE` cuando el INEGI ya publicó el mes nuevo. En `FALSE` solo regenera las
   gráficas con lo que ya está en `data/inpc.csv`.

3. **Correr el master:**

   ```
   Rscript Master_informe.R
   ```

---

## Qué produce

**Gráficas** — PNG en `graphs/` y SVG en la carpeta `graphs/` de la DT, que es de donde las
toma el Word. Son 10:

| Script | Archivos |
|---|---|
| `graphs_01.R` | `va_anual_inpc` · `va_anual_inpc_ccm` · `va_anual_inpc_productos` · `va_anual_inpp` · `va_anual_inpp_finales_intermedios` · `va_anual_inpc_quincenal` |
| `graphs_02.R` | `va_mensual_inpc` · `va_mensual_inpp` · `va_mensual_inpc_quincenal` |
| `graphs_03.R` | `va_anual_inpc_ciudades` |

Todas con sufijo `_{año}m{mes}`, por ejemplo `va_anual_inpc_2026m06.svg`.

**Datos** — a `bases/` de la DT:

| Archivo | Para qué |
|---|---|
| `inpc.csv` | Base maestra. **La consume también Negociación laboral** (`901_extra_mir.R`) |
| `tabla_inflacion_{per}.csv` | Alimenta el Tablero de indicadores del informe |

**En consola**, `resumen_precios.R` imprime las cifras que el informe narra en prosa:
INPC, subyacente y no subyacente, componentes, canasta de consumo mínimo, productos
básicos, promedio de la ZLFN e INPP.

---

## Cosas que conviene saber

- **`Master.R` vs `Master_informe.R`.** `Master_informe.R` genera lo que va al informe y
  nada más; es el que corre la copia de la carpeta compartida. `Master.R` corre además
  `900_extra_incidencias.R`, que produce una gráfica de áreas apiladas que **no** aparece
  en el informe.

- **El orden importa entre proyectos.** Este proyecto deja `inpc.csv` en `bases/` de la DT,
  y Negociación laboral lo lee de ahí. Si se corren los cuatro proyectos del informe,
  este va primero.

- **Para hacer pruebas sin escribir en la carpeta compartida:**

  ```
  Rscript -e "Sys.setenv(CNSM_COPIAR_DT='false'); source('Master_informe.R')"
  ```

- **`proyectosDT` es carpeta compartida de la Dirección Técnica.** El pipeline solo agrega
  y sobrescribe sus propios archivos del mes. No borrar nada de ahí.

- **`README.qmd` es un flujo aparte**, personal, que no corre ningún master y todavía usa
  el theme viejo. Las cifras que narra ya las imprime `resumen_precios.R` en consola.
