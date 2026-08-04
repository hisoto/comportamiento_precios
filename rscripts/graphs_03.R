#_______________________________________________________________________________

# Objetivo: Gráficas comportamiento del INPC (Ciudades)

# Autor: Héctor Iván Soto Parra

# Fecha: 19 de enero de 2026

#_______________________________________________________________________________

rm(list = ls()); gc()

pacman:::p_load(
  tidyverse,
  dplyr,
  data.table,
  readxl,
  janitor,
  lubridate,
  haven
)

source("rscripts/theme_conasami_dt2026.R")

# Configuración (Master.R la define; fallback si se corre suelto) ----------
if (is.null(getOption("precios"))) source("rscripts/_config.R")
cfg <- getOption("precios")

fecha_inicio  <- cfg$fecha_inicio
fecha_interes <- cfg$fecha_interes
dest_graphs   <- cfg$dest_graphs

# ── tamaño de etiquetas de valor (8 pt, igual que axis.text del manual) ──
lab_size <- 7 / .pt        # geom_text: 8 pt → tamaño en mm

#_______________________________________________________________________________


base <- fread("data/inpc.csv") |>
  clean_names()

base <- base |>
  filter(str_starts(api, "v_ciudad")) |>
  arrange(variable, date) |>
  group_by(variable) |>
  mutate(
    var_anual = ((valor / lag(valor, 12) - 1)*100),
    zona = case_when(
      variable == "Nacional" ~ "Nacional",
      variable == "Cd. Juárez, Chih." ~ "ZLFN",
      variable == "Matamoros, Tamps." ~ "ZLFN",
      variable == "Cd. Acuña, Coah." ~ "ZLFN",
      variable == "Tijuana, B.C." ~ "ZLFN",
      variable == "Mexicali, B.C." ~ "ZLFN",
      TRUE ~ "ZSMG"
    )
  ) |>
  filter(
    date == fecha_interes
  )

# INPC - Ciudades ---------------------------------------------------------

ggplot(base) +
  geom_col(
    mapping = aes(x = fct_reorder(variable, -var_anual), y = var_anual, fill = zona),
    position = "dodge",
    width = 0.68,
    show.legend = TRUE,
    alpha = 0.9
  ) +
  geom_text(
    mapping = aes(
      x = fct_reorder(variable, -var_anual),
      y = var_anual,
      label = round(var_anual, 2)
    ),
    vjust = 0.5,
    hjust = 1.25,
    size = lab_size,
    angle = 90,
    color = "white",
    fontface = "bold",
    show.legend = FALSE
  ) +
  scale_fill_manual(
    values = c(
      "Nacional" = "#a57f2c",
      "ZLFN" = "#611232",
      "ZSMG" = "#1e5b4f"
    )) +
  geom_abline(
    slope = 0,
    intercept = 0,
    linetype = "dashed",
    color = "gray40"
  ) +
  labs(x = "", color = "", fill = "") +
  theme_conasami() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))

archivo <- paste0("va_anual_inpc_ciudades_", format(fecha_interes, "%Ym%m"))

guardar_grafica_conasami(last_plot(), archivo,
                         tamano = "ancho", dest = dest_graphs)
