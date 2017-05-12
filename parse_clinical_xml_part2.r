############################################################

# Parse TCGA file map for clinical data

# setwd("/Users/choonoo/TCGA_new_exp")
# save.image("file_map_clinical.rda")
# load("file_map_clinical.rda")

############################################################

# clean NA function
clean_na = function(data_set){
  
  for (i in 1:dim(data_set)[2]){
    print(i)
    if(sum(na.omit(data_set[,i] == "") > 0)){
      
      data_set[which( data_set[,i] == ""),i] <- NA
    }
    
  }
  return(data_set)
}

############################################################

# set directory where to save parsed data
dir_folder = dir("clinical_data_5_9_17_parsed")

# save empty vector to save parsed data
pat_data <- vector("list",length(dir_folder))

# save empty vector to save union of clinical variables
pat_data_names <- vector("list",length(dir_folder))

# read in data
for(i in 1:length(dir_folder)){
  
  print(i)
  
  read.delim(paste("clinical_data_5_9_17_parsed", dir_folder[i],sep="/"), header=F, sep="\t") -> pat_data[[i]]
  
  #pat_data_v2 = pat_data[[1]]
  
  pat_data[[i]][,1] <- gsub(":","",sapply(strsplit(as.character(pat_data[[i]][,1]), "}"),"[",2))
  
  
  
  # fix duplicates
  if(sum(duplicated(pat_data[[i]][,1])) > 0){
    
    duplicates = unique(pat_data[[i]][duplicated(pat_data[[i]][,1]),1])
    
    
    for(a in 1:length(duplicates)){
      #print(i)
      pat_data[[i]][pat_data[[i]][,1] %in% duplicates[a],1] <- paste0(pat_data[[i]][pat_data[[i]][,1] %in% duplicates[a],1], seq(1:length(pat_data[[i]][pat_data[[i]][,1] %in% duplicates[a],1])))
      
    }
    
  }
  
  pat_data_v2 = pat_data[[i]]
  
  t(pat_data_v2) -> pat_data_v3
  
  as.data.frame(pat_data_v3) -> pat_data_v3
  
  names(pat_data_v3) <- pat_data_v2[,1]
  
  pat_data_v3[-1,] -> pat_data_v4
  
  print(names(pat_data_v4))
  
  row.names(pat_data_v4) <- pat_data_v4[,"bcr_patient_barcode"]
  
  pat_data[[i]] <- pat_data_v4
  
  pat_data_names[[i]] <- names(pat_data_v4)
  
}

# match names based on union variables between all files

unique(unlist(pat_data_names)) -> full_names

for(a in 1:length(pat_data)){
  
  print(a)
  
  if(sum(!full_names %in% names(pat_data[[a]])) > 0){
    
    for(i in full_names[!full_names %in% names(pat_data[[a]])]){
      
      pat_data[[a]][,i] <- NA
      
    }
  }
  
  pat_data[[a]] <- pat_data[[a]][,full_names]
  
}

# rbind all files
clinical_data_full = do.call(rbind,pat_data) 

############################################################

# clean "\n" to NA
for(i in 1:ncol(clinical_data_full)){
  if(length(grep("\n",clinical_data_full[,i])) > 0){
    
    if(length(levels(clinical_data_full[,i])) > 0){
      levels(clinical_data_full[,i])[grep("\n", levels(clinical_data_full[,i]))] <- NA
      
    }else{
      clinical_data_full[grep("\n",clinical_data_full[,i]),i] <- NA
    }
    
  }
}



clean_na(clinical_data_full) -> clinical_data_full_v2


# save clinical data
write.table(file="clinical_tcga_data_5_9_17.txt", x=clinical_data_full_v2, sep="\t", quote=F, row.names=F)

