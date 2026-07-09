#_______________________________________________________________________________

# Objetivo: Gráficas comportamiento del INPC (Series de tiempo)

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
  haven,
  ggrepel,
  scales
)

source("rscripts/theme_conasami_dt2026.R")

fecha_inicio <- as.Date("2021-01-01")

fecha_interes <- as.Date("2026-06-01")

dest_graphs <- "C:/Users/ivan_/OneDrive - Comision Nacional de los Salarios Minimos/proyectosDT/informes/automatizacion/graphs"

# ── tamaño de etiquetas de valor (8 pt, igual que axis.text del manual) ──
lab_size <- 8 / .pt        # geom_text_repel: 8 pt → tamaño en mm

#_______________________________________________________________________________

base <- fread("data/inpc.csv")

base <- base |>
  arrange(variable, date) |>
  group_by(variable) |>
  mutate(
    var_anual = ((valor / lag(valor, 12) - 1)*100)
  ) |>
  filter(
    date >= fecha_inicio & date <= fecha_interes
  )
#_______________________________________________________________________________

# INPC - INPC subyacente - INPC no subyacente ------------------------------------------------

plot_data <- base |> filter(variable %in% c("INPC", "Subyacente", "No subyacente"))
y_min <- floor(min(plot_data$var_anual, na.rm = TRUE)) - 0.5
y_max <- ceiling(max(plot_data$var_anual, na.rm = TRUE)) + 0.5

ggplot(plot_data) +
  geom_line(
    mapping = aes(x = date, y = var_anual, color = variable),
    linewidth = 0.75, lineend = "round", linejoin = "round"
  ) +
  geom_point(
    mapping = aes(x = date, y = var_anual, color = variable),
    size = 1.4,
    show.legend = FALSE
  ) +
  scale_color_manual(
    values = c(
      "INPC" = "#a57f2c",
      "Subyacente" = "#611232",
      "No subyacente" = "#1e5b4f"
    )
  ) +
  scale_y_continuous(
    limits = c(y_min, y_max),
    breaks = scales::pretty_breaks(n = 6)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year",
               limits = c(fecha_inicio, fecha_interes + months(3))) +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.4,
    linetype = "dotted"
  ) +
  geom_text_repel(
    data = plot_data |> filter(date == fecha_interes),
    mapping = aes(
      x = date,
      y = var_anual,
      label = round(var_anual, 2),
      color = variable
    ),
    direction     = "y",
    nudge_x       = 30,
    hjust         = 0,
    segment.color = NA,
    show.legend   = FALSE,
    fontface      = "bold",
    size          = lab_size
  ) +
  labs(
    x = "",
    color = ""
  ) +
  theme_conasami()

archivo <- paste0("va_anual_inpc_", format(fecha_interes, "%Ym%m"))

guardar_grafica_conasami(last_plot(), archivo, tamano = "ancho", dest = dest_graphs)


# INPC e INPC CCM --------------------------------------------------------------

plot_data <- base |> filter(variable %in% c("INPC", "INPC CCM"))
y_min <- floor(min(plot_data$var_anual, na.rm = TRUE)) - 0.5
y_max <- ceiling(max(plot_data$var_anual, na.rm = TRUE)) + 0.5

ggplot(plot_data) +
  geom_line(
    mapping = aes(x = date, y = var_anual, color = variable),
    linewidth = 0.75, lineend = "round", linejoin = "round"
  ) +
  geom_point(
    mapping = aes(x = date, y = var_anual, color = variable),
    size = 1.4,
    show.legend = FALSE
  ) +
  scale_color_manual(
    values = c(
      "INPC" = "#a57f2c",
      "INPC CCM" = "#611232"
    )
  ) +
  scale_y_continuous(
    limits = c(y_min, y_max),
    breaks = scales::pretty_breaks(n = 6)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year",
               limits = c(fecha_inicio, fecha_interes + months(3))) +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.4,
    linetype = "dotted"
  ) +
  geom_text_repel(
    data = plot_data |> filter(date == fecha_interes),
    mapping = aes(
      x = date,
      y = var_anual,
      label = round(var_anual, 2),
      color = variable
    ),
    direction     = "y",
    nudge_x       = 30,
    hjust         = 0,
    segment.color = NA,
    show.legend   = FALSE,
    fontface      = "bold",
    size          = lab_size
  ) +
  labs(
    x = "",
    color = ""
  ) +
  theme_conasami()

