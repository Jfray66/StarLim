- StarLim - v1.0

Installation:

Copy the file "StarLim.ijm" into FiJi/macro/toolsets/ folder.
Run StarLim from FiJi toolbar >> StarLim. Click on numbers (1 to 6) to run StarLim tool.

Description:

StarLim is a toolset designed to run under ImageJ (FiJi), for multi-channels 2D images.
This set of macro is composed of 6 independant action tools (that has to be run following the sequential order OR later if wished).
The purpose of this toolbox is to process and run image segmentation to count foci into nucleus from "x" images that has "x" channels into "x" folder.
Each action tools are recursive.

StarLim is made of 6 action tools that gives the user the possibility to: 

1 - Convert and/or split: Run image conversion into .tif format and/or split images channels.
2 - Normalisation: Run image normalisation based over mean grays intensity from images located into a specific folder.
3 - Background subtraction (Nuclei): Run background subtraction of nuclei images based over mean grays intensity from what is not a positive signal defined by the user.
4 - Background subtraction (Particles): Run background subtraction of particles images based over either mean grays intensity of a folder filled with control images or mean grays intensity of what is not a positive signal defined by the user.
5 - Counting (Nuclei): Run identification of what is a nucleus from what is not, and count.
6 - Counting (Particles): Run identification of what is a particle from what is not into a generated-list of Nucleus-ROI.zip made from tool number 5, and count.

Results are saved into .tsv format file.
Regions of interests identified from either nucleus or particles channel are saved into .zip format file.
Report is saved into the path folder once any action tool is run into .txt format.

The code includes some error-handling such as: if none nuclei or particles are found into any images, the code keeps running.
