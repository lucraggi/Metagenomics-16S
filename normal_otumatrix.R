### Normalizando las muestras para beta diversidad
library("metagenomeSeq")
mydata<-load_meta("filtered_otu_table.txt")
obj = newMRexperiment(mydata$counts)
p = cumNormStatFast(obj)
normalized_matrix = cumNormMat(obj, p = p)
exportMat(normalized_matrix, file ="normal_filtered_otu_table.txt")
