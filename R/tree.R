#' Get the index of a tip in a tree
#'
#' @param tip A character vector of tip labels
#' @param tree A phylo object
#'
#' @export
#'
#' @returns A integer index of the tip label

get_tip_index = function(tip, tree) {

  # make sure <tree> is a phylo tree object
  stopifnot("<tree> doesn't seem to be a phylo object" = inherits(tree, "phylo"))

  # make sure the given tip name is in the tree
  not_found = setdiff(tip, tree$tip.label)
  if (length(not_found) > 0) {
    stop(paste("The following tip labels were not found in the tree:", paste(not_found, collapse = ", ")), call. = F)
  }


  return(which(tree$tip.label %in% tip))
}




#' Get the edges that lead to a tip
#'
#' @param tip_index An integer index of a tip in the tree
#' @param tree A phylo object
#' @param type what to return
#'
#' @export

get_tip_edges <- function(tip_index, tree, type = "edges") {

  current_node <- tip_index
  edge_indices <- numeric()

  while (current_node != 0) {
    parent_node <- tree$edge[tree$edge[, 2] == current_node, 1]
    if (length(parent_node) == 0) break # If no parent, we've reached the root

    edge_indices <- c(edge_indices, which(tree$edge[, 2] == current_node))
    current_node <- parent_node
  }

  if (type == "edges") {
    return(edge_indices)
  } else if (type == "df") {
    df <- tibble::enframe(edge_indices, name = "edge_order", value = "edge_index")
    df$name <- tree$tip.label[tip_index]
    df$edge_length <- tree$edge.length[df$edge_index]
    return(df)
  }
}
