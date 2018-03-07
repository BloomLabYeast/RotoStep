function add_condensin_ver3(seed,infile,outfile,num_condensin)
%set random number seed
rng(seed);
% this code adds N condensin molecules to the file.

% assign parameters
mass_mass = 3.38889e-020; % mass of a standard bead
mass_sep = 1e-008; % standard distances betweem masses
spring_rest = 1e-008; % spring distance at rest
spring_const = 0.226195; % standard spring constant
spring_damp = 10; % how much factor by which the gammma spring is weaker than the normal spring constant
time = 'test'; % this is used to find the last time step
colors = 'test'; % used to assign mass colors
time_init = 'test'; % used to delete previous time steps
condensin_mass_color = 2; % color of condensin beads
DNA_mass_color = [1 4]; % color of DNA beads
mass_condensin = []; % this is used to look for condensin beads
springs_condensin = []; % this is used to look for springs bound to condensin
mass_DNA_bound = []; % this is used to add condensins to files that already have condensin
mass_DNA_exclude = [0 0 0 0 0.5]; % this is used to exclude certain DNA beads from binding
cond_sep = 13; % how far apart (at minimum) you want the condensins to start from each other in terms of mass sep
theta_input = 10; % number of degrees the condensin will rotate when looking for a position


% open up the file
fid_in = fopen(infile);

% assign tline so that the lines can be looped through
tline = fgetl(fid_in);

m = 1; % used to assign mass coords
n = 1; % used to assign springs

% loop through all the lines to find the masses and appropriate springs
while ischar(tline)
    % find the mass coordinates
    if size(strfind(tline,'mass '),1) ~= 0
        % split the string into pieces to parse coordinates
        b = strsplit(tline);
        % save the initial coordinates in a cell array
        mass_coords_in(m,1) = str2double(b{5});
        mass_coords_in(m,2) = str2double(b{6});
        mass_coords_in(m,3) = str2double(b{7});
        % record the color of each of the beads
        if size(b,2) == 7
            % rows without an eighth entry correpond to a color of 1 (red)
            mass_coords_in(m,4) = 1;
        elseif size(b,2) == 8
            % rows with an eighth entry have their color logged appropriately
            mass_coords_in(m,4) = str2double(b{8});
        else
        end
        mass_last(1,1) = str2double(b{3}); % assigns the last mass value in the file
        mass_coords_in(m,5) = str2double(b{3}); % puts the mass number in the table
        % increase the counter by 1
        m = m+1;
    else
    end
    if size(strfind(tline,'spring '),1) ~= 0
        % split the string into pieces to parse coordinates
        b = strsplit(tline);
        
        % save the desired springs into a cell array
        springs(n,1) = str2double(b{3});
        springs(n,2) = str2double(b{4});
        
        % increase the counter by 1
        n = n+1;
    else
    end
    if size(strfind(tline,'Time '),1) ~= 0
        % assign the time line to the variable time, this will always pick the last one
        if strcmp(time,'test')==1
            time_init = tline;
        else
        end
        
        time = tline;
    else
    end
    if size(strfind(tline,'MassColors'),1) ~= 0
        % assign the color line to the variable colors
        colors = tline;
    else
    end
    % loop to the next line
    tline = fgetl(fid_in);
end

% close the file
fclose('all');

% this next part logs the colors of all the beads in order
if size(strfind(colors,'MassColors'),1) ~= 0
    % open up the file (again)
    fid_in = fopen(infile);
    % assign tline so that the lines can be looped through (starts it over)
    tline = fgetl(fid_in);
    while ischar(tline)
        % looks for the beginning of the last time step
        if strcmp(colors,tline) == 1
            % loop to the next line
            tline = fgetl(fid_in);
            % this assigns the coordinates (which are listed backwards for some reason)
            for d = 0:mass_last(1,1)
                % split the line into components
                % log all of the coordinates into a cell matrix
                mass_colors(mass_last(1,1)+1-d,1) = str2double(tline);
                % loop to the next line
                tline = fgetl(fid_in);
            end
        else
            % loop to the next line if it isn't the right one
            tline = fgetl(fid_in);
        end
    end
else
end

% close the file
fclose('all');

