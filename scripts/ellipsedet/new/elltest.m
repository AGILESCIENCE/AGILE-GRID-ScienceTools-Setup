function res = elltest(C1,D1,R1,M1,C2,D2,R2,M2,tol)
%ELLTEST Summary of this function goes here
%   Detailed explanation goes here

if nargin < 9
    tol = 1e-12;
end

% First transformation:
% E1 became a unit circle centered on the origin
C3 = sqrt(D1)*R1'*(C2-C1);
S1 = [1/sqrt(D1(1,1)) 0 ; 0 1/sqrt(D1(2,2))];
M3 = S1*R1'*M2*R1*S1;

% Second trnsformation:
% Rotate to align E2 with the x/y axis
[R4,D4] = eig(M3);
C4 = R4'*C3;

% Quartic equation for extremal points
d1 = D4(1,1);
d2 = D4(2,2);
c1 = C4(1);
c2 = C4(2);

if c1 == 0 && c2 == 0 % Extremal points are along x/y axes at distance sqrt(1/d1) and sqrt(1/d2)
    
    if d1 == d2
        ds = sqrt(1/d1);
    else
        ds = [sqrt(1/d1) sqrt(1/d2)];
    end
    
else % Extremal points shall be compute usign a quartic
    
    % Quartic eq. a*s^4 + b*s^3 + c*s^2 + d*s + e = 0
    a = d1^2*d2^2;
    b = -2*d1^2*d2 - 2*d1*d2^2;
    c = d1^2 + d2^2 +4*d1*d2 - d1*d2^2*c1^2 - d1^2*d2*c2^2;
    d = -2*d2 - 2*d1 + 2*d1*d2*c1^2 + 2*d1*d2*c2^2;
    e = 1 - d1*c1^2 - d2*c2^2;

    % Get roots
    s = quartic([a b c d e], 1e-6);

    % Get real non-zero roots
    id = [];
    for i = 1 : length(s)
        if isreal(s(i))
            if s(i) ~= 0
                id = [id i];
            end
        end
    end
    s = s(id);

    % Get extremal points
    px = d1*c1*s./(d1*s - 1);
    py = d2*c2*s./(d2*s - 1);
    ds = sqrt(px.^2 + py.^2);
    
end

% Intersection query

% Error
res = -1;

if max(ds) < 1
    
    % fprintf('E2 is contained in E1\n');
    res = 0;
    
elseif max(ds) > 1
    
    if min(ds) < 1
        
        % fprintf('E2 overlap E1\n');
        res = 3;
        
    elseif min(ds) > 1
        
        % Check whether the circle centre is inside or not the ellipse
        f0 = d1*c1^2 + d2*c2^2 - 1;
        
        if f0 > 0
            
            % fprintf('E2 is external to E1\n')
            res = 7;
        
        else
            
            % fprintf('E2 contains E1\n')
            res = 5;
        
        end
               
    else
        
        % Check whether the circle centre is inside or not the ellipse
        f0 = d1*c1^2 + d2*c2^2 - 1;
        
        if f0 > 0
            
            % fprintf('E2 is external to E1 but tangent\n');
            res = 6;
            
        else
            
            % fprintf('E2 contains E1 but tangent\n');
            res = 4;
            
        end
        
    end

else
    
    if min(ds) < 1
        
        % fprintf('E2 is contained in E1 but tangent\n');
        res = 1;
        
    else
        
        % fprintf('E2 is equal to E1\n');
        res = 2;
        
    end
    
end    

end

