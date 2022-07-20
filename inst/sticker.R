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
  package = "{saffer}",
  p_x = 1.215,
  p_y = 1.0225,
  p_size = 20,
  p_color = "#ffffff",
  p_family = "mono",
  s_x = 1,
  s_y = 1,
  s_width = 1.925,
  h_color = "#000000",
  h_fill = "#FFFFFF",
  white_around_sticker = TRUE,
  filename = file.path(FIGURES_DIR, "saffer-hex.png")
)
