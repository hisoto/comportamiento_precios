# CLAUDE.md — comportamiento_precios

## Objetivo del proyecto

Pipeline mensual automatizado, orquestado desde **`Master.R`**, para descargar series de precios del portal de INEGI, procesarlas en R, generar las gráficas institucionales e imprimir un resumen de cifras en consola. Es de uso institucional en CONASAMI y cubre INPC, INPP y sus desagregaciones. El reporte Quarto (`README.qmd`) es un flujo personal complementario, fuera del Master.

---

## Estructura de directorios

```
comportamiento_precios/
├── comportamiento_precios.Rproj  # Ancla de here::here() — abrir el proyecto desde aquí
├── Master.R              # Orquestador LOCAL COMPLETO: informe + extras
├── Master_informe.R      # Orquestador del INFORME (sin extras) ← el que corre la copia DT
├── LEEME_DT.md           # Guía de arranque para quien corre sin contexto
├── rscripts/
│   ├── _config.R                 # Config central: fecha de interés + rutas → options(precios)
│   ├── _correr_pasos.R           # Motor compartido de los dos masters (tryCatch + resumen)
│   ├── 000_requisitos.R          # Prepara el equipo. Una vez por máquina
│   ├── 900_extra_incidencias.R   # EXTRA: no va al informe
│   ├── datos_01.R                # Catálogo de series (mapeo variable → idEstructura → series → api)
│   ├── datos_02.R                # Función get_inpc_ciudad_df() — web scraping INEGI
│   ├── datos_03.R                # Descarga masiva + limpieza → data/inpc.csv
│   ├── graphs_01.R               # Gráficas de variación anual (series de tiempo, líneas)
│   ├── graphs_02.R               # Gráficas de variación mensual (barras comparativas por año)
│   ├── graphs_03.R               # Gráfica de ciudades (barras ordenadas por inflación)
│   ├── resumen_precios.R         # Imprime en consola las cifras narradas del README
│   ├── theme_conasami_dt2026.R   # Tema ggplot2 institucional DT 2026 (vigente; lo usan las gráficas)
│   └── theme_conasami.R          # Tema viejo (solo lo usa README.qmd; pendiente de migrar)
├── data/
│   ├── inpc.csv          # Base maestra (salida de datos_03.R)
│   └── inpc_api.xlsx     # Catálogo exportado (salida de datos_01.R)
├── graphs/               # PNGs + SVGs generadas por graphs_01/02/03.R
└── README.qmd            # Reporte Quarto paramétrico (uso personal; aún con theme viejo)
```

---

## Pipeline de ejecución

**Hay dos masters**, con el mismo mecanismo y distinto alcance:

| Master | Corre | Para qué |
|---|---|---|
| `Master.R` | todo, **incluido `900_extra_incidencias.R`** | Trabajo diario en local |
| `Master_informe.R` | solo lo que va al informe | **Es el que corre la copia de la carpeta compartida de la DT** |

```
Master_informe.R
  ├─ _config.R           # publica fecha_interes, fecha_inicio, anio_ini/fin y rutas en options(precios)
  ├─ datos_03.R          # solo si correr_datos = TRUE (sourcea datos_01.R + datos_02.R)
  ├─ graphs_01.R → graphs_02.R → graphs_03.R
  └─ resumen_precios.R   # imprime en consola las cifras clave del mes
```

Los dos comparten el motor `rscripts/_correr_pasos.R`, que aísla cada paso con `tryCatch` y
cierra con un resumen OK/ERROR: un fallo en `graphs_02.R` ya no impide que corran los demás.
El guion inicial del nombre lo deja fuera de la secuencia del pipeline: es infraestructura.

**Para probar sin escribir en `proyectosDT`** (carpeta compartida):

```bash
Rscript -e "Sys.setenv(CNSM_COPIAR_DT='false'); source('Master_informe.R')"
```

Uso mensual:
1. Editar `anio_interes` / `mes_interes` al inicio del master (**única edición mensual**).
2. `correr_datos <- TRUE` para re-descargar de INEGI (~1-2 min de scraping); `FALSE` para
   solo regenerar gráficas + resumen con el `data/inpc.csv` existente.
3. Ejecutar `Master.R`.
4. (Flujo personal, fuera del Master) Renderizar `README.qmd` con `params$año`/`params$mes`.

`datos_01.R` solo requiere corrida manual si se agregan series nuevas (regenera
`data/inpc_api.xlsx`). Cada script sigue siendo ejecutable **suelto** (ver sección
siguiente).

---

## Configuración central (`rscripts/_config.R`)

