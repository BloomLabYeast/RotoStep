function spring_mat = parse_springs(spring_file)
%%This function parses the spring file output by the RotoStep program and
%%returns a matrix of mass idxs over time to which the springs connect
%% Open the spring file
fid = fopen(spring_file);
%% Loop through the file and collect all spring data
tline = fgetl(fid);
time = 0;
m = 1;
while ischar(tline)
    if ~isempty(regexp(strtrim(tline), 'collision*', 'once'))
        time = time + 1;
        m = 1;
    elseif ~isempty(regexp(tline, 'spring \d* \d* *', 'once'))
        line_cell = strsplit(strtrim(tline));
        spring_mat(m,:, time) = [str2double(line_cell{2}),...
                             str2double(line_cell{3})];
        m = m +1;
    end
    tline = fgetl(fid);    
end
fclose(fid);