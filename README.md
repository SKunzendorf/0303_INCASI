# Active vision varies across the cardiac cycle

**Authors:**
Stella Kunzendorf <sup>1,2</sup> , Felix Klotzsche <sup>2,3</sup> , Mert Akbal <sup>2</sup> , 
Arno Villringer <sup>2,3</sup>, Sven Ohl <sup>4,5</sup>, & Michael Gaebler <sup>2,3,6</sup>

<sup>1</sup> Charité – Universitätsmedizin Berlin

<sup>2</sup> MPI CBS

<sup>3</sup> Berlin School of Mind and Brain

<sup>4</sup> Bernstein Center of Computational Neuroscience, Berlin

<sup>5</sup> Humboldt-Universität zu Berlin

<sup>6</sup> Universität Leipzig

**Corresponding author**: Stella Kunzendorf

For access to participants' data please contact: stella.kunzendorf[-at-]charite.de


**Abstract**
Perception and cognition oscillate with fluctuating bodily states. For example, visual pro-cessing was shown to change with alternating cardiac phases. Here, we study the role of the heartbeat for active information sampling—testing whether humans implicitly act upon their environment so that relevant signals appear during preferred cardiac phases.
  During the encoding period of a visual memory experiment, participants clicked through a set of emotional pictures to memorize them for a later recognition test. By self-paced key press, they actively prompted the onset of shortly presented (100-ms) pictures. Simultaneously recorded electrocardiograms allowed us to analyse the self-initiated picture onsets relative to the heartbeat. We find that self-initiated picture onsets vary across the cardiac cycle, showing an increase during cardiac systole, while memory performance was not affected by the heartbeat. We conclude that active information sampling integrates heart-related signals, thereby extending previous findings on the association between body-brain interactions and behaviour.

For a detailed description of the study, have a look at our manuscript on bioRxiv: (coming soon).

---

## 1. Prerequisites
Programs you need to install prior to the analysis:
- Our code is computed in the R Statistical Environment (v3.4.3) with **RStudio version 1.0.136** (RStudio Team, 2016)

