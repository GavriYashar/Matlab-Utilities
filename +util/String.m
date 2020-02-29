classdef String
% Class with static methods to work on string arrays or generate string array from other inputs
%
%% VERSIONING
%             Author: Martin Lechner, SMO RS CP BG&P EN SSV TD-E
%           Copyright (C) Siemens Mobility Austria GmbH, 2017 - 2020 All Rights Reserved
%      Creation date: 2018-12-07
%             Matlab: 9.7, (R2019b)
%  Required Products: -
%
%% REVISIONS
% V0.1 | 2017-10-18 | Andreas Justin      | initial creation
% V0.2 | 2018-12-07 | Martin Lechner      | generateIndexStringForSizeVector and generateIndexString implemented
% V0.3 | 2019-04-11 | Martin Lechner      | new static method toSizeString
% V0.4 | 2019-04-26 | Martin Lechner      | new method sizeString, 'toSizeString' renamed to 'sizeStringFromSizeVector'
% V0.6 | 2019-04-30 | Martin Lechner      | new static method 'inputName'
% V0.7 | 2019-12-08 | Martin Lechner      | fh2str renamed to func2str (same name as the Matlab function)
% V0.8 | 2019-12-16 | Martin Lechner      | matrix2str uses join and stringMissing
% V0.9 | 2019-12-18 | Martin Lechner      | method inputName: '%' will be replaced by an '_' otherwise error can occure in
%                                           sprintf string creation of error messages
% V1.0 | 2020-01-31 | Martin Lechner      | inputName: '%' will be replaced with '%%' so that sprintf is working correct
%                                               if the values are directly defined the name is 'directlyDefined'
% V1.1 | 2020-02-05 | Martin Lechner      | new method limitLength
% V1.2 | 2020-02-06 | Martin Lechner      | new method limitLengthWithHash
% V1.3 | 2020-02-28 | Martin Lechner      | matrix2str extended with rowDelimiter, limitLength support also an optinal
%                                           delimiter
%
% See also
%
%% EXAMPLES
%{

a = magic(4)
indStr = util.String.generateIndexString(a)
indStr = util.String.generateIndexString(a(:))

util.String.sizeString(ones(3,4))

util.String.matrix2str(a,',',' ; ')
util.String.matrix2str({Inf,NaN,"45"},', ')

util.String.limitLength(util.String.matrix2str([a,a],',',' ; '))

%}
%% --------------------------------------------------------------------------------------------

