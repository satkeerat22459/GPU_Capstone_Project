NVCC = nvcc

LDFLAGS = -lnppicc -lnppc -lnppig -lnppidei -lnppif
CFLAGS = -std=c++17 -O3

SRC = src/main.cu
OUT = batch_proc

all:
	$(NVCC) $(SRC) -o $(OUT) $(CFLAGS) $(LDFLAGS)

clean:
	rm -f $(OUT)