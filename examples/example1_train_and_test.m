%%% Train and test a classifier "by hand", i.e. without the
%%% crossvalidation and classification across time functions provided by
%%% MVPA-Light

% Before running the code, cd into the examples subfolder or add it to your
% path temporally
[dat, clabel] = load_example_data('epoched3');

%% Let's have a look at the data first: Calculate and plot ERP for attended and unattended deviants

% ERP for each condition
erp_attended = squeeze(mean(dat.trial(clabel == 1,:,:)));
erp_unattended = squeeze(mean(dat.trial(clabel == 2,:,:)));

% Plot ERP: attended deviants in red, unattended deviants in green. Each
% line is one EEG channel.
close
h1= plot(dat.time, erp_attended, 'r'); hold on
h2 =plot(dat.time, erp_unattended, 'b');
grid on
xlabel('Time [s]'),ylabel('EEG amplitude')
title('ERP')
legend([h1(1),h2(1)],{'Attended', 'Unattended'})

%% Train and test classifier

% Looking at the ERP the classes seem to be well-separated between in the
% interval 0.6-0.8 seconds. We will apply a classifier to this interval. First, 
% find the sample corresponding to this interval, and then average the
% activity across time within this interval. Then use the averaged activity
% for classification.
ival_idx = find(dat.time >= 0.6 & dat.time <= 0.8);

% Extract the mean activity in the interval as features
X = squeeze(mean(dat.trial(:,:,ival_idx),3));

% Get default hyperparameters
param = mv_get_classifier_param('lda');

% Train an LDA classifier
cf = train_lda(param, X, clabel);

% Test classifier on the same data: the function gives the predicted
% labels (predlabel) and the decision values (dval) which represent the
% distance to the hyperplane
[predlabel, dval] = test_lda(cf, X);

% To calculate classification accuracy, compare the predicted labels to
% the true labels and take the mean
fprintf('Classification accuracy: %2.2f\n', mean(predlabel==clabel))

% Calculate AUC
auc = mv_calculate_performance('auc', dval, clabel);

% Look at the distribution of the decision values. dvals should be positive
% for clabel 1 (attended deviant) and negative for clabel 2 (unattended
% deviant). dval = 0 is the decision boundary
figure
boxplot(dval, clabel)
hold on
plot(xlim, [0 0],'k--')
ylabel('Decision values')
xlabel('Class')
