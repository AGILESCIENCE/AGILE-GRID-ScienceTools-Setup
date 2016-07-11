function [rx,ry] = ellpoints(x,y,a,b,p,n)
%ELLPOINTS Summary of this function goes here
%   Detailed explanation goes here

phi = linspace(0, 2*pi, n);

px = a*cos(phi);
py = b*sin(phi);

rx = x + cos(p)*px - sin(p)*py;
ry = y + sin(p)*px + cos(p)*py;

end

