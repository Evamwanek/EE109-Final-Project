CXX      ?= g++
CXXFLAGS ?= -std=c++17 -Istubs

WEIGHTS_DIR  ?= /Users/sarakothari/Documents/stanford/junior/spring/EE109/EE109-Final-Project/weights
INPUT_SEQ    ?= /Users/sarakothari/Documents/stanford/junior/spring/EE109/EE109-Final-Project/input_seq.bin

.PHONY: test_cpp clean

test_cpp:
	$(CXX) $(CXXFLAGS) -o test_lstm test_lstm.cpp && ./test_lstm $(WEIGHTS_DIR) $(INPUT_SEQ); rm -f test_lstm

clean:
	rm -f test_lstm