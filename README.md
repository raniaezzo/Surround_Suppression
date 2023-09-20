# Surround_Suppression

Steps before running this experiment:

(1) Install any dependencies (see below).

(2) Set the experimental parameters:
Change values as needed in the parameters.tsv file in the main directory (Surround Suppression).
The parameters.json file is a dictionary will all of the variables defined for the tsv.

(3) Add the gamma.mat table from the calibration procedure to the Config folder inside the main directory for accurate contrast settings (otherwise code will not run if debug is off).

~~~~~~~~~~~~~~~~~~

To setup run experiment:

(1) Ensure Psychtoolbox (PTB) is on the MATLAB path. 

(Optional) To permanently add PTB to MATLAB path, run:

addpath /path/to/psychtoolbox/
savepath

(2) Navigate to Surround_Suppression directory

cd /path/to/Surround_Suppression/

(3) Run expLauncher.m

~~~~~~~~~~~~~~~~~~

Data will be saved in:

Folder named Data in the main directory.

~~~~~~~~~~~~~~~~~~

Instructions for participants:

"During each trial you will see two 2 stimuli in your periphery (one isolated patch and one embedded patch within a surround). Please use the arrow keys (right/left) to adjust the contrast of the isolated stimulus to best match the embedded stimulus. Once the contrasts match, press the space bar to submit your response. IMPORTANT: throughout the experiment, please keep looking at the central fixation marker."

~~~~~~~~~~~~~~~~~~

Dependencies:

MATLAB (tested with R2019a, R2020a, R2023a)
Psychtoolbox (tested with v3)

~~~~~~~~~~~~~~~~~~

Tested and works on operating systems:
 
MacOS Montery, MacOS Mojave

~~~~~~~~~~~~~~~~~~

Troubleshooting:

If using MacOS, you may need to grant keyboard access to MATLAB (in system preferences).



