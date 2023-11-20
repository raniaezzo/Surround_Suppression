# Surround_Suppression

Steps before running this experiment:

(1) Install any dependencies (see below).

(2) Set the experimental parameters:
Measure the distance between the observers eye and the monitor - you will need to include this in the parameters.tsv file.
Change values as needed in the parameters.tsv file in the main directory (Surround Suppression).
The parameters.json file is a dictionary will all of the variables defined for the tsv.

(3) If testing on a new computer/monitor, calibrate the new monitor. Add the gamma.mat table from the calibration procedure to the Config folder inside the main directory for accurate contrast settings. The current gamma table is linked to your computer -- the default is an example gamma file, so if testing on a new computer please add this condition to scrConfig.m.

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


Behavioral Paradigm (method of adjustment):
"During each trial you will see two 2 stimuli in your periphery (one isolated patch and one embedded patch within a surround). Please use the arrow keys (right/left) to adjust the contrast of the isolated stimulus to best match the embedded stimulus. Once the contrasts match, press the space bar to submit your response. IMPORTANT: throughout the experiment, please keep looking at the central fixation marker."

Neural Paradigm:
"During each trial, two 2 stimuli will be presented in your periphery (one isolated patch and one embedded patch within a surround). There will be a series of letters that appear at the location where you are fixating. Every time you detect the letter K, press the space bar. Try your best to keep fixating at the center for the entire experiment."

~~~~~~~~~~~~~~~~~~

Dependencies for experimental code:

MATLAB (tested with R2019a, R2020a, R2023a)
Psychtoolbox (tested with v3)

Dependencies for analysis code:

MATLAB R2020b+ is needed for edfinfo()

~~~~~~~~~~~~~~~~~~

Tested and works on operating systems:
 
MacOS Montery, MacOS Mojave

~~~~~~~~~~~~~~~~~~

Troubleshooting:

If using MacOS, you may need to grant keyboard access to MATLAB (in system preferences).

~~~~~~~~~~~~~~~~~~

Saved files/variables

FILE: S00_scr_file_BlockX.mat

