#'
#'evaluate subsets of gene expression markers
#'
#'

require(tidyverse)

#' getGeneList grabs the gene list from teh synapse table
getGeneList <- function(method='cibersort'){
  geneListTable <- 'syn12211688'
  require(synapser)
  synapser::synLogin()
  
  tab <- synTableQuery(paste('select * from',geneListTable))$asDataFrame()%>%select(Gene=Hugo,Cell=cell_type,Method=Method)
  
  if(method%in%(unique(tab$Method)))
    tab <- subset(tab,Method==method)
  
  return(tab)
  
}

#'get list of clusters, annotate by 
plotGeneListByCluster <-function(gene.annotations,samples,cell.annotations){
  require(pheatmap)
  
  #reduce table to gene set
  red.tab<-subset(samples,Gene%in%rownames(gene.annotations))
  
  #hope this works
  rownames(red.tab)<-red.tab$Gene
  
  red.tab<-select(red.tab,-Gene)
  
  #remove zero variance rows/columns
  zv<-which(apply(red.tab,1,var)==0)
  if(length(zv)>0)
    red.tab<-red.tab[-zv,]
  
  zv<-which(apply(red.tab,2,var)==0)
  if(length(zv)>0)
    red.tab<-red.tab[,-zv]
  
  #plot
  pheatmap(log10(1+red.tab),
    annotation_row = gene.annotations,
    clustering_distance_rows='correlation',
    clustering_distance_cols='correlation',
    clustering_method='ward.D2')
  
}