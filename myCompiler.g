grammar myCompiler;

options {
   language = Java;
}

@header { // import packages here.
   import java.util.HashMap;
   import java.util.ArrayList;
}

@members {
   boolean TRACEON = false;

   // Type information.
   public enum Type{ 
      ERR, BOOL, INT, FLOAT, CHAR, CONST_INT, CONST_FLOAT, STRING;
   }

   // This structure is used to record the information of a variable or a constant.
   class tVar {
      int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
      int   iValue;   // value of constant integer. Ex: 123.
      float fValue;   // value of constant floating point. Ex: 2.314.
      String sValue;
   };

   class Info {
      Type theType;  // type information.
      tVar theVar;
   
      Info() {
         theType = Type.ERR;
         theVar = new tVar();
      }
   };

   class printParameter {
      int varcrec;
      String para;

      printParameter() {
         varcrec = 0;
         para = new String(); 
      }
   };
   // ============================================
   // Create a symbol table.
   // ArrayList is easy to extend to add more info. into symbol table.
   //
   // The structure of symbol table:
   // <variable ID, [Type, [varIndex or iValue, or fValue, or sValue]]>
   //    - type: the variable type   (please check "enum Type")
   //    - varIndex: the variable's index, ex: t1, t2, ...
   //    - iValue: value of integer constant.
   //    - fValue: value of floating-point constant.
   //    - sValue: value of string constant.
   // ============================================

   HashMap<String, Info> symtab = new HashMap<String, Info>();

   // labelCount is used to represent temporary label, and the first index is 0.
   int labelCount = 0;
   
   // varCount is used to represent temporary variables, and the first index is 0.
   int varCount = 0;

   // Record all assembly instructions.
   List<String> TextCode = new ArrayList<String>();

   /* Output prologue. */
   void prologue() {
      TextCode.add("; === prologue ====");
      TextCode.add("declare dso_local i32 @printf(i8*, ...)\n");
      TextCode.add("define dso_local i32 @main() #" + varCount + "{");
   }
   
   /* Output epilogue. */
   void epilogue() {
      /* handle epilogue */
      TextCode.add("\n; === epilogue ===");
      TextCode.add("ret i32 0");
      TextCode.add("}");
   }
   
   /* Generate a new label */
   String newLabel() {
      labelCount ++;
      return (new String("L")) + Integer.toString(labelCount);
   } 
   
   public List<String> getTextCode() {
      return TextCode;
   }
}

program: (VOID|INT) MAIN '(' ')'
   { prologue(); } /* Output function prologue */

   '{' declarations statements '}'
   {
      if (TRACEON) System.out.println("VOID MAIN () {declarations statements}");
      epilogue();      /* output function epilogue */	  
   }
   ;

