#test2 <- lines(stats::lowess(yhn0[ok], sqrtabsr[ok], f = span, iter = myiter), col = mycol.smooth)
## A stripped-down verision of plot.lm() or what I call "QQ/Residual Plot function"
##Tableau cannot handle R graphics plots and either single vectors or "looped" single vector output
##So this is a modified version of the plot function to work in Tableau.  Below in comment is the orginal
x <- fit
which <- 3;
#caption = list("Residuals vs Fitted", "Normal Q-Q", "Scale-Location", "Cook's distance", "Residuals vs Leverage", expression("Cook's dist vs Leverage  " * h[ii]/(1 - h[ii]))), 
panel = if (getOption("add.smooth")) panel.smooth else points;
sub.caption = NULL;
main = ""; 
#ask = prod(par("mfcol")) < length(which) && dev.interactive();
id.n = 3; 
labels.id = names(residuals(x));
cex.id = 0.75; 
qqline = TRUE;
cook.levels = c(0.5, 1);
# add.smooth = getOption("add.smooth");
label.pos = c(4, 2);
# cex.caption = 1; 
# cex.oma.main = 1.25); 

dropInf <- function(x, h) {
  if (any(isInf <- h >= 1)) {
    warning(gettextf("not plotting observations with leverage one:\n  %s", 
                     paste(which(isInf), collapse = ", ")), call. = FALSE, 
            domain = NA)
    x[isInf] <- NaN
  }
  x
}
# if (!inherits(x, "lm")) 
#   stop("use only with \"lm\" objects")
# if (!is.numeric(which) || any(which < 1) || any(which > 
#                                                 6)) 
#   stop("'which' must be in 1:6")
isGlm <- inherits(x, "glm")
show <- rep(FALSE, 6);
show[which] <- TRUE;
r <- residuals(x);
yh <- predict(x);
w <- weights(x);
# if (!is.null(w)) { ###uncomment this if lm has weights
#   wind <- w != 0
#   r <- r[wind]
#   yh <- yh[wind]
#   w <- w[wind]
#   labels.id <- labels.id[wind]
# }
n <- length(r)
# if (any(show[2L:6L])) {  ##uncomment if plot is not lm() but a Glm()
#   s <- if (inherits(x, "rlm")) 
#     x$s
#   else if (isGlm) 
#     sqrt(summary(x)$dispersion)
  # else
    s <- sqrt(deviance(x)/df.residual(x)); ##defaul verision for linear model
  hii <- (infl <- influence(x, do.coef = FALSE))$hat;
  if (any(show[4L:6L])) {
    cook <- if (isGlm) 
      cooks.distance(x, infl = infl)
    else cooks.distance(x, infl = infl, sd = s, res = r, 
                        hat = hii)
  }
#}

# if (any(show[2L:3L])) {  #uncomment if weights or GLM
#   ylab23 <- if (isGlm) 
#     "Std. deviance resid."
#   else "Standardized residuals"
#   r.w <- if (is.null(w)) 
#     r
#   else sqrt(w) * r
#   rs <- dropInf(r.w/(s * sqrt(1 - hii)), hii)
# }
if (any(show[5L:6L])) {
  r.hat <- range(hii, na.rm = TRUE)
  isConst.hat <- all(r.hat == 0) || diff(r.hat) < 1e-10 * 
    mean(hii, na.rm = TRUE)
}
if (any(show[c(1L, 3L)])) 
  l.fit <- if (isGlm) 
    "Predicted values"
else "Fitted values"
if (is.null(id.n)) 
  id.n <- 0
else {
  id.n <- as.integer(id.n)
  if (id.n < 0L || id.n > n) 
    stop(gettextf("'id.n' must be in {1,..,%d}", n), 
         domain = NA)
}
if (id.n > 0L) {
  if (is.null(labels.id)) 
    labels.id <- paste(1L:n)
  iid <- 1L:id.n
  show.r <- sort.list(abs(r), decreasing = TRUE)[iid]
  if (any(show[2L:3L])) 
    show.rs <- sort.list(abs(rs), decreasing = TRUE)[iid]
  text.id <- function(x, y, ind, adj.x = TRUE) {
    labpos <- if (adj.x) 
      label.pos[1 + as.numeric(x > mean(range(x)))]
    else 3
    text(x, y, labels.id[ind], cex = cex.id, xpd = TRUE, 
         pos = labpos, offset = 0.25)
  }
}
getCaption <- function(k) if (length(caption) < k) 
  NA_character_
