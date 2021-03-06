
#' The CellChat Class
#'
#' The CellChat object is created from a single-cell transcriptomic data matrix.
#' It takes a digital data matrices as input. Genes should be in rows and cells in columns. rownames and colnames should be included.
#' The class provides functions for data preprocessing, intercellular communication network inference, communication network analysis, and visualization.
#'
#'
#'# Class definitions
#' @importFrom methods setClassUnion
#' @importClassesFrom Matrix dgCMatrix
setClassUnion(name = 'AnyMatrix', members = c("matrix", "dgCMatrix"))
setClassUnion(name = 'AnyFactor', members = c("factor", "list"))

#' The key slots used in the CellChat object are described below.
#'
#' @slot data.raw raw data matrix, one per dataset (Genes should be in rows and cells in columns)
#' @slot data normalized matrix (genes by cells)
#' @slot data.signaling normalized matrix used in the CellChat analysis
#' @slot data.scale scaled matrix
#' @slot data.project projected data
#' @slot net a three-dimensional array P (K×K×N), where K is the number of cell groups and N is the number of ligand-receptor pairs. Each row of P indicates the communication probability originating from the sender cell group to other cell groups.
#' @slot netP communication networks on signaling pathway level
#' @slot DB ligand-receptor interaction database used in the analysis
#' @slot LR a list of information related with ligand-receptor pairs
#' @slot meta data frame storing the information associated with each cell
#' @slot idents a factor defining the cell identity
#' @slot var.features informative features to be used
#' @slot dr List of the reduced 2D coordinates, one per method, e.g., umap/tsne/dm
#' @slot options List of parameters used throughout analysis
#'
#' @exportClass CellChat
#' @importFrom Rcpp evalCpp
#' @importFrom methods setClass
# #' @useDynLib CellChat
CellChat <- methods::setClass("CellChat",
                              slots = c(data.raw = 'AnyMatrix',
                                        data = 'AnyMatrix',
                                        data.signaling = "AnyMatrix",
                                        data.scale = "matrix",
                                        data.project = "AnyMatrix",
                                        net = "list",
                                        netP = "list",
                                        meta = "data.frame",
                                        idents = "AnyFactor",
                                        DB = "list",
                                        LR = "list",
                                        var.features = "vector",
                                        dr = "list",
                                        options = "list")
)
#' show method for CellChat
#'
#' @param CellChat object
#' @param show show the object
#' @param object object
#' @docType methods
#'
setMethod(f = "show", signature = "CellChat", definition = function(object) {
  cat("An object of class", class(object), "\n", nrow(object@data), "genes.\n",  ncol(object@data), "cells.")
  invisible(x = NULL)
})



#' creat a new CellChat object
#'
#' @param data raw data matrix, a single-cell transcriptomic data
#' @param do.sparse whether use sparse format
#'
#' @return
#' @export
#'
#' @examples
#' @importFrom methods as new
createCellChat <- function(data, do.sparse = T) {
  object <- methods::new(Class = "CellChat",
                         data = data)
  if (do.sparse) {
    data <- as(data, "dgCMatrix")
  }
  object@data <- data
  return(object)
}


#' Merge CellChat objects
#'
#' @param object.list  A list of multiple CellChat objects
#' @param add.names A vector containing the name of each dataset
#' @importFrom methods slot new
#'
#' @return
#' @export
#'
#' @examples
mergeCellChat <- function(object.list, add.names = NULL) {
  slot.name <- c("net", "netP", "idents" ,"LR")
  slot.combined <- vector("list", length(slot.name))
  names(slot.combined) <- slot.name
  for (i in 1:length(slot.name)) {
    object.slot <- vector("list", length(object.list))
    for (j in 1:length(object.list)) {
      object.slot[[j]] <- slot(object.list[[j]], slot.name[i])
    }
    slot.combined[[i]] <- object.slot
    if (!is.null(add.names)) {
      names(slot.combined[[i]]) <- add.names
    }
  }
  merged.object <- methods::new(
    Class = "CellChat",
    net = slot.combined$net,
    netP = slot.combined$netP,
    idents = slot.combined$idents,
    LR = slot.combined$LR)
  message("This function only merges the slots of 'net', 'netP', 'idents' and 'LR'.")
  return(merged.object)
}
