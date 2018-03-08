# RotoStep
[![RotoStep on Slack Substrate](https://img.youtube.com/vi/3FoQhGUd-E0/0.jpg)](https://www.youtube.com/watch?v=3FoQhGUd-E0)

RotoStep is a MATLAB script that adds a condensin complex to an existing chromoShake simulation output file (outfile). The chromoShake simulator adds thermal motion to polymer models, with the default polymer being DNA (persistence length 50 nm). RotoStep alters the condensin complexes' spring attachments in between chromoShake simulator runs. The default parameters of RotoStep were set so condensin complexes extrude loops when attached to slack subtrates and traslocates on taut substrates. RotoSteps algorithm was inspired by the experiments of Terekawa et al. published in Science in 2017 (DOI: 10.1126/science.aan6516). Our initial findings using RotoStep are published in Lawrimore et al in Cold Spring Harbor symposia on quantitative biology (DOI: doi: 10.1101/sqb.2017.82.033696)

## Getting Started

### Prerequisites

* [MATLAB](https://www.mathworks.com/downloads/)
  * Given enough interest we may port RotoStep code to Python.
* chromoShake
  * [Windows Installer](http://bloomlab.web.unc.edu/files/2016/01/chromoShake_1_2_0.zip)
  * [Source Code](http://bloomlab.web.unc.edu/files/2016/01/Source_code.zip)
  * Installation [guide and tutorial](http://www.molbiolcell.org/content/suppl/2015/11/02/mbc.E15-08-0575v1.DC1/Chromoshake_Supplemental_information_FINAL_updated_03232016.pdf) for chromoShake starts on page 8 of supplemental materials for Lawrimore et al. published in Molecular Biology of the Cell (DOI: 10.1091/mbc.E15-08-0575)
* grep
  * [grep for Windows](http://gnuwin32.sourceforge.net/packages/grep.htm). Download the complete package, except sources from the link. By default the installer puts grep.exe, egrep.exe, and fgrep.exe in C:\Program Files(x86)\GnuWin32\bin. Add this directory to your system path.
* sed
  * [sed for Windows](http://gnuwin32.sourceforge.net/packages/sed.htm). Download the complete package, except sources from the link. By default the installer puts sed.exe in C:\Program Files(x86)\GnuWin32\bin. Add this directory to your system path if you didn't already.

## Tutorial

### Test of external programs
RotoStep uses MATLAB's [system function](https://www.mathworks.com/help/matlab/ref/system.html) to run chromoShake, grep, sed and, depending on your system, either rename or mv. Test that each of these programs are added to your sytsem path and can be called by MATLAB.

```
system('grep')
system('sed')
system('chromoShake')
system('rename') %if pc
system('mv') %if unix/mac
```
Each of these should return a usage error. What you should NOT see is...

```
>> system('not_a_path_program')
'not_a_path_program' is not recognized as an internal or external command, 
operable program or batch file. 

ans =

     1
```
If you are throwing the above error, double check your system path and try again.

### Pinned linear chain tutorial
In the repo you will find an altered linear chain configuration file, 'pinned_chain.cfg'. This file is a 1-micron chain with one end pinned in space. The pinning was performed by hand editing  line 16 from
```mass 0	3.38889e-020	0 0 0``` to ``mass 0	3.38889e-015	0 0 0``
This alteration increases the drag force on the end bead by 100,000-fold, effectively pinning the bead in space.

Run chromoShake on the 'pinned_chain.cfg' file. Here is the code that runs on my Windows PC:
```
chromoShake -CPU -openCL_dir C:\Users\lawrimor\chromoShake\openCL -save pinned_chain.out 5000 10 pinned_chain.cfg
```
In this example we ran chromoShake using multiple CPUs (that are OpenCL compatible) rather than the default GPU. Please note that chromoShake is only compatible with certain GPUs such as an NVIDIA GeForce GTX 780, see chromoShake [guide](http://www.molbiolcell.org/content/suppl/2015/11/02/mbc.E15-08-0575v1.DC1/Chromoshake_Supplemental_information_FINAL_updated_03232016.pdf) starting on page 8. The chromoShake simulator needs to be pointed to the OpenCL directory that contains the OpenCL codes. If you used the Windows installer point it to pathTochromoShake\chromoShake\openCL . Note: I prefer to install chromoShake outside of the 'Program File(x86)' directory as I have to run cmd in administrator mode to edit files there. We saved the outfile as 'pinned_chain.out' and ran the simulator for 10 outputs of 5000 iterations of 2 nanoseconds (the calculation time is defined in the configuration file).

Once your chromoShake simulation has completed you can run RotoStep via MATLAB.
```
%Set your parameters here
seed = 1 %any integer

infile = 'pinned_chain.out' %add condensin to this file

basename = 'pinned_chain_c1' %future files will have this name

step_path = 'C:\Users\lawrimor\Documents\GitHub\RotoStep' %where RotoStep code is located

chromo_cmd = 'chromoShake -CPU -openCL_dir C:\Users\lawrimor\chromoShake\openCL %first part of chromoShake command to specify CPU usage and openCL_dir location

steps_per_output = 5000 %number of calculations per output

output_num = 10 %number of outputs between condensin steps

max_steps = 10 %number of times condensins will step

cond_num = 1 %nubmer of condensins added

is_this_continuation = 0 %does condensin already exist on output file

current_step = 1 %What step is condensins on

%Run RotoStep
RotoStep(seed, infile, basename, step_path, chromo_cmd, steps_per_output,output_num,max_steps,cond_num,is_this_continuation,current_step)
```
This code adds one condensin complex to the 'pinned_chain.out' file. The condensin complex is placed in a random location and orientation set by the seed variable. It runs chromoShake for 10 printouts of 5000 calculations (with a timescale of 2 nanoseconds which is defined in outifle). Then it runs the condensin_step function to cause condensin to step along the chain. It repeats this process 10 times before quitting. Since RotoStep overwrites the configuration portion of the outfiles as it updates, we parse the springs from the configuration porition of each outfile and print them to the file 'springs_\<basename\>.txt' for future analysis. Please note that this example simulation may take a one to two hours to complete depending on the speed and number of your CPUs.

## Visualizing chromoShake files
If you are running a Windows PC, the chromoShake installer comes with chromView.exe. This program allows you to view chromoShake output files. On Mac/Unix machines you can visualize the simulations using a Python code packed with the chromoShake  [Source Code](http://bloomlab.web.unc.edu/files/2016/01/Source_code.zip) in the Source_code\chromoShake\video directory. The python script converts chromoShake outfiles to Blender files when can then be rendered using the free and open source animation software [Blender](https://www.blender.org/). See chromoShake [guide](http://www.molbiolcell.org/content/suppl/2015/11/02/mbc.E15-08-0575v1.DC1/Chromoshake_Supplemental_information_FINAL_updated_03232016.pdf)) for details.

## Help Wanted
We are a small group of well-meaning biologists trying to gain intuition into chromosome organization. We are learning as we go. If you run into any unexpected errors or have suggestion please let us know using the [Issues](https://github.com/jlaw8504/RotoStep/issues) tab. If you wish to begin collaborating with us to improve either RotoStep or ChromoShake (GitHub repo coming soon) please email kerry_bloom[at]email[dot]unc. If you want to build your own code seperately, we wish you the best of luck. Please cite Lawrimore et al, 2017 (DOI: doi: 10.1101/sqb.2017.82.033696) if using RotoStep in a publication.

## Authors

* Ayush Doshi
* Brandon Friedman
* Josh Lawrimore
* Kerry Bloom

## License

This project is licensed under the GNU General Public License v3 - see the [LICENSE.md](https://github.com/jlaw8504/RotoStep/blob/master/LICENSE) file for details.

## Acknowledgments

* Joseph Aicher for chromoShake
* Russ Taylor for chromoShake
* Mike Falvo for chromoShake
* Leandra Vicci for chromoShake
* UNC's [CISMM](http://cismm.web.unc.edu/) for ongoing support

> Written with [StackEdit](https://stackedit.io/).
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTEzNzgxODc4XX0=
-->
