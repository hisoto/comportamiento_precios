# ─────────────────────────────────────────────────────────────────────────────
# _config.R  —  Configuración central del pipeline comportamiento_precios
#
# Fuente única de la fecha de interés y de las rutas de salida. Todos los scripts
# (datos_03, graphs_01/02/03, resumen_precios) leen de aquí.
#
# Mecanismo: los parámetros se publican con options(precios = list(...)). A
# diferencia de una variable ordinaria, options() NO se borra con rm(list = ls()),
# así que cada script puede conservar su rm(list=ls()) al inicio y seguir leyendo
# la config con getOption("precios").
#
# Dos formas de uso:
#   1. Desde Master.R  → Master define año_precios/mes_precios y luego sourcea este
#      archivo; los valores del Master mandan.
#   2. Script suelto   → si el script no encuentra la opción, sourcea este archivo,
#      que cae en los valores por defecto de abajo.
# ─────────────────────────────────────────────────────────────────────────────

# ── mes de interés ───────────────────────────────────────────────────────────
# El mes canónico se edita en Master.R. Estos defaults solo aplican cuando se
# corre un script suelto (sin pasar antes por Master.R): ajústalos si trabajas
# mucho fuera del Master.
if (!exists("año_precios")) año_precios <- 2026L
if (!exists("mes_precios")) mes_precios <- 6L

# ── rutas de salida externas (portables) ─────────────────────────────────────
# Se derivan de USERPROFILE para no depender del nombre de usuario de la máquina.
# La copia externa alimenta el flujo de Word de la Dirección Técnica; si la
# carpeta no existe, los pasos que escriben ahí la omiten sin error.
dt_base <- file.path(
  Sys.getenv("USERPROFILE"),
  "OneDrive - Comision Nacional de los Salarios Minimos",
  "proyectosDT", "informes", "automatizacion"
)

# ── publicar configuración ───────────────────────────────────────────────────
options(precios = list(
  año           = as.integer(año_precios),
  mes           = as.integer(mes_precios),
  fecha_interes = as.Date(sprintf("%04d-%02d-01", año_precios, mes_precios)),
  fecha_inicio  = as.Date("2021-01-01"),
  anio_ini      = 2000L,
  anio_fin      = as.integer(año_precios),
  dest_graphs   = file.path(dt_base, "graphs"),
  dest_data     = file.path(dt_base, "bases", "inpc.csv")
))

message(
  "Config del pipeline lista — mes de interés: ",
  format(getOption("precios")$fecha_interes, "%Y-%m")
)