Programs used for preprocessing the cardiac data (participants' preprocessed cardiac data available upon request):
- **EEGlab** (Delorme & Makeig, 2004) was used as signal analysis tool to read bdf files from ECG recording with an ActiveTwo AD amplifier (Biosemi, Amsterdam, Netherlands)
- Electrical events indicating the beginning of each cardiac cycle (R peaks) were extracted from the ECG signal with **Kubios 2.2** (Tarvainen et al., 2014, <http://kubios.uef.fi/>). 


## 2. Setup

**1.** Clone the `0303_INCASI` repository 
```
$ https://github.com/SKunzendorf/0303_INCASI.git
```

**2.** Maintain the following file structure on your computer

`0303_INCASI` contains 5 file paths:
* **_dataframes** (saved dataframes from analysis)
* **_figures** (saved plots)
* **_functions** (computed functions for analysis)
* **_scripts** (scripts for analysis)
* **_variables** (data for additional variables of inter-individual differences: heart rate variability, trait anxiety, interoceptive awareness)

- if you want to run your own preprocessing, please contact the author (SK; details see above) for the (almost) raw data (output from Kubios analysis for each participant; **0303_INCASI_data**)
- keep this data folder (**0303_INCASI_data**) in the same directory as the cloned repo (**0303_INCASI**)
- your folder structure should look like this:  
...  <br/>
  |--`0303_INCASI`  <br/>
     |--`_dataframes`  <br/>
     |--`_figures`<br/>
     |--`_functions`  
     |--`_scripts`  
     |--`_variables`  
  |--`0303_INCASI_data`  
     |--`inc04`  
     |--`inc05`  
     ...
- For the **main analysis** (skipping preprocessing), directly open script `0303_INCASI_analysis.Rmd` (data folder **0303_INCASI_data** not needed)
- **Caveat**: If you have done your own preprocessing (and you have the folder **0303_INCASI_data**), please change the parameter `use_own_preproc_data` in the setup chunk of `0303_INCASI_analysis.Rmd` to `TRUE`
- The file pathways are then created within the script (setup chunk)


## 3. Scripts

The scripts are to be run in the following order. Preprocessing can be skipped since output dataframes are provided under `_dataframes`. Main analysis can be run directly. 


## 3.1. Preprocessing

### `0303_INCASI_preprocess_a.Rmd`

* script to load raw behavioural data and prepare ECG data for analysis in Kubios

*Script outline:*

**1.** Behavioural data (from stimulation) is loaded into dataframe (one row per trial), and split into 3 according to experimental sessions:

* `log_encode` : encoding period
* `log_recall` : recognition period
* `log_rate` : rating period

**2.** ECG data is imported from EEGlab and prepared for subsequent Rpeak detection in Kubios



### `0303_INCASI_preprocess_b.Rmd`

*Script outline:*

**1. PREPARE LONG DATAFRAME: `LOG_ENCODE`**
* Long df with one row per trial

**1.A.** Regression equations (*Weissler,1968*) are computed to determine Systolic time intervals


**1.B.** Time points of behavioural responses are analysed relative to the heartbeat


**1.B.1.** Define the relative timepoint within R-R interval, length of R-R interval, and heart rate for each key press
* The relative phase of each key press (i.e. picture onset) is computed within the cardiac cycle, indicated in the ECG as the interval between the previous and the following R peak 

**1.B.2.** Define the circular onset and cardiac phase of each key press (cf. Manuscript *Figure 2b*)

* **Circular analysis**: to exploit the oscillatory (repeating cycle of cardiac events) character of the heartbeat

  - According to its relative timing within this R-R interval, radian values between 0 and 2π are assigned to each stimulus (*Ohl et al., 2016; Pikovsky, Rosenblum, & Kurths, 2003; Schäfer, Rosenblum, Kurths, & Abel, 1998*). 

* **Binary analysis**: to exploit the phasic (two distinct cardiac phases: systole and diastole) character of the heartbeat

  - To account for inter-individual differences in cardiac phase lengths, participant-specific phases are computed based on the ECG (for detailed description of the binning procedure cf. Manuscript *Supplementary Methods*)
  - Picture onsets are binned into either individual systole, diastole, or non-defined cardiac phases (pre-ejection period, 50ms security window between end of stystole and start of diastole)


**1.B.3.** Recognition (hits, misses) is defined relative to the cardiac phase (systole, diastole) of picture onset in encoding


**1.C.** Additional variables (inter-individual variables, rating values) are added to the dataframe


**2. PREPARE SHORT DATA FRAME: `DATA_BINS`**
* Short df with one row per participant


## 3.2. Circular functions

Functions to compute within-subject (1. level) and group-level (2. level) circular analysis.

### `fx_circ_encoding.R`

**Aim:** Create circular plots to show distribution of stimulus onsets relative to the cardiac cycle (encoding period)

```
circ_click(x, val = "all_val", ray1 = F, plot1 = F, H_rad1 = F, mean1 = F, ray2 = F, plot2 = F, H_rad2 = F, mean2 = F)
```

**Function variables:**
* **x**: list of participants, or specified participant e.g. "inc25"
* **val**: "all_val" = default mode: run over all valences
  - for specific valence specify val = "positiv", val = "negativ", val = "neutral"

1. level analyis (within-subject)
default mode `= F`, select variables to be computed by writing `= T`:
* **ray1**: table with results of rayleigh test, dip test
* **plot1**: draw circular plot (c.f. `0303_INCASI_analysis.Rmd`, 1.A.1)
* **H_rad1**: circular values of 120 trials
* **mean1**: mean of circular

2. level analyis (group-level)
* **ray2**: result rayleigh test
* **plot2**: circular plot (c.f. `0303_INCASI_analysis.Rmd`, 1.A.2)
* **H_rad2**: circular values of participant means 
* **mean2**: second level mean


Exemplary function input:
* Compute circular analysis for participant 25, plot 1.level analysis, and display rayleigh-test output
* Function output c.f. Manuscript *Figure 2.b.*

```circ_click("inc25", plot1 = T, ray1 = T)```

### `fx_circ_recognition.R`

**Aim:** Create circular plots to show distribution of stimulus onsets (encoding) for correctly (hits) and erroneously (misses) recognised pictures 

```
circ_click_mem(x, det = "hit_miss", val = "all_val", ray1 = F, plot1 = F, H_rad1 = F, mean1 = F, ray2 = F, plot2 = F, H_rad2 = F, mean2 = F) {
```

**Function variables** (see also above)
* **det**: "hit_miss" = default mode: compute hits and misses (= all old pictures)
  - specify: det = "HIT", det = "MISS"



## 3.3. Run analysis

### `0303_INCASI_analysis.Rmd`

- **Caveat**: If you have done your own preprocessing (and you have the folder **0303_INCASI_data**), please change the parameter `use_own_preproc_data` in the setup chunk of `0303_INCASI_analysis.Rmd` to `TRUE`

*Script outline:*

#### MAIN ANALYSIS

**1. ENCODING - CARDIAC INFLUENCE ON VISUAL SAMPLING**

**1.A.** Circular analysis

* 1.A.1. Exemplary participant-level analysis (c.f. Manuscript *Figure 2.b.*)

* 1.A.2. Group-level analysis

* 1.A.3. Bootstrapping analysis (c.f. Manuscript *Figure 1.a*)


**1.B.** Binary analysis

* 1.B.1 Define ratios for both phases (systole, diastole)

* 1.B.2 Run analysis: Compare systolic and diastolic ratio (paired t-test)

* 1.B.3. Plot results with ggplot (c.f. Manuscript *Figure 1.b*)


**2. RECOGNITION - CARDIAC INFLUENCE ON RECOGNITION MEMORY**

**2.A.** Circular analysis

* 2.A.1. Exemplary participant-level analysis (c.f. Manuscript *Figure 2.b.*)

* 2.A.2. Group-level analysis


**2.B.** Binary analysis: 
* Linear mixed model (LMM) for binomial data with subject as random factor (c.f. Manuscript *Table 1*)
  - **m0**: recognition memory ~ valence
  - **m1**: recognition memory ~ valence * cardiac phase

* Dependent variable: recognition memory (coding: 0 = miss, 1 = hit) 
* Independent within-subject variables:
  - cardiac phase: 0 = diastole, 1 = systole
  - valence: three valence levels (positive, negative, neutral), contrast-coded with neutral as baseline condition:   
    positive-neutral, negative-neutral


#### SUPPLEMENTARY ANALYSIS

**1. Supplementary models for recognition memory: Add inter-individual variables**

* add variables to **m1**:
* recognition memory ~ valence * cardiac phase + additional variable

  - **m2**: + Heart rate variability (rmssdl: log-transformed to mitigate skewedness and centred to the mean) 
  - **m3**: + Trait Anxiety (staiz: z-transformed)
  - **m4**: + Interoceptive Awareness (IAz: z-transformed)


**2. Analyse ratings: Subjective perception of picture emotionality (normative vs. individual ratings)**

**2.A.** Normative and individual means of picture ratings for arousal and valence (c.f. Manuscript *Supplementary Table 1*)

**2.B.** Run tests to compare normative vs. individual ratings 

* Run ANOVA to test ratings across rating category (normative, individual) and valence
* Run one-sided ttests for normative vs. individual ratings across each valence level

**2.C.** Plot normative vs. individual ratings (c.f. Manuscript *Supplementary Figure 1*)



#### REFERENCES

Delorme, A., & Makeig, S. (2004). EEGLAB: an open sorce toolbox for analysis of single trail EEG dynamics including independent 
component analysis. *Journal of Neuroscience Methods, 134*, 9–21. *[URL](https://sccn.ucsd.edu/eeglab/download/eeglab_jnm03.pdf)*.

R Core Team (2017). R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, 
Austria. *[URL](https://www.R-project.org/)*.

RStudio Team (2016). RStudio: Integrated Development for R. RStudio, Inc., Boston, MA. *[URL](http://www.rstudio.com/)*.

Tarvainen M. P., Niskanen J. P., Lipponen J. A., Ranta-Aho P. O., Karjalainen P. A. (2014). Kubios HRV – heart rate variability 
analysis software. *Comput. Methods Programs Biomed., 113*, 210–220. *[URL](https://www.sciencedirect.com/science/article/pii/S0169260713002599?via%3Dihub)*.
