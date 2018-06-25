function count_mat =  count_unique(idxs)
%This function takes a list of numbers and returns a matrix of those values
%in the first column and the number of times those values appear in the
%original vector in the second column
uniq_idxs = unique(idxs);
count_mat = zeros([length(uniq_idxs),2]);
for n = 1:length(uniq_idxs)
    count_mat(n,:) = [uniq_idxs(n), sum(idxs==uniq_idxs(n))];
end