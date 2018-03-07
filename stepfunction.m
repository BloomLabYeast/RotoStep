function stepfunction(mass_coords,springs,hinges,outfile,time_step)
%% Initial Parameters
mass_mass = 3.38889e-020; % mass of a standard bead
mass_sep = 1e-008; % standard distances betweem masses
spring_rest = 1e-008; % spring distance at rest
spring_const = 0.226195; % standard spring constant
hinge_const = 4.0715e-12;
condensin_mass_color = 2; % color of condensin beads
DNA_mass_color = [1 4]; % color of DNA beads
mass_condensin = []; % this is used to look for condensin beads
springs_condensin = []; % this is used to look for springs bound to condensin
thresh = 3; % disatnce threshold for the condensin beads
spring_weak = 1000; % how much weaker the new alpha spring is
bind_dist = 3; % "Radius" of the binding box in mass_sep's
%% Step Code

% assign counters for the following section
m = 1; % used to assign DNA
n = 1; % used to assign condensin

% separate the condensin into a separate file
for z = 1:size(mass_coords)
    if max(mass_coords(z,4) == DNA_mass_color) == 1
        % assign everything with DNA colors to the DNA matrix
        mass_DNA(m,:) =  mass_coords(z,:);
        m = m+1;
    elseif max(mass_coords(z,4) == condensin_mass_color) == 1
        % assign everything with the condensin color to the condensin matrix
        mass_condensin(n,:) =  mass_coords(z,:);
        n = n+1;
    end
end

m = 1; % used to assign condensin springs

% create a list of springs that contain condensin
if size(mass_condensin,1)>0 % make sure we have condensin
    for z = 1:size(springs,1)
        if max(springs(z,2) == mass_condensin(:,5)) == 1
            % if the spring contains a condensin bead, log it in a table
            springs_condensin(m,:) = springs(z,:);
            % increase the counter by 1
            m = m + 1;
        end
    end
end

m = 1; % reset counter to assign unbound DNA

% make a table of all unbound DNA
for z = 1:size(mass_DNA,1)
    % loop through all the DNA
    if max(mass_DNA(z,5) == springs_condensin(:,1)) == 0
        % if this mass is not involved in any springs with condensin, log it
        mass_DNA_unb(m,:) = mass_DNA(z,:);
        m = m+1; % increase the counter by 1
    end
end

for z = 1:size(mass_condensin,1)/11
    % lets find all the A, B1, and B2 beads
    condensin_A(z,:) = mass_condensin(1+(11*(z-1)),:);
    condensin_B1(z,:) = mass_condensin(9+(11*(z-1)),:);
    condensin_B2(z,:) = mass_condensin(10+(11*(z-1)),:);
end

% preassign this with 0.5 so that it can be checked later
DNA_alpha = zeros(size(condensin_A,1),6)+0.5;
DNA_alpha_old = zeros(size(condensin_A,1),6)+0.5;

% use the mass numbers of the A, B1, and B2 beads to find out what they are bound to
for z = 1:size(condensin_A,1) % loop through the condensins
    for n = 1:size(springs_condensin,1) % loop through the springs
        % log all the DNA beads bound to A
        if condensin_A(z,5) == springs_condensin(n,2) &&...
                max(springs_condensin(n,1) == mass_condensin(:,5))==0 &&...
                springs_condensin(n,3) == spring_const;
            DNA_alpha(z,:) = mass_coords(springs_condensin(n,1)+1,:);
        end
        if condensin_A(z,5) == springs_condensin(n,2) &&...
                max(springs_condensin(n,1) == mass_condensin(:,5))==0 &&...
                springs_condensin(n,3) < spring_const;
            DNA_alpha_old(z,:) = mass_coords(springs_condensin(n,1)+1,:);
        end
        % log all the DNA beads bound to B1
        if condensin_B1(z,5) == springs_condensin(n,2) && max(springs_condensin(n,1) == mass_condensin(:,5))==0
            DNA_beta1(z,:) = mass_coords(springs_condensin(n,1)+1,:);
        end
        % log all the DNA beads bound to B2
        if condensin_B2(z,5) == springs_condensin(n,2) && max(springs_condensin(n,1) == mass_condensin(:,5))==0
            DNA_beta2(z,:) = mass_coords(springs_condensin(n,1)+1,:);
        end
    end
end

s = 1; % used to track the springs being deleted
y = 1; % used to track the springs being created
q = 2; % used to track the bound beads

% assign a number that you know does not correspond to a bead for the check
bound_beads=size(mass_coords,1);

