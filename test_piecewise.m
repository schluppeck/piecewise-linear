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

%% stats?

% split data into sections above and below knot point.

% lower segment / k is the third param...
low_idx = t < xEstimated(3)
low_seg_t = t(low_idx);
low_seg_y = yWithNoise(low_idx);

% could also check that there are more than 2 data points
high_idx = ~low_idx;

n_data_points_low = nnz(low_idx);
n_data_points_high = nnz(high_idx);

if n_data_points_low < 3 || n_data_points_high < 3
    warning('doing stats with that few data points does not work that well');
end

high_seg_t = t(high_idx);
high_seg_y = yWithNoise(high_idx);


figure()
plot(low_seg_t, low_seg_y, "ro",high_seg_t, high_seg_y, 'ko')



%% estimate slopes / and do stats on that.
% X = [ones(size(x1)) x1 x2 x1.*x2];
% b = regress(y,X)    % Removes NaN data

X_low = [linspace(-1,1,n_data_points_low)', ones(n_data_points_low,1) ]; % m, c
X_high = [linspace(-1,1,n_data_points_high)', ones(n_data_points_high,1)]; % m, c

% [b,bint,r,rint,stats]
[b_low, b_low_int, r_low, ~, stats_low] = regress(low_seg_y(:), X_low);
[b_high, b_high_int, r_high, ~, stats_high] = regress(high_seg_y(:), X_high);

% confidence intervals for BETA values
% check if b_low (the gradient is the first entry) overlaps
fprintf('the lower section has gradient: %.2f CI [%.2f, %.2f]\n', b_low(1), b_low_int(1,:));
fprintf('the upper section has gradient: %.2f CI [%.2f, %.2f]\n', b_high(1), b_high_int(1,:));

% plot on top of figure
hold on

% these two lines compute the best fit line
% and two lines that correspond to upper and lower limits of CI
low_fit = X_low * b_low;
low_int_fit = X_low * b_low_int; % the lower and upper CI values

high_fit = X_high * b_high;
high_int_fit = X_high * b_high_int; % the lower and upper CI values

% plot the CI versions
e_ = plot(low_seg_t, low_int_fit, 'r-', high_seg_t, high_int_fit, 'k-');

% and the estimated best fit, a bit thicker.
m_ = plot(low_seg_t, low_fit, 'r-', high_seg_t, high_fit, 'k-');
set(m_, 'linewidth',2)
hold off

title('piece wise linear fit with CI')


%% can also look at

figure()
plot(low_seg_t, low_seg_y, "ro",high_seg_t, high_seg_y, 'ko')

[ipt, res] = findchangepts(yWithNoise, 'statistic','linear', 'MaxNumChanges',1)

% R2... looks like the way to get this would be
% 1 - (residual error)/(variance of data) 
r2 = 1 - res./var(yWithNoise);
fprintf('---\n')
fprintf('KNOT according to findchangepts(): i=%i, t=%.2f\n', ipt, t(ipt))
fprintf('r2: %.3f\n', r2)
