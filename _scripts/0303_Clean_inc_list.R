#----------------------------------------------------------------------------
### A. CREATE CLEAN INC_LIST
# `inc_clean`: clean list of participants (inc_list) with normal cardiovascular states (no tachycardia, no hypertension)

# 1. EXCLUDE SUBJECTS WITH HIGH HR
  # subjects with tachycardia (HR > 100/min) (inc_list[8,38] = inc11, inc41)
  # calculate mean_HR for each subject
  mean_HR <- tapply(log_encode$HR_1perMin, log_encode$vp, mean) 

  # find subjects with mHR >100
  inc_hyperHR <- which(mean_HR > 100) # "inc11", "inc41" (position 8, 38)
  inc_hyperHR <- inc_list[c(inc_hyperHR)] # exclude vps with high HR

# 2. EXCLUDE SUBJECT WITH HYPERTONUS (HTN)
  # 1 participant with HTN ("inc40", position 37)
  inc_htn <- c(37)
  inc_cuthtn <- inc_list[-inc_htn] 
  
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
