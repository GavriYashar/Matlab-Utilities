classdef (HandleCompatible) StringCustomDisplay < matlab.mixin.CustomDisplay
% A mixing for customDisplay and string methods, the custom display method is based on the string method (to be implemented)
%
%% DESCRIPTION
% A mixing for customDisplay based on a user defined compact string representaion of the object.
% The user has to implement a string method to create a one line string representation of the object.
% char, displayScalarObject and displayNonScalarObject uses this user defined string method.
% With displayDetails() you can see the object details like the Matlab default method details returns.
%
% To see the Matlab's default display use obj.details or details(obj)!
%
%% VERSIONING
%             Author: Martin Lechner
%      Creation date: 2017-09-16
%             Matlab: 9.3, (R2017b)
%  Required Products: -
%
%% REVISIONS
% V1.0 | 2017-09-16 | Martin Lechner      | implementation of this class, made handle compatible
% V1.1 | 2018-10-17 | Martin Lechner      | char methods returns better error message and uses util.Error
% V1.2 | 2018-12-07 | Martin Lechner      | use util.String.generateIndexString to generate the index string
% V2.0 | 2019-01-09 | Martin Lechner      | getPropertyGroups implemented (CHARS_TO_REMOVE_FROM_MATLAB_HEADER constant of
%                                           this mixin isn't shown)
% V2.1 | 2019-01-10 | Andreas Justin      | no error is thrown on missing string, instead link to edit the string method
%                                           directly
% V2.2 | 2019-06-04 | Martin Lechner      | plus operator implemented for strings
%
% See also matlab.mixin.CustomDisplay, goodOldSP.messstelle.Klass, ...
%
%% EXAMPLES
%{
%% Example implementation of string in GrenzW
    function str = string(objs)
        % returns a string array with the representations of this object
        str = strings(size(objs));
        classStr = class(objs);
        for ii = 1 : numel(objs)
            str(ii) = sprintf("%s[min=%g, max=%g, NMess_min=%g, NMess_max=%d]", classStr, objs(ii).min, objs(ii).max, objs(ii).NMess_min, objs(ii).NMess_max);
        end
    end

%% Example of overloading generateDisplayStringForObject
methods (Access = protected)
    function strs = generateDisplayStringForObject(objs, variableName, isDatatipinfo)
        strs = generateDisplayStringForObject@StringCustomDisplay(objs, variableName, isDatatipinfo);
        if isDatatipinfo
            % return if string is created for datatip in editor
            % PREFERENCES > MATLAB > EDITOR/DEBUGGER > "Enable datatips in edit mode"
            return;
        end
        suffix = " <a href=""matlab:myCommand('" + objs.getSomeString() + "')"">Display String</a>";
        strs = strs + suffix;
    end
end
%}

%% --------------------------------------------------------------------------------------------

properties (Constant)
    % number of characters to remove from the Matlab's default getHeader function from the end
    CHARS_TO_REMOVE_FROM_MATLAB_HEADER = 18
end
methods (Access = public, Abstract)
    str = string(objs)
    % returns a string array with the representations of this object
    % The string representation should be a compact one line string!
    % For example if the object contains properties with multiline string, consider replacing "\n" using the line shown below
    %{
        % newline; \n
        str = util.String.to1LineString("test" + newline() + "hallo!")
    
        % tab; \t
        str = regexprep(sprintf("test\thallo!"), "\t", util.Char.RIGHTWARDS_ARROW_TO_BAR.char())
    %}
end
%% >|•| Public Methods
methods (Access = public) % doc Method Attributes
    function str = char(obj)
        % returns a character representation objects string method
        if ~isscalar(obj)
            util.Error.INVALID_SIZE.error("obj '%s' has dimension [%s], but must be scalar (use string instead)!", class(obj), matlab.mixin.CustomDisplay.convertDimensionsToString(obj))
        end
        str = char(obj.string());
    end
    
    function displayDetails(obj)
        % displays variable as Matlab does.
        % scalar - property: value
        % arrays - property
        obj.displayScalarObjetDetailed();
    end
    
    function displaySuperClasses(obj)
        if isstring(obj) || ischar(obj)
            classString = obj;
        else
            classString = class(obj);
        end
        StringCustomDisplay.dispSuperClasses(classString);
    end
    function res = plus(obj1, obj2)
        % PLUS implementation for string concatination; if any of the objects obj1 or obj2 is a string than the result is
        % the string concatinated with string(obj1 or obj2)
        % This method can be called from overladed plus operators in implementing classes
        %     res = plus@StringCustomDisplay(obj1, obj2);
        if isstring(obj1)
            res = obj1 + obj2.string();
        elseif isstring(obj2)
            res = obj1.string() + obj2;
        else
            res = builtin('plus', obj1, obj2);
        end
    end
end

%% >|•| protected methods
methods (Access = protected)
    function propgrp = getPropertyGroups(obj)
        if ~isscalar(obj)
            propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
        else
            % create struct
            props = properties(obj);
            propList = struct();
            for ii = 1 : numel(props)
                if strcmp(props{ii}, 'CHARS_TO_REMOVE_FROM_MATLAB_HEADER')
                    continue % don't show the constant of this mixin
                end
                propActual = obj.(props{ii});
                if isscalar(propActual) && isa(propActual, 'StringCustomDisplay')
                    propString = propActual.string();
                    if ismissing(propString)
                        propString = class(propActual) + ".string() method returned a <missing> string!";
                    end
                    propList.(props{ii}) = propString;
                % elseif isscalar(propActual) && isa(propActual, 'function_handle')
                %    propList.(props{ii}) = func2str(propActual);
                else
                    propList.(props{ii}) = propActual;
                end
            end
            propgrp = matlab.mixin.util.PropertyGroup(propList, 'all Properties');
        end
    end
    function displayEmptyObject(obj)
        fprintf(obj.getHeaderModified());
        fprintf(obj.getFooterModified());
    end
    function displayScalarObject(obj)
        % display for a scalar object
        obj.displayNonScalarObjectDA(inputname(1));
    end
    function displayScalarObjetDetailed(obj)
        matlab.mixin.CustomDisplay.displayPropertyGroups(obj, obj.getPropertyGroups());
    end
    function displayNonScalarObject(objs)
        objs.displayNonScalarObjectDA(inputname(1));
    end
end % protected methods

%% >|•| private methods
methods (Access = protected)
    function displayNonScalarObjectDA(objs, variableName)
        fprintf(objs.getHeaderModified());
        
        footerStrModified = objs.getFooterModified(variableName);
        isDatatipinfo = footerStrModified == "";
        strs = objs.generateDisplayStringForObject(variableName, isDatatipinfo);
        
        if ismissing(strs)
            % if there's a problem generating the string, add hyperlink to jump to string() method
            editStr = "matlab:edit('" + class(objs) + ".string')";
            strs = "could not generate string: <missing> " ...
                + "<a href=""" + editStr + """>edit string method</a>";
        end
        fprintf("%s\n", strs)
        fprintf(footerStrModified);
    end
    function strs = generateDisplayStringForObject(objs, variableName, isDatatipinfo)
        % Generates display strings for objects. Each entry will have a link prefixed to inspect the variable.
        % Will exclude this links in datatip (mouse hovering over variable Editor/Debugger>Display>Enable datatips in ...).
        strs = objs.string();
        linkedStrs = string(blanks(4));
        suffix = "";
        if ~isDatatipinfo
            % datatip (hovering over variable name in matlab editor) should not display any ahref links
            arrow = util.Char.RIGHTWARDS_ARROW_TO_BAR.char();
            linkedStrs = "<a href=""matlab:openvar('" + variableName + "(" + (1:numel(objs))' + ")')""> " + arrow +"</a>  ";
        end
        strs = util.String.generateIndexString(objs) + linkedStrs + strs(:) + suffix;
    end
    function headerStrModified = getHeaderModified(objs)
        % will replace the ClassName in headerStr with fully qualified name, and removes "with properties"
        headerStr = objs.getHeader();
        className = regexp(class(objs), "\w+$","match","once");
        headerStrModified = regexprep(headerStr, ">" + className + "<", ">" + class(objs) + "<");
        headerStrModified = [headerStrModified(1 : (end-StringCustomDisplay.CHARS_TO_REMOVE_FROM_MATLAB_HEADER)),':',newline];
        headerStrModified = string(headerStrModified);
    end
    function footerStrModified = getFooterModified(objs, variableName)
        % will extend the footer to show details and to edit class file
        footerStrModified = string(matlab.mixin.CustomDisplay.getDetailedFooter(objs));
        if footerStrModified ~= ""
            % datatip (hovering over variable name in matlab editor) should not display any ahref links
            footerStrModified = regexprep(footerStrModified, "\n$", "");
            if nargin > 1
                detailStr = "matlab:" + variableName + ".displayDetails()";
            else
                detailStr = "";
            end
            classStr = class(objs);
            editStr = "matlab:edit('" + classStr + "')";
            docStr = "matlab:doc('" + classStr + "')";
            supStr = "matlab:StringCustomDisplay.dispSuperClassesStr('" + classStr + "')";
            supExpr = "<a href=['""]matlab:superclasses[^>]+>Superclasses</a>";
            supRep = "<a href=""" + supStr + """>Superclasses</a>";
            footerStrModified = regexprep(footerStrModified, supExpr, supRep);
            footerStrModified = footerStrModified + ", <a href=""" + detailStr + """>show-details</a>";
            footerStrModified = footerStrModified + ", <a href=""" + editStr + """>edit-Class</a>";
            footerStrModified = footerStrModified + ", <a href=""" + docStr + """>documentation</a>";
            footerStrModified = footerStrModified + newline();
        end
    end
end % private methods

methods (Static = true)
    function dispSuperClassesStr(classString)
        superClasses = string(superclasses(classString));
        
        editStr = "matlab:edit('" + superClasses + "')";
        docStr = "matlab:doc('" + superClasses + "')";
        details = superClasses.pad("right");
        details = details ...
            + "  <a href=""" + editStr + """>edit-Class</a>" ...
            + "  <a href=""" + docStr + """>documentation</a>";
        
        disp("Superclasses for class classString:")
        disp(details);
    end
end
end
