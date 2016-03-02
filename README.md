# RLESUtils #

Author: Ritchie Lee (ritchie.lee@sv.cmu.edu)

RLESUtils is a collection of some useful tools.  See individual module descriptions for more information.

## General Usage ##

First call ``using RLESUtils`` to make all submodules available in the global scope.  Submodules are stored under ``RLESUtils/modules``.

Call ``RLESUtils.test(modulename)`` to test a specific submodule
Call ``Pkg.test("RLESUtils")`` to test all submodules.

## Special Considerations ##

The TikzQTrees module requires TikzPictures.jl.  During installation, Ubuntu users may encounter an error about "standalone.cls not found".  Try installing the "texlive-latex-extra" package.
