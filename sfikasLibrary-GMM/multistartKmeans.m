function [centroids weights covariances] = multistartKmeans(X, K, spatialWeightFlag)
% multistartKmeans(X, K)
% Computes K centroids for data in X (each column is one datum), using
% the k-means algorithm. Uses multiple initializations to do k-means.
% Also a choice for covariance matrices is suggested.
%
% Important notes:
%       The kmeans function in MATLAB2006b assumes that input is
%       a matrix where each _row_ is one datum.
%
% Arguments:
% X             Data. Each data is one column. (dxN)
% K             Number of desired centroids. (scalar)
%
% centroids     Resulting centroids. Each centroid is one column. (dxK)
% weights       Percentages showing how many data 'belong' to each
%                   centroid.
% covariances   
%
% See also:
%       kmeans, deterministicKmeans
%
% G.Sfikas 24 Jul 2007.
%
if nargin < 3
    spatialWeightFlag = 'nospatialWeights';
end
[d N] = size(X);
[a2, m] = kmeans(X', K, 'maxiter',100, 'emptyaction','singleton', ...
    'start','sample', 'replicates',20);
m = m';
% Initialize covariance matrices & prior weights
covariances = zeros(d, d, K);
for i=1:K
    if length(find(a2==i)) < 2
        Z=randperm(N);
        Y=X(:,Z(1:10));
    else
        Y=X(:, find(a2==i));
    end
    w(i) = sum(a2 == i);
    covariances(:,:,i) = cov(Y');
end
w = w / sum(w);

% weights will first be set to the mixing proportions of the components
% (p_{j}^{i})
z = zeros(K, N);
for i = 1:K
    z(i, :) = (w(i)*ones(1, N)) .* computeProbability(X, m(:,i), covariances(:,:,i))';
end
z = z ./ (ones(K, 1) * (sum(z, 1)+eps));

centroids = m;
if strcmp(spatialWeightFlag, 'spatialWeights')
    weights = z;
else
    weights = inv(N)*sum(z, 2)';
end
return;



function res = computeProbability(X, m, covar)
% Compute probability of data in 'X', assuming it was generated by a
% gaussian with parameters 'm', 'covar'.
d = size(X, 1);
t1 = (2*pi)^(-0.5*d) * det(covar)^(-0.5);
t2 = exp(-0.5*mahalanobis(X, m, covar));
res = t1 * t2;
return;