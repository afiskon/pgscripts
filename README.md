# pgscripts

A few scripts related to PostgreSQL development. Originally based on [Stas
Kelvich's][stas] code.

* **quick-build.sh** - runs `configure` with some common flags, then runs `make`
  and `make check`. Code is compiled with -O0. $PGINSTALL is used as a --prefix.
* **clang-quick-build.sh** - same as quick-build.sh, but Clang is used instead of
  GCC.
* **full-build.sh** - same as quick-build.sh, but `make check-world` is executed
  intead of `make check`.
* **single-install.sh** - installs PostgreSQL to $PGINSTALL and runs it with custom
  postgresql.conf.
* **install.sh** - same as single-install.sh but configures streaming replication as
  well.
* **kill.sh** - terminates all processes related to PostgreSQL.
* **code-coverage.sh** - genereates a code coverage report.
* **static-analysis.sh** - runs Clang Static Analyzer.
* **valgrind.sh** - starts PostgreSQL under Valgrind.

Used environment variables:

* **$PGINSTALL** - where to install PostgreSQL.
* **$PATH** - don't forget to add $PGINSTALL/bin here.
* **$TMPDIR** - a directory for saving temporary files.

Typical usage:

```
./full-build.sh
./single-install.sh
make installcheck-world
```

**Note:** `make installcheck` or `make installcheck-world` don't pass if there
is a replication configured with master and replica on the same machine. This is
a known issue. Thus if you want to run `make installcheck` use
`./single-install.sh` instead of `./install.sh`.

[stas]: https://github.com/kelvich
