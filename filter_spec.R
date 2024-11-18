
###########################################################################
###########################################################################
###                                                                     ###
###               FILTER AFSIS I SPECTRA FOR XRPD SAMPLES               ###
###                                                                     ###
###########################################################################
###########################################################################

# 2024-11-18
# Laura Summerauer

# remove objects in environment
rm(list = ls())

# list spectra provided in subfolders named country
# data source: https://data.worldagroforestry.org/dataset.xhtml?persistentId=doi%3A10.34725%2FDVN%2FQXCWP1 
csv_list <- list.files(
  path = "data/AfSIS_MIR_all/",  # set the path to your data
  pattern = ".csv", recursive = TRUE,
  full.names = TRUE) 

# read files into list
spec_list <- lapply(csv_list, read.csv)

# bind rows and convert to data frame
spec.df <- data.table::rbindlist(spec_list, use.names = TRUE, fill = TRUE, idcol = FALSE)

# read file with IDs (SSNs) of XRPD samples
XRPD_samples <- read.csv("data/XRPD_XY_Files/SSN_ID.csv")

# filter spectra for those samples
spec_XRPD <- spec.df[spec.df$SSN %in% XRPD_samples$SSN,]

# check for which samples we don't have spectra
missing_spec_XRPD.idx <- which(!XRPD_samples$SSN %in% spec.df$SSN)
(SSNs_missing <- data.frame(SSN = XRPD_samples[missing_spec_XRPD.idx,]))
## for 99 samples, no spectra are available.. 

# save file with missing IDs (can we request them at ICRAF?)
write.csv(SSNs_missing, "XRPD_samples_noSpectra.csv")

# check if we have MIR spectra for all samples from Sophie's subset  
subset_sophie <- read.csv("data/XRPD_XY_Files/AfSIS_Mineral_fits.csv")
which(!subset_sophie$SSN %in% spec.df$SSN) # seems ok
which(!subset_sophie$SSN.XRPD %in% XRPD_samples$SSN)

# paired samples (close by?) with radiocarbon data
subset_sophie[which(!subset_sophie$SSN == subset_sophie$SSN.XRPD),]$SSN

# prepare MIR data for further analyses
colnames(spec_XRPD)
colnames(spec_XRPD) <- gsub("m", "", colnames(spec_XRPD))
colnames(spec_XRPD)


#wavenumbers <- 
wavs <- colnames(spec_XRPD)[grep("^[0-9]", colnames(spec_XRPD))]

# names non-spectral data 
nms_non_spec <- colnames(spec_XRPD)[!colnames(spec_XRPD) %in% wavs]

# problematic row:
which(!complete.cases(spec_XRPD[, ..wavs]))
# [1] 1807

# sample with NA's instead of spectral absorbance values 
# remove! 
sample_NAs <- spec_XRPD[!complete.cases(spec_XRPD[, ..wavs]),]

# remove problematic row
spec_XRPD.noNA <- spec_XRPD[which(complete.cases(spec_XRPD[, ..wavs])),]

# change data structure
data_XRPD <- spec_XRPD.noNA[, ..nms_non_spec] |> as.data.frame()
spc_raw <- spec_XRPD.noNA[, ..wavs]
data_XRPD$spc_raw <- as.matrix(spc_raw)
str(data_XRPD)


