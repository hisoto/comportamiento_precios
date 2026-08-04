# ─────────────────────────────────────────────────────────────────────────────
# Master_informe.R  —  Solo lo que va al informe mensual
#
# Genera las 10 gráficas y el cuadro de inflación de la sección "Comportamiento
# de los precios" del informe de la Dirección Técnica, y nada más.
#
# Es el master que corre la copia de la carpeta compartida de la DT. La
# diferencia con Master.R es que este NO ejecuta 900_extra_incidencias.R.
#
# Uso: editar el mes de interés abajo y ejecutar este archivo.
#
#   Rscript Master_informe.R
#   # o, desde Positron:  source(here::here("Master_informe.R"))
#
# ─────────────────────────────────────────────────────────────────────────────

rm(list = ls()); gc()

# ── parámetros del mes ───────────────────────────────────────────────────────
# ESTAS SON LAS ÚNICAS LÍNEAS QUE SE ACTUALIZAN CADA MES.

anio_interes <- 2026L
mes_interes  <- 6L                  # 1 = enero, ..., 12 = diciembre

correr_datos <- FALSE               # TRUE  = re-descargar de INEGI (~1-2 min)
                                    # FALSE = regenerar gráficas y cuadro con el
                                    #         data/inpc.csv que ya está en disco

# El orquestador de los cuatro proyectos (CAEL/Master_CAEL_informe.R) puede
# fijarlo para todos a la vez; si está, manda sobre la línea de arriba.
if (nzchar(Sys.getenv("CNSM_CORRER_DATOS"))) {
  correr_datos <- identical(tolower(Sys.getenv("CNSM_CORRER_DATOS")), "true")
}

# ── configuración central ────────────────────────────────────────────────────
# Publica fecha_interes, fecha_inicio, anio_ini/fin y rutas de salida en
# options(precios). Todos los pasos leen de ahí (sobrevive a rm(list = ls())).

if (!requireNamespace("here", quietly = TRUE)) install.packages("here")
source(here::here("rscripts", "_config.R"))

# ── pasos del informe ────────────────────────────────────────────────────────
# 900_extra_incidencias.R NO va aquí a propósito: ver Master.R para el flujo
# local completo.

pasos <- c(
  if (correr_datos) "datos_03.R",   # sourcea datos_01 (catálogo) y datos_02 (scraping)
  "graphs_01.R",                    # variación anual (series de tiempo)
  "graphs_02.R",                    # variación mensual (barras por año)
  "graphs_03.R",                    # inflación por ciudad (barras ordenadas)
  "resumen_precios.R"               # cifras en consola + tabla_inflacion_{per}.csv
)

if (!correr_datos) {
  message("· datos_03.R omitido (correr_datos = FALSE). ",
          "Se usa el data/inpc.csv en disco.")
}

source(here::here("rscripts", "_correr_pasos.R"))
