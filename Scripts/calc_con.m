function [con] = calc_con(x1, x2, measure)
%CALC_CON calculates from the given variables x1 and x2 
% the connectivity measure defined by option measure
%
% Supported measures:
%   'plv' : phase locking value. A syncrhonization measure to find
%           synchronization between different oscillatory processes. 
%           1:1 synchronization case.
%   ciplv': corrected imaginary part of phase locking. Calculated from
%           complex representation of PLV. Used to escape zero lag synchronization
%           1:1 synchronization case. See: https://iopscience.iop.org/article/10.1088/1741-2552/aacfe4
%           for more details

switch measure
    case 'ciplv'
        cmpx = mean(exp(1i*(x1 - x2)), 2); % mean of the complex phase difference 
        iPLV = imag(cmpx); 
        rPLV = real(cmpx);
        con = iPLV./sqrt(1-rPLV.*rPLV); % ciPLV
    otherwise % also includes 'plv'
        con = abs(mean(exp(1i*(x1 - x2)), 2)); % PLV
end

end


