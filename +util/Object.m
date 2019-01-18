classdef Object
% collection of methods which generally works for every object
% 
%% VERSIONING
%             Author: Andreas Justin
%      Creation date: 2017-06-23
%             Matlab: 9.2, (R2017a)
%  Required Products: -
%
%% EXAMPLES
%{
    strct(1,1) = struct("A", "123");
    strct(2,1) = struct("A", "345");
    strct(3,1) = struct("A", "struct");
    strct(4,1) = struct("A", "565");
    strct(5,1) = struct("A", "Struct");
    strct(6,1) = struct("A", "more strings");
    strct(7,1) = struct("A", "and more");

    [strctSelected, idx] = util.Object.selectByPropRegexp(strct, "A", "\d")
        strctSelected = 
            3×1 struct array with fields:
            A
        idx =
            7×1 logical array
            1
            1
            0
            1
            0
            0
            0
    
    [strctSelected, idx] = util.Object.selectByPropStrcmpi(strct, "A", "struct")
        strctSelected = 
            2×1 struct array with fields:
            A
        idx =
            7×1 logical array
            0
            0
            1
            0
            1
            0
            0
%}
%% REVISIONS
% V1.0 | 2017-06-23 | Andreas Justin      | Ersterstellung
% V1.1 | 2018-01-17 | Andreas Justin      | searchProps accepts method names
%                                            obj.('methodName') does work
% V1.2 | 2018-06-14 | Andreas Justin      | added numerous selectBy Methods
% See also mixin.SelectBy

methods (Static)
    function meths = searchMethods(obj, expr)
        % searches given object for methods that are found by the expression
        if nargin < 2 || isempty(expr); expr = ".*"; end
        expr = string(expr);
        meths = string(methods(obj));
        meths = meths(util.regexStr(meths,expr));
        if nargout < 1
            fprintf("class[=" + class(obj) + "] with methods found by expr[='" + expr + "']\n")
            fprintf("\t%s\n", strjoin(meths(:)', '\n\t'));
        end
    end
    function props = searchProperties(obj, expr)
        % searches given object for properties that are found by the expression
        if nargin < 2 || isempty(expr); expr = ".*"; end
        expr = string(expr);
        props = string(properties(obj));
        props = props(util.regexStr(props,expr));
        if nargout < 1
            fprintf("class[=" + class(obj) + "] with properties found by expr[='" + expr + "']\n")
            fprintf("\t%s\n", strjoin(props(:)', '\n\t'));
        end
    end

    function [selected, idx] = selectByProp(objs, propertyAccessor, comperator, inverse)
        % searches given object array for every given field, returns object that matches criteria
        %             objs ... any object array any dimension (also works with structs)
        % propertyAccessor ... string: propertyName to access value (must be public accessable
        %                              methodName to access value (must be public accessable)
        %                      function_handle: function handle to access desired value
        %       comperator ... function_handle to compare the value to
        %          inverse ... boolean to inverse selection (DEFAULT := false)
        %
        %              idx ... index for objs
        %{
            objs = SP.getMessstelle();
            %                                      propertyAccessor     comperator               inverse
            util.Object.selectByPropRegexpi(objs, 'getName',           '^f.y')
            util.Object.selectByPropRegexp(objs,  @(x) x.getName(),    '^F.y')
            util.Object.selectByProp(objs,        @(x) x.getNummber(), @(x) x > 100 && x < 120, false)

            objs = SP.getMessung();
            util.Object.selectByPropIsNaN(objs,   @(x) x.Strecke.Weg,                           true)
        %}
        narginchk(3,4)
        if nargin < 4; inverse = false; end
        if isstring(propertyAccessor) || ischar(propertyAccessor)
            idx = arrayfun(@(x) comperator(x.(propertyAccessor)), objs);
        elseif isa(propertyAccessor, 'function_handle')
            idx = arrayfun(@(x) comperator(propertyAccessor(x)), objs);
        end
        if inverse; idx = ~idx; end
        selected = objs(idx);
    end
    function [selected, idx] = selectByPropRegexp(objs, propertyAccessor, expression, inverse)
        narginchk(3,4)
        if nargin < 4; inverse = []; end
        [selected, idx] = util.Object.selectByProp(objs, propertyAccessor, @(x) ~isempty(regexp(x, expression, "once")), inverse);
    end
    function [selected, idx] = selectByPropRegexpi(objs, propertyAccessor, expression, inverse)
        narginchk(3,4)
        if nargin < 4; inverse = []; end
        [selected, idx] = util.Object.selectByProp(objs, propertyAccessor, @(x) ~isempty(regexpi(x, expression, "once")), inverse);
    end
    function [selected, idx] = selectByPropStrcmp(objs, propertyAccessor, comperator, inverse)
        narginchk(3,4)
        if nargin < 4; inverse = []; end
        [selected, idx] = util.Object.selectByProp(objs, propertyAccessor, @(x) strcmp(x, comperator), inverse);
    end
    function [selected, idx] = selectByPropStrcmpi(objs, propertyAccessor, comperator, inverse)
        narginchk(3,4)
        if nargin < 4; inverse = []; end
        [selected, idx] = util.Object.selectByProp(objs, propertyAccessor, @(x) strcmpi(x, comperator), inverse);
    end
    function [selected, idx] = selectByPropIsEqual(objs, propertyAccessor, comperator, inverse)
        narginchk(3,4)
        if nargin < 4; inverse = []; end
        [selected, idx] = util.Object.selectByProp(objs, propertyAccessor, @(x) isequal(x, comperator), inverse);
    end
    function [selected, idx] = selectByPropIsMember(objs, propertyAccessor, comperator, inverse, stable)
        narginchk(3,5)
        if nargin < 4; inverse = []; end
        if nargin < 5; stable = true; end
        [selected, idx] = util.Object.selectByProp(objs, propertyAccessor, @(x) ismember(x, comperator), inverse);
        
        if stable && ~isempty(selected)
            if isstring(propertyAccessor) || ischar(propertyAccessor)
                prop = arrayfun(@(x) x.(propertyAccessor), selected);
            elseif isa(propertyAccessor, 'function_handle')
                prop = arrayfun(@(x) propertyAccessor(x), selected);
            end
            [~,sortIdx] = ismember(comperator,prop);
            sortIdx(sortIdx==0) = [];
            selected = selected(sortIdx);
        end
    end
    function [selected, idx] = selectByPropIsNaN(objs, propertyAccessor, inverse)
        narginchk(2,3)
        if nargin < 3; inverse = []; end
        [selected, idx] = util.Object.selectByProp(objs, propertyAccessor, @(x) isnan(x), inverse);
    end
    function [selected, idx] = selectByPropIsMissing(objs, propertyAccessor, inverse)
        narginchk(2,3)
        if nargin < 3; inverse = []; end
        [selected, idx] = util.Object.selectByProp(objs, propertyAccessor, @(x) ismissing(x), inverse);
    end
    function [selected, idx] = selectByPropIsEmpty(objs, propertyAccessor, inverse)
        narginchk(2,3)
        if nargin < 3; inverse = []; end
        [selected, idx] = util.Object.selectByProp(objs, propertyAccessor, @(x) isempty(x), inverse);
    end
end
end
