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

source("rscripts/theme_conasami.R")

fecha_inicio <- as.Date("2021-01-01")

fecha_interes <- as.Date("2025-11-01")

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
      variable == "La Paz, B.C.S." ~ "ZLFN",
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
    show.legend = TRUE,
    alpha = 0.9
  ) +
  geom_text(
    mapping = aes(
      x = fct_reorder(variable, -var_anual),
      y = var_anual,
      label = round(var_anual, 2),
      color = zona,
      vjust = if_else(var_anual < 0, 1.2, -0.3)
    ),
    vjust = 0.5,
    hjust = 1.25,
    size = 6,
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
  scale_color_manual(
    values = c(
      "Nacional" = "#a57f2c",
      "ZLFN" = "#611232",
      "ZSMG" = "#1e5b4f"
    ))  +
  geom_abline(
    slope = 0,
    intercept = 0,
    linetype = "dashed",
    color = "gray40"
  ) +
  labs(x = "", y = "Variación mensual (%)", color = "", fill = "") +
  theme_conasami() +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 20),
        axis.text.x = element_text(size = 18, angle = 90, hjust = 1),
        axis.text.y = element_text(size = 20))

name <- paste0("graphs/va_anual_inpc_ciudades_", fecha_interes %>% format("%Ym%m"), ".png")

ggsave(
  name,
  plot = last_plot(),
  width = 50,
  height = 25,
  units = "cm",
  dpi = 300
)
  