% if this is not the original file, it looks for the last time step
if size(strfind(time,'Time '),1) ~= 0
    % open up the file (again)
    fid_in = fopen(infile);
    % assign tline so that the lines can be looped through (starts it over)
    tline = fgetl(fid_in);
    % loop through all the lines
    while ischar(tline)
        % looks for the beginning of the last time step
        if strcmp(time,tline) == 1
            % loop to the next line
            tline = fgetl(fid_in);
            % this assigns the coordinates (which are listed backwards for some reason)
            for d = 0:mass_last(1,1)
                % split the line into components
                e = strsplit(tline);
                % log all of the coordinates into a cell matrix
                mass_coords(mass_last(1,1)+1-d,1) = str2double(e{1});
                mass_coords(mass_last(1,1)+1-d,2) = str2double(e{2});
                mass_coords(mass_last(1,1)+1-d,3) = str2double(e{3});
                mass_coords(mass_last(1,1)+1-d,4) = mass_colors(mass_last(1,1)+1-d,1);
                mass_coords(mass_last(1,1)+1-d,5) = mass_last(1,1)-d;
                % loop to the next line
                tline = fgetl(fid_in);
            end
        else
            % loop to the next line if it isn't the right one
            tline = fgetl(fid_in);
        end
    end
else
    % if this is the orginial document, then the coords were parsed earlier
    mass_coords = mass_coords_in;
end

% close the file
fclose('all');

% assign counters for the following section
m = 1; % used to assign DNA
n = 1; % used to assign condensin

% separate the condensin into a separate file
for z = 1:size(mass_coords)
    if max(mass_coords(z,4) == DNA_mass_color) == 1
        % assign everything with DNA colors to the DNA matrix
        mass_DNA(m,1:5) =  mass_coords(z,1:5);
        m = m+1;
    elseif max(mass_coords(z,4) == condensin_mass_color) == 1
        % assign everything with the condensin color to the condensin matrix
        mass_condensin(n,1:5) =  mass_coords(z,1:5);
        n = n+1;
    else
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
        else
        end
    end
else
end

m = 1; % reset counter to assign unbound DNA

% make a table of all unbound DNA

if size(springs_condensin,1)>0
    % if there is a condensin spring, select the DNA beads bound to condensin
    for z = 1:size(mass_DNA,1)
        % loop through all the DNA
        if max(mass_DNA(z,5) == springs_condensin(:,1)) == 1
            % if this mass is involved in any springs with condensin, log it
            mass_DNA_bound(m,1:5) = mass_DNA(z,1:5);
            m = m+1; % increase the counter by 1
        else
        end
    end
else
end

m = 1; % used to designate excluded DNA
s = 1; % used to designate unbound beads

% if you have condensin, prevent all adjacent beads from being bound to
if size(mass_DNA_bound,1)>0
    for z = 1:size(mass_DNA_bound,1)
        % make a binding box for the masses to be excluded
        binding_box_bind_x(z,1:2) = [mass_DNA_bound(z,1)-5*mass_sep mass_DNA_bound(z,1)+5*mass_sep];
        binding_box_bind_y(z,1:2) = [mass_DNA_bound(z,2)-5*mass_sep mass_DNA_bound(z,2)+5*mass_sep];
        binding_box_bind_z(z,1:2) = [mass_DNA_bound(z,3)-5*mass_sep mass_DNA_bound(z,3)+5*mass_sep];
        
        for n = 1:size(mass_DNA)
            if mass_DNA(n,1) >= binding_box_bind_x(z,1) && mass_DNA(n,1) <= binding_box_bind_x(z,2) &&...
                    mass_DNA(n,2) >= binding_box_bind_y(z,1) && mass_DNA(n,2) <= binding_box_bind_y(z,2) &&...
                    mass_DNA(n,3) >= binding_box_bind_z(z,1) && mass_DNA(n,3) <= binding_box_bind_z(z,2) &&...
                    max(mass_DNA(n,5) == mass_DNA_exclude(:,5)) == 0;
                % if the mass is in the box, log it the excluded table
                mass_DNA_exclude(m,1:5) = mass_DNA(n,1:5);
                m = m+1; % increase the counter by 1
            else
            end
        end
    end
    for z = 1:size(mass_DNA,1) % loop through the DNA
        if max(mass_DNA(z,5) == mass_DNA_exclude(:,5)) == 0 % if its not in the exclude table
            % log it in the unbound table
            mass_DNA_unb(s,1:5) = mass_DNA(z,1:5);
            s = s+1; % increase the counter by 1
        else
        end
    end
else
    % if there is no bound condensin, all the DNA is logged
    mass_DNA_unb = mass_DNA;
end

