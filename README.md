## Compile: 
在終端機輸入 make，用資料夾的 antlr-3.5.3-complete-no-st3.jar 編譯 myCompiler.g 以及 myCompiler_test.java。
myCompiler.g 為檢查規則。
myCompiler_test.java 為呼叫來檢查。

## Execute:
執行前得先確定有安裝 lli 跟 llc
在終端機輸入 make test1 測試 test1.c 產生 test1.ll 跟未被最佳化的組合語言 test1.s 以及產生執行檔 ./test1 後執行執行檔
在終端機輸入 make test2 測試 test2.c 產生 test2.ll 跟未被最佳化的組合語言 test2.s 以及產生執行檔 ./test2 後執行執行檔
在終端機輸入 make test3 測試 test3.c 產生 test3.ll 跟未被最佳化的組合語言 test3.s 以及產生執行檔 ./test3 後執行執行檔
若未需要執行下筆測資，可以 make clean 清除執行之前產生的檔案
若要重複執行同筆測資，請先 make clean 清除當前的執行檔，才能執行同樣的 target
例如：已經 make test1 一次，想再執行一次 make test1，得先執行 make clean 才能執行 make test1

## 清除 Execute 所產生的檔案:
在終端機輸入 make clean 清除執行產生的 myCheckerLexer.java, myCheckerParser.java, myChecker.tokens 及 class 檔

## 已完成功能:
為了能讓程式可以加入單行註解，有再加上可以單行註解也能順利產生 LLVM IR
所有的基本功能:
- Integer data types: int
- Statements for arithmetic computation. (e.g. a=b+2*(100-1);)
- Comparison expression. (e.g. a > b), comparison operation: >、>=、<、<=、==、!=
- if-then / if-then-else program constructs.
- printf() function with one/two parameters. (support types: %d)
## 擴充功能:
- Nested if construct
- printf() function with several parameters. (support types: %d)
本來有要完成浮點數運算跟輸出，但存浮點數值出現問題，似乎得再把浮點數轉成 IEEE 754 的 32 位元數字才能存好，
但時間關係沒有轉換出來，只能之後有時間再完成，
不過，浮點數相關判斷大致已完成，
也有在程式碼寫好判斷大小跟運算的部分，
只是不能存值，所以無法正確輸出。 

## 測資說明:
1. test1.c 有包含以下功能
- Integer data types: int
- Comparison expression. (e.g. score >= 80), comparison operation: >、>=、<、<=、==、!=
- if-then / if-then-else program constructs.
- printf() function with one/two parameters. (support types: %d)
bonus part:
- Nested if construct 

2. test2.c 有包含以下功能
- Integer data types: int
- Statements for arithmetic computation. (e.g. x + 2 * (100 - y);)
- Comparison expression. (e.g. z > 150), comparison operation: >、>=、<、<=、==、!=
- if-then / if-then-else program constructs.
- printf() function with one/two parameters. (support types: %d)

3. test3.c 有包含以下功能
- Integer data types: int
- Statements for arithmetic computation. (e.g. b = a + 2;)
bonus part:
- printf() function with several parameters. (support types: %d)
