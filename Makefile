FC=gfortran
F2PY=f2py
ROOT_DIR=$(shell pwd)
HELM_TABLE=${ROOT_DIR}/helm_table.dat

all: module

module: helmholtz.o eosfxt.o
	${F2PY} --lower -m fhelmholtz -c pycall.f90 helmholtz.o -I ${ROOT_DIR}
	${F2PY} --lower -m ftimmes -c pycall_eosfxt.f90 eosfxt.o -I ${ROOT_DIR}

test: test.o helmholtz.o
	${FC} -o test.x test.o helmholtz.o
	./test.x

helmholtz.o: helmholtz.f90 const.dek implno.dek vector_eos.dek
	${FC} -cpp -DTBLPATH="'${HELM_TABLE}'" -ffree-line-length-none -c -fPIC $<

eosfxt.o: eosfxt.f90 const.dek implno.dek vector_eos.dek
	${FC} -c -fPIC $<

%.o : %.f90
	${FC} -c $<

clean:
	rm -f *.o *.so *.x
