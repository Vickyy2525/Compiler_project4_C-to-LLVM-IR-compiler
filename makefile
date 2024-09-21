all:
	java -cp ./antlr-3.5.3-complete-no-st3.jar org.antlr.Tool myCompiler.g
	javac -cp ./antlr-3.5.3-complete-no-st3.jar:. myCompiler_test.java

test1:
	make clean
	make 
	java -cp ./antlr-3.5.3-complete-no-st3.jar:. myCompiler_test test1.c > test1.ll
	lli test1.ll
	llc -O0 test1.ll
	clang test1.s -o test1
	./test1

test2:
	make clean
	make 
	java -cp ./antlr-3.5.3-complete-no-st3.jar:. myCompiler_test test2.c > test2.ll
	lli test2.ll
	llc -O0 test2.ll
	clang test2.s -o test2
	./test2

test3:
	make clean
	make 
	java -cp ./antlr-3.5.3-complete-no-st3.jar:. myCompiler_test test3.c > test3.ll
	lli test3.ll
	llc -O0 test3.ll
	clang test3.s -o test3
	./test3
clean:
	rm -f myCompilerLexer.java myCompilerParser.java myCompiler.tokens *.class ./test1 ./test2 ./test3