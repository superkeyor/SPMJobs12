% conn, type 'help conn' to see help

function varargout = main(varargin)
    % ez.clean();
    [varargout{1:nargout}] = conn(varargin{:}); 
end