%% >|•| methods
%% --|••| static methods public
methods (Static = true)
    function str = to1LineString(str)
        str = regexprep(str, "\n", util.Char.DOWNWARDS_ARROW_WITH_CORNER_LEFTWARDS.char());
    end
    function strOut = limitLengthWithHash(strIn, maxLength)
        % shortens the string by replacing too long ends with the hash of the string
        arguments
            strIn string
            % maximal allowed string length (default 80 characters), must be greater than 12
            maxLength(1,1) double {validate.mustBeGreaterThanOrEqual(maxLength, 12)} = 80
        end
        strOut = strings(size(strIn));
        for ii = 1:numel(strIn)
            if strlength(strIn(ii)) > maxLength
                chr = char(strIn(ii));
                chrHash = dec2hex(str2hash(chr));
                strOut = chr(1:maxLength - numel(chrHash)-1) + "_" + chrHash;
            else
                strOut = strIn(ii);
            end
        end
    end

    function strLim = limitLength(strs, strlengthLimit, delimiter)
        % limit the length of each string of a string array to the given limit (default 80 characters)
        % If the length ot the input strs is greater than the $strlengthLimit the string is splited in the first
        % (strlengthLimit/2 - 3) characters seperated with " ... " and the last (strlengthLimit/2 - 3) characters.
        arguments
            % array of strings
            strs string
            % the maximal length of the string, must be at least 12 characters
            strlengthLimit(1,1) double {validate.mustBeGreaterThanOrEqual(strlengthLimit, 12)} = 80
            % the seperator string between the first and last part of the string (only in case of to long strings)
            % default: " … "
            delimiter(1,1) string = " " + util.Char.HORIZONTAL_ELLIPSIS.stringChar + " "
        end
        len = strlength(strs);
        strLim = strs;
        lenDelminiter = strlength(delimiter);
        part = floor(strlengthLimit/2) - ceil(lenDelminiter);
        partEnd = strlengthLimit - part - lenDelminiter;
        for i = 1 : numel(strs)
            if len(i) > strlengthLimit
                strLim(i) = strs{i}(1:part) + delimiter + strs{i}(end-partEnd+1:end);
            end
        end
    end
    function strWrap = autoWrap(str, numberOfChars, expr)
        % Will wrap lines after given expression, and if string is longer than numberOfChars, but will also ensure
        %  that the expression is not split.
        % e.g:
        %{
            % Generic Example
            a = "myFunction(sadasdadsdasdasd, asdasdafdadsf1, asdasdfasdfasdfasf22sdafasdf(@(x) data(1:3))"
            b = util.String.autoWrap(a, 15)
            c = util.String.autoWrap(a, 25)
            d = util.String.autoWrap(a+(1:5)', 15)
        
            % formelIO Example
            fs = 12345;
            dfh = @(data) data(:,1) + data(:,2) .* data(:,3).^2;
            sfh = @(signal, nChOut) Signal_calc_Function(signal, nChOut, dfh, fs);
            strI = util.String.func2str(sfh)
        
            % The idea is to insert a new line after every X characters but only at a comma "," before a variable
            %   a Variable is a word (\w+) with "[=" following it.
            expr = ",(?=\<[\w\\]+\>\[=)";
            strO = util.String.autoWrap(strI, 15, expr)
        %}
        arguments
            str string
            numberOfChars(1,1) double = 100
            expr(1,1) string = ",\s*(?=\<[\w\\]+\>)"
        end
        str = string(str);
        
        % handle array
        if numel(str) > 1
            for ii = 1:numel(str)
                strWrap(ii) = util.String.autoWrap(str(ii), numberOfChars, expr);
            end
            strWrap = handleDA.reshapeT(str, strWrap);
            return
        end
        % handle Skalar
        % suchen der möglichen zeilenumbrüche anhand von $expr
        idx = regexp(str, expr);
        if isempty(idx)
            strWrap = str;
            return
        end
        idx_ = idx;
        strWrap = "";
        
        start = 1;
        for jj = 1:numel(idx)
            strWrap = strWrap + str{1}(start:idx_(jj));
            start = idx_(jj) + 1;
            if idx(jj) > numberOfChars
                idx = idx - numberOfChars;
                strWrap = strWrap + newline() + "  ";
            end
            if jj == numel(idx)
                strWrap = strWrap + str{1}(start:end);
            end
        end
    end
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
    function [isVec, strFixed] = validateNumericIntegerVector(str)
        % returns $isVec=true if $str is a valid matlab integer vector.
        %         str ... 1x1 string; e.g.: [1,2,   5:8 9];

        % sicherstellen, dass nur ziffern, eckige klammern, beistriche und doppelpunkte enthalten sid
        isVec = isempty(regexp(str, "[^\d,: []]", "once"));
        strFixed = str;
        if nargout() == 1 || ~isVec
            return
        end
        %{
            % Test beispiel
            strFixed = "[,   1   2,  3  , 4   :   7 8   "
        %}

        % beistriche und klammern entfernen
        strFixed = regexprep(strFixed, ",", " ");
        strFixed = regexprep(strFixed, "[[]]", "");

        % multiple leerzeichen durch eines ersetzen
        strFixed = regexprep(strFixed, "\s+", " ");

        % leerzeichen am start und am ende ersetzen
        strFixed = util.String.trimStart(strFixed);
        strFixed = util.String.trimEnd(strFixed);

        % richtige doppelpunkt setzung
        strFixed = regexprep(strFixed, "\s*:\s*", ":");
        strFixed = regexprep(strFixed, " ", ", ");

        strFixed = "[" + strFixed + "]";
    end

    function booleanString = logicalStr(bool, falseStatement, trueStatement)
        % utility to convert logical to string (e.g. for fprintf)
        arguments
            bool logical
            falseStatement(1,1) = "false"
            trueStatement(1,1) = "true"
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

    function matrixString = matrix2str(matrix, columnDelimiter, rowDelimiter)
        % converts a given matrix of numbers or strings or a cell array with scalar numbers or strings 
        % to a scalar string with the given column and row delimiters.
        % "r1c1,...,r1cn;...;rmc1,...rmcn"
        %
        % "r1c1-tab- ... r1cn\n
        %  ...
        %  rmc1-tab- ... rmcn"
        arguments
            % matrix of numbers or strings or a cell array with scalar numbers or strings
            matrix
            % the delimiter character for the columns of the row (default: tabulator)
            columnDelimiter(1,1) string = sprintf("\t")
            % the delimiter character for the columns of the row (default: newline)
            rowDelimiter(1,1) string = newline()
            
        end
        matrixString = join(stringMissing(matrix), columnDelimiter, 2);
        matrixString = join(matrixString, rowDelimiter, 1);
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
    function sizeString = sizeString(varargin)
        % returns the dimensions string without the rectangular braces (e.g. 3×2) for the given size array (the size will be
        % determined from the given array).
        % util.String.sizeStringFromArray(ones(2,3,4)) == "2×3×4"
        sizeString = strings(size(varargin));
        for ii = 1:numel(varargin)
            sizeString(ii) = util.String.sizeStringFromSizeVector(size(varargin{ii}));
        end
    end
    function sizeString = sizeStringFromSizeVector(sizeVec)
        % returns the dimensions string without the rectangular braces (e.g. 3×2) for the given size vector 'sizeVec'
        % The input vector must be a size vector which is returned from the Matlab's size function!
        % (joins the elements of the array with '×')
        % util.String.toSizeString(size(ones(2,3,4)))
        sizeString = strjoin(string(sizeVec), "×");
    end
    function inputName = inputName(inputName, withSurroundingQuots)
        % returns the given input name (e.g. of a function or method call) with surrounding quotation marks 'inputName'
        % The inputname must be provided as scalar char or string as returned from the Matlab function 'inputname'. This
        % function 'inputname' must be called outside this method to get the correct input name.
        %   withSurroundingQuots ...  true - returns the input name with surrounding quots 'inputName' (default: true)
        %                            false - only the name or the default string for empty input is returned
        % typical usage: firstInputName = util.String.inputName(inputname(1));
        % In class validation the inputname is typically %out. This makes problems in error messages because %o is format
        % specifier. So '%' will be replaced by an '_'.
        inputName = string(inputName);
        if inputName == ""
            inputName = "directlyDefined";
        end
        if nargin < 2 || withSurroundingQuots
            inputName = "'" + inputName + "'";
        end
        inputName = strrep(inputName, "%", "%%");
    end

    function [str, strWithBracketMatcher] = func2str(fh, texify, maxStrLength)
        % converts the given function handle fh to a string
        % if texify is true a TEX compatible string is returned
        % stack = dbstack();
        % countIterator = numel(util.Object.selectByPropIsEqual(stack, "name", "FormelIO.fh2str"));;
        % bracketL = countIterator + string(util.Char.BOX_DRAWINGS_LIGHT_VERTICAL_AND_LEFT.char());
        % bracketR = string(util.Char.BOX_DRAWINGS_LIGHT_VERTICAL_AND_RIGHT.char()) + countIterator;
        %{
        TODO:
            fsOut = [];
            fs_GPs = 10;
            tWin = 1./fs_GPs;
            schrittWeite = tWin;
            winFunction = @median;
            indexOut = 1;
            interp2SigFs = false;
            sfh_red = @(x,nChOut) Signal_reduce2WindowFunction(x,nChOut,tWin,schrittWeite,winFunction,indexOut,interp2SigFs);
            fh_smth = @(x) smoothdata(x,'rloess',180);
            sfh_smth = @(x,nChOut) Signal_calc_Function(sfh_red(x,nChOut),nChOut,fh_smth,fs_GPs);
            fsOut = 300;
            sfh = @(x,nChOut) Signal_calc_Function(sfh_smth(sfh_red(x,nChOut),nChOut),nChOut,@(x) x,fsOut);
        %}
        arguments
            fh(1,1) function_handle
            texify(1,1) logical = false

            % if the maximum length of str is reached the rest (maxStrLength:end) will be replaced with "..."
            maxStrLength(1,1) double = inf
        end
        try
            fhs = functions(fh);
            switch fhs.type
                case {'simple', 'classsimple'}       % e.g. @mean
                    str = "@" + fhs.function;
                case {'anonymous', 'nested'}        % e.g. @(x) x or a nested function
                    for ww = 1:numel(fhs.workspace)
                        ws = fhs.workspace{ww};
                        fields = string(fieldnames(ws));
                        str = string(func2str(fh));
                        if texify
                            str = strrep(str, "_", "\_");
                        end
                        for ff = 1:numel(fields)
                            if isa(ws.(fields(ff)), "function_handle")
                                strD1 = util.String.func2str(ws.(fields(ff)), texify);
                            else
                                varWs = ws.(fields(ff));
                                if isstruct(varWs)
                                    %TODO: generate a list with all full qualified field names an their values
                                    continue
                                else
                                    strD1 = stringMissing(ws.(fields(ff)));
                                end
                            end

                            % replacing variable with variablename (word) + value
                            % "\<" marks the beginning and "\>" the end of a word
                            %{
                            regexprep("beta, e, giraffe", "\<e\>", "asdf")
                                >> "beta, asdf, giraffe"
                            %}
                            if texify
                                strD2 = fields(ff) + "_{=" + strD1 + "}";
                            else
                                strD2 = fields(ff) + "[=" + strD1 + "]";
                            end
                            str = regexprep(str, "\<" + fields(ff) + "\>", strD2);
                        end
                    end
                case 'scopedfunction'   % a local function in an M-file
                    str = fhs.parentage{1} + "@" + fhs.parentage{2};
                otherwise
                    str = func2str(fh);
                    warning("Unknown function type '%s'!", fhs.type)
            end
        catch err
            warning(err.getReport())
            str = func2str(fh);
            if texify
                str = strrep(str, "_", "\_");
            end
        end
        if strlength(str) >  maxStrLength
            str = extractBefore(str, maxStrLength) + "...";
        end
        if nargout > 1
            strWithBracketMatcher = string(util.Regexp.highlightMatchingBrackets(str, "[]"));
        end
    end
    
    function sha512 = genSha512(str)
        persistent opt;
        if isempty(opt)
            opt.Method = 'SHA-512';
            opt.Format = 'HEX';
        end
        sha512 = DataHash(str, opt);
    end
end     % static methods public

end     % classdef