% now we're gonna loop through the condensin molecules and find out what lines need to be created/deleted
for z = 1:size(condensin_A,1)
    
    % calculate the distance between the beads adjacent to the two heads
    [sep_dist] = distance_between_3D_chromoshake(...
        [mass_coords(condensin_A(z,5)+2,1) mass_coords(condensin_B1(z,5),1)],...
        [mass_coords(condensin_A(z,5)+2,2) mass_coords(condensin_B1(z,5),2)],...
        [mass_coords(condensin_A(z,5)+2,3) mass_coords(condensin_B1(z,5),3)]);
    
    if DNA_alpha(z,5) ~= 0.5 && DNA_alpha_old(z,5) == 0.5 && sep_dist > thresh*mass_sep
        % case 1 corresponds to when the alpha spring is active and the condensin ends are far apart
        
        % this condition will make the alpha spring significantly weaker
        
        % log this spring to be deleted
        spring_delete(s,:) = [DNA_alpha(z,5) condensin_A(z,5) spring_const];
        s = s+1; % increase the counter by 1
        spring_create(y,:) = [DNA_alpha(z,5) condensin_A(z,5) spring_const/spring_weak];
        % increase the counters by 1
        y = y+1;
        q = q+1;
        
    elseif DNA_alpha(z,5) == 0.5 && DNA_alpha_old(z,5) ~= 0.5
        % case 2 corresponds to when there is only one weak alpha spring
        
        % this condition will attach the A end of condensin to the closest DNA bead
        
        m = 1; % counter for the beads that will be tested for distance
        clearvars alpha_bind_test % clear this variable
        alpha_bind_test = []; % sets the table for a size check
        
        % create a binding box for the DNA
        binding_box_x(z,1:2) = [condensin_A(z,1)-bind_dist*mass_sep condensin_A(z,1)+bind_dist*mass_sep];
        binding_box_y(z,1:2) = [condensin_A(z,2)-bind_dist*mass_sep condensin_A(z,2)+bind_dist*mass_sep];
        binding_box_z(z,1:2) = [condensin_A(z,3)-bind_dist*mass_sep condensin_A(z,3)+bind_dist*mass_sep];
        
        for n = 1:size(mass_DNA_unb) % loop through all the DNA beads
            if mass_DNA_unb(n,1) > binding_box_x(z,1) && mass_DNA_unb(n,1) < binding_box_x(z,2) &&...
                    mass_DNA_unb(n,2) > binding_box_y(z,1) && mass_DNA_unb(n,2) < binding_box_y(z,2) &&...
                    mass_DNA_unb(n,3) > binding_box_z(z,1) && mass_DNA_unb(n,3) < binding_box_z(z,2) &&...
                    max(mass_DNA_unb(n,5) == bound_beads(:))==0
                
                % log the close beads to be tested
                alpha_bind_test(m,:) = mass_DNA_unb(n,:);
                
                % increase the counter by 1
                m = m+1;
            end
        end
        
        alpha_bind = [0.5 bind_dist*mass_sep]; % set a base parameter for comparison in the next for loop
        
        if size(alpha_bind_test,2)>0
            for n = 1:size(alpha_bind_test,1)
                % calculate the ditstance from A to this bead
                [sep_dist] = distance_between_3D_chromoshake(...
                    [alpha_bind_test(n,1) condensin_A(z,1)],...
                    [alpha_bind_test(n,2) condensin_A(z,2)],...
                    [alpha_bind_test(n,3) condensin_A(z,3)]);
                
                % reassign it if it is closer than the threshold
                if sep_dist <= alpha_bind(2)
                    alpha_bind = [alpha_bind_test(n,5) sep_dist];
                end
            end
            
            if alpha_bind(1) ~= 0.5
                spring_delete(s,:) = [DNA_alpha_old(z,5) condensin_A(z,5) spring_const/spring_weak];
                s = s+1; % increase the counter by 1
                % create this new spring
                spring_create(y,:) = [alpha_bind(1) condensin_A(z,5) spring_const];
                % add this bead to the bound_beads table
                bound_beads(q,1) = alpha_bind(1);
                % increase the counters by 1
                y = y+1;
                q = q+1;
            end
        end
        
    elseif DNA_alpha(z,5) ~= 0.5 && DNA_alpha_old(z,5) == 0.5 && sep_dist <= thresh*mass_sep
        % case 3 corresponds to when the alpha spring is active and the condensin ends are close together
        
        % calculate the distance between the beads bound to A and B1
        [sep_dist_AB1] = distance_between_3D_chromoshake(...
            [DNA_alpha(z,1) DNA_beta1(z,1)],...
            [DNA_alpha(z,2) DNA_beta1(z,2)],...
            [DNA_alpha(z,3) DNA_beta1(z,3)]);
        
        % calculate the distance between the beads bound to A and B2
        [sep_dist_AB2] = distance_between_3D_chromoshake(...
            [DNA_alpha(z,1) DNA_beta2(z,1)],...
            [DNA_alpha(z,2) DNA_beta2(z,2)],...
            [DNA_alpha(z,3) DNA_beta2(z,3)]);
        
        % assign the B1 and B2 heads based on proximity to A
        if sep_dist_AB1 < sep_dist_AB2
            DNA_beta_close(z,:) = DNA_beta1(z,:);
            DNA_beta_far(z,:) = DNA_beta2(z,:);
            condensin_B_close(z,:) = condensin_B1(z,:);
        else
            DNA_beta_close(z,:) = DNA_beta2(z,:);
            DNA_beta_far(z,:) = DNA_beta1(z,:);
            condensin_B_close(z,:) = condensin_B2(z,:);
        end
        
        % find the vector between the two DNA beads that the B heads are bound to
        vect(z,1:3) = DNA_beta_far(z,1:3) - DNA_beta_close(z,1:3);
        
        % add the vector to the far bead to get a point around which to build the binding box
        test_spot(z,1:3) = DNA_beta_far(z,1:3) + vect(z,1:3);
        
        % create the region in which B will search for DNA to bind to
        binding_box_x(z,1:2) = [test_spot(z,1)-bind_dist*mass_sep test_spot(z,1)+bind_dist*mass_sep];
        binding_box_y(z,1:2) = [test_spot(z,2)-bind_dist*mass_sep test_spot(z,2)+bind_dist*mass_sep];
        binding_box_z(z,1:2) = [test_spot(z,3)-bind_dist*mass_sep test_spot(z,3)+bind_dist*mass_sep];
        
        m = 1; % counter for the beads that will be tested for distance
        clearvars beta_bind_test % clear this variable
        beta_bind_test = []; % sets the table for a size check
        
        % find the beads in the binding box
        for n = 1:size(mass_DNA_unb) % loop through all the DNA beads
            if mass_DNA_unb(n,1) > binding_box_x(z,1) && mass_DNA_unb(n,1) < binding_box_x(z,2) &&...
                    mass_DNA_unb(n,2) > binding_box_y(z,1) && mass_DNA_unb(n,2) < binding_box_y(z,2) &&...
                    mass_DNA_unb(n,3) > binding_box_z(z,1) && mass_DNA_unb(n,3) < binding_box_z(z,2) &&...
                    max(mass_DNA_unb(n,5) == bound_beads(:))==0
                
                % log the close beads to be tested
                beta_bind_test(m,:) = mass_DNA_unb(n,:);
                
                % increase the counter by 1
                m = m+1;
            end
        end
        
        beta_bind = [0.5 bind_dist*mass_sep]; % set a base parameter for comparison in the next for loop
        
        if size(beta_bind_test,2)>0
            for n = 1:size(beta_bind_test,1)
                % calculate the ditstance from B to this bead
                [sep_dist] = distance_between_3D_chromoshake(...
                    [test_spot(z,1) beta_bind_test(n,1)],...
                    [test_spot(z,2) beta_bind_test(n,2)],...
                    [test_spot(z,3) beta_bind_test(n,3)]);
                
                % reassign it if it is closer than the threshold
                if sep_dist <= beta_bind(2)
                    beta_bind = [beta_bind_test(n,5) sep_dist];
                end
            end
            
            % make sure a new distance was assigned
            if beta_bind(1) ~= 0.5
                % create this new spring
                spring_create(y,:) = [beta_bind(1) condensin_B_close(z,5) spring_const];
                % add this bead to the bound_beads table
                bound_beads(q,1) = beta_bind(1);
                % delete this spring
                spring_delete(s,:) = [DNA_beta_close(z,5) condensin_B_close(z,5) spring_const];
                % increase these counters by 1
                y = y+1;
                s = s+1;
                q = q+1;
            else
            end
            
        else
        end
        
    else
    end
