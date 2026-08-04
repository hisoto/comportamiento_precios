# ─────────────────────────────────────────────────────────────────────────────
# 000_requisitos.R  —  Preparar el equipo (correr UNA vez por computadora)
#
# Instala los paquetes del pipeline y revisa las cosas que fallan en silencio al
# cambiar de máquina: la tipografía institucional, la carpeta compartida de la
# Dirección Técnica y el acceso al portal del INEGI.
#
#   Rscript rscripts/000_requisitos.R
#
# No forma parte del flujo mensual: los masters no lo sourcean.
# ─────────────────────────────────────────────────────────────────────────────

cat("\n== Requisitos · comportamiento_precios ==\n\n")

ok    <- function(x) cat("  OK      ", x, "\n")
aviso <- function(x) cat("  AVISO   ", x, "\n")
falla <- function(x) cat("  FALTA   ", x, "\n")

# ── 1. R ─────────────────────────────────────────────────────────────────────

cat("1. Versión de R\n")
if (getRversion() >= "4.2.0") {
  ok(paste0("R ", getRversion(), " (el pipeline usa el pipe nativo |>)"))
} else {
  falla(paste0("R ", getRversion(),
               " — se necesita 4.2 o superior por el pipe nativo |>"))
}

# ── 2. Paquetes de CRAN ──────────────────────────────────────────────────────

cat("\n2. Paquetes de CRAN\n")
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")

paquetes <- c(
  "here", "tidyverse", "data.table", "readxl", "writexl", "janitor",
  "lubridate", "ggrepel", "scales", "knitr",
  "rvest", "httr2", "xml2",
  "ragg", "systemfonts", "svglite"
)
pacman::p_load(char = paquetes)

faltan <- paquetes[!paquetes %in% rownames(installed.packages())]
if (length(faltan) == 0) {
  ok(paste(length(paquetes), "paquetes disponibles"))
} else {
  falla(paste("no se pudieron instalar:", paste(faltan, collapse = ", ")))
}

# ── 3. Tipografía Noto Sans ──────────────────────────────────────────────────
# El theme la registra desde la carpeta de fuentes del usuario. Si no está,
# ggplot sustituye por otra y las gráficas salen fuera del canon DT 2026 con un
# simple warning que es fácil pasar por alto.

cat("\n3. Tipografía Noto Sans\n")
familias <- systemfonts::system_fonts()$family
if ("Noto Sans" %in% familias) {
  ok("Noto Sans disponible")
} else {
  falla(paste0("Noto Sans NO está instalada.\n",
               "           Las gráficas saldrán con otra tipografía y solo\n",
               "           avisan con un warning. Instalarla antes de publicar:\n",
               "           https://fonts.google.com/noto/specimen/Noto+Sans"))
}

# ── 4. Carpeta compartida de la DT ───────────────────────────────────────────

cat("\n4. Carpeta compartida de la Dirección Técnica\n")
source(here::here("rscripts", "theme_conasami_dt2026.R"))
for (sub in c("graphs", "bases")) {
  ruta <- ruta_dt_automatizacion(sub)
  if (dir.exists(ruta)) {
    ok(paste0(sub, "/  ", ruta))
  } else {
    aviso(paste0(sub, "/ no existe — se omitirán las copias externas\n",
                 "           ", ruta))
  }
}

# ── 5. Base de datos en disco ────────────────────────────────────────────────
# Con data/inpc.csv presente el pipeline corre completo sin tocar internet
# (correr_datos = FALSE). Es la vía normal para regenerar gráficas.

cat("\n5. Base de datos local\n")
ruta_inpc <- here::here("data", "inpc.csv")
if (file.exists(ruta_inpc)) {
  ultimo <- suppressWarnings(
    max(as.Date(data.table::fread(ruta_inpc, select = "date")$date), na.rm = TRUE)
  )
  ok(paste0("data/inpc.csv con datos hasta ", format(ultimo, "%Y-%m")))
} else {
  falla(paste0("no existe data/inpc.csv.\n",
               "           Correr el master con correr_datos <- TRUE para\n",
               "           descargarlo del portal del INEGI (~1-2 min)."))
}

# ── 6. Portal del INEGI (solo si se va a re-descargar) ───────────────────────
# Este pipeline NO usa la API con token: hace scraping del portal público de
# índices de precios. Por eso no hay credenciales que configurar; a cambio,
# depende de que el INEGI no cambie el HTML.

cat("\n6. Portal del INEGI (solo hace falta con correr_datos = TRUE)\n")
url <- paste0("https://www.inegi.org.mx/app/indicesdepreciosv2/",
              "Estructura.aspx?idEstructura=112001700080")
respuesta <- tryCatch(
  suppressWarnings(
    httr2::req_perform(httr2::req_timeout(httr2::request(url), 15))
  ),
  error = function(e) e
)
if (inherits(respuesta, "error")) {
  aviso(paste0("no se pudo alcanzar el portal: ", conditionMessage(respuesta), "\n",
               "           El pipeline corre igual con correr_datos = FALSE."))
} else if (httr2::resp_status(respuesta) == 200) {
  ok("portal accesible (no requiere token ni credenciales)")
} else {
  aviso(paste0("el portal respondió ", httr2::resp_status(respuesta)))
}

cat("\n== Fin ==\n\n")
