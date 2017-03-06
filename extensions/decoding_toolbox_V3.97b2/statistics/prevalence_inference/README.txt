# Permutation-based prevalence inference using the minimum statistic

This is an implementation for TDT of the method proposed by Carsten Allefeld, Kai Goergen and John-Dylan Haynes, 'Valid population inference for information-based imaging: From the second-level *t*-test to prevalence inference', [*NeuroImage* 2016] (http://dx.doi.org/10.1016/j.neuroimage.2016.07.040). In that paper the method was introduced as a way to perform population inference for classification accuracy and other information-like measures and called 'permutation-based *information* prevalence inference using the minimum statistic'. Since it can equally well be applied to other first-level summary statistics, the method is here generically referred to as 'permutation-based prevalence inference using the minimum
statistic', or 'prevalence inference' for short.

The implementation wraps the prevalenceCore.m function that can be found on https://github.com/allefeld/prevalence-permutation/releases.

Demonstrations how to use it can be found in

   demo_prevalenceInference_TDTdata.m
   demo_prevalenceInference_provide_own_data.m

The file
   demo_prevalenceInference_Cichy2011.m
can be used to run the same analysis that is also in the paper.
The results of that file can be compared to the content of
   prevalenceResultsDemoCichy11.zip
contained in this folder.

The original version of the code, that can be found at
    https://github.com/allefeld/prevalence-permutation/releases
is included as 
   prevalence-permutation-1.0.0_org.zip 
in this folder. It also contains a prevalenceTest.m function that 
effectively calculates the same as  demo_prevalenceInference_Cichy2011.m, but writes slightly different headers.

Please CITE prevalence analysis as: 
  Allefeld, C., Goergen, K., & Haynes, J.-D. (2016). 
      Valid population inference for information-based imaging: From the 
      second-level t-test to prevalence inference. NeuroImage. 
      http://doi.org/10.1016/j.neuroimage.2016.07.040

A longer, more didactic, previous version of the manuscript exists here:   
  Allefeld, C., Goergen, K., & Haynes, J.-D. (2015). http://arxiv.org/abs/1512.00810

See the LICENSE file for more information.