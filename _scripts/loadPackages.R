#--------------------------------------------------------------------------
INCASI_packages <- c(
  'ggplot2',
  'reshape',
  'pracma',
  'pracma',
  'grid',
  'ez',				         # includes Greenhouse Geisser correction for ANOVA
  'BayesFactor',       # if you're on windows, dependency 'doMC' will be installed but run sequentially;
                       # bootstrapping will therefore take quite a while
  'dplyr',
  'R.matlab',
  'circular',
  'plotrix',
  'diptest',
  #'RHRV',
  'purrr',
  'tidyr',
  'lsr',
  'effsize',
  'plyr',
  'gridExtra',
  'cowplot',
  'lme4',
  'corrplot',
  'mgcv')


for(pkg in INCASI_packages) {
  if(!require(pkg, character.only = T)) {
    install.packages(pkg, dependencies = T, repos="http://cran.rstudio.com/")
  }
}


#--------------------------------------------------------------------------



