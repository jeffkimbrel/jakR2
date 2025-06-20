## code to prepare `jak_palettes` dataset goes here

jak_palettes = list(
  "cb"            = c("#cc79a7","#0072b2","#56b4e9","#009e73","#f0e442","#e69f00","#d55e00"),

  # from colorbook.io
  "modernUI"      = c('#09D879','#0069FF','#D6D6D6','#FF4040','#FFDD00'),
  "helpcenter"    = c('#E40035','#6900C5','#2F4AF9','#00BB6A','#8DC000','#FFC400','#FFAA3A','#FF662E','#FB4A4A'),
  "bulma"         = c('#01D1B2','#5178FA','#3273DC','#23D160','#FFDD57','#FF3860'),
  "blackdiamond"  = c('#6C7F50','#98C67C','#34557F','#FF635A','#D98626','#D3BF96','#685A5C','#786592','#78849C',
                      '#DC443A','#ACDEE6','#EFBD47','#B0583A','#E2C2C7','#0088CE','#E9BF9B','#652D86','#512B1B',
                      '#D1D4D3','#FE9666','#7BBBB2'),
  "sachi"         = c('#005eac','#E7004C','#00C36B','#6D6462','#068CD6','#FE1E36','#F57C00','#0097A7','#A35FCA'),
  "inslife"       = c('#80bec8','#6EB5C0','#e8e2e6','#FFCCBB','#83a0cd','#dee6f2','#DEAFB1','#AFDEDC','#DCC48E',
                      '#CEB28D','#56CBF9','#E9D7C3'),
  "pastelrainbow" = c('#E8CACA','#FFE5A8','#F8FF97','#BCFFA4','#A6FFD3','#B9E3FF','#C1CCFF','#E4CFFF','#F1CEF4'),

  # from https://github.com/karthik/wesanderson
  "zissou"        = c("#000000","#3B9AB2","#78B7C5","#EBCC2A","#E1AF00","#F21A00"),

  # from PNW colors (https://github.com/jakelawlor/PNWColors)
  "bay"           = c('#00496f','#0f85a0','#edd746','#ed8b00','#dd4124'),
  "winter"        = c('#2d2926','#33454e','#537380','#81a9ad','#ececec'),
  "lake"          = c('#362904','#54450f','#45681e','#4a9152','#64a8a8','#85b6ce','#cde5f9','#eef3ff'),
  "sailboat"      = c('#6e7cb9','#7bbcd5','#d0e2af','#f5db99','#e89c81','#d2848d'),

  # from Paul Tol (https://personal.sron.nl/~pault/data/colourschemes.pdf)
  "bright"        = c("#4477AA","#66CCEE","#228833","#CCBB44","#EE6677","#AA3377","#BBBBBB"),
  "highContrast"  = c("#FFFFFF","#DDAA33","#BB5566","#004488","#000000"),
  "vibrant"       = c("#007788","#33BBEE","#009988","#EE7733","#CC3311","#EE3377","#BBBBBB"),
  "muted"         = c("#332288","#88ccee","#44aa99","#117733","#999933","#ddcc77","#cc6677","#882255","#aa4499"),
  "pale"          = c("#bbccee","#cceeff","#ccddaa","#eeeebb","#ffcccc","#dddddd"),
  "dark"          = c("#222255","#225555","#225522","#666633","#663333","#555555"),
  "light"         = c("#77aadd","#99ddff","#44bb99","#bbcc33","#aaaa00","#eedd88","#ee8866","#ffaabb","#dddddd"),
  "sunset"        = c("#364b9a","#4a7bb7","#6ea6cd","#98cae1","#c2e4ef","#eaeccc","#feda8b","#fdb366","#f67e4b","#dd3d2d","#a50026"),
  "rainbow"       = c("#d1bbd7","#ae76a3","#882e72","#1965b0","#5289c7","#7bafde","#4eb265","#90c987","#cae0ab","#f7f056","#f6c141","#f1932d","#e8601c","#dc050c"),
  "earth"         = c("#5566aa","#117733","#44aa66","#55aa22","#668822","#99bb55","#558877","#88bbaa","#aaddcc","#44aa88","#ddcc66","#ffdd44","#ffee88","#bb0011")
)

usethis::use_data(jak_palettes, overwrite = TRUE)
