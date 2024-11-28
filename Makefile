FC=gfortran
F2PY=f2py
ROOT_DIR=$(shell pwd)
HELM_TABLE=${ROOT_DIR}/helm_table.dat
F2PY_FLAGS=-L${ROOT_DIR} --lower -I ${ROOT_DIR} --f90flags="-fPIC"

all: module

module: libhelmholtz.a libeosfxt.a
	${F2PY} ${F2PY_FLAGS} -m fhelmholtz -c pycall.f90 helmholtz.o -lhelmholtz
	${F2PY} ${F2PY_FLAGS} -m ftimmes -c pycall_eosfxt.f90 eosfxt.o -leosfxt

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
