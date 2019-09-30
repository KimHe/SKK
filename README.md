# Data fitting for the Spiegler-Kedem-Katchalsky model

- Input file: data.dat (flux in the first column and rejection rate in the second column)
- Output files:
    * output.dat: reflection and permeate coefficients
    * skk.gp: the gnuplot file for generating skk.tex
    * skk.tex: tex file for generating PDF file

## How to run:

- Data fitting for SKK model
    * matlab -r "SKK"
- Data fitting for Ps and C0 relationship
    * matlab -r "PsC0fit"
