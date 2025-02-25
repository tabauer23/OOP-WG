#' Does this object inherit from an R7 class?
#'
#' * `R7_inherits()` returns `TRUE` or `FALSE`.
#' * `check_is_R7()` throws an error.
#'
#' @param x An object
#' @param class An R7 class. Can be omitted in `check_is_R7()`.
#' @param arg Argument name used in error message.
#' @export
#' @examples
#' foo1 <- new_class("foo1")
#' foo2 <- new_class("foo2")
#'
#' R7_inherits(foo1(), foo1)
#' check_is_R7(foo1())
#' check_is_R7(foo1(), foo1)
#'
#' R7_inherits(foo1(), foo2)
#' try(check_is_R7(foo1(), foo2))
R7_inherits <- function(x, class) {
  if (!inherits(class, "R7_class")) {
    stop("`class` is not an <R7_class>")
  }

  inherits(x, "R7_object") && inherits(x, R7_class_name(class))
}

#' @export
#' @rdname R7_inherits
check_is_R7 <- function(x, class = NULL, arg = deparse(substitute(x))) {
  if (is.null(class)) {
    if (!inherits(x, "R7_object")) {
      msg <- sprintf("`%s` must be an <R7_object>, not a %s", arg, obj_desc(x))
      stop(msg, call. = FALSE)
    }
  } else {
    if (!R7_inherits(x, class)) {
      msg <- sprintf("`%s` must be a %s, not a %s", arg, class_desc(class), obj_desc(x))
      stop(msg, call. = FALSE)
    }
  }

  invisible()
}