declarations
:  (type Identifier ';')=> type Identifier ';' declarations
   {
      if (TRACEON) System.out.println("declarations: type Identifier : declarations");

      if (symtab.containsKey($Identifier.text)) {
         // variable re-declared.
         System.out.println("Type Error: " + $Identifier.getLine() + ": Redeclared identifier.");
         System.exit(0);
      }
            
      /* Add ID and its info into the symbol table. */
      Info the_entry = new Info();
      the_entry.theType = $type.attr_type;
      varCount ++;
      the_entry.theVar.varIndex = varCount;
      symtab.put($Identifier.text, the_entry);

      // issue the instruction. Ex: \%a = alloca i32, align 4
      if ($type.attr_type == Type.INT) { 
         TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
      } else if ($type.attr_type == Type.FLOAT) {
         TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca float, align 4");
      } 
   }
   |  (type Identifier '=')=> type Identifier '=' arith_expression ';' declarations
   {
      if (TRACEON) System.out.println("declarations: ");
      if (symtab.containsKey($Identifier.text)) {
         // variable re-declared.
         System.out.println("Type Error: " + $Identifier.getLine() + ": Redeclared identifier.");
         System.exit(0);
      }
      /* Add ID and its info into the symbol table. */
      Info the_entry = new Info();
      the_entry.theType = $type.attr_type;
      varCount ++;
      the_entry.theVar.varIndex = varCount;
      symtab.put($Identifier.text, the_entry);

      // issue the instruction. Ex: \%a = alloca i32, align 4
      if ($type.attr_type == Type.INT) { 
         TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
      } else if ($type.attr_type == Type.FLOAT) {
         TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca float, align 4");
      } 

      Info theRHS = $arith_expression.theInfo;
      Info theLHS = symtab.get($Identifier.text); 

      // issue store insruction. Ex: store i32 \%tx, i32* \%ty
      if ((theLHS.theType == Type.INT) && (theRHS.theType == Type.INT)) {		   
         TextCode.add("store i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4");
      } else if ((theLHS.theType == Type.INT) && (theRHS.theType == Type.CONST_INT)) {
         TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4");				
      } else if ((theLHS.theType == Type.FLOAT) && (theRHS.theType == Type.FLOAT)) {	
         TextCode.add("store float \%t" + theRHS.theVar.varIndex + ", float* \%t" + theLHS.theVar.varIndex + ", align 4");
      } else if ((theLHS.theType == Type.FLOAT) && (theRHS.theType == Type.CONST_FLOAT)) {
         TextCode.add("store float " + theRHS.theVar.fValue + ", float* \%t" + theLHS.theVar.varIndex + ", align 4");				
      } 
   }
   | 
   { if (TRACEON) System.out.println("declarations: "); }
   ;

type
returns [Type attr_type]
   : INT { if (TRACEON) System.out.println("type: INT"); $attr_type=Type.INT; }
   | CHAR { if (TRACEON) System.out.println("type: CHAR"); $attr_type=Type.CHAR; }
   | FLOAT {if (TRACEON) System.out.println("type: FLOAT"); $attr_type=Type.FLOAT; }
   ;

statements: statement block_content
         ;

block_content: declarations statements
            | 
            ;

statement: assign_stmt ';'
         | if_stmt
         | func_no_return_stmt ';'
         | for_stmt
         | jump_stmt ';'
         ;

for_stmt: FOR '(' assign_stmt ';'
                  cond_expression ';'
                  assign_stmt
               ')'
                  block_stmt
         ;
        
if_stmt 
returns [String label] 
@init {label = new String();}
   : a=if_then_stmt
   {
      String then = $a.label;
      String end = newLabel();
      $label = end;
      TextCode.add("br label \%" + $label);
      TextCode.add(then + ":");
   } 
   (ELSE b=if_then_stmt
   {
      String next = $b.label;
      TextCode.add("br label \%" + $label);
      TextCode.add(next + ":");
   })* if_else_stmt[label]
   {
      TextCode.add("br label \%" + $label);
      TextCode.add($label + ":");
   }
   ;
      
if_then_stmt 
returns [String label] 
@init {label = new String();}
   : IF '(' cond_expression ')' 
   {
      String L1 = newLabel();
      String L2 = newLabel();
      TextCode.add("br i1 \%t" + $cond_expression.theInfo.theVar.varIndex + ", label \%" + L1 + ", label \%" + L2);
      TextCode.add(L1 + ":");
      label = L2;
   }
   block_stmt
   ;

if_else_stmt[String label]
            : ELSE block_stmt
            |
            ;
            
block_stmt: '{' statements '}'
   ;

assign_stmt: Identifier '=' arith_expression
   {
      Info theRHS = $arith_expression.theInfo;
      Info theLHS = symtab.get($Identifier.text); 

      // issue store insruction. Ex: store i32 \%tx, i32* \%ty
      if ((theLHS.theType == Type.INT) && (theRHS.theType == Type.INT)) {		   
         TextCode.add("store i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4");
      } else if ((theLHS.theType == Type.INT) && (theRHS.theType == Type.CONST_INT)) {
         TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4");				
      } else if ((theLHS.theType == Type.FLOAT) && (theRHS.theType == Type.FLOAT)) {	
         TextCode.add("store float \%t" + theRHS.theVar.varIndex + ", float* \%t" + theLHS.theVar.varIndex + ", align 4");
      } else if ((theLHS.theType == Type.FLOAT) && (theRHS.theType == Type.CONST_FLOAT)) {
         String floatStr = String.format("\%e",theRHS.theVar.fValue); 
         TextCode.add("store float " + floatStr + ", float* \%t" + theLHS.theVar.varIndex + ", align 4");				
      } 
   }
   ;
     
