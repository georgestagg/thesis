set table "thesis.pgf-plot.table"; set format "%.5f"
set format "%.7e";; plot "numerics/figures/ripleyKpoints.dat" using 1:(0*$1*$1) with lines; 
