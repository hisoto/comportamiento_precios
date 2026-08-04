rm(list = ls()); gc()
options(scipen=999) #para desactivar la notación científica

# Manual data entry INPC por Ciudades

# Entrar al entorno del proyecto ------------------------------------------

source(here::here("rscripts", "datos_01.R"))

source(here::here("rscripts", "datos_02.R"))


# Configuración (Master.R la define; fallback si se corre suelto) ----------
# Nota: datos_01.R hace rm(list=ls()); options() sobrevive, así que la config se
# lee aquí, después de sourcear los pasos previos.

if (is.null(getOption("precios"))) source(here::here("rscripts", "_config.R"))
cfg <- getOption("precios")


# Librerías ---------------------------------------------------------------

if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")

pacman::p_load(
  tidyverse,
  haven,
  readxl,
  tictoc,
  beepr,
  data.table
)


# claves ------------------------------------------------------------------

tbl <- read_excel(here::here("data", "inpc_api.xlsx"))


# tibble  -----------------------------------------------------------------
tic("Descargando series INPC por ciudades del INEGI")

inpc <- tbl %>%
  pmap_dfr(function(variable, idEstructura, series, api) {
    get_inpc_ciudad_df(
      idEstructura = idEstructura,
      series       = series,
      anio_ini     = cfg$anio_ini,
      anio_fin     = cfg$anio_fin
    ) %>%
      mutate(
        variable = variable,
        api    = api
      )
  })

toc()
beep(4)

meses_es <- c(
  Ene = 1, Feb = 2, Mar = 3, Abr = 4, May = 5, Jun = 6,
  Jul = 7, Ago = 8, Sep = 9, Oct = 10, Nov = 11, Dic = 12
)


inpc <- inpc %>%
  mutate(
    mes_txt = str_extract(periodo, "^[A-Za-z]+"),
    year    = as.integer(str_extract(periodo, "\\d{4}")),
    month     = meses_es[mes_txt],
    date    = as.Date(sprintf("%04d-%02d-01", year, month))
  ) %>%
  select(-mes_txt)

inpc <- inpc %>% 
  mutate(
    valor = as.double(valor, na.rm = TRUE)
  ) |> 
  relocate(variable, api, year, month, date, valor)

# Base maestra local
fwrite(inpc, here::here("data", "inpc.csv"))

# Copia externa al flujo de Word de la DT (ruta portable; se omite si no existe).
# cfg$dest_data vale NA cuando se apagó la copia (options(cnsm_copiar_dt = FALSE)).
# Este CSV también lo consume Negociación laboral (901_extra_mir.R).
if (is.na(cfg$dest_data)) {
  message("Copia a la DT desactivada; inpc.csv se queda en data/.")
} else if (dir.exists(dirname(cfg$dest_data))) {
  fwrite(inpc, cfg$dest_data)
} else {
  message("Carpeta DT no encontrada (", dirname(cfg$dest_data),
          "); se omite la copia externa.")
}
