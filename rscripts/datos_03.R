rm(list = ls()); gc()
options(scipen=999) #para desactivar la notación científica

# Manual data entry INPC por Ciudades

# Entrar al entorno del proyecto ------------------------------------------

source("rscripts/datos_01.R")

source("rscripts/datos_02.R")


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

tbl <- read_excel("data/inpc_api.xlsx")


# tibble  -----------------------------------------------------------------
tic("Descargando series INPC por ciudades del INEGI")

inpc <- tbl %>%
  pmap_dfr(function(variable, idEstructura, series, api) {
    get_inpc_ciudad_df(
      idEstructura = idEstructura,
      series       = series,
      anio_ini     = 2018,
      anio_fin     = 2026
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

fwrite(inpc, "data/inpc.csv")