program_check = 1; % check for the entire program
random_placement_counter = 0; % ends the infinite loop if it trys for too long

% loop through this massive chunk of code until you get X condensin beads placed
while program_check == 1;
    condensin_count = 0; % number of currently active condensin
    
    bind_check = 1; % loops through the while loop until all designated beads are chosen
    
    while bind_check == 1
        
        rand_check = 1; % used to loop through assigning condesin start positions
        rand_dist = []; % create a matrix to be cleared
        
        % check to make sure they are not too close to each other
        if num_condensin > 1
            while rand_check == 1
                clearvars rand_dist;
                
                % pick a random DNA molecule to bind to for each condensin
                r = randi([1 size(mass_DNA_unb,1)],1,num_condensin);
                
                m = 1; % used to assign the initial binding beads
                
                for n = 1:(num_condensin-1)
                    for h = n+1:num_condensin
                        % test all of the distances and log them
                        rand_dist(m,1) = distance_between_3D_chromoshake(...
                            [mass_DNA_unb(r(n),1) mass_DNA_unb(r(h),1)],...
                            [mass_DNA_unb(r(n),2) mass_DNA_unb(r(h),2)],...
                            [mass_DNA_unb(r(n),3) mass_DNA_unb(r(h),3)]);
                        m = m+1; % increase the counter by 1
                    end
                end
                
                % end the loop if the positions are far enough apart
                if min(rand_dist)> cond_sep*mass_sep
                    rand_check = 0;
                else
                end
                
                random_placement_counter = random_placement_counter+1;
                
                if random_placement_counter == 30000
                    error('You are trying to place too many condensin');
                else
                end
            end
        else
            % pick a random DNA molecule to bind to for each condensin
            r = randi([1 size(mass_DNA_unb,1)],1,num_condensin);
        end
        
        for z = 1:num_condensin
            
            % get the coordinates of the bead that the condensin will bind to
            alpha_bind(z,:) = mass_DNA_unb(r(z),1:5);
            beta1_bind(z,1:2) = [0.5 0.5*mass_sep]; % set a base parameter for comparison in the next for loop
            beta2_bind(z,1:2) = [0.5 3*mass_sep]; % set a base parameter for comparison in the next for loop
            
            % create the region in which B will search for DNA to bind to
            binding_box_x(z,1:2) = [alpha_bind(z,1)-5*mass_sep alpha_bind(z,1)+5*mass_sep];
            binding_box_y(z,1:2) = [alpha_bind(z,2)-5*mass_sep alpha_bind(z,2)+5*mass_sep];
            binding_box_z(z,1:2) = [alpha_bind(z,3)-5*mass_sep alpha_bind(z,3)+5*mass_sep];
            
            s = 1; %used to assign bind test
            bind_test = []; % assign it so that when its cleared
            clearvars bind_test; % clears it for this itteration of the for loop
            
            for n = 1:size(mass_DNA_unb,1)
                if  mass_DNA_unb(n,1) >= binding_box_x(z,1) && mass_DNA_unb(n,1) <= binding_box_x(z,2) &&...
                        mass_DNA_unb(n,2) >= binding_box_y(z,1) && mass_DNA_unb(n,2) <= binding_box_y(z,2) &&...
                        mass_DNA_unb(n,3) >= binding_box_z(z,1) && mass_DNA_unb(n,3) <= binding_box_z(z,2)
                    % this looks for all DNA beads within the binding box range
                    
                    % the masses in range are then logged into a table
                    bind_test(s,1) = mass_DNA_unb(n,5);
                    
                    % increase the counter by 1
                    s = s+1;
                else
                end
            end
            
            if size(bind_test,2)>0
                for n = 1:size(bind_test,1)
                    % calculate the distance from B to this bead
                    [sep_dist] = distance_between_3D_chromoshake(...
                        [alpha_bind(z,1) mass_coords(bind_test(n,1)+1,1)],...
                        [alpha_bind(z,2) mass_coords(bind_test(n,1)+1,2)],...
                        [alpha_bind(z,3) mass_coords(bind_test(n,1)+1,3)]);
                    
                    % reassign it if it is greater than the threshold
                    if sep_dist > beta1_bind(z,2) && sep_dist > 0
                        beta1_bind(z,1:2) = [bind_test(n,1) sep_dist];
                    else
                    end
                end
                
                beta2_search(z,1:5) = mass_coords(beta1_bind(z,1)+1,1:5);
                
                % create the region in which B will search for DNA to bind to
                binding_box2_x(z,1:2) = [beta2_search(z,1)-2*mass_sep beta2_search(z,1)+2*mass_sep];
                binding_box2_y(z,1:2) = [beta2_search(z,2)-2*mass_sep beta2_search(z,2)+2*mass_sep];
                binding_box2_z(z,1:2) = [beta2_search(z,3)-2*mass_sep beta2_search(z,3)+2*mass_sep];
                
                s = 1; %used to assign bind test
                bind_test_b = []; % assign it so that when its cleared
                clearvars bind_test_b; % clears it for this itteration of the for loop
                
                for n = 1:size(mass_DNA_unb,1)
                    if  mass_DNA_unb(n,1) >= binding_box2_x(z,1) && mass_DNA_unb(n,1) <= binding_box2_x(z,2) &&...
                            mass_DNA_unb(n,2) >= binding_box2_y(z,1) && mass_DNA_unb(n,2) <= binding_box2_y(z,2) &&...
                            mass_DNA_unb(n,3) >= binding_box2_z(z,1) && mass_DNA_unb(n,3) <= binding_box2_z(z,2)
                        % this looks for all DNA beads (color = 1) within the binding box range
                        
                        % the masses in range are then logged into a table
                        bind_test_b(s,1) = mass_DNA_unb(n,5);
                        
                        % increase the counter by 1
                        s = s+1;
                    else
                    end
                end
                
                if size(bind_test_b,2)>0
                    for n = 1:size(bind_test_b,1)
                        % calculate the ditstance from B to this bead
                        [sep_dist] = distance_between_3D_chromoshake(...
                            [beta2_search(z,1) mass_coords(bind_test_b(n,1)+1,1)],...
                            [beta2_search(z,2) mass_coords(bind_test_b(n,1)+1,2)],...
                            [beta2_search(z,3) mass_coords(bind_test_b(n,1)+1,3)]);
                        
                        % reassign it if it is closer than the threshold and not the same bead
                        if sep_dist < beta2_bind(z,2) && sep_dist > 0
                            beta2_bind(z,1:2) = [bind_test_b(n,1) sep_dist];
                        else
                        end
                    end
                else
                end
            else
            end
        end
        
        if max(beta1_bind(:) == 0.5) == 0 && max(beta2_bind(:) == 0.5) == 0
            %  check to make sure all binding positions were assigned
            bind_check = 0; % ends the loop
        else
        end
        
    end
    
    % loop through all condensin
    for z = 1:num_condensin
        
        % find the vector between the binding sites of A and B1
        AB_vec = [mass_coords(beta1_bind(z,1)+1,1)-alpha_bind(z,1) ...
            mass_coords(beta1_bind(z,1)+1,2)-alpha_bind(z,2) ...
            mass_coords(beta1_bind(z,1)+1,3)-alpha_bind(z,3)];
        
        % find the magnitude of the AB vector
        AB_mag = norm(AB_vec);
        
        % create a unit vector
        unit_vec_AB = AB_vec/AB_mag;
        
        % use the cross product to create a perpendicular vector
        perp_vec = cross(AB_vec,[AB_vec(1) AB_vec(2) AB_vec(3)+1]);
        
        % create a unit vector
        unit_vec_perp = perp_vec/norm(perp_vec);
        
        % assign alpha, beta1, and beta2 coordinates
        condensin_coords(1,1:3,z) = alpha_bind(z,1:3) + (unit_vec_perp*1.5*mass_sep);
        condensin_coords(9,1:3,z) = condensin_coords(1,1:3,z) + AB_vec;
        condensin_coords(10,1:3,z) = condensin_coords(9,1:3,z) + unit_vec_AB*mass_sep;
        
        % use the pythagoran theorem to calculate the height of the condensin molecule
        cond_5_height = sqrt((4*mass_sep)^2-(AB_mag/2)^2);
        
        % assign bead 5 in the condensin molecule
        condensin_coords(5,1:3,z) = condensin_coords(1,1:3,z) + (unit_vec_perp*cond_5_height) + AB_vec/2;
        
        % assign coordinates for beads 2,3,4,6,7,and 8
        for h = 1:3
            condensin_coords(1+h,1:3,z) = condensin_coords(1,1:3,z) + (unit_vec_perp*(cond_5_height/4))*h + (AB_vec/8)*h;
            condensin_coords(9-h,1:3,z) = condensin_coords(1,1:3,z) + (unit_vec_perp*(cond_5_height/4))*h + AB_vec/2 + (AB_vec/8)*(4-h);
        end
        
        % assign coords for the klesin bead
        condensin_coords(11,1:3,z) = condensin_coords(1,1:3,z) + AB_vec/2 + (unit_vec_perp*cond_5_height/4);
        
        rotation_loop = 1; % sets up thw following while loop
        rotation_counter = 1; % counts the number of rotations
        
        % loop through until you find a configuration that fits
        while rotation_loop == 1 && rotation_counter < 360/theta_input
            % assign the position along the AB vector for beads 1-9
            for h = 1:9
                pos_AB(h,1:3) =  alpha_bind(z,1:3) + (AB_vec/8)*(h-1);
            end
            
            % assign the position along the AB vector for beads 10 and 11
            pos_AB(10,1:3) = pos_AB(9,1:3) + unit_vec_AB*mass_sep;
            pos_AB(11,1:3) = alpha_bind(z,1:3) + AB_vec/2;
            
            % create the vector that is to be rotated for each of the condensin beads
            for h = 1:11
                rot_vec(h,1:3) = condensin_coords(h,1:3,z) - pos_AB(h,1:3);
            end
            
            % assign a binding box to look for any beads that are too close together
            binding_box_r_x = [condensin_coords(11,1,z)-10*mass_sep condensin_coords(11,1,z)+10*mass_sep];
            binding_box_r_y = [condensin_coords(11,2,z)-10*mass_sep condensin_coords(11,2,z)+10*mass_sep];
            binding_box_r_z = [condensin_coords(11,3,z)-10*mass_sep condensin_coords(11,3,z)+10*mass_sep];
            
            % make this empty for a check later
            rot_check = [];
            
            s = 1; % used to assign the beads to the table
            
            % loop through the beads and place all of the beads within the binding box into a new table
            for h = 1:size(mass_coords,1)
                if mass_coords(h,1) >= binding_box_r_x(1) && mass_coords(h,1) <= binding_box_r_x(2)&&...
                        mass_coords(h,2) >= binding_box_r_y(1) && mass_coords(h,2) <= binding_box_r_y(2)&&...
                        mass_coords(h,3) >= binding_box_r_z(1) && mass_coords(h,3) <= binding_box_r_z(2)
                    
                    mass_rot_check(s,1:5) = mass_coords(h,1:5);
                    
                    s = s+1; % increase the counter by 1
                else
                end
            end
            
            % check the distance between the condensin beads and all other beads to make sure they are not too close
            for h = 1:11 % loop through condensin
                for j = 1:size(mass_rot_check,1) % loop through all other beads
                    [rot_check_dist] = distance_between_3D_chromoshake(...
                        [condensin_coords(h,1,z) mass_rot_check(j,1)],...
                        [condensin_coords(h,2,z) mass_rot_check(j,2)],...
                        [condensin_coords(h,3,z) mass_rot_check(j,3)]);
                    % check the distance, and assign a chech value if the beads are to close together
                    if rot_check_dist < mass_sep
                        rot_check(1,1) = 1; % tells it to rotate
                    else
                    end
                end
            end
            
            % if the beads are too close together, were going to rotate by 10 degrees
            if size(rot_check,1)>0
                
                % set theta to ten degrees
                theta = deg2rad(theta_input);
                
                % write out the rotation matrix to rotate around the AB vector
                rotation_matrix = ...
                    [cos(theta)+(unit_vec_AB(1)^2)*(1-cos(theta)),...
                    unit_vec_AB(1)*unit_vec_AB(2)*(1-cos(theta)) - unit_vec_AB(3)*sin(theta),...
                    unit_vec_AB(1)*unit_vec_AB(3)*(1-cos(theta)) + unit_vec_AB(2)*sin(theta);...
                    unit_vec_AB(2)*unit_vec_AB(1)*(1-cos(theta)) + unit_vec_AB(3)*sin(theta),...
                    cos(theta) + (unit_vec_AB(2)^2)*(1-cos(theta)),...
                    unit_vec_AB(2)*unit_vec_AB(3)*(1-cos(theta)) - unit_vec_AB(1)*sin(theta);...
                    unit_vec_AB(3)*unit_vec_AB(1)*(1-cos(theta)) - unit_vec_AB(2)*sin(theta),...
                    unit_vec_AB(3)*unit_vec_AB(2)*(1-cos(theta)) + unit_vec_AB(1)*sin(theta),...
                    cos(theta) + (unit_vec_AB(3)^2)*(1-cos(theta))];
                
                % find the new position vectors
                for h = 1:11
                    rot_vec_new(h,1:3) = (rotation_matrix*[rot_vec(h,1);rot_vec(h,2);rot_vec(h,3)])';
                    condensin_coords(h,1:3,z) = pos_AB(h,1:3) + rot_vec_new(h,1:3);
                end
                % count how many rotations are done
                rotation_counter = rotation_counter + 1;
            else
                % end this loop
                rotation_loop = 0;
            end
            
        end
        
        % if it added a condensin, count it
        if rotation_loop == 0
            condensin_count = condensin_count+1;
        else
        end
        
    end
    
    % if you added the correct number of condensin, end the loop
    if condensin_count == num_condensin
        program_check = 0;
    else
    end
    
