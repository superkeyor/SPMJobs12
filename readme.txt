spmjobs12
=========Short summary=========
Summary: Batch process (SPM 12 specific) multiple subjects' fMRI data by running a single command up to the first level analysis; separate files into each processing step; generate job files beforehand for you to double-check and review; save informative graphs as pdf for quality control; can send email notification when a job is done.

Author: Jerry Zhu (jerryzhujian9@gmail.com)

URL: http://zhupsy.com/more

=========Long summary=========
Motivation:
While SPM versions 5/8 batch processing scripts are available, a working script for SPM 12 is not listed (as of Jan 7, 2015) at http://www.fil.ion.ucl.ac.uk/spm/ext/ 

Overview/Features:
1) Batch process (SPM 12 specific) multiple subjects' fMRI data by running a single command up to the first level analysis
        e.g., job_dcm2nii(inputDir, outputDir);
2) Separate files into each processing step to declutter your life
        e.g., 00Scanner, 01Import, 02Concat, 03SliceTiming
3) Generate job files before you actually run, so that you can make sure everything is correct
        and also for review purpose
4) Save informative graphs as pdf files during the processing for quality control
5) Auto count the number of runs which could be different for each subject        
6) Use 4D nii to greatly reduce file numbers     
7) Template files/folders provided, easy to adapt to your own study, no programming needed
8) Can receive email notification when a job is done (see the end of the instructions for easy configuration)

Requirements:
1) SPM 12 added to your Matlab path
2) Accept the hard-coded convention of file naming, e.g., s1102_r02.nii
3) Install ghostscript to print pdf
        windows/linux users: http://ghostscript.com/download/gsdnld.html
        mac users: download at http://pages.uoregon.edu/koch/
4) ez general matlab functions 
        independent of spm
        downloadable from https://github.com/jerryzhujian9/ez/blob/master/ez.m

Usage:
1) put this folder somewhere anywhere
2) add jobs folder and all its subfolders to Matlab path
3) copy template folder to somewhere anywhere
4) fill/modify the template folder with your fmri data
5) in general, you only need to run the go.m file in each processing steps (e.g., 01Import, 02Concat etc)

Note:
1) modify default processing parameters
        go to jobs folder, open mod_xxx.mat file with spm batch editor, modify it, save as in processing step folder
2) to be able to use email notification when a job is done
        go to jobs folder, configure batmail.m





Sub-directories:
    /spms - different versions of spm 
    /extensions useful fmri related tools

    /homebrew   - homemade functions
        /jobs    functions that can process many files at a time
        /easylazy   stop being a clicking monkey when using spm gui

To use spm: 
1. add path of this folder (without adding subfolders) to search path
2. then every time use, type 'ignite' to initialize

Alternatively,
1. in startup.m automatically run 'ignite'
2. That's it.


author: Jerry, jerryzhujian9@gmail.com
December 08 2014, 06:37:52 PM CST        