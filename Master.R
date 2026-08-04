# ─────────────────────────────────────────────────────────────────────────────
# Master.R  —  Orquestador del pipeline comportamiento_precios
#
# Corre el flujo mensual completo desde un solo lugar:
#   descarga INEGI (datos) → gráficas → resumen de cifras en consola.
#
# Uso: editar el mes de interés abajo y ejecutar este archivo. El único parámetro
# que cambia cada mes es año_precios / mes_precios; se propaga a todos los scripts.
#
# El resumen final imprime en consola las cifras que en el flujo personal viven en
# el README.qmd, de modo que quien clone el proyecto obtiene los números sin
# renderizar el reporte.
# ─────────────────────────────────────────────────────────────────────────────

rm(list = ls()); gc()

# Ubicarse en la raíz del proyecto (los scripts usan rutas relativas: "rscripts/",
# "data/"). here detecta la raíz por el .git del repositorio.
if (!requireNamespace("here", quietly = TRUE)) install.packages("here")
setwd(here::here())

# ── parámetros del mes ───────────────────────────────────────────────────────
año_precios  <- 2026L
mes_precios  <- 6L                  # 1 = enero, ..., 12 = diciembre

correr_datos <- FALSE               # FALSE = saltar la descarga INEGI (~1-2 min)
                                    # y solo regenerar gráficas + resumen

# ── configuración central ────────────────────────────────────────────────────
# Publica fecha_interes, fecha_inicio, anio_ini/fin y rutas de salida en
# options(precios). Todos los pasos leen de ahí (sobrevive a rm(list=ls())).
source("rscripts/_config.R")

# ── pipeline ─────────────────────────────────────────────────────────────────
if (correr_datos) {
  source("rscripts/datos_03.R")     # sourcea datos_01 (catálogo) y datos_02 (scraping)
}

source("rscripts/graphs_01.R")      # variación anual (series de tiempo)
source("rscripts/graphs_02.R")      # variación mensual (barras por año)
source("rscripts/graphs_03.R")      # inflación por ciudad (barras ordenadas)

# ── resumen de cifras en consola ─────────────────────────────────────────────
source("rscripts/resumen_precios.R")

# ─────────────────────────────────────────────────────────────────────────────
# Reporte Quarto (opcional, flujo personal — NO forma parte del Master):
#   quarto render README.qmd -P año:2026 -P mes:6
# Nota: README.qmd aún sourcea theme_conasami.R (theme viejo) y usa sus propios
# params$año/params$mes; queda como pendiente de migración a theme_conasami_dt2026.R.
# ─────────────────────────────────────────────────────────────────────────────