Los parámetros del pipeline viven en `options(precios = list(...))`, publicados por
`_config.R`. Clave del diseño: `options()` **sobrevive** al `rm(list = ls()); gc()` con
que inicia cada script, así que todos leen la misma configuración sin importar el orden.
**No quitar los `rm(list = ls())` de los scripts ni pasar parámetros por variables
globales**: el canal es `options(precios)`.

- **Desde un master:** el master define `anio_interes`/`mes_interes` y sourcea `_config.R`;
  esos valores mandan. Los nombres viejos (`año_precios`/`mes_precios`) siguen funcionando
  como alias — el nombre canónico se unificó con los otros tres proyectos del informe para
  que un orquestador global pueda fijar el periodo una sola vez.
- **Script suelto:** cada script trae el fallback
  `if (is.null(getOption("precios"))) source(here::here("rscripts", "_config.R"))` y usa
  los defaults de `_config.R`.

**Rutas:** desde agosto de 2026 todos los scripts resuelven sus rutas con `here::here()`,
anclado en `comportamiento_precios.Rproj`. Antes usaban rutas relativas puras
(`"data/inpc.csv"`) y dependían de que `Master.R` hiciera `setwd()`; ese `setwd()` se
quitó. `_config.R` trae una guarda que aborta con un mensaje claro si `here` resuelve fuera
del proyecto — el caso peligroso era que resolviera a otro proyecto y las gráficas se
escribieran en el vecino.

Contenido de `options(precios)` (se accede con `cfg <- getOption("precios")`):

| Elemento | Descripción |
|---|---|
| `año`, `mes` | Mes de interés (canónico: se edita en `Master.R`) |
| `fecha_interes` | Primer día del mes de interés — último punto de todas las gráficas |
| `fecha_inicio` | `2021-01-01` — inicio de las series de tiempo y de las barras por año (`graphs_03.R` no lo usa: es corte transversal de un solo mes) |
| `anio_ini`, `anio_fin` | Rango de descarga INEGI (`2000` → año de interés) |
| `dest_graphs`, `dest_bases`, `dest_data` | Copias externas al flujo Word de la DT. Se derivan de **`ruta_dt_automatizacion()`** (del theme), que resuelve la raíz desde el entorno con tres niveles de respaldo: `OneDriveCommercial` → `OneDrive` → `USERPROFILE`. Antes se armaban a mano aquí con un solo nivel. Si la carpeta no existe, las copias se omiten con mensaje, nunca en silencio |
| — | Con `options(cnsm_copiar_dt = FALSE)` o `CNSM_COPIAR_DT=false` los tres quedan en `NULL`/`NA` y **nada sale hacia `proyectosDT`**. Es lo que hay que usar para pruebas: esa carpeta es compartida |

**`rscripts/resumen_precios.R`** (último paso del Master) recalcula desde `data/inpc.csv`
e imprime en consola las cifras que en el flujo personal se narran en `README.qmd`:
INPC/subyacente/no subyacente, componentes, INPC CCM y su brecha, productos básicos,
promedio anual de la ZLFN e INPP. Así quien clone el proyecto obtiene el resumen numérico
sin renderizar el Quarto.

Su **sección 7** imprime además el cuadro del tablero institucional: variación **mensual y
anual** de la inflación general, subyacente y no subyacente en los **últimos 13 meses**
(meses como columnas, agrupadas por año). El mismo cuadro se exporta a
`data/tabla_inflacion_{YYYY}m{MM}.csv` (con copia a la carpeta `bases/` de la DT si existe),
listo para pegar en el cuadro de Word.

---

## Base de datos maestra: `data/inpc.csv`

Columnas:

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `variable` | chr | Nombre legible de la serie (ej. `"INPC"`, `"Subyacente"`, `"Tortilla"`) |
| `api` | chr | Clave interna (ej. `"v_inpc"`, `"v_ciudad_874528"`) |
| `year` | int | Año |
| `month` | int | Mes (1–12) |
| `date` | Date | Primer día del mes (`YYYY-MM-01`) |
| `valor` | dbl | Nivel del índice |
| `periodo` | chr | Texto original del portal INEGI (ej. `"Ene 2024"`) |

En los scripts de gráficas y en el Quarto se calculan en línea:
- `var_anual = (valor / lag(valor, 12) - 1) * 100`
- `var_mensual = (valor / lag(valor, 1) - 1) * 100`

---

## Series disponibles (columna `variable` → `api`)

