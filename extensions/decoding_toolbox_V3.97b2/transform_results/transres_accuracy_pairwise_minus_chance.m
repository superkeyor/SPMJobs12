% function output = transres_accuracy_pairwise_minus_chance(decoding_out, chancelevel, varargin)
%
% For more than two classes, rather than getting the mean multiclass
% accuracy across all classes (i.e. chance = 1/n_label), report the mean
% accuracy of all pairwise comparisons (i.e. chance = 1/2).
%
% This code runs faster if all labels are in the same order in all decoding
% steps (e.g. runs).
%
% To use this transformation, use
%
%   cfg.results.output = {'accuracy_pairwise'}
%
% Martin Hebart 2016-03-09
%
% See also transres_accuracy_matrix transres_confusion_matrix

% TODO: allow using subset of accuracy matrix

function output = transres_accuracy_pairwise_minus_chance(decoding_out, chancelevel, varargin)

output = transres_accuracy_pairwise(decoding_out,chancelevel,varargin{:});

output = output - 50; % because our chancelevel is always 50 %