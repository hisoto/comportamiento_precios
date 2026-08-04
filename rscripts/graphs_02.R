#_______________________________________________________________________________

# Objetivo: Gráficas comportamiento del INPC (Variación mensual, barras)

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
lab_size <- 6 / .pt        # geom_text: 8 pt → tamaño en mm

#_______________________________________________________________________________

base <- fread("data/inpc.csv") |>
  clean_names()

base <- base |>
  arrange(variable, date) |>
  group_by(variable) |>
  mutate(
    var_mensual = ((valor / lag(valor, 1) - 1)*100)
  ) |>
  filter(
    date >= fecha_inicio & date <= fecha_interes &
    month == month(fecha_interes)
  )

# INPC - Subyacente - No subyacente ----------------------------------------

datos_p1 <- base |> filter(variable %in% c("INPC", "Subyacente", "No subyacente"))
y_pad    <- 0.3
y_min_p1 <- min(datos_p1$var_mensual, na.rm = TRUE) - y_pad
y_max_p1 <- max(datos_p1$var_mensual, na.rm = TRUE) + y_pad

ggplot(datos_p1) +
  geom_col(
    mapping = aes(x = year, y = var_mensual, fill = variable),
    position = "dodge",
    width = 0.68,
    show.legend = TRUE
  ) +
  geom_text(
    mapping = aes(
      x = year,
      y = var_mensual,
      label = round(var_mensual, 2),
      color = variable,
      vjust = ifelse(var_mensual >= 0, -0.3, 1.3)),
    position = position_dodge(width = 0.68),
    size = lab_size,
    fontface = "bold"
  ) +
  scale_fill_manual(
    values = c(
      "INPC" = "#a57f2c",
      "Subyacente" = "#611232",
      "No subyacente" = "#1e5b4f"
    )) +
  scale_color_manual(
    values = c(
      "INPC" = "#a57f2c",
      "Subyacente" = "#611232",
      "No subyacente" = "#1e5b4f"
    )) +
  scale_x_continuous(
    breaks = seq(min(base$year),
                 max(base$year),
                 by = 1)
   ) +
  scale_y_continuous(
    limits = c(y_min_p1, y_max_p1),
    breaks = seq(-10, 20, by = 1)
  ) +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.4,
    linetype = "dotted"
  ) +
  labs(x = "", color = "", fill = "") +
  theme_conasami()

archivo <- paste0("va_mensual_inpc_", format(fecha_interes, "%Ym%m"))

guardar_grafica_conasami(last_plot(), archivo, tamano = "ancho", dest = dest_graphs)

# INPP - INPP primarias - INPP secundarias sin petróleo - INPP terciarias -----

order_levels <- c(
  "INPP sin petróleo",
  "INPP primarias",
  "INPP secundarias sin petróleo",
  "INPP terciarias"
)

datos_p2 <- base |>
  filter(variable %in% c("INPP sin petróleo", "INPP primarias", "INPP secundarias sin petróleo", "INPP terciarias")) |>
  mutate(variable = factor(variable, levels = order_levels))
y_min_p2 <- min(datos_p2$var_mensual, na.rm = TRUE) - y_pad
y_max_p2 <- max(datos_p2$var_mensual, na.rm = TRUE) + y_pad

ggplot(datos_p2) +
  geom_col(
    mapping = aes(x = year, y = var_mensual, fill = variable),
    position = "dodge",
    width = 0.68,
    show.legend = TRUE
  ) +
  geom_text(
    mapping = aes(
      x = year,
      y = var_mensual,
      label = round(var_mensual, 2),
      color = variable,
      vjust = ifelse(var_mensual >= 0, -0.3, 1.3)),
    position = position_dodge(width = 0.68),
    size = lab_size,
    fontface = "bold"
  ) +
  scale_fill_manual(
    values = c(
      "INPP sin petróleo" = "#a57f2c",
      "INPP primarias" = "#611232",
      "INPP secundarias sin petróleo" = "#1e5b4f",
      "INPP terciarias" = "#98989A"
    )) +
  scale_color_manual(
    values = c(
      "INPP sin petróleo" = "#a57f2c",
      "INPP primarias" = "#611232",
      "INPP secundarias sin petróleo" = "#1e5b4f",
      "INPP terciarias" = "#98989A"
    )) +
  scale_x_continuous(
    breaks = seq(min(base$year),
                 max(base$year),
                 by = 1)
   ) +
  scale_y_continuous(
    limits = c(y_min_p2, y_max_p2),
    breaks = seq(-10, 20, by = 1)
  ) +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.4,
    linetype = "dotted"
  ) +
  labs(x = "", color = "", fill = "") +
  theme_conasami() +
  guides(fill = guide_legend(nrow = 2, byrow = TRUE))

