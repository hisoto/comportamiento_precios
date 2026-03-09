# CLAUDE.md — comportamiento_precios

## Objetivo del proyecto

Pipeline mensual automatizado para descargar series de precios del portal de INEGI, procesarlas en R y renderizar un reporte Quarto (`README.qmd`) sobre el comportamiento de los precios en México. El reporte es de uso institucional en CONASAMI y cubre INPC, INPP y sus desagregaciones.

---

## Estructura de directorios

```
comportamiento_precios/
├── rscripts/
│   ├── datos_01.R        # Catálogo de series (mapeo variable → idEstructura → series → api)
│   ├── datos_02.R        # Función get_inpc_ciudad_df() — web scraping INEGI
│   ├── datos_03.R        # Descarga masiva + limpieza → data/inpc.csv
│   ├── graphs_01.R       # Gráficas de variación anual (series de tiempo, líneas)
│   ├── graphs_02.R       # Gráficas de variación mensual (barras comparativas por año)
│   ├── graphs_03.R       # Gráfica de ciudades (barras ordenadas por inflación)
│   └── theme_conasami.R  # Tema ggplot2 institucional
├── data/
│   ├── inpc.csv          # Base maestra (salida de datos_03.R)
│   └── inpc_api.xlsx     # Catálogo exportado (salida de datos_01.R)
├── graphs/               # PNGs generadas por graphs_01/02/03.R
└── README.qmd            # Reporte Quarto paramétrico
```

---

## Pipeline de ejecución

```
datos_01.R  →  datos_02.R  →  datos_03.R  →  graphs_01/02/03.R  →  README.qmd
(catálogo)     (función)       (descarga)       (PNGs)              (reporte)
```

Orden de ejecución mensual:
1. `datos_01.R` — solo si se agregan series nuevas
2. `datos_03.R` — descarga todo (llama internamente a `datos_01.R` y `datos_02.R`)
3. `graphs_01.R`, `graphs_02.R`, `graphs_03.R` — en cualquier orden
4. Renderizar `README.qmd` en Quarto con `params$año` y `params$mes` actualizados

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
Todas las gráficas usan `theme_conasami()` (definido en `rscripts/theme_conasami.R`):
- Fuente: **Noto Sans** (cargada con `extrafont::loadfonts(device = "win")`)
- Fondo: transparente (`fill = "transparent"`)
- Grid: solo horizontal, color `#F0F0F0FF`
- Sin grid vertical

### Elementos comunes
- Línea de cero: `geom_abline(slope = 0, intercept = 0, linetype = "dotted", color = "black", linewidth = 0.5)`
- Etiqueta del último valor: `geom_text()` filtrando `date == fecha_interes`, `hjust = -0.3`, `fontface = "bold"`
- Leyenda abajo: `theme(legend.position = "bottom")`

### Dimensiones de exportación (scripts standalone)
```r
ggsave(name, plot = last_plot(), width = 50, height = 25, units = "cm", dpi = 300)
# barras comparativas: height = 20
# ciudades:           height = 20, axis.text.x rotado 90°
```

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
4. Guardar con `ggsave()` siguiendo la nomenclatura de nombre

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
