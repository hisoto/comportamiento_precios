#_______________________________________________________________________________

# Objetivo: INPC — incidencias de subyacente y no subyacente sobre la inflación
#           general (áreas apiladas con la línea del INPC encima)

# Autor: Héctor Iván Soto Parra

# EXTRA (prefijo 9xx): no forma parte del informe mensual de la DT. Lo corre
# Master.R (flujo local completo), NO Master_informe.R, y no viaja en la copia de
# la carpeta compartida. Salió de graphs_01.R en agosto de 2026, cuando se separó
# lo que va al informe de lo que no.

#_______________________________________________________________________________

rm(list = ls()); gc()

pacman:::p_load(
  tidyverse,
  dplyr,
  data.table,
  lubridate,
  ggrepel,
  scales
)

source(here::here("rscripts", "theme_conasami_dt2026.R"))

# Configuración (Master.R la define; fallback si se corre suelto) ----------
if (is.null(getOption("precios"))) source(here::here("rscripts", "_config.R"))
cfg <- getOption("precios")

fecha_inicio  <- cfg$fecha_inicio
fecha_interes <- cfg$fecha_interes
dest_graphs   <- cfg$dest_graphs

# ── tamaño de etiquetas de valor (8 pt, igual que axis.text del manual) ──
lab_size <- 8 / .pt        # geom_text_repel: 8 pt → tamaño en mm

#_______________________________________________________________________________

base <- fread(here::here("data", "inpc.csv")) |>
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
