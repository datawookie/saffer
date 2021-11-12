R                  = R -q -s --vanilla
PKGDIR             = $(shell basename `pwd`)
PKGNAME            = $(shell sed -n 's/Package: *//p' DESCRIPTION 2> /dev/null)
PKGVERS            = $(shell sed -n 's/Version: *//p' DESCRIPTION 2> /dev/null)
TARGZ              = ${PKGNAME}_${VERSION}.tar.gz
BUILDARGS          = --no-build-vignettes
INSTALLARGS        = --install-tests

all: check clean

document:
	@${R} -e "devtools::document()"

# Build package data.
#
rda:
	Rscript scripts/history-create.R
	Rscript scripts/fuel-price-create.R
	Rscript scripts/fuel-price-basic-create.R

build: rda document
	@${R} -e "devtools::build()"

build-cran: build

install: rda document
	@${R} -e "devtools::install()"

check: build-cran
	@${R} -e "devtools::check()"

clean:
	rm -f *~
