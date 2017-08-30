function varargout = mv_check_labels(labels)
%Checks binary class labels and returns the unique labels for class 1, class 2 , etc.
%
% Returns:
% l1        - first label
% l2        - second label
% labels    - fixed labels with 1's and -1's

% Check the labels
u=unique(labels);
if numel(u)~= 2
    error('there are %d different label types, should be only 2',numel(u))
end
if any(u==1)
    l1= 1;
    l2= u(u~=1);
else
    l1= u(1);
    l2= u(2);
end

varargout{1}= l1;
varargout{2}= l2;

if nargout > 2
%     warning('Labels should consist of -1 and 1''s, trying to fix')
    tmp = double(labels);
    varargout{3}(tmp==l1) = 1;
    varargout{3}(tmp==l2) = -1;
end