archivo <- paste0("va_anual_inpc_ccm_", format(fecha_interes, "%Ym%m"))

guardar_grafica_conasami(last_plot(), archivo, tamano = "ancho", dest = dest_graphs)

# Productos específicos: Tortilla, Frijol, Huevo, Leche, Carne de res ----------

plot_data <- base |> filter(variable %in% c("INPC", "Tortilla", "Frijol", "Huevo", "Leche", "Carne res"))
y_min <- floor(min(plot_data$var_anual, na.rm = TRUE)) - 0.5
y_max <- ceiling(max(plot_data$var_anual, na.rm = TRUE)) + 0.5

ggplot(plot_data) +
  geom_line(
    mapping = aes(x = date, y = var_anual, color = variable),
    linewidth = 0.75, lineend = "round", linejoin = "round"
  ) +
  geom_point(
    mapping = aes(x = date, y = var_anual, color = variable),
    size = 1.4,
    show.legend = FALSE
  ) +
  scale_color_manual(
    values = c(
      "INPC" = "#a57f2c",
      "Tortilla" = "#611232",
      "Carne res" = "#1e5b4f",
      "Leche" = "#9b2247",
      "Carne cerdo" = "#2e6f6f",
      "Huevo" = "#161a1d",
      "Frijol" = "#98989A"
    )
  ) +
  scale_y_continuous(
    limits = c(y_min, y_max),
    breaks = scales::pretty_breaks(n = 6)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year",
               limits = c(fecha_inicio, fecha_interes + months(3))) +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.4,
    linetype = "dotted"
  ) +
  geom_text_repel(
    data = plot_data |> filter(date == fecha_interes),
    mapping = aes(
      x = date,
      y = var_anual,
      label = round(var_anual, 2),
      color = variable
    ),
    direction     = "y",
    nudge_x       = 30,
    hjust         = 0,
    segment.color = NA,
    show.legend   = FALSE,
    fontface      = "bold",
    size          = lab_size
  ) +
  labs(
    x = "",
    color = ""
  ) +
  theme_conasami() +
  guides(color = guide_legend(nrow = 2, byrow = TRUE))

archivo <- paste0("va_anual_inpc_productos_", format(fecha_interes, "%Ym%m"))

guardar_grafica_conasami(last_plot(), archivo, tamano = "ancho", dest = dest_graphs)

# INPP - INPP secundarias sin petróleo - INPP terciarias ------------------------------

plot_data <- base |> filter(variable %in% c("INPP sin petróleo", "INPP primarias", "INPP secundarias sin petróleo", "INPP terciarias"))
y_min <- floor(min(plot_data$var_anual, na.rm = TRUE)) - 0.5
y_max <- ceiling(max(plot_data$var_anual, na.rm = TRUE)) + 0.5

ggplot(plot_data) +
  geom_line(
    mapping = aes(x = date, y = var_anual, color = variable),
    linewidth = 0.75, lineend = "round", linejoin = "round"
  ) +
  geom_point(
    mapping = aes(x = date, y = var_anual, color = variable),
    size = 1.4,
    show.legend = FALSE
  ) +
  scale_color_manual(
    values = c(
      "INPP sin petróleo" = "#a57f2c",
      "INPP primarias" = "#9b2247",
      "INPP secundarias sin petróleo" = "#611232",
      "INPP terciarias" = "#1e5b4f"
    )
  ) +
  scale_y_continuous(
    limits = c(y_min, y_max),
    breaks = scales::pretty_breaks(n = 6)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year",
               limits = c(fecha_inicio, fecha_interes + months(3))) +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.4,
    linetype = "dotted"
  ) +
  geom_text_repel(
    data = plot_data |> filter(date == fecha_interes),
    mapping = aes(
      x = date,
      y = var_anual,
      label = round(var_anual, 2),
      color = variable
    ),
    direction     = "y",
    nudge_x       = 30,
    hjust         = 0,
    segment.color = NA,
    show.legend   = FALSE,
    fontface      = "bold",
    size          = lab_size
  ) +
  labs(
    x = "",
    color = ""
  ) +
  theme_conasami() +
  guides(color = guide_legend(nrow = 2, byrow = TRUE))

