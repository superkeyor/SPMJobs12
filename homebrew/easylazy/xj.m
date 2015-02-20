% xjview, type 'help xjview' to see help

function varargout = main(varargin)
    ez.clean();
    [varargout{1:nargout}] = xjview(varargin{:}); 
end