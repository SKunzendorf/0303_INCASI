# function to calculate standard error (se)
se <- function(x) {1.96*sd(x)/sqrt(length(x))} #sd(x)/sqrt(length(x))

# load helper functions
se_up   <-  function(x){mean(x) + 1.96*sd(x)/sqrt(length(x))}
se_down <-  function(x){mean(x) - 1.96*sd(x)/sqrt(length(x))}