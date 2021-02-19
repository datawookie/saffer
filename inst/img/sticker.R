library(hexSticker)

URL_FLAG_SVG = "https://raw.githubusercontent.com/hampusborgos/country-flags/master/svg/za.svg"
NAME_FLAG_SVG = "za_flag.svg"
NAME_FLAG_PNG = "za_flag.png"

if (!file.exists(NAME_FLAG_SVG)) {
  download.file(URL_FLAG_SVG, NAME_FLAG_SVG)
}

if (!file.exists(NAME_FLAG_PNG)) {
  system(paste("convert -density 7200", NAME_FLAG_SVG, NAME_FLAG_PNG))
}

FIGURES_DIR <- here::here("man", "figures")
#
dir.create(FIGURES_DIR)

sticker(
  "za_flag.png",
  package = "saffer",
  p_y = 1.6,
  p_size = 20,
  p_color = "#000000",
  p_family = "sans",
  s_x = 1,
  s_y = 0.95,
  s_width = 0.75,
  h_color = "#000000",
  h_fill = "#FFFFFF",
  filename = file.path(FIGURES_DIR, "logo.png")
)
