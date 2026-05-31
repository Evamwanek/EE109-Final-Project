CXX      ?= g++
CXXFLAGS ?= -std=c++17 -Istubs

.PHONY: test_cpp clean

test_cpp:
	$(CXX) $(CXXFLAGS) -o test_gemm test_gemm.cpp && ./test_gemm; rm -f test_gemm

clean:
	rm -f test_gemm
