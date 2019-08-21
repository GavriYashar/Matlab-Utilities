classdef Error
% Error identifier enumeration with utility function to create errors or throw errors
%
%% DESCRIPTION
% An collection of commonly used error identifiers with utility functionality for the creation "error" function or appending
% errors with the "errorWithCause..." methods. If an output argument is provided the MException object is returned, otherwise
% the created MException is thrown as caller.
%
%% VERSIONING
%             Author: Andreas Justin, MO RS SC BG EN SSV TD-E
%           Copyright (C) Siemens Mobility GmbH, 2018 - 2019 All Rights Reserved
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
% V1.1 | 2019-04-25 | Martin Lechner      | throwAsCaller implemented for validation functions
% V1.2 | 2019-04-26 | Martin Lechner      | improve docu, error Tags fixed
% V2.0 | 2019-08-09 | Martin Lechner      | all error method throws the error as caller in the case of no output argument;
%                                           throw and throwAsCaller methods removed, comments added to the methods
%
% See also
%
%% EXAMPLES
%{
    % directly throws error
    util.Error.INVALID_TYPE.error("given class[=" + class("asdf") + "] is not supported")
    
    % also returns an MException object
    mException = util.Error.INVALID_TYPE.error("given class[=" + class("asdf") + "] is not supported")

    % allows to add causes to error
    mException = MException("some:identifier", "some error message")
    util.Error.INVALID_TYPE.errorWithCause(mException, "Some user who is testing the given examples")

    mException = MException("some:identifier", "some error message");
    util.Error.INVALID_TYPE.errorWithCauseBefore(mException, "Some user who is testing the given examples with errorWithCauseBefore!")
    
    mException = MException("some:identifier", "some error message");
    util.Error.INVALID_TYPE.errorWithCauseAfter(mException, "Some user who is testing the given examples with errorWithCauseAfter!")

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
    INVALID_TYPE("da:InvalidType")
    
    % for invalid size of input arguments or internal states
    INVALID_SIZE("da:InvalidSize")
    
    % for invalid input arguments in functions or methods
    INVALID_ARGUMENT("da:InvalidArgument")
    
    % for invalid states in the calculation of functions or methods
    INVALID_STATE("da:InvalidState")
    
    % for invalid states where equal elements are expected but not available
    NOT_EQUAL("da:NotEqual")
    
    % function or parameter is defined but not supported to use (only if the implementation isn't finish)
    % If a function or parameter option isn't support anymore than use the DEPRECATED error instead.
    NOT_SUPPORTED("da:NotSupported")
    
    % for deprecated functions, methods or classes
    % Don't use this error for not yet implemented functions or parameter options!
    DEPRECATED("da:Deprecated")
    
    % work in progress, for not yet finished functions
    WIP("da:WIP")
    
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

    function mException = error(obj, message, varargin)
        % Creates an MException and returns this object if an output argument is provided, otherwise the created error is
        % thrown as caller.
        % The error message is created from the given message string and the additionally arguments varargin like the Matlab
        % error functions supports.
        % The best solution for validate functions is to use the following pattern:
        %       err = util.Error.INVALID_ARGUMENT.error("Reason");
        %       err.throwAsCaller()
        % If the error is throw directly also the validation function line is included in the stack trace!
        %       util.Error.INVALID_ARGUMENT.error("Reason")
        mException = MException(obj.identifier.string(), message, varargin{:});
        if nargout < 1
            mException.throwAsCaller();
        end
    end

    function mException = errorWithCause(obj, baseException, message, varargin)
        % Generates an error message with this created error as cause appended to the primary exception containing the
        % primary cause and location of an error, specified as an MException object. If an output argument is provided the
        % MException object is returned, otherwise the created MException is thrown as caller. The error message is created
        % from the given message string and the additionally arguments varargin like the Matlab error functions supports.
        % Useful in catch blocks to add information to the condition or situation in which the baseException happend. Same
        % behaviour as "errorWithCauseAfter".
        %
        % Hint:
        % In case of long stack traces the real cause expressed by this error message is shown belog the primary exception,
        % so that the user doesn't have to scroll up to the first line of the stack trace.
        mException = obj.errorWithCauseAfter(baseException, message, varargin{:});
        if nargout < 1
            mException.throwAsCaller();
        end
    end

    function mException = errorWithCauseAfter(obj, baseException, message, varargin)
        % Generates an error message with this created error as cause appended to the primary exception containing the
        % primary cause and location of an error, specified as an MException object.If an output argument is provided the
        % MException object is returned, otherwise the created MException is thrown as caller. The error message is created
        % from the given message string and the additionally arguments varargin like the Matlab error functions supports.
        % Useful in catch blocks to add information to the condition or situation in which the baseException happend.
        %
        % Hint:
        % In case of long stack traces the real cause expressed by this error message is shown below the primary exception,
        % so that the user doesn't have to scroll up to the first line of the stack trace.
        cause = obj.error(message, varargin{:});
        mException = addCause(baseException, cause);
        if nargout < 1
            mException.throwAsCaller();
        end
    end

    function mException = errorWithCauseBefore(obj, baseException, message, varargin)
        % Generates an error message with this created error as the primary exception appended with the baseException
        % containing the real cause and location of an error, specified as an MException object. If an output argument is
        % provided the MException object is returned, otherwise the created MException is thrown as caller. The error message
        % is created from the given message string and the additionally arguments varargin like the Matlab error functions
        % supports.
        % Useful in catch blocks to add information to the condition or situation in which the baseException happend.
        %
        % Hint:
        % In case of long stack traces the real cause expressed by this error message is shown above (first line) the primary
        % exception, so that the user doesn't have to scroll up to the first line of the stack trace.
        cause = obj.error(message, varargin{:});
        mException = addCause(cause, baseException);
        if nargout < 1
            mException.throwAsCaller();
        end
    end
end

end     % classdef
