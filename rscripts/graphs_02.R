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

source("rscripts/theme_conasami.R")

fecha_inicio <- as.Date("2021-01-01")

fecha_interes <- as.Date("2026-01-01")

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

ggplot(
  base |> filter(variable %in% c("INPC", "Subyacente", "No subyacente"))
) + 
  geom_col(
    mapping = aes(x = year, y = var_mensual, fill = variable),
    position = "dodge",
    show.legend = TRUE
  ) + 
  geom_text(
    mapping = aes(
      x = year, 
      y = var_mensual, 
      label = round(var_mensual, 2), 
      color = variable,
      vjust = ifelse(var_mensual >= 0, -0.3, 1.3)),
    position = position_dodge(width = 0.9),
    size = 6, 
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
  scale_y_continuous(
    limits = c(-0.5, 1.0),
    breaks = seq(-10, 20, by = 1)
  ) + 
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.5,
    linetype = "dotted"
  ) +
  labs(x = "", y = "Variación mensual (%)", color = "", fill = "") +
  theme_conasami() +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 20),
        axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20))

name <- paste0("graphs/va_mensual_inpc_", fecha_interes %>% format("%Ym%m"), ".png")

ggsave(
  name,
  plot = last_plot(),
  width = 50,
  height = 20,
  units = "cm",
  dpi = 300
)

# INPP - INPP primarias - INPP secundarias sin petróleo - INPP terciarias -----

order_levels <- c(
  "INPP sin petróleo",
  "INPP primarias",
  "INPP secundarias sin petróleo",
  "INPP terciarias"
)

ggplot(
  base |> 
    filter(variable %in% c("INPP sin petróleo", "INPP primarias", "INPP secundarias sin petróleo", "INPP terciarias")) |> 
    mutate(variable = factor(variable, levels = order_levels))
) + 
  geom_col(
    mapping = aes(x = year, y = var_mensual, fill = variable),
    position = "dodge",
    show.legend = TRUE
  ) + 
  geom_text(
    mapping = aes(
      x = year, 
      y = var_mensual, 
      label = round(var_mensual, 2), 
      color = variable,
      vjust = ifelse(var_mensual >= 0, -0.3, 1.3)),
    position = position_dodge(width = 0.9),
    size = 6, 
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
  scale_y_continuous(
    limits = c(-1, 1.2),
    breaks = seq(-10, 20, by = 1)
  ) + 
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.5,
    linetype = "dotted"
  ) +
  labs(x = "", y = "Variación mensual (%)", color = "", fill = "") +
  guides(fill = guide_legend(nrow = 2, byrow = TRUE)) +
  theme_conasami() +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 20),
        axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20))

name <- paste0("graphs/va_mensual_inpp_", fecha_interes %>% format("%Ym%m"), ".png")

ggsave(
  name,
  plot = last_plot(),
  width = 50,
  height = 20,
  units = "cm",
  dpi = 300
)

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

ggplot(base) + 
  geom_col(
    mapping = aes(x = year, y = va_mensual, fill = variable),
    position = "dodge",
    show.legend = TRUE
  ) + 
  geom_text(
    mapping = aes(
      x = year, 
      y = va_mensual, 
      label = round(va_mensual, 2), 
      color = variable,
      vjust = ifelse(va_mensual >= 0, -0.3, 1.3)),
    position = position_dodge(width = 0.9),
    size = 6, 
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
  scale_y_continuous(
    limits = c(-1.5, 1),
    breaks = seq(-10, 20, by = 1)
  ) + 
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.5,
    linetype = "dotted"
  ) +
  labs(x = "", y = "Variación mensual (%)", color = "", fill = "") +
  theme_conasami() +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 20),
        axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20))

name <- paste0("graphs/va_mensual_inpc_quincenal_", fecha_interes %>% format("%Ym%m"), ".png")

ggsave(
  name,
  plot = last_plot(),
  width = 50,
  height = 20,
  units = "cm",
  dpi = 300
)
