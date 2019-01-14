classdef (HandleCompatible) SelectBy
% A mixin for object arrays to select by any given expression
%% VERSIONING
%             Author: Andreas Justin
%      Creation date: 2018-06-20
%             Matlab: 9.5, (R2018b)
%  Required Products: -
%
%% REVISONS
% V0.1 | 2018-06-20 | Andreas Justin      | first implementation
%
% See also util.Object
%
%% --------------------------------------------------------------------------------------------
%% >|•| Methods
%% --|••| Public Methods
methods (Access = public)
    function [objsSelected, idx] = selectBy(objs, propertyAccessor, comparator, inverse)
        % searches given object array for every given field, returns object that matches criteria
        %             objs ... any object array any dimension (also works with structs)
        % propertyAccessor ... string: propertyName to access value (must be public accessable
        %                              methodName to access value (must be public accessable)
        %                      function_handle: function handle to access desired value
        %       comperator ... function_handle to compare the value to
        %          inverse ... boolean to inverse selection (DEFAULT := false)
        %
        % see util.Object.selectByProp
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
        if nargin < 4; inverse = []; end
        [objsSelected, idx] = util.Object.selectByProp(objs, propertyAccessor, comparator, inverse);
    end
    function [objsSelected, idx] = selectByRegexp(objs, propertyAccessor, comparator, inverse)
        narginchk(3,4)
        if nargin < 4; inverse = []; end
        [objsSelected, idx] = util.Object.selectByPropRegexp(objs, propertyAccessor, comparator, inverse);
    end
    function [objsSelected, idx] = selectByRegexpi(objs, propertyAccessor, comparator, inverse)
        narginchk(3,4)
        if nargin < 4; inverse = []; end
        [objsSelected, idx] = util.Object.selectByPropRegexpi(objs, propertyAccessor, comparator, inverse);
    end
    function [objsSelected, idx] = selectByStrcmp(objs, propertyAccessor, comparator, inverse)
        narginchk(3,4)
        if nargin < 4; inverse = []; end
        [objsSelected, idx] = util.Object.selectByPropStrcmp(objs, propertyAccessor, comparator, inverse);
    end
    function [objsSelected, idx] = selectByStrcmpi(objs, propertyAccessor, comparator, inverse)
        narginchk(3,4)
        if nargin < 4; inverse = []; end
        [objsSelected, idx] = util.Object.selectByPropStrcmpi(objs, propertyAccessor, comparator, inverse);
    end
    function [objsSelected, idx] = selectByIsEqual(objs, propertyAccessor, comparator, inverse)
        narginchk(3,4)
        if nargin < 4; inverse = []; end
        [objsSelected, idx] = util.Object.selectByPropIsEqual(objs, propertyAccessor, comparator, inverse);
    end
    function [objsSelected, idx] = selectByIsMember(objs, propertyAccessor, comparator, inverse)
        narginchk(3,4)
        if nargin < 4; inverse = []; end
        [objsSelected, idx] = util.Object.selectByPropIsMember(objs, propertyAccessor, comparator, inverse);
    end
    function [objsSelected, idx] = selectByIsNaN(objs, propertyAccessor, inverse)
        narginchk(2,3)
        if nargin < 3; inverse = []; end
        [objsSelected, idx] = util.Object.selectByPropIsNaN(objs, propertyAccessor, inverse);
    end
    function [objsSelected, idx] = selectByIsMissing(objs, propertyAccessor, inverse)
        narginchk(2,3)
        if nargin < 3; inverse = []; end
        [objsSelected, idx] = util.Object.selectByPropIsMissing(objs, propertyAccessor, inverse);
    end
    function [objsSelected, idx] = selectByIsEmpty(objs, propertyAccessor, inverse)
        narginchk(2,3)
        if nargin < 3; inverse = []; end
        [objsSelected, idx] = util.Object.selectByPropIsEmpty(objs, propertyAccessor, inverse);
    end
end
end