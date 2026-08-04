# ─────────────────────────────────────────────────────────────────────────────
# resumen_precios.R  —  Resumen de cifras en consola
#
# Imprime las variables que en el flujo personal se narran en el README.qmd:
# niveles y variaciones anual/mensual del INPC y sus desagregaciones, canasta de
# consumo mínimo, productos básicos, inflación promedio de la ZLFN e INPP.
#
# Recalcula todo desde data/inpc.csv con la misma lógica del reporte, de modo que
# quien clone el proyecto obtenga el resumen numérico sin renderizar el Quarto.
# Corre desde Master.R o suelto (usa el fallback de configuración).
# ─────────────────────────────────────────────────────────────────────────────

rm(list = ls()); gc()

if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(tidyverse, data.table, knitr)

# ── configuración (Master.R la define; fallback si se corre suelto) ───────────
if (is.null(getOption("precios"))) source("rscripts/_config.R")
cfg <- getOption("precios")

fecha_interes <- cfg$fecha_interes

# ── base con variaciones anual y mensual ─────────────────────────────────────
base <- fread("data/inpc.csv") |>
  arrange(variable, date) |>
  group_by(variable) |>
  mutate(
    var_anual   = ((valor / lag(valor, 12) - 1) * 100),
    var_mensual = ((valor / lag(valor, 1)  - 1) * 100)
  ) |>
  ungroup()

hoy <- base |> filter(date == fecha_interes)

if (nrow(hoy) == 0) {
  stop("No hay datos para ", format(fecha_interes, "%Y-%m"),
       " en data/inpc.csv. Revisa el mes de interés o vuelve a correr datos_03.R.")
}

# ── helpers ──────────────────────────────────────────────────────────────────
# Valor de una variable en el mes de interés (col = "valor" | "var_anual" | "var_mensual").
pick <- function(v, col = "var_anual") {
  i <- which(hoy$variable == v)
  if (length(i) == 0) return(NA_real_)
  hoy[[col]][i[1]]
}

pct <- function(x) if (is.na(x)) "s/d" else sprintf("%.2f%%", x)
pp  <- function(x) if (is.na(x)) "s/d" else sprintf("%.2f pp", x)

# Tabla compacta (Valor, anual, mensual) para un conjunto de variables, en orden.
tabla <- function(vars) {
  hoy |>
    filter(variable %in% vars) |>
    mutate(variable = factor(variable, levels = vars)) |>
    arrange(variable) |>
    transmute(
      Variable      = as.character(variable),
      Valor         = round(valor, 3),
      `Anual (%)`   = round(var_anual, 2),
      `Mensual (%)` = round(var_mensual, 2)
    )
}

meses_es <- c("enero", "febrero", "marzo", "abril", "mayo", "junio",
              "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre")
mes_nom  <- meses_es[cfg$mes]

# Abreviaturas en altas para los encabezados del cuadro de 13 meses.
meses_abr <- c("ENE", "FEB", "MAR", "ABR", "MAY", "JUN",
               "JUL", "AGO", "SEP", "OCT", "NOV", "DIC")

# ── impresión ────────────────────────────────────────────────────────────────
regla <- strrep("─", 78)

cat("\n", regla, "\n", sep = "")
cat("  RESUMEN — COMPORTAMIENTO DE PRECIOS · ", mes_nom, " de ", cfg$año, "\n", sep = "")
cat(regla, "\n")

# 1. INPC general, subyacente y no subyacente ---------------------------------
cat("\n1) INPC, subyacente y no subyacente\n\n")
print(kable(tabla(c("INPC", "Subyacente", "No subyacente")),
            format = "simple", align = c("l", "r", "r", "r")))
cat("\nInflación anual: INPC ", pct(pick("INPC")),
    " · subyacente ", pct(pick("Subyacente")),
    " · no subyacente ", pct(pick("No subyacente")), ".\n", sep = "")
cat("Variación mensual: INPC ", pct(pick("INPC", "var_mensual")),
    " · subyacente ", pct(pick("Subyacente", "var_mensual")),
    " · no subyacente ", pct(pick("No subyacente", "var_mensual")), ".\n", sep = "")

# 2. Componentes de subyacente y no subyacente --------------------------------
cat("\n2) Componentes (variación anual)\n\n")
print(kable(tabla(c("Subyacente - Servicios", "Subyacente - Mercancias",
                    "No subyacente - Agropecuarios",
                    "No subyacente - Energéticos y tarifas autorizadas")),
            format = "simple", align = c("l", "r", "r", "r")))

# 3. Canasta de consumo mínimo (INPC CCM) -------------------------------------
brecha_anual   <- pick("INPC") - pick("INPC CCM")
brecha_mensual <- pick("INPC", "var_mensual") - pick("INPC CCM", "var_mensual")
cat("\n3) Canasta de consumo mínimo (INPC CCM)\n\n")
cat("Variación anual ", pct(pick("INPC CCM")),
    " · mensual ", pct(pick("INPC CCM", "var_mensual")), ".\n", sep = "")
cat("Brecha vs INPC general: ", pp(brecha_anual), " anual · ",
    pp(brecha_mensual), " mensual.\n", sep = "")

# 4. Productos básicos --------------------------------------------------------
cat("\n4) Productos básicos\n\n")
print(kable(tabla(c("INPC", "Tortilla", "Frijol", "Huevo", "Leche", "Carne res")),
            format = "simple", align = c("l", "r", "r", "r")))

# 5. Inflación por ciudad — promedio ZLFN -------------------------------------
zlfn <- c("Cd. Juárez, Chih.", "Matamoros, Tamps.", "Cd. Acuña, Coah.",
          "Tijuana, B.C.", "Mexicali, B.C.")
