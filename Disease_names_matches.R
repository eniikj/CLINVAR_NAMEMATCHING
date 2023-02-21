#####################2022-05-28#################################################
################################################################################

#MATCHING THE DISEASE NAMES TO THE CLINVAR DATABASE#




#loading in the databases
library(readxl)
draft <- read_excel("/home/robot/Letöltések/Draft_sum_diseases list.xlsx", 
                                        range = cell_cols("C"), col_names = FALSE)




#renaming the column
names(draft)[1] <- "DISEASES"




#converting the names to uppercase
#and getting rid of duplications
#and changing spaces to "_"
#and removing special characters
#and sorting
draft$DISEASES <- toupper(draft$DISEASES)
draft$DISEASES <- gsub(" ", "_", draft$DISEASES)
draft$DISEASES <- gsub("\\(","", draft$DISEASES)
draft$DISEASES <- gsub("\\)","", draft$DISEASES)
draft$DISEASES <- gsub("\\;","", draft$DISEASES)
draft  <- draft[order(draft$DISEASES),]
draft  <- unique(draft)
draft <- na.omit(draft)


clinvar <- read.table("~/Letöltések/clinvar_20211016.ncbi.hg38.diseaseNames.list.unique.v02.txt",
                                                                      quote="\"", comment.char="")

clinvar$V1 <- toupper(clinvar$V1)
clinvar  <- clinvar[order(clinvar$V1),]
clinvar <- as.data.frame(clinvar)
names(clinvar)[1] <- "DISEASES"




#installing the packages
install.packages("fuzzyjoin")
library(fuzzyjoin)


install.packages("stringdist")
library(stringdist)


#finding the exact matches
exact <- stringdist_left_join(draft, clinvar, by="DISEASES", max_dist = 0)


#finding the best matches 
best <- stringdist_left_join(draft, clinvar, by="DISEASES", max_dist = Inf)

best$strdist <- stringdist(a = best$DISEASES.x,
                                   b = best$DISEASES.y)

best <- best[order(best$strdist,decreasing=F),]


best <- best[match(unique(best$DISEASES.x), best$DISEASES.x),]
best <- best[order(best$DISEASES.x),]












#merging the  tables
final <- merge(exact, best, by.x = "DISEASES.x", by.y = "DISEASES.x")

names(final)[1:3] <- c("DISEASES", "EXACT MATCH", "BEST MATCH")






                       
                       
                       
                       
                       
                       

#saving the table
install.packages("writexl")
library("writexl")

write_xlsx(final, path = "/home/robot/Dokumentumok/matches_diseases.xlsx")



