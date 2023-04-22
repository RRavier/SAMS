# SAMS
SAMS: Software for the Analysis and Mapping of Surfaces

This is a package containing software that allows for simultaneous matching of surfaces as well as a degree of statistical analysis. This package is suitable for aligned rigid, homeomorphic, simply connected surfaces like anatomical surfaces and not for other datasets of interests such as SCAPE, FAUST, or non-homeomorphic or non-simply connected data.

SAMS consists of three stages:

1. Surface data (OFF, OBJ, and/or PLY) is imported into the SAMS framework, and geometric features are computed.
2. The surfaces are consistently registered.
3. Consistent pseudolandmarks and/or segmentations are output for further analysis.

Though this suite is reasonably robust, it is still very much in beta. Users are encouraged to contact Robert Ravier at robert.ravier@duke.edu (please note that this email may change in the future; come to this webpage for further updates). Note that this code will be gradually cleaned up. Scripts not related to those referenced below should be considered unsupported.

## Prerequisites
SAMS is a MATLAB-based software suite that requires the following toolboxes on top of the base MATLAB install:
- Bioinformatics Toolbox
- Deep Learning Toolbox (note: despite needing this toolbox, SAMS contains no deep learning. This is just where certain functions are contained).
- Image Processing Toolbox
- Mapping Toolbox
- Optimization Toolbox
- Robust Control Toolbox
- Statistics and Machine Learning Toolbox
- Symbolic Math Toolbox

SAMS also requires [Mosek](https://www.mosek.com/), which is available at no cost to those who qualify for an academic license. To successfully use SAMS, Mosek must be installed and setup appropriately for MATLAB as given in the Mosek documentation.

Note: SAMS was developed and tested only on MATLAB release R2021a, with most development and testing done on Windows 10 and CentOS. It may work on other releases, but there is no guarantee that it will be successful. Users should feel free to contact the author as to issues running SAMS on other versions, though please be advised that troubleshooting ability will be limited for those not running R2021a.

## Instructions

1. Download SAMS into your desired directory
2. In the Setup subdirectory, please edit the MappingSetup.m folder as necessary. Users should only edit variables dataPath, projectDir, and numGPLmks unless other issues are experienced.
3. Run Execute01_RunPreparation.m from the SAMS base directory. This will also call the mosekdiag function, which verifies that Mosek is setup properly. Note that this script will also detail surfaces that cannot be processed further. If the output is unacceptable, please verify the quality of your surfaces in the folder, and see the FAQ below.
4. Run Execute02_RunMatching.m. This will select a template surface in your collection, and determine, for each other surface, a collection of pseudolandmarks in correspondence. These can be iteratively visualized by running visualizeLandmarkCorrespondences.m. When running this script, a window will pop up showing a subset of surfaces, the template, and their corresponding landmarks in multiple columns. Columns should not be compared. These surfaces can be rotated with the mouse. Press any key while in the console to continue iterating through the surfaces, or press Ctrl+C in the console to stop the script.
5. Run Execute02b_CreateFinalMappings.m. The methods in this script rely on slight modifications of the external packages [hyperbolic_orbifolds](https://github.com/noamaig/hyperbolic_orbifolds) and [AcceleratedQuadraticProxy](https://github.com/shaharkov/AcceleratedQuadraticProxy). Please report any issues to the author, though also note that limited support can be provided.
6. Users interested in obtaining a consistent set of pseudolandmarks for further analysis should run PrintPseudolandmarksSampleMean(workingPath, numGPLmks, numFPSLmks). The variable workingPath should be that given by the output of MappingSetup.m in the Setup subfolder. This script will output two sets of files to the PseudolandmarkFiles subdirectory in your given output directory, one CSV and one Morphologika. A total of numGPLmks+numFPSLmks will be output. The values to choose are likely dependent on the application at hand, though setting numGPLmks=200 and numFPSLmks=100 is a reasonable start in the author's opinion.
7. Users interested in consistent surface segmentation should edit the HecateSetup.m file in the Setup subdirectory before running Execute03a_RunHecate.m. Please note that this function may take a significant amount of time.

## FAQ

**I am having consistent issues running my data through SAMS. What's wrong?**

SAMS has very stringent requirements on data quality: all surfaces used must be aligned, and must either be topological disks, or topological spheres. SAMS will fail if the input data does not follow this assumption. To verify that this assumption is met, please make use of the scripts in [Auto3dgm_Python](https://github.com/ToothAndClaw/Auto3dgm_Python/). Meshes that are neither topological disks or topological spheres after running through this Auto3dgm_Python and its data cleaning script must be edited by hand.

**Okay, so I did the above, everything looks good, and I'm still having issues. What's wrong?**

If you have not installed MATLAB R2021a, we highly recommend you do so before proceeding. Assuming your Mosek installation is good, the issue might lie in either the hyperbolic_orbifolds or AcceleratedQuadraticProxy packages, specifically in terms of compiling MEX files. Please make sure those files are compiled and working on your system via the documentation in these packages. If this still fails, do not hesitate to contact me. ***Note that I might need data to assist in troubleshooting, and may be unable to assist if you are not willing to provide data.***

**I want a feature implemented that you don't have. Can you help?**

I'm happy to try! I work on this as a hobby, and my bandwidth is limited.

**MATLAB and Mosek are expensive. Is there any alternative?**

At this time, no, though there is (gradual) work on a freeware version.

**Can you explain what the file ________ does?**

The relevant information insofar as how SAMS works can be found in the papers listed below. Any other function that you see that is not referenced in the above can safely be assumed to be irrelevant.

## Citations

**If using this software for mapping, please cite the following works:**

Ravier, Robert J. *Algorithms with Applications to Anthropology.* Diss. Duke University, 2018.
Ravier, Robert J. "Eyes on the Prize: Improved Registration via Forward Propagation." *arXiv preprint arXiv:1812.10592 (2018).*

**If you use the mapping package for topological spheres, please cite:**

Aigerman, Noam, and Yaron Lipman. "Hyperbolic orbifold tutte embeddings." *ACM Transactions on Graphics (TOG)* 35.6 (2016): 217.

**For those using SAMS for topological disks, please cite:**

Kovalsky, Shahar Z., Meirav Galun, and Yaron Lipman. "Accelerated quadratic proxy for geometric optimization." ACM Transactions on Graphics (TOG) 35.4 (2016): 1-11.

**For those using SAMS for segmentation, please cite:**

Gao, Tingran. "The diffusion geometry of fibre bundles: Horizontal diffusion maps." Applied and Computational Harmonic Analysis 50 (2021): 147-215.

## License

The above is an amalgamation of the work of different individuals over the course of a decade, namely academics who wrote code and provided it publicly with no guarantees. Essentially, an MIT license.
