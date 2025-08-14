# pgscripts

A few scripts related to PostgreSQL development. Originally based on [Stas
Kelvich's][stas] code.

Used environment variables:

* **$PGINSTALL** - where to install PostgreSQL.
* **$PATH** - don't forget to add $PGINSTALL/bin here.
* **$TMPDIR** - a directory for saving temporary files.

In order to install PostgreSQL dependencies run:

```
# for basic build
sudo apt install gcc make flex bison pkg-config libreadline-dev \
  zlib1g-dev libssl-dev libxml2-dev libxslt1-dev libipc-run-perl \
  meson ninja-build

# to build the documentation as well
sudo apt install docbook docbook-dsssl docbook-xsl libxml2-utils \
  openjade opensp xsltproc

# for code-coverage.sh
sudo apt install lcov
```

Typical usage:

```
git clone git://git.postgresql.org/git/postgresql.git
cd postgresql
git checkout master
# make sure the copy of the code is clean!
git clean -dfx
cd ..

git clone https://github.com/afiskon/pgscripts.git
cd pgscripts
./full-build.sh && ./single-install.sh && make installcheck-world
# or:
./quick-build.sh && ./single-install.sh && make installcheck
```

Building with Meson:

```
git clean -dfx
meson setup --buildtype debug \
  -DPG_TEST_EXTRA="kerberos ldap ssl" \
  -Dldap=disabled -Dssl=openssl \
  -Dcassert=true -Dtap_tests=enabled \
  -Dprefix=/home/eax/pginstall build
ninja -C build
ninja -C build docs
meson test -C build
../pgscripts/single-install-meson.sh
```

List of the scripts:

* **quick-build.sh** - runs `configure` with some common flags, then runs `make`
  and `make check`. Code is compiled with -O0. $PGINSTALL is used as a --prefix.
* **clang-quick-build.sh** - same as quick-build.sh, but Clang is used instead of
  GCC.
* **full-build.sh** - same as quick-build.sh, but `make check-world` is executed
  intead of `make check`.
* **single-install.sh** - installs PostgreSQL to $PGINSTALL and runs it with custom config
* **single-install-meson.sh** - same for Meson build system.
* **install.sh** - same as single-install.sh but configures streaming replication as
  well.
* **start.sh / stop.sh** - start/stop PostgreSQL using `pg_ctl`.
* **kill.sh** - terminates all processes related to PostgreSQL with `pkill`.
* **code-coverage.sh** - genereates a code coverage report (works only with GCC stack!).
* **static-analysis.sh** - runs Clang Static Analyzer.
* **valgrind.sh** - starts PostgreSQL under Valgrind.
* **valgrind-meson.sh** - same for Meson build system.

**Note:** `make installcheck` or `make installcheck-world` don't pass if there
is a replication configured with master and replica on the same machine. This is
a known issue. Thus if you want to run `make installcheck` use
`./single-install.sh` instead of `./install.sh`.

[stas]: https://github.com/kelvich
