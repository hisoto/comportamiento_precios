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
  haven 
)

source("rscripts/theme_conasami.R")

fecha_inicio <- as.Date("2021-01-01")

fecha_interes <- as.Date("2026-01-01")

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

# INPC - INPC subyacente - INPC no subyacente 

ggplot(base |> filter(variable %in% c("INPC", "Subyacente", "No subyacente"))) + 
  geom_point(
    mapping = aes(x = date, y = var_anual, color = variable),
    shape = 1,
    show.legend = FALSE
  ) + 
  geom_line(
    mapping = aes(x = date, y = var_anual, color = variable)
  ) +
  scale_color_manual(
    values = c(
      "INPC" = "#a57f2c",
      "Subyacente" = "#611232",
      "No subyacente" = "#1e5b4f"
    )
  ) +
  scale_y_continuous(
    limits = c(-1, NA),
    breaks = seq(-10, 20, by = 2)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.5,
    linetype = "dotted"
  ) + 
  geom_text(
    data = base %>% filter(date == fecha_interes & variable %in% c("INPC", "Subyacente", "No subyacente")),
    mapping = aes(
      x = date,
      y = var_anual,
      label = round(var_anual, 2),
      color = variable
    ),
    hjust = -0.3,
    vjust = 0,
    show.legend = FALSE, 
    fontface = "bold", 
    size = 6
  ) + 
  labs(
    title = "",
    subtitle = "",
    x = "",
    y = "Variación anual (%)",
    caption = "",
    color = ""
  ) +
  theme_conasami() + 
  theme(legend.position = "bottom",
        legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 20),
        axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20))



name <- paste0("graphs/va_anual_inpc_", fecha_interes %>% format("%Ym%m"), ".png")

ggsave(
  name,
  plot = last_plot(),
  width = 50,
  height = 25,
  units = "cm",
  dpi = 300
)


# INPC e INPC CCM --------------------------------------------------------------

ggplot(base |> filter(variable %in% c("INPC", "INPC CCM"))) + 
  geom_point(
    mapping = aes(x = date, y = var_anual, color = variable),
    shape = 1,
    show.legend = FALSE
  ) + 
  geom_line(
    mapping = aes(x = date, y = var_anual, color = variable)
  ) + 
  scale_color_manual(
    values = c(
      "INPC" = "#a57f2c",
      "INPC CCM" = "#611232"
    )
  ) +
  scale_y_continuous(
    limits = c(-.5, NA),
    breaks = seq(-10, 20, by = 2)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.5,
    linetype = "dotted"
  ) + 
  geom_text(
    data = base %>% filter(date == fecha_interes & variable %in% c("INPC", "INPC CCM")),
    mapping = aes(
      x = date,
      y = var_anual,
      label = round(var_anual, 2),
      color = variable,
      vjust = if_else(variable == "INPC", 0, 1),
    ),
    hjust = -0.3,
    show.legend = FALSE, 
    fontface = "bold", 
    size = 6
  ) + 
  labs(
    title = "",
    subtitle = "",
    x = "",
    y = "Variación anual (%)",
    caption = "",
    color = ""
  ) +
  theme_conasami() + 
  theme(legend.position = "bottom",
        legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 20),
        axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20))

name <- paste0("graphs/va_anual_inpc_ccm_", fecha_interes %>% format("%Ym%m"), ".png")

ggsave(
  name,
  plot = last_plot(),
  width = 50,
  height = 25,
  units = "cm",
  dpi = 300
)

# Productos específicos: Tortilla, Frijol, Huevo, Leche, Carne de res ----------

ggplot(base |> filter(variable %in% c("INPC", "Tortilla", "Frijol", "Huevo", "Leche", "Carne res"))) + 
  geom_point(
    mapping = aes(x = date, y = var_anual, color = variable),
    shape = 1,
    show.legend = FALSE
  ) + 
  geom_line(
    mapping = aes(x = date, y = var_anual, color = variable)
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
    limits = c(-15, NA),
    breaks = seq(-15, 40, by = 5)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.5,
    linetype = "dotted"
  ) + 
  geom_text(
    data = base %>% filter(date == fecha_interes & variable %in% c("INPC", "Tortilla", "Frijol", "Huevo", "Leche", "Carne res")),
    mapping = aes(
      x = date,
      y = var_anual,
      label = round(var_anual, 2),
      color = variable,
      vjust = case_when(
        variable == "Tortilla" ~ 1,
        variable == "Frijol" ~ 0,
        variable == "Huevo" ~ -1,
        variable == "Leche" ~ 0,
        variable == "Carne res" ~ 0,
        TRUE ~ 0
      )
    ),
    hjust = -0.3,
    show.legend = FALSE, 
    fontface = "bold", 
    size = 6
  ) +
  labs(
    title = "",
    subtitle = "",
    x = "",
    y = "Variación anual (%)",
    caption = "",
    color = ""
  ) +
  theme_conasami() + 
  guides(color = guide_legend(nrow = 2, byrow = TRUE)) +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 20),
        axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20))

