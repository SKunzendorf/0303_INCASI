#--------------------------------------------------------------------------
### MODEL 3
# model: recognition answer (0= miss, 1=hit) ~ heart rate variability
m3 <- glmer(answer ~  rmssdl+ (1|vp),data=d, family="binomial")
summary(m3)

#--------------------------------------------------------------------------
## get predictions of model m3
estimates <- coef(m3)$vp[1,] # check intercept and slope of first participant (first row)

## substract conditional modes(ranef) of random effects from individual coefficients (coef)
# conditional modes: difference btw. average predicted response and response for an individual
# get mean regression coefficient
estimates[1] <- (coef(m3)$vp[,1]- ranef(m3)$vp)[1,1] # ranef: extract conditional modes of the random effects from fitted model object

## vector for range of possible rmssdl variable values
#rmssdl_range <-seq(range(rmssdl)[1],range(rmssdl)[2],length.out=2110) #seq(range(rmssdl)[1],range(rmssdl)[2],length.out=200) # -2,2
rmssdl <- unique(d$rmssdl) # individual rmssdl values

## function to calculate model estimate
# rmssdx: value of rmssd
modelestimate <- function(rmssdx) {

  answer <- estimates[[1]] + estimates[[2]]*rmssdx # calculate model outcome

  # logistic regression ->  1/(1+exp(-modelestimate))
  answer <- 1/(1+exp((-1)*answer)) 
  
  # create output
  out <- cbind(rmssdx, answer)
}

# predict outcome with values of rmssdl
out1 <- modelestimate(rmssdl)
plot(out1)

# put predictions together (if more predictors)
out  <- as.data.frame(out1)

## predict m3
d$pred_logit <- predict(m3)
d$pred_prob  <- exp(d$pred_logit)/(1+exp(d$pred_logit)) 

#--------------------------------------------------------------------------
# plot model output
# par(mar=c(0,0,0,0))
# pdf(file = paste(path_figures, "Manuscript/", "figm3",".pdf",sep=""),width=5,height=5)


figm3 <- ggplot(data = d, aes(x=rmssdl, y=pred_prob)) +
  geom_smooth(aes(x=rmssdl,y=pred_prob), size = 1, col = defdarkgrey) +  #"loess"
  geom_point(data = out, aes(x=rmssdx, y=answer), size = 1, col = defdarkblue) + 
  #geom_line(data = out, aes(x=rmssdl_range, y=answer), lty = 2, size = 1.2, col = deforange) + #lty = 2,
  #geom_point(aes(x=rmssdl_range,y=answer),alpha=0.8,size=0.5,position=position_jitter(height=0.02)) +
  xlab("rmssd [log transformed and centered]") + ylab("p(correct recognition)") + 
  mytheme 
  
figm3

# dev.off()
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
### MODEL 2
m2 <- glmer(answer ~ valence2*ds + rmssdl+ (1|vp),data=d, family="binomial")
summary(m2)

# get predictions of the model m2
estimates <- coef(m2)$vp[1,] # select first row
estimates[1] <- (coef(m2)$vp[,1]- ranef(m2)$vp)[1,1] # ranef: extract conditional modes of the random effects from fitted model

# rmssdl: vector for range of rmssd variable values
rmssdl_range <-seq(range(rmssdl)[1],range(rmssdl)[2],length.out=2110)

# function to calculate model estimate
# rmssdx: value of rmssd -> rmssdl_range
# val2: value of valence2: positiv-neutral (nicht neg-neu)
# val3: value of valence2: negativ-neutral (nicht pos-neu)
# ds: value of phase: 0=diastole, 1=systole
modelestimate2 <- function(rmssdx, val2, val3, ds) {
  
  answer <- estimates[[1]] + estimates[[5]]*rmssdx + estimates[[2]]*val2 + estimates[[3]]*val3 + estimates[[4]]*ds  + estimates[[6]]*ds*val2 + estimates[[7]]*ds*val3
  
  # logistic regression ->  1/(1+exp(-modelestimate))
  answer <- 1/(1+exp((-1)*answer))
  
  # create output
  out <- cbind(rmssdx, answer, ds, val2)
}

# predict
out1 <- modelestimate2(rmssdl, 1, 0, 0) # pos-neu, diastole
out2 <- modelestimate2(rmssdl, 0, 1, 0) # neg-neu, diastole
out3 <- modelestimate2(rmssdl, 1, 0, 1) # pos-neu, systole
out4 <- modelestimate2(rmssdl, 0, 1, 1) # neg-neu, diastole

#plot(out)

# put predictions together
out  <- as.data.frame(rbind(out1,out2,out3,out4))
out$ds <- as.factor(out$ds)
levels(out$ds) <- c("diastole","systole")

out$val2 <- as.factor(out$val2)
levels(out$val2) <- c("negative-neutral", "positive-neutral")


## predict m2
d$pred_logit2 <- predict(m2)
d$pred_prob2  <- exp(d$pred_logit2)/(1+exp(d$pred_logit2)) 

#--------------------------------------------------------------------------
# plot model output
# par(mar=c(0,0,0,0))
# pdf(file = paste(path_figures, "Manuscript/", "figm2",".pdf",sep=""),width=9,height=5)

figm2 <- ggplot(data = d, aes(x=rmssdl, y=pred_prob)) +
  geom_smooth(aes(x=rmssdl,y=pred_prob2), size = 1, col = defdarkgrey) +  #"loess"
  geom_point(data = out, aes(x=rmssdx, y=answer, col = ds), size = 1) + 
  scale_colour_manual(values=c(defmedblue, deforange)) +
  #geom_line(data = out, aes(x=rmssdl_range, y=answer), lty = 2, size = 1.2, col = deforange) + #lty = 2,
  #geom_point(aes(x=rmssdl_range,y=answer),alpha=0.8,size=0.5,position=position_jitter(height=0.02)) +
  facet_wrap(~val2) +
  xlab("rmssd [log transformed and centered]") + ylab("p(correct recognition)") + 
  mytheme 

figm2

# dev.off()
#--------------------------------------------------------------------------