else as.graphicsAnnot(caption[[k]])
if (is.null(sub.caption)) {
  cal <- x$call
  if (!is.na(m.f <- match("formula", names(cal)))) {
    cal <- cal[c(1, m.f)]
    names(cal)[2L] <- ""
  }
  cc <- deparse(cal, 80)
  nc <- nchar(cc[1L], "c")
  abbr <- length(cc) > 1 || nc > 75
  sub.caption <- if (abbr) 
    paste(substr(cc[1L], 1L, min(75L, nc)), "...")
  else cc[1L]
}
one.fig <- prod(par("mfcol")) == 1
if (ask) {
  oask <- devAskNewPage(TRUE)
  on.exit(devAskNewPage(oask))
}
if (show[1L]) {
  ylim <- range(r, na.rm = TRUE)
  if (id.n > 0) 
    ylim <- extendrange(r = ylim, f = 0.08)
  dev.hold()
  plot(yh, r, xlab = l.fit, ylab = "Residuals", main = main, 
       ylim = ylim, type = "n", ...)
  panel(yh, r, ...)
  if (one.fig) 
    title(sub = sub.caption, ...)
  mtext(getCaption(1), 3, 0.25, cex = cex.caption)
  if (id.n > 0) {
    y.id <- r[show.r]
    y.id[y.id < 0] <- y.id[y.id < 0] - strheight(" ")/3
    text.id(yh[show.r], y.id, show.r)
  }
  abline(h = 0, lty = 3, col = "gray")
  dev.flush()
}
if (show[2L]) {
  ylim <- range(rs, na.rm = TRUE)
  ylim[2L] <- ylim[2L] + diff(ylim) * 0.075
  dev.hold()
  qq <- qqnorm(rs, main = main, ylab = ylab23, ylim = ylim, 
               ...)
  if (qqline) 
    qqline(rs, lty = 3, col = "gray50")
  if (one.fig) 
    title(sub = sub.caption, ...)
  mtext(getCaption(2), 3, 0.25, cex = cex.caption)
  if (id.n > 0) 
    text.id(qq$x[show.rs], qq$y[show.rs], show.rs)
  dev.flush()
}
if (show[3L]) {
  sqrtabsr <- sqrt(abs(rs));
  ylim <- c(0, max(sqrtabsr, na.rm = TRUE));
  yl <- as.expression(substitute(sqrt(abs(YL)), list(YL = as.name(ylab23))));
  yhn0 <- if (is.null(w)) 
    yh;
  else yh[w != 0]
  dev.hold()
  plot(yhn0, sqrtabsr, xlab = l.fit, ylab = yl, main = main, 
       ylim = ylim, type = "n", ...)
  panel(yhn0, sqrtabsr, ...)
  if (one.fig) 
    title(sub = sub.caption, ...)
  mtext(getCaption(3), 3, 0.25, cex = cex.caption)
  if (id.n > 0) 
    text.id(yhn0[show.rs], sqrtabsr[show.rs], show.rs)
  dev.flush()
}
if (show[4L]) {
  if (id.n > 0) {
    show.r <- order(-cook)[iid]
    ymx <- cook[show.r[1L]] * 1.075
  }
  else ymx <- max(cook, na.rm = TRUE)
  dev.hold()
  plot(cook, type = "h", ylim = c(0, ymx), main = main, 
       xlab = "Obs. number", ylab = "Cook's distance", 
       ...)
  if (one.fig) 
    title(sub = sub.caption, ...)
  mtext(getCaption(4), 3, 0.25, cex = cex.caption)
  if (id.n > 0) 
    text.id(show.r, cook[show.r], show.r, adj.x = FALSE)
  dev.flush()
}
if (show[5L]) {
  ylab5 <- if (isGlm) 
    "Std. Pearson resid."
  else "Standardized residuals"
  r.w <- residuals(x, "pearson")
  if (!is.null(w)) 
    r.w <- r.w[wind]
  rsp <- dropInf(r.w/(s * sqrt(1 - hii)), hii)
  ylim <- range(rsp, na.rm = TRUE)
  if (id.n > 0) {
    ylim <- extendrange(r = ylim, f = 0.08)
    show.rsp <- order(-cook)[iid]
  }
  do.plot <- TRUE
  if (isConst.hat) {
    if (missing(caption)) 
      caption[[5L]] <- "Constant Leverage:\n Residuals vs Factor Levels"
    aterms <- attributes(terms(x))
    dcl <- aterms$dataClasses[-aterms$response]
    facvars <- names(dcl)[dcl %in% c("factor", "ordered")]
    mf <- model.frame(x)[facvars]
    if (ncol(mf) > 0) {
      dm <- data.matrix(mf)
      nf <- length(nlev <- unlist(unname(lapply(x$xlevels, 
                                                length))))
      ff <- if (nf == 1) 
        1
      else rev(cumprod(c(1, nlev[nf:2])))
      facval <- (dm - 1) %*% ff
      xx <- facval
      dev.hold()
      plot(facval, rsp, xlim = c(-1/2, sum((nlev - 
                                              1) * ff) + 1/2), ylim = ylim, xaxt = "n", 
           main = main, xlab = "Factor Level Combinations", 
           ylab = ylab5, type = "n", ...)
      axis(1, at = ff[1L] * (1L:nlev[1L] - 1/2) - 
             1/2, labels = x$xlevels[[1L]])
      mtext(paste(facvars[1L], ":"), side = 1, line = 0.25, 
            adj = -0.05)
      abline(v = ff[1L] * (0:nlev[1L]) - 1/2, col = "gray", 
             lty = "F4")
      panel(facval, rsp, ...)
      abline(h = 0, lty = 3, col = "gray")
      dev.flush()
    }
    else {
      message(gettextf("hat values (leverages) are all = %s\n and there are no factor predictors; no plot no. 5", 
                       format(mean(r.hat))), domain = NA)
      frame()
      do.plot <- FALSE
    }
  }
  else {
    xx <- hii
    xx[xx >= 1] <- NA
    dev.hold()
    plot(xx, rsp, xlim = c(0, max(xx, na.rm = TRUE)), 
         ylim = ylim, main = main, xlab = "Leverage", 
         ylab = ylab5, type = "n", ...)
    panel(xx, rsp, ...)
    abline(h = 0, v = 0, lty = 3, col = "gray")
    if (one.fig) 
      title(sub = sub.caption, ...)
    if (length(cook.levels)) {
      p <- x$rank
      usr <- par("usr")
      hh <- seq.int(min(r.hat[1L], r.hat[2L]/100), 
                    usr[2L], length.out = 101)
      for (crit in cook.levels) {
        cl.h <- sqrt(crit * p * (1 - hh)/hh)
        lines(hh, cl.h, lty = 2, col = 2)
        lines(hh, -cl.h, lty = 2, col = 2)
      }
      legend("bottomleft", legend = "Cook's distance", 
             lty = 2, col = 2, bty = "n")
      xmax <- min(0.99, usr[2L])
      ymult <- sqrt(p * (1 - xmax)/xmax)
      aty <- sqrt(cook.levels) * ymult
      axis(4, at = c(-rev(aty), aty), labels = paste(c(rev(cook.levels), 
                                                       cook.levels)), mgp = c(0.25, 0.25, 0), las = 2, 
           tck = 0, cex.axis = cex.id, col.axis = 2)
    }
    dev.flush()
  }
  if (do.plot) {
    mtext(getCaption(5), 3, 0.25, cex = cex.caption)
    if (id.n > 0) {
      y.id <- rsp[show.rsp]
      y.id[y.id < 0] <- y.id[y.id < 0] - strheight(" ")/3
      text.id(xx[show.rsp], y.id, show.rsp)
    }
  }
}
if (show[6L]) {
  g <- dropInf(hii/(1 - hii), hii)
  ymx <- max(cook, na.rm = TRUE) * 1.025
  dev.hold()
  plot(g, cook, xlim = c(0, max(g, na.rm = TRUE)), ylim = c(0, 
                                                            ymx), main = main, ylab = "Cook's distance", xlab = expression("Leverage  " * 
                                                                                                                             h[ii]), xaxt = "n", type = "n", ...)
  panel(g, cook, ...)
  athat <- pretty(hii)
  axis(1, at = athat/(1 - athat), labels = paste(athat))
  if (one.fig) 
    title(sub = sub.caption, ...)
  p <- x$rank
  bval <- pretty(sqrt(p * cook/g), 5)
  usr <- par("usr")
  xmax <- usr[2L]
  ymax <- usr[4L]
  for (i in seq_along(bval)) {
    bi2 <- bval[i]^2
    if (p * ymax > bi2 * xmax) {
      xi <- xmax + strwidth(" ")/3
      yi <- bi2 * xi/p
      abline(0, bi2, lty = 2)
      text(xi, yi, paste(bval[i]), adj = 0, xpd = TRUE)
    }
    else {
      yi <- ymax - 1.5 * strheight(" ")
      xi <- p * yi/bi2
      lines(c(0, xi), c(0, yi), lty = 2)
      text(xi, ymax - 0.8 * strheight(" "), paste(bval[i]), 
           adj = 0.5, xpd = TRUE)
    }
  }
  mtext(getCaption(6), 3, 0.25, cex = cex.caption)
  if (id.n > 0) {
    show.r <- order(-cook)[iid]
    text.id(g[show.r], cook[show.r], show.r)
  }
  dev.flush()
}
if (!one.fig && par("oma")[3L] >= 1) 
  mtext(sub.caption, outer = TRUE, cex = cex.oma.main)
