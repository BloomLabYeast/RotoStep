function RotoStep(seed, infile, basename, step_path, chromo_cmd, steps_per_output,output_num,max_steps,cond_num,is_this_continuation,current_step)
%%ROTOSTEP function adds condensin adds a condensin complex to an existing
%chromoShake simulation output file (AKA outfile). The
%chromoShake simulator adds thermal motion to polymer models, with the
%default polymer being DNA (persistence length 50 nm). RotoStep alters the
%condensin complexes' spring attachments in between chromoShake simulator
%runs. The default parameters of RotoStep were set so condensin complexes
%extrude loops when attached to slack subtrates and traslocates on taut
%substrates.

% Input
%    seed - the random number seed to set rng function in add_condensin.m
%
%    infile - the chromoShake configuration or outfile to which you want to
%    add condensin
%
%    basename - name of returned outfiles without file extension (i.e.
%    'linear_chain_one_condensin'
%
%    step_path - directory that contains all RotoStep code and chromoShake
%    files to be altered
%
%    chromo_cmd - A string calling chromoShake program with initial flag
%    tags (i.e. C:\\Users\\ayush\\Desktop\\chromoShake_1.2.0\\chromoShake.exe -CPU -openCL_dir C:\\Users\\ayush\\Desktop\\chromoShake_1.2.0\\openCL'.
%    The final '-save outfile_name steps_per_output output_num config_file'
%    of calling chromoShake is added in RotoStep
%
%    steps_per_output - number of calculations chromoShake performs before
%    outputting a set of coordinates. This prevent massive simulation
%    files. Typically set to 5000.
%
%    output_num - number of times chromoShake outputs coordinates before
%    quitting and calling for condensin to step.
%
%    max_steps - number of times condensin complexes step
%
%    cond_num - number of condensin molecules to add to simulations
%
%    is_this_continuation - 1 if this is a continuation of a simulation
%    already containing condensin. 0 if this is a new simulation from an
%    outfile without condensin
%
%   current_step - number of times condensin has stepped if file is
%
%Written by Ayush Doshi, Brandon Friedman, and Josh Lawrimore. August, 2017

%% Initial setup
cd(step_path); %Set initial path
if is_this_continuation == 0 %If this starting anew
    master_outfile = sprintf('%s.out',basename); %Create an the master .out file name
    add_condensin(seed, infile, master_outfile, cond_num); %Add condensins
    system(sprintf('%s -save %s %d %d -continue',...
        chromo_cmd, master_outfile,steps_per_output,output_num)); %Run first set of iterations
    system(sprintf('grep spring %s >> springs_%s.txt',...
        master_outfile, basename)); % Save the initial spring information
else % If this is continuing from another .out file
    master_outfile = infile;
end
%parse for time step variable
[~, step_str] = system(sprintf('grep time_step %s', master_outfile));
step_cell = strsplit(strtrim(step_str));
time_step = str2double(step_cell{2});
%% While loop
n = current_step+1; %Create a counter at the new step (1 if a new simulation)
input = master_outfile; % Set the first input file to be the master_outfile
while n <= max_steps %Run simulation to maximum step number
    if n < 10 % Create a number padding for the string
        str_pad = '000';
    elseif n < 100
        str_pad = '00';
    elseif n < 1000
        str_pad = '0';
    else
        str_pad = [];
    end
    condensin_step(input,sprintf('%s_temp.cfg',basename), time_step); %Create a new .cfg with new step information
    %% Alter the random_seed information
    [~,rand_seed_line] = system(...
        sprintf('grep random_number_seed %s_temp.cfg',basename));
    %trim off leading and lagging whitespace
    rand_seed_line = strtrim(rand_seed_line);
    %generate new random seed number based on n
    new_seed_line = sprintf('random_number_seed %d',n);
    %use sed to replace line
    %Windows 10 systems have a bug with GNUwin32 sed -i function
    %below is a workaround to prevent a large amount of sed* files
    system(sprintf('sed -e "s/%s/%s/" %s_temp.cfg > delme.txt', rand_seed_line, new_seed_line, basename));
    if ispc
        system(sprintf('del %s_temp.cfg', basename));
        system(sprintf('rename delme.txt %s_temp.cfg', basename));
    else
        system(sprintf('rm %s_temp.cfg', basename));
        system(sprintf('mv delme.txt %s_temp.cfg', basename));
    end
    %% Run chromoshake
    system(sprintf('%s -save %s_temp.out %d %d %s_temp.cfg',...
        chromo_cmd,basename,steps_per_output,output_num,basename)); %Run interations on temp.cfg
    %% Check for nans
    nan_command = sprintf('grep -i nan %s_temp.out | wc -l', basename);
    [~,nan_line] = system(nan_command);
    result_list = strsplit(nan_line);
    nan_num = str2double(result_list{end-1});
    disp(strcat('Number of NaNs:',num2str(nan_num)));
    if nan_num > 1
        %remove the offending simulation iteration
        system('rm %s_temp.out', basename);
        %alter the random seed by adding by 2
        new_seed_num = n + 2;
        new_seed_line = sprintf('random_number_seed %d',new_seed_num);
        %sed the new seed in the old .cfg file
        system(sprintf('sed -e "s/%s/%s/" %s_temp.cfg > delme.txt', rand_seed_line, new_seed_line, basename))
        if ispc
            system(sprintf('del %s_temp.cfg', basename));
            system(sprintf('rename delme.txt %s_temp.cfg', basename));
        else
            system(sprintf('rm %s_temp.cfg', basename));
            system(sprintf('mv delme.txt %s_temp.cfg', basename));
        end
        system(sprintf('%s -save %s_temp.out %d %d %s_temp.cfg',...
            chromo_cmd,basename,steps_per_output,output_num,basename)); %Run interations on temp.cfg
        %Repeat check, if still breaks kill function with retrun
        nan_command = sprintf('grep -i nan %s_temp.out | wc -l', basename);
        [~,nan_line] = system(nan_command);
        result_list = strsplit(nan_line);
        nan_num = str2double(result_list{end-1});
        if nan_num > 1
            return
        end
    end
    %% Convert timelines
    %calculate correct times
    %gather final timeline of simulation
    [~, timeline] = system(sprintf('grep "Time " %s | tail -n1', master_outfile));
    time_cell = strsplit(strtrim(timeline));
    final_time = str2double(time_cell{2});
    %get times from temp.out file
    [~, times] = system(sprintf('grep "Time " %s_temp.out', basename));
    times_cell = strsplit(times);
    select_times = times_cell(2:2:size(times_cell,2));
    for i = 1:size(select_times,2)
        output_time = final_time + str2double(select_times{i});
        output_time_str = sprintf('%g', output_time);
        %correct for matlab's single zero padding in %g
        if abs(floor(log10(output_time))) < 100
            output_time_str = strrep(output_time_str,'e-', 'e-0');
        end
        system(sprintf('sed -e "0,/Time %s/s//Time %s/" %s_temp.out > delme.txt',...
            select_times{i},output_time_str,basename));
        if ispc
            system(sprintf('del %s_temp.out', basename));
            system(sprintf('rename delme.txt %s_temp.out', basename));
        else
            system(sprintf('rm %s_temp.out', basename));
            system(sprintf('mv delme.txt %s_temp.out', basename));
        end
    end
    [~,output] = system(sprintf('grep -n -B2 -m2 "Time " %s_temp.out |tail -n3| head -n1 | cut -d"-" -f1',basename)); %Find the linenumber of the first timestep to isolate
    cut_off_point = str2double(output); %Convert the linenumber from string to double
    system(sprintf('sed "1,%dd" %s_temp.out >> %s',cut_off_point,basename,master_outfile)); %Remove the region before the beginning of the timesteps and added that to the end of master_outfile
    name_update = sprintf('%s_%s%d.out',basename,str_pad,n); %Create a new string that has the updated name (to easily track status)
    if ispc %change command based on platform
        system(sprintf('rename %s %s', master_outfile, name_update)); % Rename the master .out to the new, updated name
    else
        system(sprintf('mv %s %s', master_outfile, name_update)); % Rename the master .out to the new, updated name
    end
    master_outfile = name_update; %Set the new updated name to the master_outfile variable so it can be properly referenced
    input = sprintf('%s_temp.out',basename); %Set temp.out to input so that it can re-enter the cycle of creating a new .cfg and so on
    n = n+1; %Increase the counter
    system(sprintf('grep spring %s_temp.cfg >> springs_%s.txt',basename,basename)); %Output the new spring information in the temp.cfg file to the main springs file
end
fclose all;
end