### INPC general y componentes
| variable | api |
|----------|-----|
| `"INPC"` | `"v_inpc"` |
| `"Subyacente"` | `"v_subyacente"` |
| `"Subyacente - Mercancias"` | `"v_subyacente_mercancias"` |
| `"Subyacente - Servicios"` | `"v_subyacente_servicios"` |
| `"No subyacente"` | `"v_inpc_nsubyacente"` |
| `"No subyacente - Agropecuarios"` | `"v_nsubyacente_agropecuarios"` |
| `"No subyacente - Energéticos y tarifas autorizadas"` | `"v_nsubyacente_energeticos"` |
| `"INPC CCM"` | `"v_inpc_ccm"` |

### INPC quincenal
| variable | api |
|----------|-----|
| `"INPC quincenal"` | `"v_inpc_quincenal"` |
| `"INPC quincenal subyacente"` | `"v_subyacente_quincenal"` |
| `"INPC quincenal nsubyacente"` | `"v_nsubyacente_quincenal"` |

### Productos básicos
| variable | api |
|----------|-----|
| `"Tortilla"` | `"v_tortilla"` |
| `"Frijol"` | `"v_frijol"` |
| `"Huevo"` | `"v_huevo"` |
| `"Leche"` | `"v_leche"` |
| `"Carne res"` | `"v_carne_res"` |

### INPP
| variable | api |
|----------|-----|
| `"INPP sin petróleo"` | `"v_inpp"` |
| `"INPP primarias"` | `"v_inpp_primarias"` |
| `"INPP secundarias sin petróleo"` | `"v_inpp_secundarias"` |
| `"INPP terciarias"` | `"v_inpp_terciarias"` |
| `"INPP finales"` | `"v_inpp_finales"` |
| `"INPP intermedios"` | `"v_inpp_intermedios"` |

### Ciudades (46 + Nacional)
- `api` sigue el patrón `"v_ciudad_XXXXXX"` (número = serie INEGI)
- `"Nacional"` → `"v_ciudad_inpc"`
- Filtrar ciudades: `filter(str_starts(api, "v_ciudad"))`

**Ciudades ZLFN** (Zona Libre de la Frontera Norte):
`"Cd. Juárez, Chih."`, `"Matamoros, Tamps."`, `"Cd. Acuña, Coah."`, `"Tijuana, B.C."`, `"Mexicali, B.C."`

---

## Reporte Quarto (`README.qmd`)

**Flujo personal de Héctor, fuera del Master**: no lo corre `Master.R` (las cifras que
narra las imprime `resumen_precios.R` en consola). Se renderiza aparte y mantiene sus
propios `params$año`/`params$mes` (sincronizarlos a mano con `Master.R`). Pendiente:
migrarlo del theme viejo (`theme_conasami.R`) al DT 2026.

### Parámetros
```yaml
params:
  año: 2026
  mes: 1   # número de mes (1 = enero)
```

### Variables de control (dentro de los chunks)
```r
fecha_interes <- ymd(sprintf("%s-%s-01", params$año, params$mes))
fecha_inicio  <- "2021-01-01"   # inicio fijo de todas las series en gráficas
```

### Base de datos en el reporte
```r
base <- fread("data/inpc.csv") |>
  arrange(variable, date) |>
  group_by(variable) |>
  mutate(
    var_anual   = ((valor / lag(valor, 12) - 1) * 100),
    var_mensual = ((valor / lag(valor, 1)  - 1) * 100)
  ) |>
  filter(date >= fecha_inicio & date <= fecha_interes)
```

### Estilo de texto en el Quarto
Los chunks del Quarto añaden este override al `theme_conasami()` para que el texto sea blanco (fondo oscuro del reporte):
```r
theme(
  legend.position = "bottom",
  text       = element_text(color = "white"),
  axis.text  = element_text(color = "white"),
  axis.title = element_text(color = "white"),
  axis.ticks = element_line(color = "white")
)
```
Los scripts standalone (`graphs_01/02/03.R`) **no** tienen este override (texto negro) y usan tamaños grandes (`size = 6`, `axis.text = 20`).

---

## Paleta de colores institucional

| Uso | Color hex |
|-----|-----------|
| INPC general / Nacional | `#a57f2c` (dorado) |
| Subyacente / ZLFN / CCM | `#611232` (guinda oscuro) |
| No subyacente / ZSMG / INPP terciarias | `#1e5b4f` (verde) |
| INPP primarias / Leche | `#9b2247` (rosa institucional) |
| Huevo | `#161a1d` (negro) |
| Frijol / INPP terciarias (alt) | `#98989A` (gris) |
| Carne cerdo (no activo) | `#2e6f6f` (teal) |

---

## Convenciones de gráficas

