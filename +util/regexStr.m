function idx = regexStr(str, expr, ignorecase)
% searches an array of strings for a valid regex and returns an index with the same size as string
% 
%% DESCRIPTION
% searches for a given regular expression a matrix given in any dimension for occurences.
% if an occurence is found true will be returned in an index array of the same size as string matrix at the exact position.
%
% This method is preferred over util.regexCell. due to overhead in regexCell, regexStr is faster.
%% INPUT
%        str ... (:,:,...) string: string array
%       expr ... (1,1) string: valid regular expression
% ignorecase ... (1,1) logical: true (DEFAULT) will ignore case
% 
%% OUTPUT
%    idx ... (:,:,...) logical: true if expression is found in string
% 
%% VERSIONING
%             Author: Andreas Justin
%      Creation date: 2018-11-23
%             Matlab: 9.5, (R2018b)
%  Required Products: -
%
%% REVISONS
% V0.1 | 2018-11-23 | Andreas Justin      | first implementation
%
% See also util.regexCell
%
%% EXAMPLES
%{

str = ["A", "a", "b", "B"];
idx = util.regexStr(str, "[AB]")
    idx =
        1   0   0   1

ignorecase = true;
idx = util.regexStr(str, "[AB]", ignorecase)
    idx =
        1   1   1   1

%% Performance
% ~4.5 seconds for 2k by 2k matrix
% compared to ~8 seconds in regexCell
str = strings(2e3);

profile off
profile on

util.regexStr(str, ""); % 

profile viewer

% =~-=~-=~-=~-=~-=~-=~-=~-=~-= %
str = repmat("a",10000,1000);
expr = "a";

tic
util.regexStr(str, expr, true);
toc

% 2014a: 'isempty' : Elapsed time is 7.740784 seconds.
% 2019a: 'isempty' : Elapsed time is 18.091592 seconds.
% 2019a:  @isempty : Elapsed time is 25.741338 seconds.
%}
%% --------------------------------------------------------------------------------------------
%% Input Validation
narginchk(2,3)
if ~isstring(str)
    util.Error.INVALID_ARGUMENT.throw("str must be a matlab string isa " + class(str));
elseif isempty(str)
    util.Error.INVALID_ARGUMENT.throw("str must not be empty");
end
if ~isstring(expr)
    util.Error.INVALID_ARGUMENT.throw("str must be a matlab string isa " + class(expr));
elseif isempty(expr)
    util.Error.INVALID_ARGUMENT.throw("str must not be empty");
elseif numel(expr) > 1
    util.Error.INVALID_ARGUMENT.throw("expression can only be scalar");
end
if nargin < 3 || isempty(ignorecase)
    ignorecase = false;
end
if ~(ismember(ignorecase, [true, false]) || ismember(ignorecase, [0,1]))
    util.Error.INVALID_ARGUMENT.throw("ignorecase must be boolean");
elseif numel(ignorecase) > 1
    util.Error.INVALID_ARGUMENT.throw("ignorecase can only be scalar");
end
ignorecase = iif(ignorecase, "ignorecase", "matchcase");

%% execution
res = regexp(str, expr, ignorecase, "once");
if ~iscell(res)
    res = {res};
end
idx = ~cellfun("isempty", res);
