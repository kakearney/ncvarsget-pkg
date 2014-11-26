function Data = ncvarsget(file, varargin)
%NCVARSGET Read several variables from a netcdf file
%
% Data = ncvarsget(file, var1, var2, ...)
%
% This function reads multiple variables from a netcdf file.  It is just a
% wrapper function for nc_varget and/or ncread.
%
% Input variables:
%
%   file:   name of netcdf file
%
%   var:    name of variable to read in, which must correspond exactly to a
%           variable in the file.  If no variable names are listed, all
%           variables are read.
%
%   useget: if true, reads data via nc_varget.  If false, reads via ncread.
%           The two functions use different conventions for dimensions. If
%           not included, true is assumed.
%         
%
% Output variables:
%
%   Data:   1 x 1 structure, with fieldnames corresponding to requested
%           variables, each holding the data value for that variable

% Copyright 2009-2013 Kelly Kearney

varnames = varargin;
isflag = cellfun(@(x) islogical(x) && isscalar(x), varnames);
if any(isflag)
    useget = varnames{isflag};
    varnames = varnames(~isflag);
else
    useget = true;
end

if isempty(varnames)
    Info = nc_info(file);
    flds = fields(Info);
    isds = strcmp(lower(flds), 'dataset');
    ds = flds{isds};
    varnames = {Info.(ds).Name};
end

isdimshortcut = strcmp(varnames, 'dimensions');
if any(isdimshortcut)
    varnames = varnames(~isdimshortcut);
    Info = nc_info(file);
    filevars = {Info.(ds).Name};
    if any(strcmp('dimensions', filevars))
        warning('''dimensions'' refers to a variable in this file; option disabled');
    else
        dims = {Info.Dimension.Name};
        isvar = ismember(dims, filevars);
        dimvars = dims(isvar);
        varnames = [dimvars varnames];
        varnames = unique(varnames);
    end
end

nvar = length(varnames);

for iv = 1:nvar
    if useget
        Data.(varnames{iv}) = nc_varget(file, varnames{iv});
    else
        Data.(varnames{iv}) = ncread(file, varnames{iv});
    end
end