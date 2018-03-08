#--------------------------------------------------------------------------
# load colors (see also rgb and col2rgb)
deforange <- rgb(229, 134, 1, max=255)  #E58601 ->FantasticFox 4
defred <- rgb(180,15,32, max=255) #b40f20 -> FantasticFox 5

defdarkblue <- rgb(35, 92, 106,max=255) ##235C6A blaue dunkel
defmedblue   <- rgb(120, 183, 197,max=255) #78B7C5 blau mittel heller -> Zissou2
deflightblue <- rgb(174, 211, 220, max=255) #aed3dc blau hell

defgrey   <- rgb(150,150,150,max=255)
defdarkgrey <- rgb(137,157,164,max=255) #899DA4 Royal 
#defdarkgrey <- rgb(121, 142, 135,max=255) #798E87 Moonrise2

defgreen  <- rgb(100,255,100,max=255)


# colourblind friendly colours
deforangecb <- rgb(230,159,0,max=255)
defmedbluecb   <- rgb(86, 180, 233,max=255) 
defbluecb   <- rgb(0, 114, 178,max=255)
defgreencb <- rgb(0, 158, 115,max=255)
defredcb   <- rgb(213, 94, 0,max=255) 
defgreycb <- rgb(153, 153, 153,max=255) 
#--------------------------------------------------------------------------
# change saturation of colours
pal <- function(col, border = "light gray", ...) {
  n <- length(col)
  plot(0, 0, type="n", xlim = c(0, 1), ylim = c(0, 1),
       axes = FALSE, xlab = "", ylab = "", ...)
  rect(0:(n-1)/n, 0, 1:n/n, 1, col = col, border = border)
}

desat <- function(cols, sat=0.5) {
  X <- diag(c(1, sat, 1)) %*% rgb2hsv(col2rgb(cols))
  hsv(X[1,], X[2,], X[3,])
}

defmedbluex <- desat(defmedblue, 0.6)
deforangex <- desat(deforange, 0.6)
defgreyx <- desat(defgrey, 0.6)