archivo <- paste0("va_anual_inpp_", format(fecha_interes, "%Ym%m"))

guardar_grafica_conasami(last_plot(), archivo, tamano = "ancho", dest = dest_graphs)

# INPP - INPP finales - INPP intermedios ------------------------------

plot_data <- base |> filter(variable %in% c("INPP sin petróleo", "INPP finales", "INPP intermedios"))
y_min <- floor(min(plot_data$var_anual, na.rm = TRUE)) - 0.5
y_max <- ceiling(max(plot_data$var_anual, na.rm = TRUE)) + 0.5

ggplot(plot_data) +
  geom_line(
    mapping = aes(x = date, y = var_anual, color = variable),
    linewidth = 0.75, lineend = "round", linejoin = "round"
  ) +
  geom_point(
    mapping = aes(x = date, y = var_anual, color = variable),
    size = 1.4,
    show.legend = FALSE
  ) +
  scale_color_manual(
    values = c(
      "INPP sin petróleo" = "#a57f2c",
      "INPP finales" = "#611232",
      "INPP intermedios" = "#1e5b4f"
    )
  ) +
  scale_y_continuous(
    limits = c(y_min, y_max),
    breaks = scales::pretty_breaks(n = 6)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year",
               limits = c(fecha_inicio, fecha_interes + months(3))) +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.4,
    linetype = "dotted"
  ) +
  geom_text_repel(
    data = plot_data |> filter(date == fecha_interes),
    mapping = aes(
      x = date,
      y = var_anual,
      label = round(var_anual, 2),
      color = variable
    ),
    direction     = "y",
    nudge_x       = 30,
    hjust         = 0,
    segment.color = NA,
    show.legend   = FALSE,
    fontface      = "bold",
    size          = lab_size
  ) +
  labs(
    x = "",
    color = ""
  ) +
  theme_conasami() +
  guides(color = guide_legend(nrow = 2, byrow = TRUE))

archivo <- paste0("va_anual_inpp_finales_intermedios_", format(fecha_interes, "%Ym%m"))

guardar_grafica_conasami(last_plot(), archivo, tamano = "ancho", dest = dest_graphs)

# INPC quincenal - INPC quincenal subyacente - INPC quincenal nsubyacente ------------------------------

base <- fread("data/inpc.csv")

base <- base |>
  filter(
    variable %in% c("INPC quincenal", "INPC quincenal subyacente", "INPC quincenal nsubyacente")
  ) |>
  mutate(
    quincena = substr(periodo, 1,2),
    fecha = substr(periodo, 4,11)
  ) %>%
  filter(quincena == "1Q") |>
  mutate(
    fecha = str_replace_all(fecha, c(
      "Ene" = "Jan", "Feb" = "Feb", "Mar" = "Mar", "Abr" = "Apr",
      "May" = "May", "Jun" = "Jun", "Jul" = "Jul", "Ago" = "Aug",
      "Sep" = "Sep", "Oct" = "Oct", "Nov" = "Nov", "Dic" = "Dec"
    )),
    fecha = dmy(paste0("01-", fecha)),
    mes = month(fecha),
    year = year(fecha)
  ) |>
  arrange(variable, fecha) |>
  group_by(variable) |>
  mutate(
    var_anual = ((valor / lag(valor, 12) - 1)*100)
  ) |>
  filter(
    fecha >= fecha_inicio & fecha <= fecha_interes
  )

y_min <- floor(min(base$var_anual, na.rm = TRUE)) - 0.5
y_max <- ceiling(max(base$var_anual, na.rm = TRUE)) + 0.5

