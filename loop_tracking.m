function loop_sizes = loop_tracking(spring_file)

%% Open Spring file
spring_mat = parse_springs(spring_file);
%% Find Condensin's
[anchor_idx, ~, beta_idx] = condensin_id(spring_mat);
%% Track Condensin loop formation
for n = 1:length(anchor_idx)
    for t = 1:size(spring_mat,3)
        %over time, find the binding partners of anchor_idx and beta_idx
        [a_row, a_col] = ind2sub(size(spring_mat(:,:,t)),...
            find(spring_mat(:,:,t) == anchor_idx(n)));
        [b_row, b_col] = ind2sub(size(spring_mat(:,:,t)),...
            find(spring_mat(:,:,t) == beta_idx(n)));
        %swap column indices to point at partner value for anchor beads
        %there are always two partners for the anchor bead
        %first column has the condensin bead to which it is bound
        %second column has the dna bead to which it is bound
        if a_col(2) == 1
            a_col(2) = 2;
        else
            a_col(2) = 1;
        end
        a_partners(n,t) = spring_mat(a_row(2), a_col(2), t);
        %         swap column indices to point at partner value for anchor beads
        if b_col(2) == 1
            b_col(2) = 2;
        else
            b_col(2) = 1;
        end
        b_partners(n,t) = spring_mat(b_row(2), b_col(2), t);
    end
end
loop_sizes = abs(a_partners - b_partners);
