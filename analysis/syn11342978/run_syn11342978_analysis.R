#run R md template

##try to use general Rmd template to 

#first format file

#
#synapse file
require(synapser)
require(tidyverse)
require(singleCellSeq)
synapser::synLogin()

#define variables for RMd
syn_file<-synapser::synTableQuery('select id from syn11974770')
analysis_dir<-"syn12508617"

#define matrix
samp.tab<-read.table(synapser::synGet(syn_file)$path,header=T,as.is=TRUE)%>%dplyr::select(-c(gene_id,gene_type))%>%dplyr::rename(Gene="gene_name") 

require(org.Hs.eg.db)
all.gn<-unique(unlist(as.list(org.Hs.egSYMBOL)))
samp.tab <- samp.tab%>%filter(Gene%in%all.gn)
allz<-which(apply(samp.tab%>%dplyr::select(-Gene),1,function(x) all(x==0)))
if(length(allz)>0)
  samp.tab<-samp.tab[-allz,]

#need to remove the gene column
samp.mat<-samp.tab%>%dplyr::select(-Gene)

print(dim(samp.mat))
rownames(samp.mat) <- make.names(samp.tab$Gene,unique=TRUE)

#define any cell specific annotations
cell.annotations<-data.frame(
  Patient=as.factor(sapply(colnames(samp.tab), function(x) gsub("LN","",unlist(strsplit(x,split='_'))[1]))),
  IsPooled=as.factor(sapply(colnames(samp.tab),function(x) unlist(strsplit(x,split='_'))[2]=="Pooled")),
  IsTumor=as.factor(sapply(colnames(samp.tab),function(x) length(grep('LN',x))==0)))[-1,]

#then knit file
rmd<-system.file('processing_clustering_vis.Rmd',package='singleCellSeq')

kf<-rmarkdown::render(rmd,rmarkdown::html_document(),output_file=paste(getwd(),'/processing_cluster_vis.html',sep=''),params=list(samp.mat=samp.mat,gene.list='mcpcounter'))

synapser::synStore(File(kf,parentId=analysis_dir),executed=paste("https://raw.githubusercontent.com/Sage-Bionetworks/single-cell-seq/master/analysis/",syn_file,"/run_",syn_file,"_analysis.R",sep=''),used=syn_file)

##then try to detach seurat and plo the other file

rmd<-system.file('heatmap_vis.Rmd',package='singleCellSeq')
kf<-rmarkdown::render(rmd,rmarkdown::html_document(),output_file=paste(getwd(),'/heatmap_vis.html',sep=''),params=list(samp.mat=samp.mat,cell.annotations=cell.annotations))

synapser::synStore(File(kf,parentId=analysis_dir),executed=paste("https://raw.githubusercontent.com/Sage-Bionetworks/single-cell-seq/master/analysis/",syn_file,"/run_",syn_file,"_analysis.R",sep=''),used=syn_file)
