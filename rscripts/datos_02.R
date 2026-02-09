# Funcion INPC Ciudades ---------------------------------------------------

get_inpc_ciudad_df <- function(
    idEstructura,
    series,
    anio_ini = 2000,
    anio_fin = as.integer(format(Sys.Date(), "%Y"))
) {
  
  library(httr2)
  library(rvest)
  library(xml2)
  library(dplyr)
  library(purrr)
  library(tibble)
  
  # ------------------------------------------------------------
  # 1) GET estructura (tokens ASP.NET)
  # ------------------------------------------------------------
  
  url_estructura <- paste0(
    "https://www.inegi.org.mx/app/indicesdepreciosv2/Estructura.aspx?idEstructura=",
    idEstructura
  )
  
  html_get <- request(url_estructura) %>%
    req_perform() %>%
    resp_body_string() %>%
    read_html()
  
  viewstate <- html_get %>%
    html_element("#__VIEWSTATE") %>%
    html_attr("value")
  
  viewstate_gen <- html_get %>%
    html_element("#__VIEWSTATEGENERATOR") %>%
    html_attr("value")
  
  event_validation <- html_get %>%
    html_element("#__EVENTVALIDATION") %>%
    html_attr("value")
  
  # ------------------------------------------------------------
  # 2) POST exportación HTML
  # ------------------------------------------------------------
  
  body <- list(
    "__VIEWSTATE"          = viewstate,
    "__VIEWSTATEGENERATOR" = viewstate_gen,
    INPTipoExporta         = "HTML",
    idEstructura           = idEstructura,
    `_formato`             = "HTML",
    `_anioI`               = anio_ini,
    `_anioF`               = anio_fin,
    `_meta`                = 0,
    `_tipo`                = "Niveles",
    `_info`                = "Índices",
    `_orient`              = "vertical",
    esquema                = 0,
    pf                      = "inp",
    cuadro                  = idEstructura,
    `_series`               = series,
    cveEstructura           = idEstructura
  )
  
  if (!is.na(event_validation)) {
    body$`__EVENTVALIDATION` <- event_validation
  }
  
  html_post <- request(
    "https://www.inegi.org.mx/app/indicesdepreciosv2/Exportacion.aspx"
  ) %>%
    req_method("POST") %>%
    req_body_form(!!!body) %>%
    req_perform() %>%
    resp_body_string() %>%
    read_html()
  
  # ------------------------------------------------------------
  # 3) Extraer filas de datos → df crudo
  # ------------------------------------------------------------
  
  filas <- html_post %>%
    html_elements("table#TableCuadro tr") %>%
    keep(~ length(html_elements(.x, "td.fecha")) == 1)
  
  if (length(filas) == 0) {
    stop("No se encontraron filas de datos en TableCuadro")
  }
  
  map_dfr(filas, function(tr) {
    tds <- tr %>% html_elements("td")
    
    tibble(
      periodo = tds[[1]] %>% html_text(trim = TRUE),
      valor   = tds[[2]] %>% html_text(trim = TRUE)
    )
  })
}