func_no_return_stmt
   :  'printf' '(' argument[1] ')'
   |  Identifier '(' argument[0] ')'
   ;

argument
[int choice] 
returns [printParameter thepara] 
@init {thepara = new printParameter();}
   : a=arg
   {  
      if(choice == 1){
         int len = $a.theInfo.theVar.sValue.length() + 1;
         String str = $a.theInfo.theVar.sValue;
         if (str.endsWith("\\n")) {
            len --;
         }

         str = str.replace("\\n","\\0A");
         varCount ++;
         TextCode.add(1 , "@t"+ varCount + " = constant [" + len + " x i8] c\"" + str + "\\00\"");
         $thepara.varcrec = varCount;
      }
   }
   (',' b=arg
   {
      // thepara.para += ", i32 \%t"+ $b.theInfo.theVar.varIndex;
      if ($b.theInfo.theType == Type.FLOAT || $b.theInfo.theType == Type.CONST_FLOAT) {
         varCount++;
         TextCode.add("\%t" + varCount + " = fpext float \%t" + $b.theInfo.theVar.varIndex + " to double");
         thepara.para += ", double \%t" + varCount;
      } else if ($b.theInfo.theType == Type.INT || $b.theInfo.theType == Type.CONST_INT) {
         thepara.para += ", i32 \%t" + $b.theInfo.theVar.varIndex;
      }
   })*
   {
      if(choice == 1){
         int len = $a.theInfo.theVar.sValue.length() + 1;
         String str = $a.theInfo.theVar.sValue;
         if (str.endsWith("\\n")) {
            len --;
         }
         
         varCount ++;
         TextCode.add("\%t" + varCount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + len + " x i8], [" + len +" x i8]* @t" + $thepara.varcrec + ", i64 0, i64 0)" + $thepara.para + ")");
      }
   }
   ;

arg 
returns [Info theInfo] 
@init {theInfo = new Info();}
   : arith_expression  { $theInfo=$arith_expression.theInfo; } 
   | STRING_LITERAL
   {
      String str = $STRING_LITERAL.text;
      $theInfo.theType = Type.STRING;
      $theInfo.theVar.sValue = str.substring(1, str.length() - 1);
   }
   ;
         
