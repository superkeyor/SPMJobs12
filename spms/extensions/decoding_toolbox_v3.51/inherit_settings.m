function cfg_adj = inherit_settings(cfg_adj,cfg_orig,varargin)

% This function inherits specific settings from cfg to a subfield of cfg
% (e.g. cfg.parameter_selection).It adds those fields that should be added,
% but doesn't overwrite manually specified settings.
% The logic behind this function: The user does not want to specify all
% settings manually, but most often use the same in the nested method as
% the original (e.g. what classifier to use for feature selection or what
% type of cross-validation to do for parameter selection).
% Input:
%   cfg_adj:  struct array to be adjusted (e.g. cfg.parameter_selection)
%   cfg_orig: struct array where chosen field entries are taken from to
%             fill in cfg_adj
%   varargin: Multiple fields entered
% Output:
%   cfg_adj:  Adjusted struct array (e.g. cfg.parameter_selection)
%
% Example:
% cfg = decoding_defaults;
% cfg.feature_selection.software = 'liblinear';
%

% Is the method actually used? If not, don't run this.
try %#ok<TRYNC>
    if strcmpi(cfg_adj.method,'none')
        return
    end
end

% The easiest solution: Remove all fields from orig that are not part of
% varargin. Then run assign_fields which fills cfg with orig.

if iscell(varargin{1}) && ~isempty(varargin{1})
    varargin = varargin{1};
end

% Remove all other fields from orig (subfields are not touched)
removefields = setdiff(fieldnames(cfg_orig),varargin);
cfg_reduced = rmfield(cfg_orig,removefields);

% Assign_fields
cfg_adj = assign_fields(cfg_reduced,cfg_adj);

% Assign field cfg.results.setwise (needed for results transformation, but
% for nested methods there is only one set anyway)
cfg_adj.results.setwise = 0;

% Have results been specified manually?
try cfg_adj.results.output; %#ok<TRYNC>
   return
end

% Otherwise try filling field
resout = cfg_orig.results.output;

% Check if any results output belongs to this list and remove this entry
% (these entries will not work for optimization)
rmlist = {'confusion_matrix','model_parameters','other',...
    'primal_SVM_weights','primal_SVM_weights_nobias',...
    'rsa_beta','RSA_dist_corr','RSA_dist_euclidean',...
    'SVM_pattern','SVM_weights','SVM_weights_plusbias'};

resout_reduc = setdiff(resout,rmlist);

% If there is only one method choose that
if numel(resout_reduc) == 1
    cfg_adj.results.output = resout_reduc;
else
% Otherwise we cannot know which method to use, so throw warning and use default
    % get defaults
    tmp = decoding_defaults;
    if iscell(tmp.results.output), tmp.results.output = tmp.results.output{1}; end
    cfg_adj.results.output = tmp.results.output;
    warningv('INHERIT_SETTINGS:UsingDefault',...
        ['Unclear which optimization method to use for your nested method ',...
         '(i.e. cfg.feature_selection.results.output or cfg.parameter_selection.results.output). Setting it to: %s ',...
         '\nIf you don''t want this, manually set this field in advance.'],cfg_adj.results.output)
end

    

function cfg = assign_fields(defaults,cfg)

% Self-referencing function that goes through all field names and adds 
% non-existent fields to cfg from the defaults.

d_fields = fieldnames(defaults);

for i = 1:size(d_fields,1)
    % If there are no subfields in the current field
    if ~isstruct(defaults.(d_fields{i}))
        % If this field doesn't exist in cfg, add it from defaults
        if ~isfield(cfg,d_fields{i})
            cfg.(d_fields{i}) = defaults.(d_fields{i});
        end
    % If there are subfields in the current field
    else
        % If this field doesn't exist in cfg, add it (and all subfields) from defaults
        if ~isfield(cfg,d_fields{i})
            cfg.(d_fields{i}) = defaults.(d_fields{i});
        % Else loop through function again for all subfields    
        else
            cfg.(d_fields{i}) = assign_fields(defaults.(d_fields{i}),cfg.(d_fields{i}));
        end
    end
end