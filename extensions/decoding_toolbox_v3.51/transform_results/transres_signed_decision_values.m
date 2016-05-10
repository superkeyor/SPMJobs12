% function output = transres_signed_decision_values(decoding_out, chancelevel, varargin)
%
% Calculate signed decision values. This function outputs decision values
% of the classifier with negative sign for incorrect predictions and
% positive sign for correct predictions. The output can be understood as
% accuracy weighted by decision values, with an expected value of 0. In
% other words, it uses the size of the decision value as evidence weight.
% The more obviously correct samples will receive a higher weight than less
% obviously correct samples. This can be useful also when there are only
% very few test samples available to get a more continuous results measure.
%
% To use this transformation, use
%
%   cfg.results.output = {'signed_decision_values'}
%
% Antonius Wiehler & Martin Hebart, 2015-09-03

function output = transres_signed_decision_values(decoding_out, chancelevel, varargin)

decision_values = vertcat(decoding_out.decision_values);  % decision values of classifier
predicted_labels = vertcat(decoding_out.predicted_labels);  % predicted labels by classifier
true_labels = vertcat(decoding_out.true_labels);  % observed labels

% prepare predictions for multiplication (based on accuracy of each sample):
correct_mult = 2 * (predicted_labels == true_labels) - 1;  
% wrong predictions will receive a negative weight (-1), 
% correct predictions a positive weight (1)

% decision values are signed by correctness of prediction
output = sum(abs(decision_values) .* correct_mult);