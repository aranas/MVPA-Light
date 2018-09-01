% Classifier unit test
%
% Classifier: svm

rng(42)   %% do not change - might affect the results
tol = 10e-10;
mf = mfilename;

%% check classifier on multi-class spiral data: linear classifier should near chance, RBF kernel should be near 100%

% Create spiral data
N = 100;
nrevolutions = 1;       % how often each class spins around the zero point
nclasses = 2;
prop = 'equal';
scale = 0;
[X,clabel] = simulate_spiral_data(N, nrevolutions, nclasses, prop, scale, 0);

%%% LINEAR kernel: cross-validation
cfg                 = [];
cfg.classifier      = 'svm';
cfg.param           = [];
cfg.param.kernel    = 'linear';
cfg.param.c         = 10e2;
cfg.feedback        = 0;

acc_linear = mv_crossvalidate(cfg,X,clabel);

%%% RBF kernel: cross-validation
cfg.param.kernel    = 'rbf';
cfg.param.gamma     = 10e1;
acc_rbf = mv_crossvalidate(cfg,X,clabel);

% Since CV is a bit chance-dependent: tolerance of 2%
tol = 0.03;

% For linear kernel: close to chance?
print_unittest_result('classif spiral data (linear kernel)',1/nclasses, acc_linear, tol);

% For RBF kernel: close to 1
print_unittest_result('classif spiral data (RBF kernel)',1, acc_rbf, tol);

%% providing kernel matrix directly VS calculating it from scratch should give same result
gamma = 10e1;

% Get classifier params
param = mv_get_classifier_param('svm');
param.gamma  = gamma;
param.kernel = 'rbf';

% 1 -provide kernel matrix directly
K = rbf_kernel(struct('gamma',gamma),X);
param.kernel_matrix = K;
cf_kernel = train_svm(param, X, clabel);

% 2 - do not provide kernel matrix (it is calculated in train_kernel_fda)
param.kernel_matrix = [];
cf_nokernel = train_svm(param, X, clabel);

% Compare solutions - the discriminant
% axes can be in different order, so we look whether there's (nclasses-1)
% 1's in the cross-correlation matrix
C = abs(cf_kernel.alpha' * cf_nokernel.alpha); % cross-correlation since all axes have norm = 1
C = sort(C(:),'descend'); % find the largest correlation values
d = all(C(1:nclasses-1) - 1 < 10e-4);

% Are all returned values between 0 and 1?
print_unittest_result('providing kernel matrix vs calculating it from scratch should be equal',1, d, tol);


%% Check probabilities

% Get classifier params
param = mv_get_classifier_param('svm');
param.prob      = 1;
param.kernel    = 'rbf';

% Train SVM
cf = train_svm(param, X, clabel);

% Test SVM
[~, dval, prob] = test_svm(cf, X);

% Are all returned values between 0 and 1?
print_unittest_result('all probabilities in [0,1]',1, all(prob>=0 | prob<=1), tol);
