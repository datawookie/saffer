library(hexSticker)

URL_FLAG_PNG = "https://github.com/hampusborgos/country-flags/raw/main/png1000px/za.png"
NAME_FLAG_PNG = "za_flag.png"

if (!file.exists(NAME_FLAG_PNG)) {
  download.file(URL_FLAG_PNG, NAME_FLAG_PNG)
}

FIGURES_DIR <- here::here("man", "figures")
#
dir.create(FIGURES_DIR)

sticker(
  NAME_FLAG_PNG,
  package = "{saffer}",
  p_x = 1.215,
  p_y = 1.0225,
  p_size = 20,
  p_color = "#ffffff",
  p_family = "mono",
  s_x = 1,
  s_y = 1,
  s_width = 1.45,
  h_color = "#000000",
  h_fill = "#FFFFFF",
  white_around_sticker = TRUE,
  filename = file.path(FIGURES_DIR, "saffer-hex.png")
)
