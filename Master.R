# ─────────────────────────────────────────────────────────────────────────────
# Master.R  —  Orquestador del flujo LOCAL COMPLETO
#
# Corre el flujo mensual entero desde un solo lugar: descarga INEGI (opcional) →
# gráficas del informe → material complementario (9xx_extra_*) → resumen de
# cifras en consola.
#
# Uso: editar el mes de interés abajo y ejecutar este archivo. El único parámetro
# que cambia cada mes es anio_interes / mes_interes; se propaga a todos los
# scripts vía _config.R.
#
# ¿Cuál master usar?
#   · Master.R          → todo (este). Es el de trabajo diario.
#   · Master_informe.R  → solo lo que va al informe. Es el que corre la copia de
#                         la carpeta compartida de la DT.
#
# El resumen final imprime en consola las cifras que en el flujo personal viven
# en el README.qmd, de modo que quien clone el proyecto obtiene los números sin
# renderizar el reporte.
# ─────────────────────────────────────────────────────────────────────────────

rm(list = ls()); gc()

# ── parámetros del mes ───────────────────────────────────────────────────────
# ESTAS SON LAS ÚNICAS LÍNEAS QUE SE ACTUALIZAN CADA MES.

anio_interes <- 2026L
mes_interes  <- 6L                  # 1 = enero, ..., 12 = diciembre

correr_datos <- FALSE               # FALSE = saltar la descarga INEGI (~1-2 min)
                                    # y solo regenerar gráficas + resumen

# ── configuración central ────────────────────────────────────────────────────
# Publica fecha_interes, fecha_inicio, anio_ini/fin y rutas de salida en
# options(precios). Todos los pasos leen de ahí (sobrevive a rm(list=ls())).
#
# Ya no hace falta setwd(): los scripts resuelven sus rutas con here::here(),
# anclado en comportamiento_precios.Rproj. _config.R aborta con un mensaje claro
# si here resuelve fuera del proyecto.

if (!requireNamespace("here", quietly = TRUE)) install.packages("here")
source(here::here("rscripts", "_config.R"))

# ── pipeline ─────────────────────────────────────────────────────────────────

pasos <- c(
  if (correr_datos) "datos_03.R",   # sourcea datos_01 (catálogo) y datos_02 (scraping)
  "graphs_01.R",                    # variación anual (series de tiempo)
  "graphs_02.R",                    # variación mensual (barras por año)
  "graphs_03.R",                    # inflación por ciudad (barras ordenadas)
  "900_extra_incidencias.R",        # EXTRA: no va al informe
  "resumen_precios.R"               # cifras en consola + tabla_inflacion_{per}.csv
)

if (!correr_datos) {
  message("· datos_03.R omitido (correr_datos = FALSE). ",
          "Se usa el data/inpc.csv en disco.")
}

source(here::here("rscripts", "_correr_pasos.R"))

# ─────────────────────────────────────────────────────────────────────────────
# Reporte Quarto (opcional, flujo personal — NO forma parte del Master):
#   quarto render README.qmd -P año:2026 -P mes:6
# Nota: README.qmd aún sourcea theme_conasami.R (theme viejo) y usa sus propios
# params$año/params$mes; queda como pendiente de migración a theme_conasami_dt2026.R.
# ─────────────────────────────────────────────────────────────────────────────