end

% close all files just in case
fclose('all');
% open up the file (again)
fid_in = fopen(infile);
% assign the name of the new file that is to be created
fid_out = fopen(outfile,'w');
% assign tline so that the lines can be looped through (starts it over)
tline = fgetl(fid_in);
% this condition will add the condensin
while ischar(tline)==1
    if strcmp(tline,'}')==1
        % add the condensin masses and springs to the document
        for z = 1:num_condensin
            %  add all of the masses
            for a = 1:11
                fprintf(fid_out,'  mass %d\t%.6g\t%.6g %.6g %.6g %d\r\n',mass_last(1,1)+(11*(z-1))+a,mass_mass,condensin_coords(a,1,z),condensin_coords(a,2,z),condensin_coords(a,3,z),condensin_mass_color);
            end
            % add all of the basic springs
            for a = 1:9
                fprintf(fid_out,'  spring %d %d %.1g %.6g\r\n',mass_last(1,1)+(11*(z-1))+a,mass_last(1,1)+(11*(z-1))+a+1,spring_rest,spring_const);
            end
            
            % add the alpha spring
            fprintf(fid_out,'  spring %d %d %.1g %.6g\r\n',alpha_bind(z,5),mass_last(1,1)+(11*(z-1))+1,spring_rest,spring_const);
            
            % add the beta 1 spring
            fprintf(fid_out,'  spring %d %d %.1g %.6g\r\n',beta1_bind(z,1),mass_last(1,1)+(11*(z-1))+9,spring_rest,spring_const);
            
            % add the beta 2 spring
            fprintf(fid_out,'  spring %d %d %.1g %.6g\r\n',beta2_bind(z,1),mass_last(1,1)+(11*(z-1))+10,spring_rest,spring_const);
            
            % add the klesin springs
            fprintf(fid_out,'  spring %d %d %.1g %.6g\r\n',mass_last(1,1)+(11*(z-1))+2,mass_last(1,1)+(11*(z-1))+11,spring_rest,spring_const/spring_damp);
            fprintf(fid_out,'  spring %d %d %.1g %.6g\r\n',mass_last(1,1)+(11*(z-1))+8,mass_last(1,1)+(11*(z-1))+11,spring_rest,spring_const/spring_damp);
        end
        
        % ends the structure
        fprintf(fid_out,'}\r\n');
        % if you find the mass colors line
    elseif strcmp(tline,colors)==1
        % reprint it
        fprintf(fid_out,'%s\r\n',tline);
        for z = 1:num_condensin*11
            % print out the mass colors for the number of condensins added
            fprintf(fid_out,'%d\r\n',condensin_mass_color);
        end
        % if you find the mass colors line
    elseif strcmp(tline,time_init)==1
        while strcmp(tline,time)==0
            % loop to the next line
            tline = fgetl(fid_in);
        end
        % reprint the line
        fprintf(fid_out,'%s\r\n',tline);
        for z = 1:num_condensin % for all three condensin
            for n = 1:11 % for all 11 beads, per condensin
                % print the coords in reverse order
                fprintf(fid_out,'%d %d %d\r\n',condensin_coords(12-n,1,num_condensin+1-z),condensin_coords(12-n,2,num_condensin+1-z),condensin_coords(12-n,3,num_condensin+1-z));
            end
        end
    else
        % otherwise, it reprints the line
        fprintf(fid_out,'%s\r\n',tline);
    end
    
    % loop to the next line
    tline = fgetl(fid_in);
    
end

% close the files
fclose('all');