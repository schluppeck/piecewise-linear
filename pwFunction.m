function y = pwFunction(X, xdata)
% pwFunction - piecewise linear function
% 
% accepts parameters in the style needed to work with
% LSQCURVEFIT, which takes params in x as well as xdata ydata
% 
% here, parameter conventions are
%   x = [m1, m2, k, c1]
%
%  where m1 and m2 are the gradients of the two linear sections, k represents
%  the point at which the gradient changes, and c1 is the y-intercept.
%
% ie y = m1 * x + c1 for x < k and
%    y = m2 * x + c2 for x >= k, where c2 actually depends on 
%    the value of c1, m1, m2 and k. (c2 = c1 + m1 * k - m2 * k)

% unpack -- to make things explicit
m1 = X(1);
m2 = X(2);
k = X(3);
c1 = X(4);

idx = xdata < k; % and ~idx for the rest

% calculate y for the whole range and then replace the second segment
y = m1 * xdata + c1;

% overwrite second bit
y(~idx) = m2 * xdata(~idx) + c1 + k * (m1 - m2);

end