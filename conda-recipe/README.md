# AGILE-GRID-ScienceTools-recipe

## Building the conda package
Install *conda-build*:
```
conda install conda-build
conda update conda-build
```
Download this repo:
```bash
git clone https://github.com/AGILESCIENCE/AGILE-GRID-ScienceTools-Setup.git
cd conda-recipe
```


Call the utility script to start the build:
*build_number*.
```bash
bash start_build.sh BUILD26
```

## Uploading the package
Login to anaconda cloud:
```bash
anaconda login
```
Upload the package with:
```bash
anaconda upload <path-to-package>
```
The *<path-to-package>* is written on the console at the end of the *conda-build* command.

## Troubleshooting

### The command *anaconda login* is not found
Be sure to use the *anaconda Command line client*.
```bash
anaconda --version
anaconda Command line client (version 1.7.2)
```
and not
```bash
anaconda --version
anaconda 21.48.22.156-1
```

### Packages not found
Add the conda-forge channel.
```bash
conda config --add channels conda-forge
```
