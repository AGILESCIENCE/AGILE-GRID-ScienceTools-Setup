function [str,code] = ellmsg(res)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

switch res
    
    case 0
       % str = 'E2 is contained in E1';
       str = 'is contained in';
       code = '0';

    case 1
        % str = 'E2 is contained in E1 but tangent';
        str = 'is contained but tangent to';
		code = '1';	
    
    case 2
        % str = 'E2 is equal to E1';
        str = 'is equal to';
        code = '2';

    case 3
        % str = 'E2 overlap E1';
        str = 'overlap with';
        code = '3';

    case 4
        % str = 'E2 contains E1 but tangent';
        str = 'contains but tangent to';
        code = '4';

    case 5
        % str = 'E2 contains E1';
        str = 'contains';
        code = '5';
         
    case 6
        % str = 'E2 is external to E1 but tangent';
        str = 'is external but tangent to';
        code = '6';
        
    case 7
        % str = 'E2 is external to E1';
        str = 'is external to';
        code = '7';

    otherwise
        str = 'error';
        code = '-1';

end

end