invisible()

print()
# rplot <- function (x, which = c(1L:3L, 5L), caption = list("Residuals vs Fitted", 
#                                                   "Normal Q-Q", "Scale-Location", "Cook's distance", "Residuals vs Leverage", 
#                                                   expression("Cook's dist vs Leverage  " * h[ii]/(1 - h[ii]))), 
#           panel = if (add.smooth) panel.smooth else points, sub.caption = NULL, 
#           main = "", ask = prod(par("mfcol")) < length(which) && dev.interactive(), 
#           ..., id.n = 3, labels.id = names(residuals(x)), cex.id = 0.75, 
#           qqline = TRUE, cook.levels = c(0.5, 1), add.smooth = getOption("add.smooth"), 
#           label.pos = c(4, 2), cex.caption = 1, cex.oma.main = 1.25) 
# {
#   dropInf <- function(x, h) {
#     if (any(isInf <- h >= 1)) {
#       warning(gettextf("not plotting observations with leverage one:\n  %s", 
#                        paste(which(isInf), collapse = ", ")), call. = FALSE, 
#               domain = NA)
#       x[isInf] <- NaN
#     }
#     x
#   }
#   if (!inherits(x, "lm")) 
#     stop("use only with \"lm\" objects")
#   if (!is.numeric(which) || any(which < 1) || any(which > 
#                                                   6)) 
#     stop("'which' must be in 1:6")
#   isGlm <- inherits(x, "glm")
#   show <- rep(FALSE, 6)
#   show[which] <- TRUE
#   r <- residuals(x)
#   yh <- predict(x)
#   w <- weights(x)
#   if (!is.null(w)) {
#     wind <- w != 0
#     r <- r[wind]
#     yh <- yh[wind]
#     w <- w[wind]
#     labels.id <- labels.id[wind]
#   }
#   n <- length(r)
#   if (any(show[2L:6L])) {
#     s <- if (inherits(x, "rlm")) 
#       x$s
#     else if (isGlm) 
#       sqrt(summary(x)$dispersion)
#     else sqrt(deviance(x)/df.residual(x))
#     hii <- (infl <- influence(x, do.coef = FALSE))$hat
#     if (any(show[4L:6L])) {
#       cook <- if (isGlm) 
#         cooks.distance(x, infl = infl)
#       else cooks.distance(x, infl = infl, sd = s, res = r, 
#                           hat = hii)
#     }
#   }
#   if (any(show[2L:3L])) {
#     ylab23 <- if (isGlm) 
#       "Std. deviance resid."
#     else "Standardized residuals"
#     r.w <- if (is.null(w)) 
#       r
#     else sqrt(w) * r
#     rs <- dropInf(r.w/(s * sqrt(1 - hii)), hii)
#   }
#   if (any(show[5L:6L])) {
#     r.hat <- range(hii, na.rm = TRUE)
#     isConst.hat <- all(r.hat == 0) || diff(r.hat) < 1e-10 * 
#       mean(hii, na.rm = TRUE)
#   }
#   if (any(show[c(1L, 3L)])) 
#     l.fit <- if (isGlm) 
#       "Predicted values"
#   else "Fitted values"
#   if (is.null(id.n)) 
#     id.n <- 0
#   else {
#     id.n <- as.integer(id.n)
#     if (id.n < 0L || id.n > n) 
#       stop(gettextf("'id.n' must be in {1,..,%d}", n), 
#            domain = NA)
#   }
#   if (id.n > 0L) {
#     if (is.null(labels.id)) 
#       labels.id <- paste(1L:n)
#     iid <- 1L:id.n
#     show.r <- sort.list(abs(r), decreasing = TRUE)[iid]
#     if (any(show[2L:3L])) 
#       show.rs <- sort.list(abs(rs), decreasing = TRUE)[iid]
#     text.id <- function(x, y, ind, adj.x = TRUE) {
#       labpos <- if (adj.x) 
#         label.pos[1 + as.numeric(x > mean(range(x)))]
#       else 3
#       text(x, y, labels.id[ind], cex = cex.id, xpd = TRUE, 
#            pos = labpos, offset = 0.25)
#     }
#   }
#   getCaption <- function(k) if (length(caption) < k) 
#     NA_character_
#   else as.graphicsAnnot(caption[[k]])
#   if (is.null(sub.caption)) {
#     cal <- x$call
#     if (!is.na(m.f <- match("formula", names(cal)))) {
#       cal <- cal[c(1, m.f)]
#       names(cal)[2L] <- ""
#     }
#     cc <- deparse(cal, 80)
#     nc <- nchar(cc[1L], "c")
#     abbr <- length(cc) > 1 || nc > 75
#     sub.caption <- if (abbr) 
#       paste(substr(cc[1L], 1L, min(75L, nc)), "...")
#     else cc[1L]
#   }
#   one.fig <- prod(par("mfcol")) == 1
#   if (ask) {
#     oask <- devAskNewPage(TRUE)
#     on.exit(devAskNewPage(oask))
#   }
#   if (show[1L]) {
#     ylim <- range(r, na.rm = TRUE)
#     if (id.n > 0) 
#       ylim <- extendrange(r = ylim, f = 0.08)
#     dev.hold()
#     plot(yh, r, xlab = l.fit, ylab = "Residuals", main = main, 
#          ylim = ylim, type = "n", ...)
#     panel(yh, r, ...)
#     if (one.fig) 
#       title(sub = sub.caption, ...)
#     mtext(getCaption(1), 3, 0.25, cex = cex.caption)
#     if (id.n > 0) {
#       y.id <- r[show.r]
#       y.id[y.id < 0] <- y.id[y.id < 0] - strheight(" ")/3
#       text.id(yh[show.r], y.id, show.r)
#     }
#     abline(h = 0, lty = 3, col = "gray")
#     dev.flush()
#   }
#   if (show[2L]) {
#     ylim <- range(rs, na.rm = TRUE)
#     ylim[2L] <- ylim[2L] + diff(ylim) * 0.075
#     dev.hold()
#     qq <- qqnorm(rs, main = main, ylab = ylab23, ylim = ylim, 
#                  ...)
#     if (qqline) 
#       qqline(rs, lty = 3, col = "gray50")
#     if (one.fig) 
#       title(sub = sub.caption, ...)
#     mtext(getCaption(2), 3, 0.25, cex = cex.caption)
#     if (id.n > 0) 
#       text.id(qq$x[show.rs], qq$y[show.rs], show.rs)
#     dev.flush()
#   }
#   if (show[3L]) {
#     sqrtabsr <- sqrt(abs(rs))
#     ylim <- c(0, max(sqrtabsr, na.rm = TRUE))
#     yl <- as.expression(substitute(sqrt(abs(YL)), list(YL = as.name(ylab23))))
#     yhn0 <- if (is.null(w)) 
#       yh
#     else yh[w != 0]
#     dev.hold()
#     plot(yhn0, sqrtabsr, xlab = l.fit, ylab = yl, main = main, 
#          ylim = ylim, type = "n", ...)
#     panel(yhn0, sqrtabsr, ...)
#     if (one.fig) 
#       title(sub = sub.caption, ...)
#     mtext(getCaption(3), 3, 0.25, cex = cex.caption)
#     if (id.n > 0) 
#       text.id(yhn0[show.rs], sqrtabsr[show.rs], show.rs)
#     dev.flush()
#   }
#   if (show[4L]) {
#     if (id.n > 0) {
#       show.r <- order(-cook)[iid]
#       ymx <- cook[show.r[1L]] * 1.075
#     }
#     else ymx <- max(cook, na.rm = TRUE)
#     dev.hold()
#     plot(cook, type = "h", ylim = c(0, ymx), main = main, 
#          xlab = "Obs. number", ylab = "Cook's distance", 
#          ...)
#     if (one.fig) 
#       title(sub = sub.caption, ...)
#     mtext(getCaption(4), 3, 0.25, cex = cex.caption)
#     if (id.n > 0) 
#       text.id(show.r, cook[show.r], show.r, adj.x = FALSE)
#     dev.flush()
#   }
#   if (show[5L]) {
#     ylab5 <- if (isGlm) 
#       "Std. Pearson resid."
#     else "Standardized residuals"
#     r.w <- residuals(x, "pearson")
#     if (!is.null(w)) 
#       r.w <- r.w[wind]
#     rsp <- dropInf(r.w/(s * sqrt(1 - hii)), hii)
#     ylim <- range(rsp, na.rm = TRUE)
#     if (id.n > 0) {
#       ylim <- extendrange(r = ylim, f = 0.08)
#       show.rsp <- order(-cook)[iid]
#     }
#     do.plot <- TRUE
#     if (isConst.hat) {
#       if (missing(caption)) 
#         caption[[5L]] <- "Constant Leverage:\n Residuals vs Factor Levels"
#       aterms <- attributes(terms(x))
#       dcl <- aterms$dataClasses[-aterms$response]
#       facvars <- names(dcl)[dcl %in% c("factor", "ordered")]
#       mf <- model.frame(x)[facvars]
#       if (ncol(mf) > 0) {
#         dm <- data.matrix(mf)
#         nf <- length(nlev <- unlist(unname(lapply(x$xlevels, 
#                                                   length))))
#         ff <- if (nf == 1) 
#           1
#         else rev(cumprod(c(1, nlev[nf:2])))
#         facval <- (dm - 1) %*% ff
#         xx <- facval
#         dev.hold()
#         plot(facval, rsp, xlim = c(-1/2, sum((nlev - 
#                                                 1) * ff) + 1/2), ylim = ylim, xaxt = "n", 
#              main = main, xlab = "Factor Level Combinations", 
#              ylab = ylab5, type = "n", ...)
#         axis(1, at = ff[1L] * (1L:nlev[1L] - 1/2) - 
#                1/2, labels = x$xlevels[[1L]])
#         mtext(paste(facvars[1L], ":"), side = 1, line = 0.25, 
#               adj = -0.05)
#         abline(v = ff[1L] * (0:nlev[1L]) - 1/2, col = "gray", 
#                lty = "F4")
#         panel(facval, rsp, ...)
#         abline(h = 0, lty = 3, col = "gray")
#         dev.flush()
#       }
#       else {
#         message(gettextf("hat values (leverages) are all = %s\n and there are no factor predictors; no plot no. 5", 
#                          format(mean(r.hat))), domain = NA)
#         frame()
#         do.plot <- FALSE
#       }
#     }
#     else {
#       xx <- hii
#       xx[xx >= 1] <- NA
#       dev.hold()
#       plot(xx, rsp, xlim = c(0, max(xx, na.rm = TRUE)), 
#            ylim = ylim, main = main, xlab = "Leverage", 
#            ylab = ylab5, type = "n", ...)
#       panel(xx, rsp, ...)
#       abline(h = 0, v = 0, lty = 3, col = "gray")
#       if (one.fig) 
#         title(sub = sub.caption, ...)
#       if (length(cook.levels)) {
#         p <- x$rank
#         usr <- par("usr")
#         hh <- seq.int(min(r.hat[1L], r.hat[2L]/100), 
#                       usr[2L], length.out = 101)
#         for (crit in cook.levels) {
#           cl.h <- sqrt(crit * p * (1 - hh)/hh)
#           lines(hh, cl.h, lty = 2, col = 2)
#           lines(hh, -cl.h, lty = 2, col = 2)
#         }
#         legend("bottomleft", legend = "Cook's distance", 
#                lty = 2, col = 2, bty = "n")
#         xmax <- min(0.99, usr[2L])
#         ymult <- sqrt(p * (1 - xmax)/xmax)
#         aty <- sqrt(cook.levels) * ymult
#         axis(4, at = c(-rev(aty), aty), labels = paste(c(rev(cook.levels), 
#                                                          cook.levels)), mgp = c(0.25, 0.25, 0), las = 2, 
#              tck = 0, cex.axis = cex.id, col.axis = 2)
#       }
#       dev.flush()
#     }
#     if (do.plot) {
#       mtext(getCaption(5), 3, 0.25, cex = cex.caption)
#       if (id.n > 0) {
#         y.id <- rsp[show.rsp]
#         y.id[y.id < 0] <- y.id[y.id < 0] - strheight(" ")/3
#         text.id(xx[show.rsp], y.id, show.rsp)
#       }
#     }
#   }
#   if (show[6L]) {
#     g <- dropInf(hii/(1 - hii), hii)
#     ymx <- max(cook, na.rm = TRUE) * 1.025
#     dev.hold()
#     plot(g, cook, xlim = c(0, max(g, na.rm = TRUE)), ylim = c(0, 
#                                                               ymx), main = main, ylab = "Cook's distance", xlab = expression("Leverage  " * 
#                                                                                                                                h[ii]), xaxt = "n", type = "n", ...)
#     panel(g, cook, ...)
#     athat <- pretty(hii)
#     axis(1, at = athat/(1 - athat), labels = paste(athat))
#     if (one.fig) 
#       title(sub = sub.caption, ...)
#     p <- x$rank
#     bval <- pretty(sqrt(p * cook/g), 5)
#     usr <- par("usr")
#     xmax <- usr[2L]
#     ymax <- usr[4L]
#     for (i in seq_along(bval)) {
#       bi2 <- bval[i]^2
#       if (p * ymax > bi2 * xmax) {
#         xi <- xmax + strwidth(" ")/3
#         yi <- bi2 * xi/p
#         abline(0, bi2, lty = 2)
#         text(xi, yi, paste(bval[i]), adj = 0, xpd = TRUE)
#       }
#       else {
#         yi <- ymax - 1.5 * strheight(" ")
#         xi <- p * yi/bi2
#         lines(c(0, xi), c(0, yi), lty = 2)
#         text(xi, ymax - 0.8 * strheight(" "), paste(bval[i]), 
#              adj = 0.5, xpd = TRUE)
#       }
#     }
#     mtext(getCaption(6), 3, 0.25, cex = cex.caption)
#     if (id.n > 0) {
#       show.r <- order(-cook)[iid]
#       text.id(g[show.r], cook[show.r], show.r)
#     }
#     dev.flush()
#   }
#   if (!one.fig && par("oma")[3L] >= 1) 
#     mtext(sub.caption, outer = TRUE, cex = cex.oma.main)
#   invisible()
# }