zlfn_prom <- mean(hoy$var_anual[hoy$variable %in% zlfn], na.rm = TRUE)
cat("\n5) Inflación por ciudad\n\n")
cat("Promedio anual ZLFN (frontera norte): ", pct(zlfn_prom), ".\n", sep = "")
cat("(Detalle por las 46 ciudades + Nacional en data/inpc.csv.)\n")

# 6. INPP ---------------------------------------------------------------------
cat("\n6) Índice Nacional de Precios al Productor (INPP)\n\n")
print(kable(tabla(c("INPP sin petróleo", "INPP primarias",
                    "INPP secundarias sin petróleo", "INPP terciarias",
                    "INPP finales", "INPP intermedios")),
            format = "simple", align = c("l", "r", "r", "r")))

# 7. Cuadro de inflación — últimos 13 meses ----------------------------------
# Formato ancho del tablero institucional: meses como columnas agrupadas por año
# y, para cada bloque de inflación, las filas Mensual y Anual.

fechas_13 <- seq(fecha_interes %m-% months(12), fecha_interes, by = "month")

bloques <- c("INPC"          = "Inflación general",
             "Subyacente"    = "Inflación subyacente",
             "No subyacente" = "Inflación no subyacente")

tabla_infl <- base |>
  filter(variable %in% names(bloques), date %in% fechas_13) |>
  transmute(
    bloque  = factor(unname(bloques[variable]), levels = unname(bloques)),
    date    = as.Date(date),   # fread devuelve IDate; complete() exige el mismo tipo
    Mensual = var_mensual,
    Anual   = var_anual
  ) |>
  pivot_longer(c(Mensual, Anual), names_to = "medida", values_to = "valor") |>
  mutate(medida = factor(medida, levels = c("Mensual", "Anual"))) |>
  complete(bloque, medida, date = fechas_13) |>
  arrange(bloque, medida, date)

# ── impresión en consola ─────────────────────────────────────────────────────
# Ancho fijo por celda; el cambio de año se marca con un separador vertical que
# se dibuja en todas las líneas para que las columnas queden alineadas.
ancho_celda <- 7
ancho_lab   <- 20
anio_col    <- year(fechas_13)

# Une 13 celdas ya formateadas insertando el separador donde cambia el año.
fila <- function(celdas) {
  piezas <- character(0)
  for (i in seq_along(celdas)) {
    piezas <- c(piezas, celdas[i])
    if (i < length(celdas) && anio_col[i] != anio_col[i + 1]) piezas <- c(piezas, " │")
  }
  paste0(piezas, collapse = "")
}

# Centra un texto en un ancho dado (sobrante extra a la derecha).
centrar <- function(txt, ancho) {
  hueco <- max(ancho - nchar(txt), 0)
  paste0(strrep(" ", hueco %/% 2), txt, strrep(" ", hueco - hueco %/% 2))
}

pad      <- function(x) sprintf(paste0("%", ancho_celda, "s"), x)
celda    <- function(x) pad(if (is.na(x)) "s/d" else sprintf("%.2f", x))
etiqueta <- function(x) sprintf(paste0("%-", ancho_lab, "s"), x)

# Encabezado de años: un rótulo centrado sobre el tramo de columnas de cada año.
enc_anios <- paste0(
  strrep(" ", ancho_lab),
  paste0(
    sapply(unique(anio_col), function(a) centrar(a, sum(anio_col == a) * ancho_celda)),
    collapse = " │"
  )
)

enc_meses <- paste0(etiqueta(""), fila(pad(meses_abr[month(fechas_13)])))

regla_13 <- strrep("─", nchar(enc_meses))

cat("\n7) Inflación mensual y anual — últimos 13 meses\n\n")
cat(enc_anios, "\n", sep = "")
cat(enc_meses, "\n", sep = "")
cat(regla_13, "\n", sep = "")

for (b in levels(tabla_infl$bloque)) {
  cat(b, "\n", sep = "")
  for (m in levels(tabla_infl$medida)) {
    v <- tabla_infl$valor[tabla_infl$bloque == b & tabla_infl$medida == m]
    cat(etiqueta(paste0("  ", m)), fila(sapply(v, celda)), "\n", sep = "")
  }
}

# ── exportación csv (layout idéntico, listo para pegar en Word) ──────────────
tabla_infl_csv <- tabla_infl |>
  mutate(
    col   = factor(paste(meses_abr[month(date)], year(date)),
                   levels = paste(meses_abr[month(fechas_13)], year(fechas_13))),
    valor = round(valor, 2)
  ) |>
  select(Bloque = bloque, Medida = medida, col, valor) |>
  pivot_wider(names_from = col, values_from = valor)

archivo_csv <- paste0("tabla_inflacion_", format(fecha_interes, "%Ym%m"), ".csv")
fwrite(tabla_infl_csv, file.path("data", archivo_csv), na = "s/d", bom = TRUE)
cat("\nCuadro exportado a data/", archivo_csv, "\n", sep = "")

# Copia a la carpeta externa de la DT (se omite sin error si no existe).
dest_bases <- dirname(cfg$dest_data)
if (dir.exists(dest_bases)) {
  fwrite(tabla_infl_csv, file.path(dest_bases, archivo_csv), na = "s/d", bom = TRUE)
  cat("Copia en ", file.path(dest_bases, archivo_csv), "\n", sep = "")
} else {
  message("Carpeta DT no encontrada (", dest_bases, "); se omite la copia externa.")
}

cat("\n", regla, "\n\n", sep = "")
