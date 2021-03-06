#! /usr/bin/R


getPlot <- function(fileData, flag, selector){
#default option
DDA2009.proposed <- dataProcess(raw = fileData,
                                normalization = 'equalizeMedians',
                                summaryMethod = 'TMP',
                                censoredInt = "NA",
                                cutoffCensored = "minFeature",
                                MBimpute = TRUE,
                                maxQuantileforCensored=0.999)

# use type="QCplot" with all proteins
# change the upper limit of y-axis=35
# set up the size of pdf
if (flag == 'qc'){
  dataProcessPlots(data = DDA2009.proposed, type="QCplot",which.Protein=selector,
                 ylimDown=0, ylimUp=35,width=5, height=5, address=FALSE)
}

DDA2009.TMP <- dataProcess(raw = fileData,
                           normalization = 'equalizeMedians',
                           summaryMethod = 'TMP',
                           censoredInt = NULL, MBimpute=FALSE)


# Automatically create the manually created matrix in MSstats, user manual p23
len <- length(levels(DDA2009.TMP$ProcessedData$GROUP_ORIGINAL))

ourMatrix <- matrix(c(0:0),nrow=len,ncol=len)
diag(ourMatrix) = -1
for(i in 1:len-1){
  ourMatrix[i,i+1] = 1
}
ourMatrix[len,1] = 1

ourCondition <- unique(fileData$Condition)
len2 <- length(ourCondition)
tmp <- matrix(ourCondition, nr=len2, nc=1)
name <- matrix(nr=len2, nc=1)
for(i in 1:len2-1){
  name[i,1] <- sprintf('%s-%s', tmp[i+1,1], tmp[i,1])
}
name[len2,1] <- sprintf('%s-%s', tmp[1,1], tmp[len2,1])

row.names(ourMatrix) <- name
#----------End of creation-----------

DDA2009.comparisons <- groupComparison(contrast.matrix = ourMatrix,
                                       data = DDA2009.proposed)

# volcanoPlots
if (flag == 'volcano'){
  groupComparisonPlots(data = DDA2009.comparisons$ComparisonResult, type = 'VolcanoPlot',
                       width=5, height=5, address=FALSE, which.Comparison=selector)
}

# Heatmaps
if (flag == 'heat'){
  #groupComparisonPlots(data = DDA2009.comparisons$ComparisonResult, type = 'Heatmap',
  #                     address=FALSE)
  
  write.csv(DDA2009.comparisons$ComparisonResult, file="MSstats_output.csv")
  
  #! /usr/bin/python
  #conda_install(packages = 'pandas') # If you are using it for the first time, you need to install the pandas package
  
  #! Note that the path also needs to be set in the python file (must be corresponding)
  now_path = getwd()
  py_run_file('./app/MSstatas to pheatmap.py')
  
  heatmap <- read.csv('./pheatmap_input.csv', row.names = 1)
  pheatmap(heatmap)
}


}