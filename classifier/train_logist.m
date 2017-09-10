function cf = train_logist(X,clabel,param)
% Trains a logistic regression classifier. This is a wrapper for Lucas
% Parra's logist.m function.
%
% Usage:
% cf = train_logist(X,clabel,param)
% 
%Parameters:
% X              - [samples x features] matrix of training samples
% clabel         - [samples x 1] vector of class labels containing 
%                  1's (class 1) and 2's (class 2)
%
% param          - struct with hyperparameters (see logist.m for
%                  description)
% .v             - initialisation for normal to hyperplane plus threshold
%                  (last element of v). Can speed up convergence. If set to
%                  mean, the vector between the class means is taken as v
%                  and threshold is 0.
% .lambda        - regularisation parameter
% .eigvalratio   - cut-off ratio of highest-to-lowest eigenvalue
%
%Output:
% cf - struct specifying the classifier with the following fields:
% w            - projection vector (normal to the hyperplane)
% b            - bias term, setting the threshold 

if ischar(param.v) && strcmp(param.v,'mean')
    % Normal is initialised as the vector between the class means
    param.v= mean(X(clabel==1,:)) - mean(X(clabel==2,:));
    param.v = param.v(:)/norm(param.v);
    % Intercept is the projected grand mean projected onto v
    param.v(end+1) = 0.5*(mean(X(clabel==1,:)) + mean(X(clabel==2,:))) * param.v;
end

[v,~] = logist(X, clabel(:)==1, param.v, 0, param.lambda, param.eigvalratio);

cf= struct();
cf.classifier= 'Logistic Regression';
cf.w= v(1:end-1);
cf.b= v(end);