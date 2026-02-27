#' Transparent backgrounds
#'
#' Sets all background elements to transparent. Useful for plots intended
#' for slides or documents with varying background colors.
#'
#' @return A ggplot2 theme object
#' @export
jak_transparent <- function() {
  ggplot2::theme(
    panel.background      = ggplot2::element_rect(fill = "transparent", color = NA),
    plot.background       = ggplot2::element_rect(fill = "transparent", color = NA),
    legend.background     = ggplot2::element_rect(fill = "transparent", color = NA),
    legend.box.background = ggplot2::element_rect(fill = "transparent", color = NA),
    legend.key            = ggplot2::element_rect(fill = "transparent", color = NA),
    strip.background      = ggplot2::element_rect(fill = "transparent", color = NA)
  )
}

#' Color defaults
#'
#' Sets default colors for text, axes, panel border, and geom aesthetics.
#' Uses `element_geom()` (requires ggplot2 >= 4.0.0) to set the default outline
#' color for filled shapes (pch 21-25).
#'
#' @param base_color Base color for text and borders. Default `"gray30"`.
#' @param plot_title_color Color for plot title. Default `"gray30"`.
#' @param axis_title_color Color for axis titles. Default `"gray30"`.
#' @param border_width Panel border line width. Default `0.5`.
#' @param outline_color Default outline/border color for filled geom shapes (pch 21-25).
#'   Default `"gray70"`.
#'
#' @return A ggplot2 theme object
#' @export
jak_color <- function(
    base_color       = "gray30",
    plot_title_color = "gray30",
    axis_title_color = "gray30",
    border_width     = 0.5,
    outline_color    = base_color
) {
  ggplot2::theme(
    text         = ggplot2::element_text(color = base_color),
    axis.text    = ggplot2::element_text(color = base_color),
    axis.title.x = ggplot2::element_text(color = axis_title_color),
    axis.title.y = ggplot2::element_text(color = axis_title_color),
    plot.title   = ggplot2::element_text(color = plot_title_color),
    panel.border = ggplot2::element_rect(fill = "transparent", color = base_color, linewidth = border_width),

    # ggplot2 4.0.0+ — sets default outline color for filled shapes (pch 21-25)
    geom         = ggplot2::element_geom(colour = outline_color)
  )
}

#' Text sizes and styles
#'
#' Sets font sizes, families, and text angles for plot elements.
#'
#' @param base_size Base font size. Default `10`.
#' @param plot_title_size Plot title font size. Default `12`.
#' @param axis_title_size Axis title font size. Default `11`.
#' @param base_family Base font family. Default `""` (system default).
#'
#' @return A ggplot2 theme object
#' @export
jak_text <- function(
    base_size        = 10,
    plot_title_size  = 12,
    axis_title_size  = 11,
    base_family      = ""
) {
  ggplot2::theme(
    text         = ggplot2::element_text(size = base_size, family = base_family),
    plot.title   = ggplot2::element_text(size = plot_title_size, face = "bold", hjust = 0, vjust = 1),
    axis.title.x = ggplot2::element_text(size = axis_title_size, face = "bold"),
    axis.title.y = ggplot2::element_text(size = axis_title_size, face = "bold", angle = 90),
    axis.text.x  = ggplot2::element_text(angle = 90, hjust = 1, vjust = 0.5)
  )
}

#' Grid lines
#'
#' Controls panel grid line appearance. Defaults to no grid lines.
#'
#' @param grid_color Color for major grid lines. Default `"transparent"` (no grid).
#' @param border_width Panel border line width. Default `0.5`.
#'
#' @return A ggplot2 theme object
#' @export
jak_grid <- function(
    grid_color   = "transparent",
    border_width = 0.5
) {
  ggplot2::theme(
    panel.grid.major = ggplot2::element_line(color = grid_color, linewidth = 0.2),
    panel.grid.minor = ggplot2::element_blank()
  )
}

#' Legend styling
#'
#' Sets legend position and text sizes.
#'
#' @param legend_position Legend position. One of `"bottom"`, `"top"`, `"left"`,
#'   `"right"`, or `"none"`. Default `"bottom"`.
#' @param legend_size Font size for legend text and title. Default `10`.
#'
#' @return A ggplot2 theme object
#' @export
jak_legend <- function(
    legend_position = "bottom",
    legend_size     = 10
) {
  ggplot2::theme(
    legend.position = legend_position,
    legend.text     = ggplot2::element_text(size = legend_size),
    legend.title    = ggplot2::element_text(size = legend_size, face = "bold")
  )
}

#' Strip text styling
#'
#' Sets facet strip text appearance using [ggtext::element_textbox()].
#'
#' @param strip_size Font size for strip text. Default `10`.
#' @param strip_color Background fill color for strip text boxes. Default `"transparent"`.
#' @param strip_line Border line width for strip text boxes. Default `0`.
#' @param base_color Text color for strips. Default `"gray30"`.
#'
#' @return A ggplot2 theme object
#' @export
jak_strips <- function(
    strip_size  = 10,
    strip_color = "transparent",
    strip_line  = 0,
    base_color  = "gray30"
) {
  ggplot2::theme(
    strip.background = ggplot2::element_blank(),
    strip.text.x = ggtext::element_textbox(
      size    = strip_size, color = base_color, fill = strip_color,
      width   = ggplot2::unit(1, "npc"), halign = 0.5, linetype = 1,
      r       = ggplot2::unit(3, "pt"), linewidth = strip_line,
      padding = ggplot2::margin(2, 0, 1, 0), margin = ggplot2::margin(2, 2, 2, 2)
    ),
    strip.text.y = ggtext::element_textbox(
      size    = strip_size, color = base_color, fill = strip_color,
      halign  = 0.5, linetype = 1, r = ggplot2::unit(3, "pt"), linewidth = strip_line,
      hjust   = 0, padding = ggplot2::margin(4, 0, 1, 0), margin = ggplot2::margin(2, 2, 2, 2)
    )
  )
}

#' Complete JAK theme
#'
#' A complete ggplot2 theme that combines [jak_transparent()], [jak_color()],
#' [jak_text()], [jak_grid()], [jak_legend()], and [jak_strips()] into a single
#' convenience wrapper. Built on top of [ggplot2::theme_bw()].
#'
#' @inheritParams jak_color
#' @inheritParams jak_text
#' @inheritParams jak_grid
#' @inheritParams jak_legend
#' @inheritParams jak_strips
#'
#' @return A ggplot2 theme object
#' @export
jak_theme <- function(
    base_size        = 10,
    plot_title_size  = 12,
    axis_title_size  = 11,
    base_color       = "gray30",
    plot_title_color = "gray30",
    axis_title_color = "gray30",
    grid_color       = "transparent",
    border_width     = 0.5,
    outline_color    = base_color,
    strip_size       = 10,
    strip_color      = "transparent",
    strip_line       = 0,
    legend_size      = 10,
    legend_position  = "bottom",
    base_family      = ""
) {
  ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
    jak_transparent() +
    jak_color(base_color, plot_title_color, axis_title_color, border_width, outline_color) +
    jak_text(base_size, plot_title_size, axis_title_size, base_family) +
    jak_grid(grid_color, border_width) +
    jak_legend(legend_position, legend_size) +
    jak_strips(strip_size, strip_color, strip_line, base_color)
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
