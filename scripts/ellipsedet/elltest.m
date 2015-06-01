function res = elltest(C1,D1,R1,M1,C2,D2,R2,M2,tol)
%ELLTEST Summary of this function goes here
%   Detailed explanation goes here

if nargin < 9
    tol = 1e-12;
end

% Change of variables
S1 = [1/sqrt(D1(1,1)) 0 ; 0 1/sqrt(D1(2,2))];

C3 = sqrt(D1)*R1'*(C2-C1);
M3 = S1*R1'*M2*R1*S1;

[R4,M4] = eig(M3);
C4 = R4'*C3;

% Quartic equation for extremal points
d1 = M4(1,1);
d2 = M4(2,2);
c1 = C4(1);
c2 = C4(2);

% a*s^4 + b*s^3 + c*s^2 + d*s + e = 0
a = d1^2*d2^2;
b = -2*d1^2*d2 - 2*d1*d2^2;
c = d1^2 + d2^2 +4*d1*d2 - d1*d2^2*c1^2 - d1^2*d2*c2^2;
d = -2*d2 - 2*d1 + 2*d1*d2*c1^2 + 2*d1*d2*c2^2;
e = 1 - d1*c1^2 - d2*c2^2;

% Get roots
s = quartic([a b c d e], tol);

id = [];
for i = 1 : length(s)
    if isreal(s(i))
        id = [id i];
    end
end
    
s = s(id);

% Get extremal points

px = d1*c1*s./(d1*s - 1);
py = d2*c2*s./(d2*s - 1);

ds = sqrt(px.^2 + py.^2);  

if max(ds) < 1
    
    % fprintf('Contained\n');
    
    res = 5;
    
elseif max(ds) > 1
    
    if min(ds) < 1
        
        % fprintf('Overlap\n');
        
        res = 2;
        
    elseif min(ds) > 1
        
        % fprintf('External\n');
        
        res = 0;
        
    else
        
        % fprintf('Tangent external\n');
        
        res = 1;
        
    end

else
    
    if min(ds) < 1
        
        % fprintf('Tangent overlap\n');
        
        res = 4;
        
    else
        
        % fprintf('Equal\n');
        
        res = 3;
        
    end
    
end    

end

