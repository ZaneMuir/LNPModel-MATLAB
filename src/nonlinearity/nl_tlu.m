function [func, der_func] = nl_tlu(alpha, offset)
% Thresholded Linear Unit
%
%   [func, der_func] = nl_tlu(alpha, offset)
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

func = @(x) (x > 0) .* (alpha * x + offset) + (x <= 0) * offset;

der_func = @(x) (x > 0) .* alpha;

end

