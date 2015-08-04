#!/usr/local/bin/gnuplot
reset
# Making figures call nothing, interactive use x11
load "~/.gnuplot-settings" 

# Output type controls general features of the plot that are (mostly) set in stone. 
# For presentation, boarders wont' be mirrored, tics will be gone and need to be set manually.
# For text, no specific options are set yet, but it may be useful in the future.
# This all will require fine tuning but for some basic settings is fine.
output_type='text'

# Output parameters
outname='csi_normal_convergence_grid'
xsize='4.0 cm'
ysize='3.0 cm'
dash='2'
debug='no'

# latexcommand controls the font and the font size. To change font size.......
# Uncomment the font type you want. More info on ss fonts is in evernote.

# SANS SERIF
#latexcommand='\\usepackage{cmbright}'
# SERIF
latexcommand='\\usepackage[T1]{fontenc}\n\\usepackage{mathptmx}'

# Getting rid of borders in presentation output
if (output_type eq 'presentation') {
set border 3                # No left or top lines
set xtics nomirror          # Get rid of tics on top and left lines
set ytics nomirror
}

# Axes
#set xrange[0:2.0]
#set yrange[1E-31:1E-28]
#set logscale y
#set tics scale 3 
#set border lw 1.5
#set xtics add ( "0.7" 0.7)
set format y '%5.3f'

# Text
#set title ''
#set key left at 4.6, 5E-34
set xlabel 'k grid'
set ylabel 'Converged Energy (Ryd)'

# Minor margin adjustments for Text
#set (tlbr)margin #

# Custom Labels (and coordinate specifications)
# Graph specifies percentages of the graph size
# First specifies the actual coordinates ON the plot
# Article about doing this interactively in evernote!!!!
#set label 1 '' at graph -0.3, graph 1.05 
#set label 2 '' at first 2.3, 2.0

# Arrows
# Add nohead to just get a line. Can add ls # to get a specific color
# style 1 is flat bars, style 2 is an actual arrow
# set arrow from 0.7,1E-31 to 0.7,1E-28 arrowstyle 1 ls 18 lw 4 nohead 

# Plots
# Linestyles 1-9 are solid lines, 10-18 are dashed. Must specify the line width specifically.
LW=4
plot 'energies_grid.dat'  w l ls 2 lw LW title '35 cut',\

# Calls commands to make into eps plot with parameters specified above

eval latexterm(outname, xsize, ysize, dash, debug, latexcommand)