ggplot(base) +
  geom_line(
    mapping = aes(x = fecha, y = var_anual, color = variable),
    linewidth = 0.75, lineend = "round", linejoin = "round"
  ) +
  geom_point(
    mapping = aes(x = fecha, y = var_anual, color = variable),
    size = 1.4,
    show.legend = FALSE
  ) +
  scale_color_manual(
    values = c(
      "INPC quincenal" = "#a57f2c",
      "INPC quincenal subyacente" = "#611232",
      "INPC quincenal nsubyacente" = "#1e5b4f"
    ),
    labels = c(
      "INPC quincenal" = "INPC quincenal",
      "INPC quincenal subyacente" = "Subyacente",
      "INPC quincenal nsubyacente" = "No subyacente"
    )
  ) +
  scale_y_continuous(
    limits = c(y_min, y_max),
    breaks = scales::pretty_breaks(n = 6)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year",
               limits = c(fecha_inicio, fecha_interes + months(3))) +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.4,
    linetype = "dotted"
  ) +
  geom_text_repel(
    data = base %>% filter(fecha == fecha_interes),
    mapping = aes(
      x = fecha,
      y = var_anual,
      label = round(var_anual, 2),
      color = variable
    ),
    direction     = "y",
    nudge_x       = 30,
    hjust         = 0,
    segment.color = NA,
    show.legend   = FALSE,
    fontface      = "bold",
    size          = lab_size
  ) +
  labs(
    x = "",
    color = ""
  ) +
  theme_conasami()

archivo <- paste0("va_anual_inpc_quincenal_", format(fecha_interes, "%Ym%m"))

guardar_grafica_conasami(last_plot(), archivo, tamano = "ancho", dest = dest_graphs)

# INPC — Incidencias subyacente y no subyacente --------------------------------

base <- fread("data/inpc.csv") |>
  arrange(variable, date) |>
  group_by(variable) |>
  mutate(var_anual = ((valor / lag(valor, 12) - 1) * 100)) |>
  filter(date >= fecha_inicio & date <= fecha_interes)

wide <- base |>
  filter(variable %in% c("INPC", "Subyacente", "No subyacente")) |>
  select(date, variable, var_anual) |>
  pivot_wider(names_from = variable, values_from = var_anual) |>
  rename(va_inpc = INPC, va_sub = Subyacente, va_nsub = `No subyacente`) |>
  mutate(
    inc_sub  = va_inpc * va_sub / (va_sub + va_nsub),
    inc_nsub = va_inpc - inc_sub
  )

y_min <- floor(min(wide$inc_sub, wide$va_inpc, na.rm = TRUE)) - 0.5
y_max <- ceiling(max(wide$va_inpc, na.rm = TRUE)) + 0.5

ggplot(wide, aes(x = date)) +
  geom_ribbon(
    aes(ymin = 0, ymax = inc_sub, fill = "Subyacente"),
    alpha = 0.5
  ) +
  geom_ribbon(
    aes(ymin = inc_sub, ymax = va_inpc, fill = "No subyacente"),
    alpha = 0.5
  ) +
  geom_line(
    aes(y = va_inpc, color = "INPC"),
    linewidth = 0.75, lineend = "round", linejoin = "round"
  ) +
  geom_point(
    aes(y = va_inpc, color = "INPC"),
    size = 1.4,
    show.legend = FALSE
  ) +
  scale_fill_manual(
    values = c("Subyacente" = "#611232", "No subyacente" = "#1e5b4f")
  ) +
  scale_color_manual(
    values = c("INPC" = "#a57f2c")
  ) +
  scale_y_continuous(
    limits = c(y_min, y_max),
    breaks = scales::pretty_breaks(n = 6)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year",
               limits = c(fecha_inicio, fecha_interes + months(3))) +
  geom_abline(
    slope = 0, intercept = 0,
    color = "black", linewidth = 0.4, linetype = "dotted"
  ) +
  geom_text_repel(
    data = wide |> filter(date == fecha_interes),
    aes(x = date, y = va_inpc, label = round(va_inpc, 2)),
    color         = "#a57f2c",
    direction     = "y",
    nudge_x       = 30,
    hjust         = 0,
    segment.color = NA,
    fontface      = "bold",
    size          = lab_size
  ) +
  labs(
    x = "",
    fill = "", color = ""
  ) +
  theme_conasami()

archivo <- paste0("va_anual_inpc_incidencias_", format(fecha_interes, "%Ym%m"))

guardar_grafica_conasami(last_plot(), archivo, tamano = "ancho", dest = dest_graphs)
