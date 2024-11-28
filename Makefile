FC=gfortran
F2PY=f2py
ROOT_DIR=$(shell pwd)
HELM_TABLE=${ROOT_DIR}/helm_table.dat

# Determine the Python version
PYTHON := $(shell which python3 || which python)
PYTHON_VERSION := $(shell $(PYTHON) -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

# Set flags based on the Python version
ifeq ($(shell echo "$(PYTHON_VERSION) >= 3.9" | bc), 1)
  F2PY_FLAGS := --backend=meson -L${ROOT_DIR} --lower -I ${ROOT_DIR} --f90flags="-fPIC"
	LIB1 := -lhelmholtz
	LIB2 := -leosfxt
else
  F2PY_FLAGS := --fcompiler=${FC}
	I_FLAG := -I
endif

all: module

module: libhelmholtz.a libeosfxt.a
	${F2PY} ${F2PY_FLAGS} -m fhelmholtz -c pycall.f90 ${I_FLAG} helmholtz.o ${LIB1}
	${F2PY} ${F2PY_FLAGS} -m ftimmes -c pycall_eosfxt.f90 ${I_FLAG} eosfxt.o ${LIB2}

test: test.o helmholtz.o
	${FC} -o test.x test.o helmholtz.o
	./test.x

helmholtz.o: helmholtz.f90 const.dek implno.dek vector_eos.dek
	${FC} -cpp -DTBLPATH="'${HELM_TABLE}'" -ffree-line-length-none -c -fPIC $<

eosfxt.o: eosfxt.f90 const.dek implno.dek vector_eos.dek
	${FC} -c -fPIC $<

%.o : %.f90
	${FC} -c $<

lib%.a: %.o
	ln -s $< $@

clean:
	rm -f *.o *.so *.x lib*.a
