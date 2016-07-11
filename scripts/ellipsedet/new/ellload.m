function ell = ellload(fname)
%ELLLOAD Summary of this function goes here
%   Detailed explanation goes here

% Load data

fid = fopen(fname, 'r');

data = textscan(fid, '%s %f %f %f %f %f');

fclose(fid);

% Build Ellipse structure

ell = struct();

for i = 1 : length(data{1})
    
    ell(i).name = data{1}{i};
    
    ell(i).x    = data{2}(i);
    ell(i).y    = data{3}(i);
    ell(i).a    = data{4}(i);
    ell(i).b    = data{5}(i);
    ell(i).p    = data{6}(i)*pi/180;
    
    ell(i).r    = max(ell(i).a,ell(i).b);
    
    ell(i).C    = [];
    ell(i).D    = [];
    ell(i).R    = [];
    ell(i).M    = [];
    
end

end

