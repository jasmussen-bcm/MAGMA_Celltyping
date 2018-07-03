magma.tileplot <- function(ctd,results,figurePath=NA,height=13,width=4,annotLevel=1,fileTag=""){
    # First, error checking of arguments
    if(sum(!c("Celltype","GWAS","log10p","q","level") %in% colnames(results))>0){stop("results dataframe must contain 'Celltype', 'GWAS', 'log10p', 'level' and 'q' columns")}
    if(length(unique(results$GWAS))<2){stop("Must be more than one unique entry in results$GWAS for plotting tileplot")}
    if(!annotLevel %in% results$level){stop(sprintf("No results for annotation level = %s found in results",annotLevel))}
    
    # Reduce results to only contain results for the relevant annotation level
    results = results[results$level==annotLevel,]
    
    # Setup folder for saving figures
    if(is.na(figurePath)){
        dir.create("Figures", showWarnings = FALSE)
        dir.create("Figures/Tileplots", showWarnings = FALSE)
        figurePath = "Figures/Tileplots"
    }else{
        if(!dir.exists(figurePath)){
            stop(sprintf("No folder exists at: %s",figurePath))
        }
    }
    
    # Then prep
    library(ggplot2)
    ctdDendro = get.ctd.dendro(ctd,annotLevel=annotLevel)
    
    # Order cells by dendrogram
    allRes$Celltype <- factor(allRes$Celltype, levels=ctdDendro$ordered_cells)
    # Plot it!
    allRes$q=p.adjust(allRes$P,method="bonferroni")
    
    # Prepare the tileplot
    fig_Heatmap_WOdendro = ggplot(allRes)+geom_tile(aes(x=GWAS,y=Celltype,fill=log10p)) + 
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
        theme(legend.position="none") +
        xlab("") + ylab("") + scale_fill_gradient(low = "darkblue",high = "white") + ggtitle("MAGMA")+
        geom_point(aes(x=GWAS,y=Celltype,size=ifelse(q<0.00001, "HUGEdot", ifelse(q<0.0001, "BIGdot", ifelse(q<0.001, "BiiGdot", ifelse(q<0.05, "dot", "no_dot"))))),col="black") +
        scale_size_manual(values=c(HUGEdot=4,BIGdot=3,BiiGdot=2,dot=1, no_dot=NA), guide="none") 
    
    # Prepare the dendrogram
    Fig_Dendro <- ggplot(segment(ctdDendro$ddata)) + geom_segment(aes(x=x, y=y, xend=xend, yend=yend)) + coord_flip() +  theme_dendro()
    Fig_Dendro <- Fig_Dendro + scale_x_continuous(expand = c(0, 1.3)) 
    
    # Write the figures to PDF
    pdf(sprintf("%s/CombinedRes_TilePlot_MAGMA_noDendro_level%s_%s.pdf",figurePath,annotLevel,fileTag),width=width,height=height)
    print(fig_Heatmap_WOdendro)
    dev.off()
    
    pdf(sprintf("%s/CombinedRes_TilePlot_MAGMA_wtDendro_level%s_%s.pdf",figurePath,annotLevel,fileTag),width=width+1,height=height)
    print(grid.arrange(fig_Heatmap_WOdendro,Fig_Dendro,ncol=2,widths=c(0.8,0.2)))
    dev.off()
}