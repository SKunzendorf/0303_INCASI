# Define mytheme
fontsize = 12

mytheme <-  theme_bw() + theme(legend.position="none") +
	
	# Set information about ticks
	theme(axis.ticks=element_line(size=0.2358491)) +
	theme(axis.ticks.length=unit(0.05,"cm")) +

	# Remove all pre-defined lines
	theme(panel.grid.major=element_blank()) +
	theme(panel.grid.minor=element_blank()) +
	theme(panel.background=element_blank()) +
	theme(panel.border=element_blank()) +
	theme(plot.background=element_blank()) +

	# Determine style of box
	theme(axis.line = element_line(color= "black",size=0.2358491)) +	#results in 0.5pt
	
	# Determine font size of axes
	theme(text = element_text(size=fontsize)) +
	theme(axis.title.y=element_text(vjust=0.3,size=fontsize)) +
	theme(axis.title.x=element_text(vjust=0.3,size=fontsize)) +	
	theme(axis.text.x = element_text(size= fontsize)) +
	theme(axis.text.y = element_text(size= fontsize)) +
	theme(strip.text.x = element_text(size= fontsize)) +
	theme(strip.text.y = element_text(size= fontsize))	
  theme(strip.background=element_blank()) 



