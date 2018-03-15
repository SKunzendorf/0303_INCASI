### circ_click_mem

# aim: compute key presses (i.e. picture onsets) relative to the cardiac cycle for hits and misses
# in 1st (within-subject) and 2nd (between-subject) level analysis

#--------------------------------------------------------------------------
### function variables
# det = "hit_miss": default mode: compute hits and misses (= old pictures)
  # specify: det = "HIT", det = "MISS"

# val = "all_val": default mode: run over all valences
  # specify valences val: "positiv", "negativ", "neutral"

## 1. LEVEL analyis (within-subject)
  # ray1: table with rayleigh test
  # plot1: circular plot
  # H_rad1: circular values of 120 trials
  # mean1: mean of circular

## 2. LEVEL analyis (group-level)
  # ray2: result rayleigh test
  # plot2: circular plot
  # H_rad2: circular values of participant means 
  # mean2: second level mean

#--------------------------------------------------------------------------
circ_click_mem <- function(x, det = "hit_miss", val = "all_val", ray1 = F, plot1 = F, H_rad1 = F, mean1 = F, ray2 = F, plot2 = F, H_rad2 = F, mean2 = F) {
  
  # function to draw line segments into circular plot
  circseg <- function (a, lty, col) { # define a= radians value to draw segment at, lty = linetype (1 = normal, 2 = dashed)
    xcoord <- sin(a)
    ycoord <- cos(a)
    segments(0,0,xcoord, ycoord, col = col, lty= lty, lwd = 3)
  }
  
  # specify detection and valence
  idx <- which(is.na(log_encode$answer)==FALSE) # select only rows where answer is not NA (NA for new pictures)
  d <- log_encode[idx,] 
  
  # define variables for loop
  zerorad <- NULL
  ray.p <- numeric()
  ray.stat <- numeric()
  mean_click_rad <- vector()
  mean_length <- vector()
  circ.dens_rad <- NULL
  mean_secondlevel <- vector()
  raytest_secondlevel <- numeric()
  H_rad <- list()

  
  ## 1. LEVEL CIRCULAR ANALYSIS (within-subject)
  for(part in x[1:length(x)]) {     
    
    
    if (det == "hit_miss" & val == "all_val") {  # loop over all memory probes (old pics): all det (hit, miss) & all valences
      vec <- (d$radclick[(d$vp == part)]) # take whole column
      H_rad[[part]] <- circular(vec, type = "angles", units="radians", modulo="2pi", rotation="clock", zero=pi/2)  
      
    } else if (det == "hit_miss" & val != "all_val") {  # all memory probes for specified valence
      vec <- (d$radclick[(d$vp == part) & (d$valence == val)]) # whole columns
      H_rad[[part]] <- circular(vec, type = "angles", units="radians", modulo="2pi", rotation="clock", zero=pi/2)  
      
    } else if (det != "hit_miss" & val == "all_val") { # specified detection (hit, miss), but no specified valence
      vec <- (d$radclick[(d$vp == part) & (d$det == det)]) # whole columns
      H_rad[[part]] <- circular(vec, type = "angles", units="radians", modulo="2pi", rotation="clock", zero=pi/2) 
      
    } else {  # specified det (hits, miss) and specified valence (neutral, positiv, negaitv)
      vec <- (d$radclick[(d$vp == part) & (d$detection == det) & (d$valence == val)])
      H_rad[[part]] <- circular(vec, type="angles", units="radians", modulo="2pi", rotation="clock", zero=pi/2)
    }
    
    # exclude vector with <= 1 circular elements 
    if(length(vec) <= 1) { # H_rad contains <= 1 element -> no further tests, plot possible
      zerorad[[part]] <- x[[which(x == part)]] # store inc with <= 1 rad in zerorad
      message(paste(part, ": <= 1 items for", det, val)) # message which inc have <= 1 rad
      next # skip next to next part -> continue with loop
      
      # if H_rad > 1 elements:
    } else { 
      
      # run tests 1st level
      mean_click_rad[part] <- mean(H_rad[[part]])
      mean_length[part] <- rho.circular(H_rad[[part]])
      raytesttmp <- rayleigh.test(H_rad[[part]])
      ray.p[part] <- raytesttmp$p.value
      ray.stat[part] <- raytesttmp$statistic
      
      
      #create circular plots from H_rad (circular data of picture onsets)
      if (plot1 == T) {
        
        plot(H_rad[[part]], stack=TRUE, bins = 720, cex = 1.0, col="black",
             main = (paste(part,":", det, val))) #, ": memory probes relative to cardiac phase")))   
        
        # extract individual intervals for part from data_bins
        dat <- data_bins[data_bins$vp == part,] # select row of data_bins where vp == part
        circtrans <- 2 * pi * (1/dat$R_R_s) # transformation vector to transform sec -> rad
        
        # compute circular density
        circ.dens_rad[[part]] = density(H_rad[[part]], bw=40)
        lines(circ.dens_rad[[part]], col="lightgrey", lwd = 1, xpd=TRUE)
        
        #compute circular mean
        arrows.circular(mean(H_rad[[part]]), lwd = 3, col = defgrey) #y = rho.circular(H_rad),
        
        # define radians of cardiac phase segments
        sysstart <- (circtrans * (dat$crop)) # start of systole
        sysend <- (circtrans * (dat$Rtend_s)) # end of systole
        diasstart <- (circtrans * (dat$Rtend_s + 0.05)) # start of diastole
        diasend <- (circtrans * (dat$Rtend_s + 0.05 + dat$diaspat)) # en of diastole
        
        # draw segments
        circseg(sysstart, 1, deforange) # sys start
        circseg(sysend, 2, deforange) # sys end
        circseg(diasstart, 1, defmedblue) # dias start
        circseg(diasend, 2, defmedblue) # dias stop

      } # end of if loop
    } # end of else loop
  } # end of for loop
  
  
  #print circular mean1
  if (ray1 == T) {
    rayvec1 <- data.frame(x, ray.stat, ray.p)
    colnames(rayvec1) <- c("vp", "rayleigh statistics", "pvalue")
    return(rayvec1)
  }
  

  #print circular data (circular picture onset means = H_rad1)
  if (H_rad1 == T) {
    return(H_rad)
  }
  
  
  #print circular mean1
  if (mean1 == T) {
    meanvec1 <- data.frame(x, mean_click_rad, mean_length)
    colnames(meanvec1) <- c("vp", "individual mean (rad)", "mean length ϱ")
    return(meanvec1)
  }
  
  #--------------------------------------------------------------------------
  ## 2. LEVEL CIRCULAR ANALYSIS (group-level)
  H_rad_secondlevel=circular(mean_click_rad, type="angles", units="radians", rotation="clock", zero=pi/2)
  
  if (ray2 == T) {
    # run tests 2nd level
    raytest_secondlevel <- rayleigh.test(H_rad_secondlevel)
    print(raytest_secondlevel)
  }
  
  if (plot2 == T) {
    # plot circular 2nd level
    plot(H_rad_secondlevel, stack=TRUE, bins = 720, shrink=1.0, cex = 1.0, col= "black", axes=F) #main = paste(deparse(substitute(x)), val)
    
    ## draw lines for individual picture onset means
    for (i in seq_along(H_rad_secondlevel)) {
      dat <- data_bins
      circtrans <- 2 * pi * (1/dat$R_R_s[i])
      if (H_rad_secondlevel[i] <= (circtrans * (dat$crop[i])) | (H_rad_secondlevel[i] > (circtrans * (dat$R_R_s[i] - dat$qonR[i])))) { #pep
        circseg(H_rad_secondlevel[i], defgrey, lty = "dotted")     #arrows.circular(H_rad_secondlevel[i],col = defgrey, lwd = 3, lty = "dotted")
      } else if (H_rad_secondlevel[i] <= (circtrans * (dat$Rtend_s[i])) &  #syspat
                 H_rad_secondlevel[i] > (circtrans * (dat$crop[i]))) {
        circseg(H_rad_secondlevel[i], deforange, lty = "solid") #arrows.circular(H_rad_secondlevel[i],col = deforange, lwd = 3, lty = "solid")
      } else if (H_rad_secondlevel[i] <= (circtrans * (dat$Rtend_s[i] + 0.05)) & #bermuda x
                 H_rad_secondlevel[i] > (circtrans * (dat$Rtend_s[i]))) {
        circseg(H_rad_secondlevel[i], defgrey, lty = "dotted") #arrows.circular(H_rad_secondlevel[i],col = defgrey, lwd = 3, lty = "dotted")
      } else if (H_rad_secondlevel[i] <= (circtrans * (dat$Rtend_s[i] + 0.05 + dat$diaspat[i])) &  #diaspat
                 H_rad_secondlevel[i] > (circtrans * (dat$Rtend_s[i] + 0.05))) {
        circseg(H_rad_secondlevel[i], defmedblue, lty = "longdash") #arrows.circular(H_rad_secondlevel[i],col = defmedblue, lwd = 3, lty = "longdash")
      } else {
        arrows.circular(H_rad_secondlevel[i],col = "red", lwd = 3)
      }
      
    }
    
    #overall mean
    arrows.circular(mean(H_rad_secondlevel), y=rho.circular(H_rad_secondlevel), lwd = 5, col = "black") #y = rho.circular(H_rad),
    
    # circular density
    circ.dens_rad_secondlevel = density(H_rad_secondlevel, bw=40)
    lines(circ.dens_rad_secondlevel, col=defgrey, lwd = 2, xpd=TRUE)
  }
  
  if (H_rad2 == T) {
    return(H_rad_secondlevel)
  }
  
  #--------------------------------------------------------------------------
  #print mean_click_rad2
  if (mean2 == T) {
    x <- H_rad_secondlevel # radians of all participants means
    se <- 1.96*sd(x)/sqrt(length(x)) # calculate standard error
    mean2 <- as.numeric(mean(H_rad_secondlevel)) # calculate 2nd level mean
    meanlength <- rho.circular(H_rad_secondlevel) # calculate mean lenght
    sd <- sd.circular(x)
    meanvec <- c(mean2, se, meanlength, sd)
    names(meanvec) <- c("group-level mean (rad)", "se", "mean length ϱ", "sd")
    print(meanvec)
  }
  
}

#--------------------------------------------------------------------------
