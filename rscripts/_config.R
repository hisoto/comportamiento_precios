# ─────────────────────────────────────────────────────────────────────────────
# _config.R  —  Configuración central del pipeline comportamiento_precios
#
# Fuente única de la fecha de interés y de las rutas de salida. Todos los scripts
# (datos_03, graphs_01/02/03, resumen_precios, 900_extra_incidencias) leen de aquí.
#
# Mecanismo: los parámetros se publican con options(precios = list(...)). A
# diferencia de una variable ordinaria, options() NO se borra con rm(list = ls()),
# así que cada script puede conservar su rm(list=ls()) al inicio y seguir leyendo
# la config con getOption("precios").
#
# Dos formas de uso:
#   1. Desde un master → el master define anio_interes/mes_interes y luego sourcea
#      este archivo; los valores del master mandan.
#   2. Script suelto   → si el script no encuentra la opción, sourcea este archivo,
#      que cae en los valores por defecto de abajo.
# ─────────────────────────────────────────────────────────────────────────────

if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(here)

# ── verificación del ancla ───────────────────────────────────────────────────
# here::here() se ancla en el WORKING DIRECTORY, no en la ubicación del script.
# Correr desde la raíz del proyecto o desde cualquier subcarpeta suya funciona;
# correr parado fuera, no. Esta guarda evita el caso peor: que here resuelva a
# otro proyecto y las gráficas se escriban en el vecino.
if (!file.exists(here::here("comportamiento_precios.Rproj"))) {
  stop(
    "here::here() resolvió a:\n    ", here::here(), "\n",
    "que no es la raíz de comportamiento_precios.\n\n",
    "Correr desde la raíz del proyecto:\n",
    "    Rscript Master_informe.R\n",
    "o abrir comportamiento_precios.Rproj en Positron/RStudio.",
    call. = FALSE
  )
}

# El theme trae theme_conasami(), guardar_grafica_conasami() y, sobre todo,
# ruta_dt_automatizacion(), que resuelve la carpeta compartida de la DT desde el
# entorno en vez de armarla a mano.
source(here::here("rscripts", "theme_conasami_dt2026.R"))

# ── mes de interés ───────────────────────────────────────────────────────────
# El mes canónico se edita en el master. Estos defaults solo aplican cuando se
# corre un script suelto (sin pasar antes por un master).
#
# Los nombres canónicos son anio_interes / mes_interes, iguales en los cuatro
# proyectos del informe, para que un orquestador global pueda fijar el periodo
# una sola vez. Se aceptan los nombres viejos (año_precios / mes_precios) como
# alias, para no romper scripts o costumbres previas.
if (!exists("anio_interes") && exists("año_precios")) anio_interes <- año_precios
if (!exists("mes_interes")  && exists("mes_precios")) mes_interes  <- mes_precios


# Un orquestador global (Master_CAEL_informe.R, en la raíz de CAEL) fija el mes
# para los cuatro proyectos del informe con estas variables de entorno. Tienen
# prioridad sobre lo escrito en el master: si están, es que alguien está corriendo
# los cuatro proyectos juntos y el periodo debe ser el mismo en todos.
if (nzchar(Sys.getenv("CNSM_ANIO"))) anio_interes <- as.integer(Sys.getenv("CNSM_ANIO"))
if (nzchar(Sys.getenv("CNSM_MES")))  mes_interes  <- as.integer(Sys.getenv("CNSM_MES"))
if (!exists("anio_interes")) anio_interes <- 2026L
if (!exists("mes_interes"))  mes_interes  <- 6L

# Alias hacia atrás: los scripts viejos que leyeran estas variables siguen vivos.
año_precios <- anio_interes
mes_precios <- mes_interes

# ── rutas de salida externas (portables) ─────────────────────────────────────
# ruta_dt_automatizacion() (del theme) resuelve la raíz desde el entorno:
# OneDriveCommercial → OneDrive → USERPROFILE. Antes aquí se armaba a mano con
# un solo nivel de respaldo; el helper tiene tres y es el que usan los demás
# proyectos de Informes/.
dest_graphs <- ruta_dt_automatizacion("graphs")
dest_bases  <- ruta_dt_automatizacion("bases")

# ── interruptor de copia a la carpeta compartida ─────────────────────────────
# proyectosDT es carpeta compartida de la Dirección Técnica. Para pruebas, para
# correr un mes viejo o para verificar portabilidad fuera del árbol CAEL:
#
#   options(cnsm_copiar_dt = FALSE)   # antes de sourcear este archivo
#   Sys.setenv(CNSM_COPIAR_DT = "false")
copiar_dt <- getOption(
  "cnsm_copiar_dt",
  !identical(tolower(Sys.getenv("CNSM_COPIAR_DT", "true")), "false")
)

if (!isTRUE(copiar_dt)) {
  message("· Copia a proyectosDT DESACTIVADA (cnsm_copiar_dt = FALSE). ",
          "Las salidas se quedan en el proyecto.")
  dest_graphs <- NULL
  dest_bases  <- NA_character_
}

# guardar_grafica_conasami() toma su destino de esta opción: así ningún script
# tiene que pasar `dest = ...` en cada llamada.
options(cnsm_dest_graphs = dest_graphs)

# ── dispositivo gráfico en sesiones no interactivas ──────────────────────────
# Bajo Rscript el dispositivo por defecto es pdf(), que no conoce "Noto Sans" y
# aborta con "invalid font type" en cuanto un script hace print() de una gráfica
# (además de dejar un Rplots.pdf en la raíz).
if (!interactive()) {
  options(device = function(...) {
    ragg::agg_png(filename = file.path(tempdir(), "preview_%03d.png"), ...)
  })
}

# ── publicar configuración ───────────────────────────────────────────────────
options(precios = list(
  año           = as.integer(anio_interes),
  mes           = as.integer(mes_interes),
  anio          = as.integer(anio_interes),
  fecha_interes = as.Date(sprintf("%04d-%02d-01", anio_interes, mes_interes)),
  fecha_inicio  = as.Date("2021-01-01"),
  anio_ini      = 2000L,
  anio_fin      = as.integer(anio_interes),
  dest_graphs   = dest_graphs,
  dest_bases    = dest_bases,
  # dest_data conserva la ruta completa del CSV porque datos_03.R la usa tal cual.
  dest_data     = if (is.na(dest_bases)) NA_character_
                  else file.path(dest_bases, "inpc.csv")
))

message(
  "Config del pipeline lista — mes de interés: ",
  format(getOption("precios")$fecha_interes, "%Y-%m")
)
