#' A full-service color palette creator
#'
#' The function creates a vector of RGB values suitable for ggplot or similar.
#' If using the `p` argument it will use one of the default palettes in the
#' `jak_palettes` data object, or you can pass it your own colors using the
#' `colors` argument. What makes this function useful is that it will extend
#' and interpolate the values of the given palette so it can return `n` colors.
#' The final parameter is whether you want to reverse the values or not.
#'
#' Internally, the color palette is "ramped" using `colorRampPalette()`.
#' Further, colors passed via the `colors` argument are first checked whether
#' they're valid using the `all_are_valid_colors()` function.
#'
#' @param n Number of colors to return
#' @param colors An optional vector of rgb or colors to use. Overwrites `p`
#' @param p A named color palette
#' @param reverse A boolean for whether the palette should be reversed or not
#'
#' @export

palette_jak <- function(p = "bay",
                        colors = NULL,
                        n = 2,
                        reverse = FALSE) {
  # error if "bay" not %in% names(jak_palettes)
  if (!p %in% names(jak_palettes)) {
    stop(paste("palette", p, "not found in jak_palettes. Available palettes are:", paste(sort(names(jak_palettes)), collapse = "\n")))
  }

  # n must be an integer greater than 0
  if (!is.numeric(n) || length(n) != 1 || n <= 0 || n != round(n)) {
    stop("n must be a positive integer")
  }

  # reverse must be a bool
  if (!is.logical(reverse) || length(reverse) != 1) {
    stop("reverse must be a boolean")
  }

  if (is.null(colors)) {
    cols <- colorRampPalette(unname(unlist(jak_palettes[p])))(n)
  } else {
    if (all(all_are_valid_colors(colors))) {
      cols <- colorRampPalette(colors)(n)
    } else {
      stop("ERROR: one of the colors isn't valid")
    }
  }

  if (isTRUE(reverse)) {
    return(rev(cols))
  } else {
    return(cols)
  }
}


#' Check if a string contains valid color strings
#'
#' This function is from [Stack Overflow #13289009](https://stackoverflow.com/questions/13289009/)
#' originally by [Josh O'Brien](https://stackoverflow.com/users/980833/josh-obrien).
#'
#' @param x A vector of colors in rgb or text string
#'
#' @export

all_are_valid_colors <- function(x) {
  sapply(x, function(X) {
    tryCatch(is.matrix(col2rgb(X)),
      error = function(e) FALSE
    )
  })
}


#' Return table of colors for a palette
#'
#' On the surface this function doesn't seem useful as it basically enframes a vector
#' of a color palette. But, with the `full = TRUE` parameter set, it is used within
#' the `show_color_paeltte()` function to return a data frame with the color, position,
#' luminance, and text color for each color in the palette. This is useful for creating
#' a ggplot2 plot of the color palette.
#'
#'
#' @param pal A color palette
#' @param full A boolean for whether to return the full data frame or just the color and position
#'
#' @export

get_color_palette <- function(pal, full = FALSE) {

  rows <- ceiling(sqrt(length(pal)))

  df <- data.frame(toupper(pal))
  df$POS <- as.integer(rownames(df))

  colnames(df) <- c("COLOR", "POS")

  df = df |>
    dplyr::mutate(y = dplyr::ntile(n = rows)) |>
    dplyr::group_by(y) |>
    dplyr::mutate(x = seq(dplyr::n())) |>
    dplyr::rowwise() |>
    dplyr::mutate(LUM = get_luminance(COLOR)) |>
    dplyr::mutate(TEXT_COLOR = get_text_color(COLOR, t = 0.5)) |>
    dplyr::ungroup()

  if (isTRUE(full)) {
    return(df)
  } else {
    df_small = df |>
      dplyr::select("Position" = POS, "HEX" = COLOR)
    return(df_small)
  }

}

#' showColorPalette
#'
#' @export
#'
#' @param pal A color palette
#' @param labels Boolean for whether to show the rgb value as a label
#' @param label_angle The rotational angle for the label
#' @param alpha A numeric value between 0 and 1 for the transparency of the colors

show_color_palette <- function(pal,
                               labels = FALSE,
                               label_angle = 0,
                               alpha = 1) {

  df = get_color_palette(pal, full = TRUE)

  p <- df |>
    ggplot2::ggplot(ggplot2::aes(x = x, y = y, fill = COLOR)) +
    ggplot2::theme_void() +
    ggplot2::geom_tile(alpha = alpha) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_y_reverse()

  if (isTRUE(labels)) {
    p <- p +
      ggplot2::geom_text(ggplot2::aes(label = paste(POS, COLOR, sep = ") "),
                                             color = TEXT_COLOR),
                                angle = label_angle) +
      ggplot2::scale_color_identity()
  }

  p
}

#' Show all color palettes in the jak_palettes object
#'
#' @param alpha A numeric value between 0 and 1 for the transparency of the colors
#'
#' @export

show_all_color_palettes <- function(alpha = 1) {


  # Check if alpha is a valid numeric value between 0 and 1
  if (!is.numeric(alpha) || length(alpha) != 1 || alpha < 0 || alpha > 1) {
    stop("alpha must be a numeric value between 0 and 1", call. = F)
  }


  input2 <- lapply(jak_palettes, as.data.frame, stringsAsFactors = FALSE)
  df <- dplyr::bind_rows(input2, .id = "Palette") |>
    dplyr::select(Palette, RGB = `X[[i]]`)

  df <- df |>
    dplyr::group_by(Palette) |>
    dplyr::mutate(x = seq(dplyr::n()))

  df |>
    ggplot2::ggplot(ggplot2::aes(x = x, y = Palette, fill = RGB)) +
      ggplot2::theme_minimal() +
      ggplot2::geom_tile(alpha = alpha) +
      ggplot2::scale_fill_identity() +
      ggplot2::scale_y_discrete(limits = rev)
}





#' Title
#'
#' @param hex A hex color string (e.g. "#FFFFFF")
#'
#' @export

get_luminance <- function(hex) {
  rgb_color = col2rgb(hex) / 255
  R <- rgb_color[1]
  G <- rgb_color[2]
  B <- rgb_color[3]

  # https://stackoverflow.com/questions/596216/formula-to-determine-perceived-brightness-of-rgb-color
  luminance <- 0.2126*R + 0.7152*G + 0.0722*B
  return(luminance)
}

#' Title
#'
#' @param background_rgb A hex color string (e.g. "#FFFFFF")
#' @param t A threshold value between 0 and 1 to determine the text color
#'
#' @export

get_text_color <- function(background_rgb, t = 0.5) {
  luminance <- get_luminance(background_rgb)
  if (luminance > t) {
    return("#000000")
  } else {
    return("#FFFFFF")
  }
}
