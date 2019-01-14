classdef Error
% Error utility with identifier enumeration
% 
%% DESCRIPTION
% An collection of commonly used error identifiers with utility functionality.
% 
%% VERSIONING
%             Author: Andreas Justin
%      Creation date: 2018-06-21
%             Matlab: 9.5, (R2018b)
%  Required Products: -
%
%% REVISONS
% V0.1 | 2018-06-21 | Andreas Justin      | first implementation
% V0.2 | 2018-06-26 | Martin Lechner      | new error type DEPRECATED
% V0.3 | 2018-08-25 | Martin Lechner      | new error type INVALID_STATE
% V0.4 | 2018-10-31 | Martin Lechner      | new error type NOT_SUPPORTED_COMPILER
% V0.5 | 2018-11-13 | Martin Lechner      | comments added to the different error categories
% V1.0 | 2019-01-08 | Martin Lechner      | throw instead of throwAsCaller so that the root cause is also shown
%
% See also 
%
%% EXAMPLES
%{
    % directly throws error
    util.Error.INVALID_TYPE.throw("given class[=" + class("asdf") + "] is not supported")
    util.Error.INVALID_TYPE.error("given class[=" + class("asdf") + "] is not supported")
    
    % also returns an MException object
    mException = util.Error.INVALID_TYPE.error("given class[=" + class("asdf") + "] is not supported")

    % allows to add causes to error
    mException = MException("some:identifier", "some error message")
    util.Error.INVALID_TYPE.errorWithCause(mException, "Some user who is testing the given examples")
    
    % also allows to return the error
    mException = util.Error.INVALID_TYPE.errorWithCause(mException, "Some user who is testing the given examples")

    % Try-Catch example
    try
        error("asdf")
    catch e
        util.Error.INVALID_TYPE.errorWithCause(e, "try catch")
    end
%}
%% --------------------------------------------------------------------------------------------

enumeration
    % for invalid types in inputs
    INVALID_TYPE ("da:InvalidType")
    % for invalid size of inputs or internal states
    INVALID_SIZE ("da:InvalidSize")
    INVALID_ARGUMENT ("da:invalidArgument")
    % for invalid states in the calculation or methods
    INVALID_STATE ("da:invalidState")
    NOT_EQUAL ("da:NotEqual")
    % function or parameter is defined but not supported to use (only if the implementation isn't finish)
    % If a function or parameter option isn't support anymore than use the DEPRECATED error instead.
    NOT_SUPPORTED ("da:NotSupported")
    % for deprecated functions, methods or classes
    % Don't use this error for not yet implemented functions or parameter options!
    DEPRECATED ("da:Deprecated")
    % work in progress, for not yet finished functions
    WIP ("da.WIP")
    % error for not supported functions in standalone applications due to Matlab Compiler limitations (like opening Matlab
    % GUI's or calling unsupported functions)
    NOT_SUPPORTED_COMPILER("da:NotSupportedCompiler")
end

properties (SetAccess = immutable)
    % the error identifier of the MException
    identifier(1,1) string
end

methods
    function obj = Error(str)
        obj.identifier = str;
    end

    function str = string(obj)
        str = obj.identifier;
    end

    function throw(obj, message, varargin)
        mException = obj.error(message, varargin{:});
        mException.throw();
    end

    function mException = error(obj, message, varargin)
        mException = MException(obj.identifier.string(), message, varargin{:});
        if nargout < 1
            mException.throw();
        end
    end

    function mException = errorWithCause(obj, baseException, message, varargin)
        mException = obj.errorWithCauseAfter(baseException, message, varargin{:});
        if nargout < 1
            mException.throw();
        end
    end

    function mException = errorWithCauseAfter(obj, baseException, message, varargin)
        cause = obj.error(message, varargin{:});
        mException = addCause(baseException, cause);
        if nargout < 1
            mException.throw();
        end
    end

    function mException = errorWithCauseBefore(obj, baseException, message, varargin)
        cause = obj.error(message, varargin{:});
        mException = addCause(cause, baseException);
        if nargout < 1
            mException.throw();
        end
    end
end

end