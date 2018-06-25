function [anchor_idx, alpha_idx, beta_idx] = condensin_id(spring_mat)
%%This function parses the spring file output by the RotoStep program to
%%identify the condensin complexs' anchor beads.
%% Use diff to detect spring rows with changing values
diff_mat = diff(spring_mat,1,3);
%% Construct a list of the mass idxs that springs change to
%pre-allocat binary matrix
bin_mat = zeros(size(diff_mat));
for n = 1:size(diff_mat,3)
    bin_mat(:,:,n) = diff_mat(:,:,n) ~= 0;
end
%apply the bin_mat to the spring_mat to get a list of mass idxs
%this list will contain both DNA masses and condensin masses
spring_mat_trim = spring_mat(:,:,2:end);
idxs = spring_mat_trim(boolean(bin_mat));
count_mat = count_unique(idxs);
%use thresholding to determine most promiscious masses
thresh = multithresh(count_mat(:,2));
thresh_array = count_mat(:,2) > thresh;
freq_idxs = count_mat(thresh_array,1);
%% Check if freq_idx masses have common permanent binding partner
for i = 1:length(freq_idxs)
    idx_mat = find(spring_mat == freq_idxs(i));
    [row, col, page] = ind2sub(size(spring_mat),idx_mat);
    for n = 1:length(page)
        if col(n) == 1
            col(n) = 2;
        else
            col(n) = 1;
        end
        partners(n) = spring_mat(row(n), col(n), page(n));
    end
    part_count_mat = count_unique(partners);
    %find counts that are equal to third dimension of spring_mat, which means
    %that they are always bound to that bead.
    [part_row, ~] = ind2sub(size(part_count_mat), find(part_count_mat == size(spring_mat,3)));
    perm_partners(:,i) = part_count_mat(part_row, 1);
end
%if the frequent masses are in the permanent partners that is an alpha beta
%pair
for i = 1:length(freq_idxs)
    mass_idx = freq_idxs(i);
    %find to which mass this permiscuous mass is permanently partnered
    [~, perm_pair_cols] = ind2sub(size(perm_partners),...
        find(perm_partners == freq_idxs(i)));
    %due to lazy indexing, repeat values can exist, so use unique to get
    %rid of them
    uniq_cols = unique(perm_pair_cols);
    pair(i,:) = [freq_idxs(i), freq_idxs(uniq_cols)];
end
uniq_pairs = unique(sort(pair,2),'rows');
alpha_idx = uniq_pairs(:,1);
beta_idx = uniq_pairs(:,2);
anchor_idx = beta_idx - 9;
    