end

springs(find(ismember(springs,spring_delete,'rows')),:) = []; % Delete the springs that need to be removed
springs = [springs;spring_create]; %Add the springs that need to be made

%% Print out output
fid = fopen(outfile, 'w');
string = sprintf('meta collision_scheme 1\nmeta temperature_Celsius 25\nmeta viscosity_centiPoise 1\nmeta effective_damping_radius 8e-09\nmeta dna_modulus_gigaPascal 2\nmeta dna_radius_nanometers 0.6\nmeta damping_radius_factor 0.8\nstructure {\n  random_force 2.78554e-11\n  mass_damping 4.44973e+09\n  mass_radius 4.5e-09\n  time_step %e\n  collision_spring_constant 0.0565487\n  spring_damping_factor 0\n  random_number_seed 42\n  color 1\n', time_step);
fprintf(fid, string); %Print out main information

for x = 1:size(mass_coords,1) %Print out masses
    fprintf(fid,'  mass %d\t %.6g\t %.6g %.6g %.6g %d\n',...
            mass_coords(x,5),mass_coords(x,6),mass_coords(x,1),mass_coords(x,2),mass_coords(x,3),mass_coords(x,4));
end
for x = 1:size(springs,1) %Pring out springs
    fprintf(fid,'  spring %d %d %.1g %.6g\n',springs(x,1),springs(x,2),...
            spring_rest, springs(x,3));
end
for x = 1:size(hinges,1)%Print out hinges
    fprintf(fid,'  hinge %d %d %d %.5g\n',hinges(x,1),hinges(x,2),...
                hinges(x,3),hinge_const);
end
fprintf(fid,'}\n'); %Print out closing bracket
% close the files
fclose('all');