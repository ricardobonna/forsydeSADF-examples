# forsyde-sadf-examples

RISC processor and MPEG-4 decoder examples using ForSyDe-SADF.

## Note

This is a temporary repository for the case study for the paper

R. Bonna, D. S. Loubach, G. Ungureanu and I. Sander, _Modeling and Simulation of Dynamic Applications using Scenario-Aware Dataflow_

In the future these examples will be migrated and integrated to [`forsyde-shallow-examples`](https://github.com/forsyde/forsyde-shallow-examples).

## Installation

This project needs the [Haskell](https://www.haskell.org/) platform and the package manager [Stack](https://docs.haskellstack.org/en/stable/README/).

**Note:** install stack according to the [instructions on the web page](https://docs.haskellstack.org/en/stable/README/), i.e.

    curl -sSL https://get.haskellstack.org/ | sh

or

    wget -qO- https://get.haskellstack.org/ | sh

Update Stack the repository snapshots:

    stack upgrade
    stack update

Now you only need to install this project:

    cd path/to/forsyde-sadf-examples
    stack install

and wait until everything is properly installed.

## Usage

The source files can be found in the [`src/`](src) directory. To load them into a Haskell interpreter session where you can execute all the declared functions individually, type in

    stack ghci

To run the provided test suite defined in in [`test/Spec.hs`](test/Spec.hs) with example input values, type in

    stack test

These examples generate also a binary in the path printed at the end of the command `stack install`, e.g. on Ubuntu Linux `$HOME/.local/bin`. You can check its usage by executing the command

    ./forsyde-sadf-exe -h

