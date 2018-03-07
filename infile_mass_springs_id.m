function [mass_coords, springs, hinges] = infile_mass_springs_id(infile)
fid_in = fopen(infile); %Opens the infile
tline = fgetl(fid_in); %Sets current line as a variable
m = 1; % used to assign mass coords
n = 1; % used to assign springs
p = 1; % used to assign hinges
while ischar(tline)
    % Find the mass coordinates
    if size(strfind(tline,'mass '),1) ~= 0
        % split the string into pieces to parse coordinates
        b = strsplit(tline);
        % save the initial coordinates in a cell array
        mass_coords(m,1) = str2double(b{5});
        mass_coords(m,2) = str2double(b{6});
        mass_coords(m,3) = str2double(b{7});
        % record the color of each of the beads
        if size(b,2) == 7
            % rows without an eighth entry correpond to a color of 1 (red)
            mass_coords(m,4) = 1;
        elseif size(b,2) == 8
            % rows with an eighth entry have their color logged appropriately
            mass_coords(m,4) = str2double(b{8});
        end
        mass_coords(m,5) = str2double(b{3}); % puts the mass number in the table
        mass_coords(m,6) = str2double(b{4}); % gather mass of mass
        % increase the counter by 1
        m = m+1;
    end
    if size(strfind(tline,'spring '),1) ~=0
        % Split the string into pieces to parse coordinates
        b = strsplit(tline);
        % Save the desired springs into a cell array
        springs(n,1) = str2double(b{3});
        springs(n,2) = str2double(b{4});
        springs(n,3) = str2double(b{6});
        % Increase the counter by 1
        n = n+1;
    end
    if size(strfind(tline,'hinge '),1) ~=0
        %Split the hinge information into pieces
        b = strsplit(tline);
        %Save the hinge into an array
        hinges(p,1) = str2double(b{3});
        hinges(p,2) = str2double(b{4});
        hinges(p,3) = str2double(b{5});
        %Increase the counter
        p = p+1;
    end
    tline = fgetl(fid_in);
    if size(strfind(tline,'}'),1) ~= 0
        break;
    end
end
fclose all;
end