#----------------------------------------------------------------------------
### A. CREATE CLEAN INC_LIST
# `inc_clean`: clean list of participants (inc_list) with normal cardiovascular states (no tachycardia, no hypertension)

# 1. EXCLUDE SUBJECTS WITH HIGH HR
  # subjects with tachycardia (HR > 100/min) (inc_list[8,38] = inc11, inc41)
  # calculate mean_HR for each subject during encoding period
  mean_HR <- tapply(log_encode$HR_1perMin, log_encode$vp, mean) 

  # find subjects with mHR >100
  inc_hyperHR <- which(mean_HR > 100) # "inc11", "inc41" (position 8, 38)
  inc_hyperHR <- inc_list[c(inc_hyperHR)] # exclude vps with high HR

# 2. EXCLUDE SUBJECT WITH HYPERTONUS (HTN)
  #--------------------------------------------------------------------------
  # boxplot bp
  # boxplot(data_bp[,2:3])
  
  # overview bp
  # summary(bp$bpsys[bp$vp %in% inc_list]) #_clean
  # sd(bp$bpsys[bp$vp %in% inc_list]) #_clean
  # 
  # summary(bp$bpdias[bp$vp %in% inc_list])
  # sd(bp$bpdias[bp$vp %in% inc_list])
  # 
  # summary(data_bins$HR_1perMin)
  # sd(data_bins$HR_1perMin)
  
  #--------------------------------------------------------------------------
  # Remove outliers based on Tukey's rule
  # IQR = Q3 - Q1 -> contains middle 50% of the data
  
  x <- data_bp$bpsys # systolic BP
  iqr <- IQR(x) # interquartile range
  quant <- quantile(x, probs=c(.25, .75)) # determine 25% and 75% quartile
  H <- IQR(x)*1.5
  
  # Calculate lower limit
  lower_limit <- as.numeric(quant[1] - H) # Q1 = 1st quartile: 25% of data <= this value
  
  # Calculate upper limit
  upper_limit <- as.numeric(quant[2] + H) # Q3 = 3rd quartile: 25% of data >= this value
  
  # Retrive index of elements which are outliers
  lower_index <- which(x < lower_limit)
  upper_index <- which(x > upper_limit)
  
  idx_htn <- upper_index #  1 outlier ("inc40", position 37)
  inc_htn <- inc_list[idx_htn] 
  inc_cuthtn <- inc_list[-idx_htn]
  #--------------------------------------------------------------------------

# 3. clean inc list without non-physiologic states: without HYPER HR, HTN
  inc_clean <- as.factor(inc_list[-c(inc_hyperHR, inc_htn)])


#----------------------------------------------------------------------------
### B. ADJUST MEMORY PROBES - for circular analysis recognition performance
# * for analysis of recognition memory relative to timepoint of encoding: control for self-paced picture encoding of memory probes
# * For each subject: test distribution of memory probes (old pictures from encoding) against uniform distribution 
# * Exclude subjects with significant non-uniform distribution of memory probes (Rayleigh test) 
# * `inc_clean_cutSignmem_ray`: adapted subject list (participants with significant memory ditribution cutted out)

# dataframe tests_mem: rayleigh test (ray.p) for memory probes for each subject
tests_mem <- map_df(inc_clean, circ_click_mem, ray1 = T) # store dataframe with testresults in ray1

# with sign mem probes: subjects whose distribution of mem probes significantly differs from normal distribution
inc_sign_mem_ray <- inc_clean[c(which(tests_mem$pvalue < 0.05))] # vps who differ sign. in distribution of mem probes - ray

# create inc_clean without sign mem probes: all val
inc_clean_cutSignmem_ray <- inc_clean[!inc_clean %in% inc_sign_mem_ray] # substract sign mem probes ray from inc_clean_recall
#----------------------------------------------------------------------------