cond_expression 
returns [Info theInfo] 
@init {theInfo = new Info();}
   : a=arith_expression 
   ( '>' b=arith_expression
   {
      if (($a.theInfo.theType == Type.INT) && ($b.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp sgt i32 \%t"+$a.theInfo.theVar.varIndex +", \%t"+$b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.INT) && ($b.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp sgt i32 \%t"+$a.theInfo.theVar.varIndex +", "+$b.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($b.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp sgt i32 "+$a.theInfo.theVar.iValue +", \%t"+$b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($b.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp sgt i32 "+$a.theInfo.theVar.iValue +", "+$b.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = fcmp ogt float \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp ogt float \%t" + $a.theInfo.theVar.varIndex + ", " + floatStr);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $a.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp ogt float " + floatStr + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStrA = String.format("\%e", $a.theInfo.theVar.fValue);
         String floatStrB = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp ogt float " + floatStrA + ", " + floatStrB);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      }
   }
   | '<' c=arith_expression
   {
      if (($a.theInfo.theType == Type.INT) && ($c.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp slt i32 \%t"+$a.theInfo.theVar.varIndex+", \%t"+$c.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.INT) && ($c.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp slt i32 \%t"+$a.theInfo.theVar.varIndex+", "+$c.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($c.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp slt i32 "+$a.theInfo.theVar.iValue +", \%t"+$c.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($c.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp slt i32 "+$a.theInfo.theVar.iValue +", "+$c.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = fcmp olt float \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp olt float \%t" + $a.theInfo.theVar.varIndex + ", " + floatStr);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $a.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp olt float " + floatStr + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStrA = String.format("\%e", $a.theInfo.theVar.fValue);
         String floatStrB = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp olt float " + floatStrA + ", " + floatStrB);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      }
   }
   | '>=' d=arith_expression
   {
      if (($a.theInfo.theType == Type.INT) && ($d.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp sge i32 \%t"+$a.theInfo.theVar.varIndex+", \%t"+$d.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.INT) && ($d.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp sge i32 \%t"+$a.theInfo.theVar.varIndex+", "+$d.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($d.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp sge i32 "+$a.theInfo.theVar.iValue +", \%t"+$d.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($d.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp sge i32 "+$a.theInfo.theVar.iValue +", "+$d.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = fcmp oge float \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp oge float \%t" + $a.theInfo.theVar.varIndex + ", " + floatStr);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $a.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp oge float " + floatStr + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStrA = String.format("\%e", $a.theInfo.theVar.fValue);
         String floatStrB = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp oge float " + floatStrA + ", " + floatStrB);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      }
   }
   | '<=' e=arith_expression
   {
      if (($a.theInfo.theType == Type.INT) && ($e.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp sle i32 \%t"+$a.theInfo.theVar.varIndex+", \%t"+$e.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.INT) && ($e.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp sle i32 \%t"+$a.theInfo.theVar.varIndex+", "+$e.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($e.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp sle i32 "+$a.theInfo.theVar.iValue +", \%t"+$e.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($e.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp sle i32 "+$a.theInfo.theVar.iValue +", "+$e.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = fcmp ole float \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp ole float \%t" + $a.theInfo.theVar.varIndex + ", " + floatStr);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $a.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp ole float " + floatStr + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStrA = String.format("\%e", $a.theInfo.theVar.fValue);
         String floatStrB = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp ole float " + floatStrA + ", " + floatStrB);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      }
   }
   | '==' f=arith_expression
   {
      if (($a.theInfo.theType == Type.INT) && ($f.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp eq i32 \%t"+$a.theInfo.theVar.varIndex+", \%t"+$f.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.INT) && ($f.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp eq i32 \%t"+$a.theInfo.theVar.varIndex+", "+$f.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($f.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp eq i32 "+$a.theInfo.theVar.iValue +", \%t"+$f.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($f.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp eq i32 "+$a.theInfo.theVar.iValue +", "+$f.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = fcmp eq float \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp eq float \%t" + $a.theInfo.theVar.varIndex + ", " + floatStr);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $a.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp eq float " + floatStr + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStrA = String.format("\%e", $a.theInfo.theVar.fValue);
         String floatStrB = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp eq float " + floatStrA + ", " + floatStrB);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      }
   }
   | '!=' g=arith_expression
   {
      if (($a.theInfo.theType == Type.INT) && ($g.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp ne i32 \%t"+$a.theInfo.theVar.varIndex+", \%t"+$g.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.INT) && ($g.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp ne i32 \%t"+$a.theInfo.theVar.varIndex+", "+$g.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($g.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp ne i32 "+$a.theInfo.theVar.iValue +", \%t"+$g.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($g.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = icmp ne i32 "+$a.theInfo.theVar.iValue +", "+$g.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = fcmp ne float \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp ne float \%t" + $a.theInfo.theVar.varIndex + ", " + floatStr);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $a.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp ne float " + floatStr + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStrA = String.format("\%e", $a.theInfo.theVar.fValue);
         String floatStrB = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fcmp ne float " + floatStrA + ", " + floatStrB);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      }
   }
   )
   ;
            
arith_expression
returns [Info theInfo]
@init {theInfo = new Info();}
   : a=multExpr { $theInfo=$a.theInfo; }
   ( '+' b=multExpr
   {  // We need to do type checking first. -> ... -> code generation.					   
      if (($a.theInfo.theType == Type.INT) && ($b.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.INT) && ($b.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($b.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = add nsw i32 " + $theInfo.theVar.iValue + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($b.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = add nsw i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {	
         varCount ++;
         TextCode.add("\%t" + varCount + " = fadd float \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = fpext float \%t"+ $a.theInfo.theVar.varIndex +" to double");
         
         int temp1 = varCount;
         String floatStr = String.format("\%e",$b.theInfo.theVar.fValue); 
         varCount ++;
         TextCode.add("\%t" + varCount + " = fadd double \%t" + temp1 + ", " + floatStr);

         int temp2 = varCount;
         TextCode.add("\%t"+ varCount +" = fptrunc double \%t"+ temp2 +" to float");
         varCount ++;
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = fpext float \%t"+ $a.theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.fValue);

         int temp1 = varCount;
         String floatStr = String.format("\%e",$b.theInfo.theVar.fValue); 
         varCount ++;
         TextCode.add("\%t" + varCount + " = fadd double \%t" + temp1 + ", " + floatStr);

         int temp2 = varCount;
         TextCode.add("\%t"+ varCount +" = fptrunc double \%t"+ temp2 +" to float");
         varCount ++;
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      }  
   }
   | '-' c=multExpr
   {  // We need to do type checking first. -> ... -> code generation.					   
      if (($a.theInfo.theType == Type.INT) && ($c.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.INT) && ($c.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($c.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = sub nsw i32 " + $theInfo.theVar.iValue + ", \%t" + $c.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($c.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = sub nsw i32 " + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($c.theInfo.theType == Type.FLOAT)) {	
         varCount ++;
         TextCode.add("\%t" + varCount + " = fsub float \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($c.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = fpext float \%t"+ $a.theInfo.theVar.varIndex +" to double");

         int temp1 = varCount;
         String floatStr = String.format("\%e",$c.theInfo.theVar.fValue); 
         varCount ++;
         TextCode.add("\%t" + varCount + " = fsub double \%t" + temp1 + ", " + floatStr);

         int temp2 = varCount;
         TextCode.add("\%t"+ varCount +" = fptrunc double \%t"+ temp2 +" to float");
         varCount ++;
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($c.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         TextCode.add("\%t"+ varCount +" = fpext float \%t"+ $a.theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.fValue);

         int temp1 = varCount;
         String floatStr = String.format("\%e",$c.theInfo.theVar.fValue); 
         varCount ++;
         TextCode.add("\%t" + varCount + " = fsub double \%t" + temp1 + ", " + floatStr);

         int temp2 = varCount;
         TextCode.add("\%t"+ varCount +" = fptrunc double \%t"+ temp2 +" to float");
         varCount ++;
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } 
   }
   )*
   ;

multExpr
returns [Info theInfo]
@init {theInfo = new Info();}
   : a=signExpr { $theInfo=$a.theInfo; }
   ( '*' b=signExpr
   { // We need to do type checking first. -> code generation.
      if (($a.theInfo.theType == Type.INT) && ($b.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.INT) && ($b.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($b.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = mul nsw i32 " + $theInfo.theVar.iValue + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($b.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = mul nsw i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount++;
         TextCode.add("\%t" + varCount + " = fmul float \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount++;
         String floatStr = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fmul float \%t" + $a.theInfo.theVar.varIndex + ", " + floatStr);
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.FLOAT)) {
         varCount++;
         String floatStr = String.format("\%e", $a.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fmul float " + floatStr + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($b.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStrA = String.format("\%e", $a.theInfo.theVar.fValue);
         String floatStrB = String.format("\%e", $b.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fmul float " + floatStrA + ", " + floatStrB);
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      }
   }
   | '/' c=signExpr
   {  // We need to do type checking first. -> code generation.					   
      if (($a.theInfo.theType == Type.INT) && ($c.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.INT) && ($c.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($c.theInfo.theType == Type.INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = sdiv i32 " + $theInfo.theVar.iValue + ", \%t" + $c.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_INT) && ($c.theInfo.theType == Type.CONST_INT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = sdiv i32 " + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      }  else if (($a.theInfo.theType == Type.FLOAT) && ($c.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         TextCode.add("\%t" + varCount + " = fdiv float \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.FLOAT) && ($c.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $c.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fdiv float \%t" + $a.theInfo.theVar.varIndex + ", " + floatStr);
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($c.theInfo.theType == Type.FLOAT)) {
         varCount ++;
         String floatStr = String.format("\%e", $a.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fdiv float " + floatStr + ", \%t" + $c.theInfo.theVar.varIndex);
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } else if (($a.theInfo.theType == Type.CONST_FLOAT) && ($c.theInfo.theType == Type.CONST_FLOAT)) {
         varCount ++;
         String floatStrA = String.format("\%e", $a.theInfo.theVar.fValue);
         String floatStrB = String.format("\%e", $c.theInfo.theVar.fValue);
         TextCode.add("\%t" + varCount + " = fdiv float " + floatStrA + ", " + floatStrB);
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      }
   }
   )*
   ;

signExpr
returns [Info theInfo]
@init {theInfo = new Info();}
   : a=primaryExpr { $theInfo=$a.theInfo; } 
   | '-' b=primaryExpr{
      if($b.theInfo.theType == Type.INT){
         varCount ++;
         TextCode.add("\%t" + varCount + " = sub nsw i32 " + 0 + ", \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if($b.theInfo.theType == Type.CONST_INT){
         varCount ++;
         TextCode.add("\%t" + varCount + " = sub nsw i32 " + 0 + ", " + $b.theInfo.theVar.iValue);
         $theInfo.theType = Type.INT;
         $theInfo.theVar.varIndex = varCount;
      } else if ($b.theInfo.theType == Type.FLOAT) {
         varCount ++;
         TextCode.add("\%t" + $theInfo.theVar.varIndex + " = fneg float \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } else if ($b.theInfo.theType == Type.CONST_FLOAT) {
         varCount ++;
         TextCode.add("\%t" + $theInfo.theVar.varIndex + " = fneg float \%t" + $b.theInfo.theVar.varIndex);
         $theInfo.theType = Type.CONST_FLOAT;
         $theInfo.theVar.varIndex = varCount;
      } else {
         $theInfo = new Info();
         $theInfo.theType = Type.ERR;
      }
   }
   ;
      
primaryExpr
returns [Info theInfo]
@init {theInfo = new Info();}
   : Integer_constant
   {
      $theInfo.theType = Type.CONST_INT;
      $theInfo.theVar.iValue = Integer.parseInt($Integer_constant.text);
   }
   | Floating_point_constant
   {
      $theInfo.theType = Type.CONST_FLOAT;
      $theInfo.theVar.fValue = Float.parseFloat($Floating_point_constant.text);
   }
   | Identifier
   {
      // get type information from symtab.
      Type the_type = symtab.get($Identifier.text).theType;
      $theInfo.theType = the_type;
      int vIndex = symtab.get($Identifier.text).theVar.varIndex;
   
      switch (the_type) {
         case INT: 
            varCount++;
            TextCode.add("\%t" + varCount + " = load i32, i32* \%t" + vIndex + ", align 4");
            $theInfo.theVar.varIndex = varCount;
            break;
         case FLOAT:
            varCount ++;
            TextCode.add("\%t" + varCount + " = load float, float* \%t" + vIndex + ", align 4");
            $theInfo.theVar.varIndex = varCount;
            break;
         case CHAR:
            break;
      }
   }
   | '&' Identifier
   | '(' arith_expression {$theInfo = $arith_expression.theInfo;} ')'
   ;

jump_stmt: return_stmt
   ; 

return_stmt
  : RETURN Integer_constant 
  | RETURN Floating_point_constant 
  | RETURN Identifier 
  | RETURN 
  ;
         
/* description of the tokens */
FLOAT:'float';
INT:'int';
CHAR: 'char';

MAIN: 'main';
VOID: 'void';
IF: 'if';
ELSE: 'else';
FOR: 'for';
RETURN: 'return';

Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:'0'..'9'+;
Floating_point_constant:'0'..'9'+ '.' '0'..'9'+;

STRING_LITERAL
   :  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
   ;

WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};
COMMENT1  : '//'(.)*'\n' {$channel=HIDDEN;};
COMMENT2  : '/*' (options{greedy=false;}: .)* '*/' {$channel=HIDDEN;};
fragment
EscapeSequence
   :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\'|'//')
   ;