### Tema base
Los scripts de gráficas usan `theme_conasami()` del **theme DT 2026**
(`rscripts/theme_conasami_dt2026.R`, copia del canon en la raíz CAEL; **no editarla
localmente**, ver `GUIA_GRAFICAS_DT2026.md`):
- Fuente: **Noto Sans** (numerales de eje/leyenda en la variante `"Noto Sans Tab"`),
  resuelta vía `systemfonts`/`ragg` (ya no `extrafont`)
- Fondo transparente; grid solo horizontal (`#ECE8DE`); leyenda abajo
- `README.qmd` aún usa el theme viejo (`rscripts/theme_conasami.R`) — pendiente de migrar

### Elementos comunes
- Línea de cero: `geom_abline(slope = 0, intercept = 0, linetype = "dotted", color = "black", linewidth = 0.4)`
- Etiqueta del último valor: `geom_text_repel()` filtrando `date == fecha_interes`,
  `nudge_x = 30`, `fontface = "bold"`, tamaño `lab_size` (pt → mm vía `/.pt`)
- Leyenda abajo (la trae el theme)

### Exportación
Con `guardar_grafica_conasami()` (helper del theme DT 2026):
```r
guardar_grafica_conasami(last_plot(), archivo, tamano = "ancho", dest = dest_graphs)
```
- Genera **PNG 300 dpi + SVG** en `graphs/` (tamaños del Manual: `"ancho"` 17.5×8 cm,
  `"medio"` 8×8 cm, `"libre"` con `width`/`height`)
- `dest = dest_graphs` (de `cfg$dest_graphs`) copia además el **SVG** a la carpeta DT
  externa (`dest_formato = "svg"` es el default del theme desde 2026-07-27; antes
  copiaba el PNG). Si la carpeta no existe, avisa con `message()` y sigue

### Nomenclatura de archivos PNG
```
graphs/va_{tipo}_{variable}_{año}m{mes}.png
```
Ejemplos:
- `va_anual_inpc_2026m02.png`
- `va_mensual_inpp_2026m01.png`
- `va_anual_inpc_ciudades_2026m01.png`

---

## Agregar una nueva gráfica

### En `graphs_01.R` / `graphs_02.R` (series de tiempo o barras)
1. Filtrar `base` con las variables deseadas usando sus nombres exactos de `variable`
2. Construir el `ggplot` siguiendo el patrón existente (ver gráficas de INPC o INPP)
3. Definir colores con `scale_color_manual()` usando la paleta institucional
4. Guardar con `guardar_grafica_conasami(last_plot(), archivo, tamano = "ancho", dest = dest_graphs)`
   siguiendo la nomenclatura de nombre (`archivo <- paste0("va_..._", format(fecha_interes, "%Ym%m"))`)
5. Si la cifra se narra en el reporte, considerar añadirla también a `resumen_precios.R`

### En `README.qmd` (reporte)
1. Agregar un chunk con el mismo código de la gráfica
2. Usar `size = 2.5` en `geom_text()` (no `size = 6`)
3. Agregar el override de texto blanco al final del `theme_conasami()`
4. Añadir texto narrativo con inline R: `` `r round(base[base$date == fecha_interes & base$variable == "X", "var_anual"], 2)` ``

---

## Agregar una nueva serie de datos

1. En `datos_01.R`, agregar fila al tibble `temp` con `variable`, `idEstructura`, `series`, y `api`
2. Correr `datos_01.R` para actualizar `data/inpc_api.xlsx`
3. Correr `datos_03.R` para re-descargar todo incluyendo la nueva serie
4. La nueva variable quedará disponible en `data/inpc.csv` con su nombre en `variable`

---

## Web scraping — función `get_inpc_ciudad_df()`

Ubicada en `rscripts/datos_02.R`. Recibe:
- `idEstructura`: clave de estructura del portal INEGI
- `series`: identificador de serie (`"e|XXXXXX"`)
- `anio_ini`, `anio_fin`: rango de años

Flujo interno:
1. **GET** `https://www.inegi.org.mx/app/indicesdepreciosv2/Estructura.aspx?idEstructura={id}` — extrae tokens ASP.NET (`__VIEWSTATE`, `__VIEWSTATEGENERATOR`, `__EVENTVALIDATION`)
2. **POST** `https://www.inegi.org.mx/app/indicesdepreciosv2/Exportacion.aspx` — obtiene tabla HTML
3. Parsea filas `td.fecha` de `table#TableCuadro` → devuelve tibble con `periodo` (texto) y `valor` (texto)

`datos_03.R` convierte `periodo` a fecha con un diccionario de meses en español.
