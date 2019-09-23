#!/usr/bin/gnuplot -persist 
load 'gpHeader.gp' 
@TeX 
set output 'skk.tex' 
set xlabel '$J_v$' 
set ylabel '$\frac{R_{\text{obs}}}{1 - R_{\text{obs}}}$' 
set key nobox left 
set grid 
plot 24.957055*(1-exp(-0.097866*x)) title 'sims', 'data.dat' using 1:2 with points title 'meas'
set output
