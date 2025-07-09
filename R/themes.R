#' JAK ggplot theme
#'
#' Modify theme of ggplots
#'
#' @param base_size Font size for most things
#' @param plot_title_size Font size for plot titles
#' @param plot_title_color Color for plot titles
#' @param axis_title_size Font size for axis titles
#' @param axis_title_color Color for axis titles
#' @param base_color Color for most text and lines
#' @param bg_color background color
#' @param grid_color Color for grid lines
#' @param strip_size Font size for facet strip titles
#' @param strip_color Color for facet strip titles
#' @param strip_line Line width for facet strip titles
#' @param legend_size Font size for legend
#' @param legend_position Position of legend
#' @param base_family Font family
#'
#' @importFrom ggplot2 '%+replace%'
#' @export

jak_theme <- function(base_size = 10,
                      plot_title_size = 12,
                      axis_title_size = 11,
                      base_color = "gray30",
                      plot_title_color = "gray30",
                      axis_title_color = "gray30",
                      bg_color = "transparent",
                      grid_color = "gray80",
                      border_width = 0.5,
                      strip_size = 10,
                      strip_color = "transparent",
                      strip_line = 0,
                      legend_size = 10,
                      legend_position = "bottom",
                      base_family = "") {

  ggplot2::theme_bw(base_size = base_size,
                    base_family = base_family) %+replace%
    ggplot2::theme(
      line = ggplot2::element_line(color = base_color, size = 0.2, linetype = 1, lineend = "butt"),
      rect = ggplot2::element_rect(fill = "transparent", color = base_color, size = 0.5, linetype = 1),
      text = ggplot2::element_text(
        family = base_family,
        face = "plain",
        color = base_color,
        size = base_size,
        lineheight = 0.9,
        hjust = 0.5,
        vjust = 0.5,
        angle = 0,
        margin = ggplot2::margin()
      ),
      legend.background = ggplot2::element_blank(),
      legend.box.background = ggplot2::element_rect(fill = "transparent", color = base_color, size = 0.2),
      legend.text = ggplot2::element_text(size = legend_size),
      legend.title = ggplot2::element_text(size = legend_size, face = "bold"),
      legend.key = ggplot2::element_rect(color = "transparent", fill = "transparent"),
      legend.position = legend_position,
      plot.background = ggplot2::element_rect(fill = bg_color, color = bg_color),
      plot.title = ggplot2::element_text(size = plot_title_size, face = "bold", color = plot_title_color, hjust = 0, vjust = 1),
      panel.background = ggplot2::element_rect(fill = "transparent", color = base_color),
      panel.grid.major = ggplot2::element_line(color = grid_color, size = 0.2),
      panel.grid.minor = ggplot2::element_blank(),
      panel.border = ggplot2::element_rect(fill = "transparent", color = base_color, size = border_width),
      axis.text = ggplot2::element_text(color = base_color),
      axis.text.x = ggplot2::element_text(angle = 90, hjust = 1, vjust = 0.5),
      axis.title.x = ggplot2::element_text(color = axis_title_color, size = axis_title_size, face = "bold"),
      axis.title.y = ggplot2::element_text(color = axis_title_color, size = axis_title_size, face = "bold", angle = 90),
      strip.background = ggplot2::element_blank(),
      strip.text.x = ggtext::element_textbox(
        size = strip_size,
        color = base_color,
        fill = strip_color,
        width = ggplot2::unit(1, "npc"),
        halign = 0.5, linetype = 1, r = ggplot2::unit(3, "pt"), linewidth = strip_line,
        padding = ggplot2::margin(2, 0, 1, 0), margin = ggplot2::margin(2, 2, 2, 2)
      ),
      strip.text.y = ggtext::element_textbox(
        size = strip_size,
        color = base_color,
        fill = strip_color,
        halign = 0.5, linetype = 1, r = ggplot2::unit(3, "pt"), linewidth = strip_line, hjust = 0,
        padding = ggplot2::margin(4, 0, 1, 0), margin = ggplot2::margin(2, 2, 2, 2)
      )
    )
}







#' Custom discrete ggplot2 scale color
#'
#' @param p color palette to use from `jakR2::jak_palettes`
#' @param colors An optional vector of rgb or colors to use. Overwrites `p`
#' @param order Order of the palette, "default", "reverse" or "random"
#'
#' @export

scale_color_jak_d <- function(p = "bay",
                              colors = NULL,
                              order = "default") {

  # p must be in the names of jak_palettes
  if (!p %in% names(jak_palettes)) {
    stop(paste0("'", p, "' is not a known palette name"))
  }

  # if colors isn't null, run through all_are_valid_colors()
  if (!is.null(colors) && !all(all_are_valid_colors(colors))) {
    stop("Invalid <colors> given")
  }

  # order must be default, reverse or random
  if (!order %in% c("default", "reverse", "random")) {
    stop("<order> must be 'default', 'reverse' or 'random'")
  }

  ggplot2::discrete_scale(
    "color",
    palette = function(n) {
      palette_jak(
        p = p,
        colors = colors,
        n = n, # will be determined as needed and can't be "set"
        order = order
      )
    }
  )
}


#' Custom discrete ggplot2 scale fill
#'
#' @param p color palette to use from `jakR2::jak_palettes`
#' @param colors An optional vector of rgb or colors to use. Overwrites `p`
#' @param order Order of the palette, "default", "reverse" or "random"
#'
#' @export


scale_fill_jak_d <- function(p = "bay", colors = NULL, order = "default") {

  # p must be in the names of jak_palettes
  if (!p %in% names(jak_palettes)) {
    stop(paste0("'", p, "' is not a known palette name"))
  }

  # if colors isn't null, run through all_are_valid_colors()
  if (!is.null(colors) && !all(all_are_valid_colors(colors))) {
    stop("Invalid <colors> given")
  }

  # order must be default, reverse or random
  if (!order %in% c("default", "reverse", "random")) {
    stop("<order> must be 'default', 'reverse' or 'random'")
  }

  ggplot2::discrete_scale(
    "fill",
    palette = function(n) {
      palette_jak(
        p = p,
        colors = colors,
        n = n, # will be determined as needed and can't be "set"
        order = order
      )
    }
  )
}
