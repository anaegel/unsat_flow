# Flow and Transport in unsaturated media

**UG4-App** implementing an unsaturated density driven flow equation system.

Authors: Niklas Conen, Arne Nägel

https://github.com/Nordegraf/unsat_flow

## Documentation
The equations used are: 

$\partial_t (\Phi \rho_w S_w) + \nabla \cdot [\rho_w \vec{v}_w] = \rho_w \Gamma_w$

$\partial_t (\Phi \rho_w S_w \omega) + \nabla \cdot [\rho_w \omega \vec{v}_w - \rho_w D \nabla \omega] = \rho_w \omega \Gamma_w$



## Possible arguments
* --problem-id specifies the problems config file, standard: "trench2D"
* --numPreRefs specifies the number of refinements before distribution
* --numRefs specifies the number of refinements after distribution
* --check checks if a problem file has the correct layout
* -o: outfile name prefix, standard: problem ID

## Examples

Usage:

ugshell -ex unsat_flow_app/unsat_flow_driver.lua --problem-id "example" --check

## Dependencies
This app depends on the following UG4 plugins: ConvectionDiffusion, LIMEX, Richards.

## References
[1] Eckhard Schneid: Hybrid-Gemischte Finite-Elemente-Diskretisierung der Richards-Gleichung, Dissertation, FAU Erlangen, 2000

[2] K. Johannsen: Numerische Aspekte dichtegetriebener Strömung in porösen Medien, Habilitationsschrift, Universität Heidelberg, 2004

[3] P. Frolkovic: Application of level set method for groundwater flow with moving boundary. Advances in Water Resources 47 (2012) 56–66

[4] N. Conen: Hydrochemische Modellierung des Stickstoffeintrags durch landwirtschaftliche Nutzflächen in Regionen mit Trinkwasserbrunnen. B.Sc. thesis, Universtität Frankfurt, 2022.
