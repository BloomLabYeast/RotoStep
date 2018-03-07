# RotoStep

RotoStep is a MATLAB script that adds a condensin complex to an existing chromoShake configuration file or simulation output file (outfile). The chromoShake simulator adds thermal motion to polymer models, with the default polymer being DNA (persistence length 50 nm). RotoStep alters the condensin complexes' spring attachments in between chromoShake simulator runs. The default parameters of RotoStep were set so condensin complexes extrude loops when attached to slack subtrates and traslocates on taut substrates. RotoSteps algorithm was inspired by the experiments of Terekawa et al. published in Science in 2017 (DOI: 10.1126/science.aan6516).

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

### Installing

A step by step series of examples that tell you have to get a development env running

** *Install [MATLAB](https://www.mathworks.com/downloads/)
* Install chromoShake


End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone who's code was used
* Inspiration
* etc