name <- paste0("graphs/va_anual_inpc_productos_", fecha_interes %>% format("%Ym%m"), ".png")

ggsave(
  name,
  plot = last_plot(),
  width = 50,
  height = 20,
  units = "cm",
  dpi = 300
)

# INPP - INPP secundarias sin petróleo - INPP terciarias ------------------------------

ggplot(
  base |> filter(variable %in% c("INPP sin petróleo", "INPP primarias", "INPP secundarias sin petróleo", "INPP terciarias"))
) + 
  geom_point(
    mapping = aes(x = date, y = var_anual, color = variable),
    shape = 1,
    show.legend = FALSE
  ) + 
  geom_line(
    mapping = aes(x = date, y = var_anual, color = variable)
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
    limits = c(-6, NA),
    breaks = seq(-10, 20, by = 2)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.5,
    linetype = "dotted"
  ) +
  geom_text(
    data = base %>% filter(date == fecha_interes & variable %in% c("INPP sin petróleo", "INPP primarias", "INPP secundarias sin petróleo", "INPP terciarias")),
    mapping = aes(
      x = date,
      y = var_anual,
      label = round(var_anual, 2),
      color = variable,
      vjust = if_else(variable == "INPP secundarias sin petróleo", 1, 0)
    ),
    hjust = -0.3,
    show.legend = FALSE,
    fontface = "bold",
    size = 6
  ) +
  labs(
    title = "",
    subtitle = "",
    x = "",
    y = "Variación anual (%)",
    caption = "",
    color = ""
  ) +
  theme_conasami() +
  guides(color = guide_legend(nrow = 2, byrow = TRUE)) +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 20),
        axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20))

 name <- paste0("graphs/va_anual_inpp_", fecha_interes %>% format("%Ym%m"), ".png")

ggsave(
  name,
  plot = last_plot(),
  width = 50,
  height = 20,
  units = "cm",
  dpi = 300
)

# INPP - INPP finales - INPP intermedios ------------------------------

ggplot(
  base |> filter(variable %in% c("INPP sin petróleo", "INPP finales", "INPP intermedios"))
) + 
  geom_point(
    mapping = aes(x = date, y = var_anual, color = variable),
    shape = 1,
    show.legend = FALSE
  ) + 
  geom_line(
    mapping = aes(x = date, y = var_anual, color = variable)
  ) +
  scale_color_manual(
    values = c(
      "INPP sin petróleo" = "#a57f2c",
      "INPP finales" = "#611232",
      "INPP intermedios" = "#1e5b4f"
    )
  ) +
  scale_y_continuous(
    limits = c(-2, NA),
    breaks = seq(-10, 20, by = 2)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.5,
    linetype = "dotted"
  ) +
  geom_text(
    data = base %>% filter(date == fecha_interes & variable %in% c("INPP sin petróleo", "INPP finales", "INPP intermedios")),
    mapping = aes(
      x = date,
      y = var_anual,
      label = round(var_anual, 2),
      color = variable,
      vjust = case_when(
        variable == "INPP finales" ~ -1,
        variable == "INPP intermedios" ~ 1,
        TRUE ~ 0
      )
    ),
    hjust = -0.3,
    show.legend = FALSE,
    fontface = "bold",
    size = 6
  ) +
  labs(
    title = "",
    subtitle = "",
    x = "",
    y = "Variación anual (%)",
    caption = "",
    color = ""
  ) +
  theme_conasami() +
  guides(color = guide_legend(nrow = 2, byrow = TRUE)) +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 20),
        axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20))

  name <- paste0("graphs/va_anual_inpp_finales_intermedios_", fecha_interes %>% format("%Ym%m"), ".png")

ggsave(
  name,
  plot = last_plot(),
  width = 50,
  height = 25,
  units = "cm",
  dpi = 300
)

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

ggplot(
  base 
) + 
  geom_point(
    mapping = aes(x = fecha, y = var_anual, color = variable),
    shape = 1,
    show.legend = FALSE
  ) + 
  geom_line(
    mapping = aes(x = fecha, y = var_anual, color = variable)
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
    limits = c(-1, NA),
    breaks = seq(-10, 20, by = 2)
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  geom_abline(
    slope = 0,
    intercept = 0,
    color = "black",
    linewidth = 0.5,
    linetype = "dotted"
  ) +
  geom_text(
    data = base %>% filter(fecha == fecha_interes),
    mapping = aes(
      x = fecha,
      y = var_anual,
      label = round(var_anual, 2),
      color = variable
    ),
    hjust = -0.3,
    show.legend = FALSE,
    fontface = "bold",
    size = 6
  ) +
  labs(
    title = "",
    subtitle = "",
    x = "",
    y = "Variación anual (%)",
    caption = "",
    color = ""
  ) +
  theme_conasami() +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 18),
        axis.title.y = element_text(size = 20),
        axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20))

  name <- paste0("graphs/va_anual_inpc_quincenal_", fecha_interes %>% format("%Ym%m"), ".png")

ggsave(
  name,
  plot = last_plot(),
  width = 50,
  height = 25,
  units = "cm",
  dpi = 300
)
  
