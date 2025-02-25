global_variables <- function(names) {
  env <- topenv(parent.frame())
  if (exists(".__global__", envir = env) && bindingIsLocked(".__global__", env = env)) {
    get("unlockBinding", baseenv())(".__global__", env = env)
    on.exit(lockBinding(".__global__", env = env))
  }
  current <- get0(".__global__", envir = env, ifnotfound = character())
  current <- unique(c(current, names))
  assign(".__global__", current, envir = env)
}

vlapply <- function(X, FUN, ...) vapply(X = X, FUN = FUN, FUN.VALUE = logical(1), ...)
vcapply <- function(X, FUN, ...) vapply(X = X, FUN = FUN, FUN.VALUE = character(1), ...)
`%||%` <- function(x, y) if (length(x) == 0) y else x

method_signature <- function(generic, signature) {
  single <- length(generic@dispatch_args) == 1
  if (single) {
    signature <- class_deparse(signature[[1]])
  } else {
    classes <- vcapply(signature, class_deparse)
    signature <- paste0("list(", paste0(classes, collapse = ", "), ")")
  }

  sprintf("method(%s, %s)", generic@name, signature)
}

names2 <- function(x) {
  nms <- names(x)
  if (is.null(nms)) {
    rep("", length(x))
  } else {
    nms
  }
}

is_prefix <- function(x, y) {
  length(x) <= length(y) && identical(unclass(x), unclass(y)[seq_along(x)])
}

oxford_or <- function (x)  {
  n <- length(x)
  if (n == 1) {
    x
  } else if (n == 2) {
    paste0(x[[1]], " or ", x[[2]])
  } else if (n >= 2) {
    x <- c(x[seq(1, n - 2, by = 1)], paste0(x[[n - 1]], ", or ", x[[n]]))
    paste0(x, collapse = ", ")
  }
}

str_nest <- function(
    object,
    prefix,
    ...,
    nest.lev = 0,
    indent.str = paste(rep.int(" ", max(0, nest.lev + 1)), collapse = "..")
) {

  names <- format(names(object))

  for (i in seq_along(object)) {
    cat(indent.str, prefix, " ", names[[i]], ":", sep = "")

    xi <- object[[i]]
    if (is.function(xi)) {
      str_function(xi, nest.lev = nest.lev + 1)
    } else {
      str(xi, ..., nest.lev = nest.lev + 1)
    }
  }
}

str_function <- function(object, ..., nest.lev = 0) {
  attr(object, "srcref") <- NULL
  if (identical(class(object), "function")) {
    cat(" ")
  }
  str(object, ..., nest.lev = nest.lev)
}

check_name <- function(name, arg = deparse(substitute(name))) {
  if (length(name) != 1 || !is.character(name)) {
    msg <- sprintf("`%s` must be a single string", arg)
    stop(msg, call. = FALSE)
  }
  if (is.na(name) || name == "") {
    msg <- sprintf("`%s` must not be \"\" or NA", arg)
    stop(msg, call. = FALSE)
  }
}

check_function <- function(f, args, arg = deparse(substitute(f))) {
  if (!is.function(f)) {
    msg <- sprintf("`%s` must be a function", arg)
    stop(msg, call. = FALSE)
  }

  args <- as.pairlist(args)
  if (!identical(formals(f), args)) {
    msg <- sprintf(
      "`%s` must be %s, not %s",
      arg,
      show_args(args),
      show_args(formals(f))
    )
    stop(msg, call. = FALSE)
  }
}
show_args <- function(x, name = "function") {
  if (length(x) == 0) {
    args <- ""
  } else {
    val <- vcapply(x, deparse1)
    args <- paste0(names(x), ifelse(val == "", "", " = "), val, collapse = ", ")
  }

  paste0(name, "(", args, ")")
}
