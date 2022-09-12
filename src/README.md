# CSCI 3366 Programming Languages

Bob Muller

The `bin/` directory contains OCaml code implementing an interpreter for the mini-PL called Mercury. This language has only integers and integer operators. But it does trap division by zero.

Compile and run:

```bash
> dune exec bin/main.exe
```

To clean up intermediate files:

```bash
> dune clean
```

To run the test system

```bash
> dune exec bin/main.exe test
```

To run a solved version of this problem set:

```bash
> ./solved
```

Type `ctrl-d` to exit the REPL.