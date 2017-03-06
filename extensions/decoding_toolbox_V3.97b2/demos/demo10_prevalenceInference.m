% This function tells you the location for demos for prevalence_inference.
% You should find them in decoding_toolbox/statistics/prevalence_inference

if isempty(which('decoding_defaults')), error('Please add TDT'), end

display(['See demos in' char(10) ...
    '   ' fileparts(which('prevalenceTDT')) char(10) ...
    'on how to use the prevalence inference analysis'])