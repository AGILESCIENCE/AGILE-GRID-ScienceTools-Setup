function [C,D,R,M] = ellmatrix(x,y,a,b,p)
%ELLMATRIX Summary of this function goes here
%   Detailed explanation goes here

C = [x ; y];
D = [1/a^2 0 ; 0 1/b^2];
R = [cos(p) -sin(p) ; sin(p) cos(p)];
M = R*D*R';

end

