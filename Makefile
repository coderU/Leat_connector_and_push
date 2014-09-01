DIR_SRC = ./source
DIR_BIN = ./bin/


COFFEE_SRC = $(wildcard ${DIR_SRC}/*.coffee)  
CC_SRC = $(wildcard ${DIR_SRC}/*.cc)  


all: coffee cc

coffee: $(COFFEE_SRC)
	coffee -o $(DIR_BIN) -c $(COFFEE_SRC)


cc: $(CC_SRC)
	g++ -o $(DIR_BIN)/connector $(CC_SRC) 

clean:
	rm ./bin/*
