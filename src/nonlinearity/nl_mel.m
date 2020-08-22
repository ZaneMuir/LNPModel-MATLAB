function [func, der_func] = nl_mel(alpha, offset)
% Mixed Exponential and Linear function
%
%   [func, der_func] = nl_mel(alpha, offset)
%
%   Input Arguments:
%   ----------------
%   alpha   - 
%   offset  - constant bias
%

if nargin == 0
    alpha = 1;
    offset = 0;
elseif nargin == 1
    offset = 0;
end

func = @(x) (x > 0) .* (alpha * x + 1 + offset) + (x <= 0) .* (exp(alpha * x) + offset);

der_func = @(x) (x > 0) .* alpha + (x <= 0) .* (alpha * exp(alpha * x));

end

