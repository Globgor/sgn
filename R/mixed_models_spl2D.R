## File was edited in ESS mode in emacs and some indents changed. sorry.
##First read in the arguments listed at the command line
args=commandArgs(TRUE)

##args is now a list of character vectors
## First check to see if arguments are passed.
## Then cycle through each element of the list and evaluate the expressions.

if(length(args)==0){
    print("No arguments supplied.")
    ##supply default values
    datafile=''
    paramfile=''
    fixed_factors<-c()
    random_factors<-c()

} else {
    for(i in 1:length(args)){
        print(paste("Processing arg ", args[[i]]));
        eval(parse(text=args[[i]]))
    }
}


workdir = dirname(datafile);
setwd(workdir);

#library(lme4)
#library(lmerTest)
library(sommer)
library(emmeans)
#library(effects)
library(stringr)
library(dplyr)

pd = read.csv(datafile, sep="\t")

source(paramfile)  # should give us dependent_variable and the model

trait = dependent_variables
pd$studyYear = as.factor(pd$studyYear)

##Replacing location name to locationDbId
fixed_model <- gsub("locationName", "locationDbId", fixed_model)
random_model <- gsub("locationName", "locationDbId", random_model)
fixed_factors <- gsub("locationName", "locationDbId", fixed_factors)
random_factors <- gsub("locationName", "locationDbId", random_factors)

print(paste("FIXED MODEL :", fixed_model))
print(paste("RANDOM MODEL: ", random_model))
print(paste("FIXED FACTORS: ", fixed_factors))
print(paste("RANDOM FACTORS: ", random_factors))
#print(head(pd))

BLUE = as.data.frame(unique(pd$germplasmName))
colnames(BLUE) = "germplasmName"
adjustedBLUE = BLUE

BLUPS = BLUE
adjusted_means = BLUE

for(i in 1:length(trait)){

    pd$rowNumber = as.numeric(pd$rowNumber)
    pd$colNumber = as.numeric(pd$colNumber)

    #print(paste("processing trait", trait[i]))
    dependent_variables = trait[i]
    dependent_variables = gsub(" ", "\\.", dependent_variables) # replace space with "." in variable name
    dependent_variables = gsub("\\|", "\\.", dependent_variables) # replace | with .
    dependent_variables = gsub("\\:", "\\.", dependent_variables)
    dependent_variables = gsub("\\-", "\\.", dependent_variables)
    dependent_variables = gsub("\\/", "\\.", dependent_variables)

    print(paste("Dependent variables : ", dependent_variables))

    pd <- pd[!(is.na(pd[c(dependent_variables)])), ]

    # row and column factors of the plots that are left, so that they match the rows of pd
    Rowf = as.factor(pd$rowNumber)
    Colf = as.factor(pd$colNumber)

 

    genotypeEffectType = as.vector(str_match(random_model, 'germplasmName'))
    genotypeEffectType = ifelse(is.na(genotypeEffectType), 'fixed', 'random')
    print(paste('modeling genotypes as: ', genotypeEffectType))


    if (genotypeEffectType=="random") {

        mixmodel = mmes(as.formula(fixed_model), random = as.formula(random_model), rcov = ~ units, dateWarning = F, data=pd)

        print(paste("MIXED MODEL: ", mixmodel))
	      varcomp<- summary(mixmodel)$varcomp
        print(varcomp)

        print("---------")

        print("---------")

        res <- mixmodel$uList[["vsm(ism(germplasmName))"]]
        BLUP <- as.data.frame(res)
        colnames(BLUP) <- dependent_variables
        BLUP <- tibble::rownames_to_column(BLUP, var="germplasmName")
        # print(BLUP)

        ##adjusted means
        adjusted_means = BLUP
        adjusted_means[,2] = adjusted_means[,2] +as.numeric(mixmodel$b[1, 1])

        print(adjusted_means)


    } else {
        
        mixmodel = mmes(as.formula(fixed_model), random = as.formula(random_model), rcov = ~ units, dateWarning = F, data=pd)
        
        # mmes() keeps the effect names in the row names
        blue <- summary(mixmodel)$betas
        Blues <- data.frame(Trait = dependent_variables, Effect = rownames(blue), blue, row.names = NULL)
        BLUE<-as.data.frame(Blues)
        BLUE <- BLUE[,-1]
        colnames(BLUE)[1] <- "accession name"

        Blues$Effect <- gsub("germplasmName","",Blues$Effect)
        inter_name <- as.character(unique(pd$germplasmName[!unique(pd$germplasmName) %in% Blues$Effect]))
        Blues$Effect[Blues$Effect == "Intercept"] <- inter_name[1]
        
        ##obtains adjusted blues
        adjustedBLUE <- Blues[,c("Effect", "Estimate", "Std.Error")]
        colnames(adjustedBLUE) <- c("accession name", "predicted value", "std.Error")
        adjustedBLUE$`predicted value`[2:nrow(adjustedBLUE)] <- adjustedBLUE$`predicted value`[2:nrow(adjustedBLUE)] + mixmodel$b[1, 1]


        BLUE$`accession name` <- adjustedBLUE$`accession name`
        
        print(adjustedBLUE)

    }
}

# save result files
#
# for random effects: file.BLUPs and file.adjustedBLUPs
# for fixed effects: file.BLUEs and file.adjustedBLUEs
#
if (genotypeEffectType=="random") {
    outfile_blup = paste(datafile, ".BLUPs", sep="");
    sink(outfile_blup)
    write.table(BLUP, quote=F, sep='\t', row.names=FALSE)
    sink();
    outfile_adjmeans = paste(datafile, ".adjustedBLUPs", sep="")
    sink(outfile_adjmeans)
    write.table(adjusted_means, quote=F , sep='\t', row.names=FALSE)
    sink();

} else {   #fixed
    outfile_blue = paste(datafile, ".BLUEs", sep="")
    sink(outfile_blue)
    write.table(BLUE, quote=F , sep='\t', row.names=FALSE)
    sink();
    outfile_adjblues = paste(datafile, ".adjustedBLUEs", sep="")
    sink(outfile_adjblues)
    write.table(adjustedBLUE, quote=F , sep='\t', row.names=FALSE)
    sink();
}
