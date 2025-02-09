% trying out options for finding piecewise
% linear data and transition points... 
%
% ds 2025-02-09
%
%
% 1. generate some piecewise linear data
% 2. add some noise
% 3. try to find the transition point
% 4. try to fit the data with a piecewise linear function
% 5. plot the results
%
% ... if you rerun the function, results will jump around a bit because 
% of the noise which is generated randomly each time. if you want to make things    
% reproducible, you can set the random seed at the beginning of the script
%
% with real data, the noise might be quite different = you can play around with 
% noiseFactor to see how it affects the results

% generate some piecewise linear data
rng(42)

% time window data, 5s interval
t = 0:5:120; % in s

% knot point / gradients before and after
knotPoint = 45; % m1 = 2.0, m2 = 1.2
% say
xReal = [3.0, 1.5, knotPoint, 5.0];

yData = pwFunction(xReal, t);

% some noise
noiseFactor = 20; % 10? 20?
yNoise = noiseFactor * randn(size(yData));

yWithNoise = yData + yNoise;

figure() 
plot(t, yData, 'k','linewidth', 2)
hold on
plot(knotPoint, pwFunction(xReal, knotPoint), 'ko', 'markerfacecolor', 'k', 'linewidth', 2, 'markersize', 15)
plot(t, yWithNoise, 'ro', 'markerfacecolor', 'w', 'linewidth', 2)

% now, how to find the knot point and the gradients?
% ischange() in matlab ... 
% https://uk.mathworks.com/matlabcentral/answers/475306-how-to-perform-piece-wise-linear-regression-to-determine-break-point#answer_854945


kEstimated = ischange(yWithNoise, 'linear', 'SamplePoints', t)
% looks like it's too sensitive to noise w. default settings

% but can limit to N=1 changes

kEstimatedSolo = ischange(yWithNoise, 'linear', 'SamplePoints', t,'MaxNumChanges',1)
t(kEstimatedSolo)

t0 = t(kEstimatedSolo);
y0 = yWithNoise(kEstimatedSolo)
hold on
plot(t0, y0, 'bo', 'markerfacecolor', 'b', 'linewidth', 2, 'markersize', 15)

% but looks like it just finds large outliers...

% i used before
% lsqcurvefit() with a function that has two
%   linear pieces connected with a "knot"

k0 = median(t); % somwhere in the middle of t values as initial guess
x0 = [1,1,k0,0]; % initial guess for m1, m2, k, c1
xEstimated = lsqcurvefit(@pwFunction, x0, t, yWithNoise)

% now plot the function with the values we found!
yFit = pwFunction(xEstimated, t);
plot(t, yFit, 'm', 'linewidth', 4)
plot(xEstimated(3), pwFunction(xEstimated, xEstimated(3)), ...
    'mo', 'markerfacecolor', 'm', 'linewidth', 2, ...
    'markersize', 15)

titlestr = sprintf('Estimated knot point: %.2f [real: %.2f]', xEstimated(3), knotPoint);
title(titlestr)