archivo <- paste0("va_mensual_inpp_", format(fecha_interes, "%Ym%m"))

guardar_grafica_conasami(last_plot(), archivo, tamano = "ancho", dest = dest_graphs)

# INPC quincenal, INPC quincenal subyacente, INPC quincenal nsubyacente -----

base <- fread("data/inpc.csv") |>
  clean_names()

order_levels <- c(
  "INPC quincenal",
  "INPC quincenal subyacente",
  "INPC quincenal nsubyacente"
)

base <- base |>
  filter(
    variable %in% c("INPC quincenal", "INPC quincenal subyacente", "INPC quincenal nsubyacente")
  ) |>
  mutate(
    quincena = substr(periodo, 1,1),
    fecha = substr(periodo, 4,11),
    fecha = str_replace_all(fecha, c(
      "Ene" = "Jan", "Feb" = "Feb", "Mar" = "Mar", "Abr" = "Apr",
      "May" = "May", "Jun" = "Jun", "Jul" = "Jul", "Ago" = "Aug",
      "Sep" = "Sep", "Oct" = "Oct", "Nov" = "Nov", "Dic" = "Dec"
    )),
    fecha = dmy(paste0("01-", fecha)),
    mes = month(fecha),
    year = year(fecha),
    va_mensual = (valor / lag(valor, 1) - 1)*100,
    variable = factor(variable, levels = order_levels)
  ) |>
  filter(
    fecha >= fecha_inicio & fecha <= fecha_interes &
    mes == month(fecha_interes) &
    quincena == "1"
  )

y_min_p3 <- min(base$va_mensual, na.rm = TRUE) - y_pad
y_max_p3 <- max(base$va_mensual, na.rm = TRUE) + y_pad

ggplot(base) +
  geom_col(
    mapping = aes(x = year, y = va_mensual, fill = variable),
    position = "dodge",
    width = 0.68,
    show.legend = TRUE
  ) +
  geom_text(
    mapping = aes(
      x = year,
      y = va_mensual,
      label = round(va_mensual, 2),
      color = variable,
      vjust = ifelse(va_mensual >= 0, -0.3, 1.3)),
    position = position_dodge(width = 0.68),
    size = lab_size,
    fontface = "bold"
  ) +
  scale_fill_manual(
    values = c(
      "INPC quincenal" = "#a57f2c",
      "INPC quincenal subyacente" = "#611232",
      "INPC quincenal nsubyacente" = "#1e5b4f"
    ),
  labels = c(
    "INPC quincenal" = "INPC",
    "INPC quincenal subyacente" = "Subyacente",
    "INPC quincenal nsubyacente" = "No subyacente"
  )) +
  scale_color_manual(
    values = c(
      "INPC quincenal" = "#a57f2c",
      "INPC quincenal subyacente" = "#611232",
      "INPC quincenal nsubyacente" = "#1e5b4f"
    ),
  labels = c(
    "INPC quincenal" = "INPC",
    "INPC quincenal subyacente" = "Subyacente",
    "INPC quincenal nsubyacente" = "No subyacente"
  )) +
  scale_x_continuous(
    breaks = seq(min(base$year),
                 max(base$year),
                 by = 1)
   ) +
  scale_y_continuous(
    limits = c(y_min_p3, y_max_p3),
    breaks = seq(-10, 20, by = 1)
  ) +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.4,
    linetype = "dotted"
  ) +
  labs(x = "", color = "", fill = "") +
  theme_conasami()

archivo <- paste0("va_mensual_inpc_quincenal_", format(fecha_interes, "%Ym%m"))

guardar_grafica_conasami(last_plot(), archivo, tamano = "ancho", dest = dest_graphs)