scr.scr_num (screen pointer for PTB)
scrX_cm (screen width in cm)
scrY_cm (screen height in cm)
scrViewingDist_cm (screen distance from eye in cm)
experimenter (string with initials of experimenter, if set up in code. ‘Unknown’ if not specified)
scrX_px (# of pixels for screen width)
scrY_px (# of pixels for screen height)
scrPixelDepth_bpp (# of bits per pixel)
windX_px (# of pixels for window width - actual display)
windY_px (# of pixels for window height - actual display)
windCenter_px (central pixel position X,Y)
vbl (time tracker - only used during experiment)
ifi (inter frame interval - inverse of refresh rate)

FILE: S00_design_BlockX.mat

expDes.rng (random seed used for the run)
expDes.nb_repeat (# of stimulus repeats - counts 0 and 180 as 2x)
expDes.locations (possible locations within the session, 0=right and 180=left)
expDes.stimulus (string with stimulus descriptor: ‘perlinNoise’ or ‘grating’)
expDes.contrasts (contrast levels of the embedded stimulus)
expDes.mainStimTypes (table of all unique stimuli in the session)
expDes.nb_trials (# of trials in the experiment)
expDes.trialMat (matrix of trial parameters, row=trial; column=[trial#, contrast level, location])
expDes.startingContrasts (starting contrast of the matching stimulus)
expDes.itiDur_s (inter trial interval)
expDes.trial_onsets (time that has elapsed from the start of the experiment in seconds)
expDes.stimulus_onsets (time that has elapsed from the start of the experiment in seconds)
expDes.response (col1: contrast response - the contrast that is submitted for the perceptual judgement; col2: response time - time that elapsed since stimulus onset)

FILE: S00_const_file_BlockX.mat

const.DEBUG (whether debug mode was on (1) or off (0))
const.miniWindow (whether it was run on fullscreen or partial screen - usually for debugging purposes)
const.makemovie (optional flag used when saving the stimulus frames as movie - for debugging)
const.subjID (string of subject ID, e.g., ’01’)
const.subjDir (string of directory of subject data folder)
const.blockLog (string of directory of subject session log file)
const.gammaTablePath (string of directory of screen calibration table)
const.block (block #)
const.blockDir (string of directory of data for this block)
const.scr_fileMat (string of directory for screen information)
const.const_fileMat (string of directory for constant variables throughout experiment)
const.design_fileMat (string of directory for experiment design / trial information)
const.text_size (size of text for instructions)
const.text_font (font of text for instructions)
const.white (3 element array to define white color in PTB)
const.gray (3 element array to define gray color in PTB)
const.black (3 element array to define black color in PTB)
const.lightgray (3 element array to define light gray color in PTB)
const.my_clock_ini (time stamp of experiment)
const.gapRatio (ratio of surround radius that is used for a gap. Note when 0, still small gap appears due to cosine ramp)
const.stimType (cell array with stimulus type - noise or grating)
const.targetContrast (contrast from 0 to 1 of the target / embedded stimulus)
const.keyboard (string to identify keyboard)
const.stimEcc_deg (eccentricity of target stimulus center in degrees)
const.stimEccpix (distance of fixation marker to target center in pixels)
const.stimRadius_deg (radius of the target / matching stimulus in degrees)
const.stimRadiuspix (radius of the target / matching stimulus in pixels)
const.surroundRadius_deg (radius of the surround stimulus in degrees)
const.surroundRadiuspix (radius of the surround stimulus in pixels)
const.fixationRadius_px (radius of the fixation marker in pixels)
const.fixationRadius_deg  (radius of the fixation marker in degrees)
const.window (window pointer for PTB)
const.windowRect (pixel locations for window rectangle corners - for PTB)
const.gammaVals (loaded gamma table - row corresponds to contrast from 0:255)
const.calibSuccess (successfully loaded in and incorporated provided gamma table)
const.stimOri (orientation of stimulus, if applicable - e.g., 90 degrees = vertical orientation)
const.scalar4noiseTarget (constant that can be increased/decreased to manipulate the spatial frequency of noise patch of target)
const.flicker_hz (temporal frequency of stimuli - in hertz)
const.contrast_surround (constant contrast from 0-1 of the surround)
const.stimCosEdge_deg (distance of the cosine ramp of the stimulus - in degrees)
const.stimCosEdge_pix (distance of the cosine ramp of the stimulus - in pixels)
const.gapWidth (# of pixels of the gap between stimulus and surround)
const.surroundWidth (# of pixels of the surround radius not including the gap or central stimulus)
const.grating_halfw  (half stimulus width in pixels)
const.visiblesize  (entire target size visible in width, rounding for pixel misalignment - in pixels)
const.squarewavetex (grating texture pointer for PTB)
const.centermask (mask texture pointer for PTB)
const.surround_halfw   (half surround width in pixels)
const.visiblesize_surr  (entire surround size visible in width, rounding for pixel misalignment - in pixels)
const.surroundwavetex (surround texture pointer for PTB)
const.surroundmask (surround mask texture pointer for PTB)
const.scalar4noiseSurround (constant that can be increased/decreased to manipulate the spatial frequency of noise patch of surround)
const.gapRadius_px  (# of pixels from center to gap edge)
const.gapTexture (mask texture for the gap for PTB)
const.phaseLine (random phases per texture per trial - target, matching stim)
const.maporientation (map needed to display orientations in interpretable form: 90 deg = vertical, 0 deg = horizontal etc.)
const.mapdirection (map needed to display directions/drift in interpretable form: 90 deg = upwards, 0 deg = rightwards etc.)
const.expStart (1 if experiment started)
const.expStop (1 if experiment ended)
const.forceQuit (1 if experiment was force quit)



