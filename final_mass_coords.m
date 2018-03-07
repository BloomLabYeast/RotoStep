function [mass_coords] = final_mass_coords(infile,mass_coords) %If an outfile, accounts for updated final mass locations
num_masses = size(mass_coords,1); %Total number of masses
command = sprintf('grep "Time " %s -a%d | tail -%d',infile, num_masses, num_masses);%Isolate the final mass coordinates
[~,output] = system(command); %Run the command and store the output
if isempty(output) == 0
    b = strsplit(output); %Split the string into a cell array that contains numbers in string format
    vector = cellfun(@str2double,b); %Convert to a vector of doubles
    vector = vector(1:end-1); %Cleave off the last cell (contains NaN from left over white space)
    matrix = vec2mat(vector,3); %Organize to X,Y,Z format with 3 columns
    mass_xyz = flipud(matrix); % Flip the matrix due to coordinates being written backwards
    mass_coords(:,1:3) = mass_xyz; %Store the final coordinates into the original mass_coords variable
end
end