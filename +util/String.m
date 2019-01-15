classdef String
% Class with static methods to work on string arrays or generate string array from other inputs
%
%% VERSIONING
%             Author: Martin Lechner
%      Creation date: 2018-12-07
%             Matlab: 9.5, (R2018b)
%  Required Products: -
%
%% REVISIONS
% V0.1 | 2017-10-18 | Andreas Justin      | initial creation
% V0.2 | 2018-12-07 | Martin Lechner      | generateIndexStringForSizeVector and generateIndexString implemented
%
% See also
%
%% EXAMPLES
%{

a = magic(4)
indStr = util.String.generateIndexString(a)
indStr = util.String.generateIndexString(a(:))

%}

%% --------------------------------------------------------------------------------------------

%% >|•| methods
%% --|••| static methods public
methods (Static = true)
    function substr = substringIdx(str, idx)
        % returns substring as string
        % e.g.: 
        %       util.String.substring("asdf", 2:3)
        %       "sd" 
        str = string(str);
        substr = string(str{1}(idx));
    end
    
    function substr = substring(str, idxStart, idxEnd)
        % returns substring as string
        % e.g.: 
        %       util.String.substring("Hello world", 2, 6)
        %       "ello "
        substr = util.String.substringIdx(str, idxStart:idxEnd);
    end

    function c = charAt(str, idx)
        % returns character at given idx
        chr = char(str);
        c = chr(idx);
    end

    function c = lowerAt(str, idx)
        % converts uppercase character at given index to lowercase character
        c = char(str);
        c(idx) = lower(c(idx));
        c = string(c);
    end

    function c = upperAt(str, idx)
        % converts lowercase character at given index to uppercase character
        c = char(str);
        c(idx) = upper(c(idx));
        c = string(c);
    end

    function strTrim = trim(str)
        strTrim = strtrim(str);
    end

    function strTrim = trimStart(str)
        strTrim = strip(str,'left');
    end

    function strTrim = stripStart(str)
        strTrim = strip(str,'left');
    end

    function strTrim = trimEnd(str)
        strTrim = strip(str,'right');
    end

    function isNum = isScalarNumericExcludeInfNaN(str)
        % returns true if str is numeric string in following formats excluding inf
        %  true: 
        %        1; -2; 1,1; 1.1; 1.3e-3
        str = string(str);
        str = regexprep(str, ',', '.');
        if isempty(str)
            return;
        end
        isNum = ~isempty(regexp(str, '-?\d+\.?\d*e?-?\d*','once'));
        if ~isNum
            return;
        end
        n = str2double(str);
        isNum = ~(isempty(n) || isnan(n) || isinf(n) || ~isnumeric(n));
    end

    function booleanString = logicalStr(bool, falseStatement, trueStatement)
        % utility to convert logical to string (e.g. for fprintf)
        if nargin < 2
            falseStatement = "false";
        end
        if nargin < 3
            trueStatement = "true";
        end
        if isa(falseStatement, "util.Char")
            falseStatement = falseStatement.char();
        end
        if isa(trueStatement, "util.Char")
            trueStatement = trueStatement.char();
        end
        falseStatement = string(falseStatement);
        trueStatement = string(trueStatement);
        booleanString = repmat(falseStatement, size(bool));
        booleanString(bool) = trueStatement;
    end

    function matrixString = matrix2str(matrix, sep)
        % converts a given matrix to a single $sep separated string.
        % "r1c1-tab- ... r1cn\n
        %  ...
        %  rmc1-tab- ... rmcn"
        if nargin < 2
            sep = sprintf("\t");
        end
        matrix = string(matrix);
        matrixString = strings(size(matrix,1),1);
        for rr = 1:size(matrix,1)
            matrixString(rr,1) = strjoin(matrix(rr, :), sep);
        end
        matrixString = strjoin(matrixString, newline());
    end

    function indexString = generateIndexString(array, asCellIndex)
        % generate index string for all elements of the given array as column vector like ["(1,1)";"(1,2)"]
        % works for all dimensions.
        %  asCellIndex ...  true - in case of array is a cell array the index will be returned as {1,1}
        %                  false - the index will be returned as array index also if the input array iscell
        if nargin < 2
            asCellIndex = iscell(array);
        end
        if asCellIndex && ~iscell(array)
            asCellIndex = false;
        end
        indexString = util.String.generateIndexStringForSizeVector(size(array), asCellIndex);
    end
    function indexString = generateIndexStringForSizeVector(sizeVec, asCellIndex)
        % generate index string for all elements of the given array as column vector like ["(1,1)";"(1,2)"]
        % Works for all dimensions!
        %  asCellIndex ...  true - the index string is generated as cell index {}
        %                  false - the index string is generated as array index (), DEFAULT
        if nargin < 2
            asCellIndex = false;
        end
        numberDim = numel(sizeVec);
        indRes = cell(numberDim,1);
        [indRes{:}] = ind2sub(sizeVec, 1:prod(sizeVec));
        ind = vertcat(indRes{:}).';
        indStr = string(ind);
        for ii = 1 : numberDim
            indStr(:,ii) = pad(indStr(:,ii), "left");
        end
        indStr = join(indStr,',', 2);
        if asCellIndex
            indexString = "{" + indStr + "}";
        else
            indexString = "(" + indStr + ")";
        end
    end
end     % static methods public

end     % classdef
