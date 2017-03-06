% function output = transres_accuracy_matrix_minus_chance(decoding_out, chancelevel, varargin)
%
% Get a matrix of the accuracies of all pairwise comparisons (i.e. chance =
% 50 %) from a multiclass classification. Libsvm doesn't provide this
% directly. The diagonal is not defined and set to NaN.
% IMPORTANT:
% This function is NOT a confusion matrix and does not provide a matrix of multiclass
% accuracies (where chance = 1/n_class). For the confusion matrix use
% transres_confusion_matrix 
% Reporting the multiclass accuracy of each class is not implemented yet.
%
% The output will be an NxN matrix where n is the number of unique labels.
% The columns will represent the true labels, whereas the rows will
% represent the predicted labels. The output is sorted by label number,
% from low to high.
%
% This code runs faster if all labels are in the same order in all decoding
% steps (e.g. runs).
%
% To use this transformation, use
%
%   cfg.results.output = {'accuracy_matrix_minus_chance'}
%
% Martin Hebart 2016-03-09
%
% See also transres_accuracy_matrix

% TODO: allow using subset of accuracy matrix

function output = transres_accuracy_matrix_minus_chance(decoding_out, chancelevel, varargin)

output = transres_accuracy_matrix(decoding_out,chancelevel,varargin{:});

output = output - chancelevel;