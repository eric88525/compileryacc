%{
#include "symbols.hpp"
#include "lex.yy.cpp"
#define Trace(t) if (Opt_P) cout << "TRACE => " << t << endl;
int Opt_P = 1;
void yyerror(string s);
symboltableList symbolTable;
vector<vector<IDclass> > functions;
%}

/* yylval */
%union {
  int ival;
  float fval;
  bool bval;
  string *sval;
  IDclass* idClassval;
  int type;
}

/* tokens*/
//operator & keyword
%token EE LE GE NE OR AND
%token BOOLEAN BREAK CHAR CASE CLASS CONTINUE DEF DO ELSE EXIT FLOAT FOR IF INT OBJECT PRINT PRINTLN REPEAT RETURN STRING TO TYPE VAL VAR WHILE READ TRUE FALSE
%token <sval> ID
%token <ival> INT_C
%token <fval> FLOAT_C
%token <bval> BOOL_C
%token <sval> STRING_C
%type <idClassval> const_val expression function_invocation
/*NT return type*/
%type <type> var_type return_type 

/* precedence */
%left OR
%left AND
%left '!'
%left '<' LE EQ GE '>' NEQ
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%%

program: 				OBJECT ID
						{
							Trace("program start");
							IDclass* c = new IDclass();
							c->idFlag = objectFlag;	
							c->idType = None;				
							symbolTable.insert(*$2,*c);
						} 
						'{' var_const_decs method_decs '}'
						{
							Trace("End program");
							symbolTable.dump();
							symbolTable.pop();
						}
						;

var_const_decs:			const_dec var_const_decs		
						|	var_dec var_const_decs
						|	/* zero */
						;

/* constant declaration */
const_dec:				VAL ID ':' var_type '=' expression
						{
							Trace("VAL ID : var_type = expression");
							$6->idFlag = constVariableFlag;
							$6->init = true;
							if(symbolTable.insert(*$2,*$6) == -1) yyerror("const redefine");
						}
						| VAL ID '=' expression
						{
							Trace("VAL ID = expression");
							$4->idFlag = constVariableFlag;
							$4->init = true;
							if(symbolTable.insert(*$2,*$4) == -1) yyerror("const redefine");
						}
						;
var_dec:				VAR ID ':' var_type
						{
							Trace("VAR ID : var_type");
							IDclass* c = new IDclass(variableFlag,$4,false);
							if(symbolTable.insert(*$2,*c) == -1) yyerror("var_dec redefine");
						}
						| VAR ID ':' var_type '[' INT_C ']'
						{
							Trace("VAR ID ':' var_type '[' INT_C ']'");

							symbolTable.insert(*$2,$4,$6);
						}
						| VAR ID '=' expression
						{
							Trace("VAR ID '=' expression");
							$4 ->init = true;
							$4 ->idFlag = variableFlag;
							symbolTable.insert(*$2,*$4);
						}
						| VAR ID ':' var_type '=' expression
						{
							Trace("VAR ID ':' var_type '=' expression");
							$6->init = true;
							$6->idFlag = variableFlag;
							if(symbolTable.insert(*$2,*$6) == -1 ){yyerror("variable redefine");}
						}
						;			
/* variable type */
var_type                : INT
                        {
                          $$ = intType;
                        }
                        | FLOAT
                        {
                          $$ = realType;
                        }
                        | BOOLEAN
                        {
                          $$ = boolType;
                        }
                        | STRING
                        {
                          $$ = strType;
                        }
                        ;
method_decs:			method_dec method_decs
						| method_dec
						;
method_dec:				DEF ID 
						{
							Trace("DEF ID '(' args ')' return_type");
							IDclass *c = new IDclass(functionFlag,None,false);
							if(symbolTable.insert(*$2,*c)==-1) yyerror("function redefine");
							symbolTable.push();
						}
						'(' args ')' return_type '{' var_const_decs zero_more_staments '}'
						{
							Trace("method_desc");
							symbolTable.dump();
							symbolTable.pop();
						}
						;
args:					arg ',' args
						|  arg
						;
arg:					ID ':' var_type
    					{
    						Trace("Add function arg");
        					IDclass* c = new IDclass(variableFlag,$3,false);
        					if(symbolTable.insert(*$1,*c) == -1) yyerror("variable redefine");
        					symbolTable.addFunctionArg(*$1, *c);
    					}
    					| /*zero arg*/
    					;
return_type:			':' var_type
						{
							Trace("return_type':' var_type");
							symbolTable.setFunctionType($2);
						}
						| /*empty*/
						{
							Trace("return_type':' None");
							symbolTable.setFunctionType(voidType);
						}
						;
zero_more_staments:		statements zero_more_staments
						| /*zero*/
						;
one_more_staments:		statements zero_more_staments
						;
statements:				stament
						| block
						| conditional
						| loop
						| function_invocation	
						;
stament:				ID '=' expression
						{
							Trace("statement: variable assignment");
							IDclass* c = symbolTable.lookup(*$1);
							if(c == NULL){
								yyerror("variable not declare!");
							}else if(c->idFlag!=variableFlag){
								yyerror("this is not variable");
							}else if(c->idType != $3->idType){
								yyerror("variable type not the same");
							} else{
								c->init = true;
								c->setValue(*$3);
							}
						}
						|  ID '[' INT_C ']' '=' expression
						{
							Trace("statement: variable[] assignment");
							IDclass* c = symbolTable.lookup(*$1);
							if(c == NULL){
								yyerror("variable array not declare!");
							}else if(c->idType != arrayType){
								yyerror("this is not array");
							}else if(c->idFlag!=variableFlag){
								yyerror("this is not variable array");
							}else{
								c->init = true;
								c->arrayValue[$3] = *$6;
							}
						}
						|  PRINT '(' expression ')' 
						{
							Trace("print expression");
						}
						|  PRINTLN '(' expression ')'
						{
							Trace("println expression");
						} 
						|  READ ID
						{
							Trace("Read id");
						}
						|  RETURN
						{
							Trace("return");
						}
						|  RETURN expression
						{
							Trace("return expression");
						}
						;
block:					'{'
						{
							Trace("Block start");
							symbolTable.push();
						}
						var_const_decs one_more_staments '}'
						{
                          symbolTable.dump();
                          symbolTable.pop();
                        }
                        ;
conditional:			IF '(' expression ')' a_block_or_statement ELSE a_block_or_statement	
						{
							Trace("statement: if else");
							if($3->idType != boolType )yyerror("condition type error");
						}
						| IF '(' expression ')' a_block_or_statement
						{
							Trace("conditional IF");
							if($3->idType != boolType) { yyerror("condition type error");}
						}
						; 	
a_block_or_statement:	block
						| stament
						;
loop:					WHILE '(' expression ')' 
						{
							Trace("while loop start");
							if($3->idType != boolType) yyerror("Conditional not bool");
						} a_block_or_statement
						{	
							Trace("while loop end");
						}	
						|  FOR '(' ID '<' '-' INT_C TO INT_C ')' 
						{
							Trace("For loop start");
							IDclass* c = symbolTable.lookup(*$3);
							if(c == NULL){
								yyerror("variable not declare!");
							}else if(c->idFlag!=variableFlag){
								yyerror("this is not variable");
							}else if(c->idType != intType){
								yyerror("variable in for can only be int");
							} 
						} a_block_or_statement
						{
							Trace("For loop end");
						}
						;
function_invocation:	ID 
						{
							functions.push_back(vector<IDclass>());
						}
						'(' comma_separated_expressions ')'
					    {
                          Trace("statement: function invocation");
                          IDclass *c = symbolTable.lookup(*$1);
                          if (c == NULL) yyerror("undeclared indentifier"); /* declaration check */
                          if (c->idFlag != functionFlag) yyerror("not a function"); /* function check */
                          vector<IDclass> para = c->arrayValue;
                          if (para.size() != functions[functions.size() - 1].size()) yyerror("parameter size not match"); /* parameter size check */

                          for (int i = 0; i < para.size(); ++i) {
                            if (para[i].idType != functions[functions.size() - 1].at(i).idType) yyerror("parameter type not match"); /* parameter type check */
                          }
                          $$ = c;
                          functions.pop_back();
                        }
                        ;

/* optional comma-separated expressions */
comma_separated_expressions: 
						comma_separated
                        | /* zero */
                        ;

/* comma-separated expressions */
comma_separated         : func_expression ',' comma_separated
                        | func_expression 	/* func_expression */
                        ;

/* function expression */
func_expression         : expression
                        {
                          	functions[functions.size() - 1].push_back(*$1);
                        }
                        ;
/* constant value */
const_val               : INT_C
                        {
                          	$$ = intConst($1);
                        }
                        | FLOAT_C
                        {
                          	$$ = realConst($1);
                        }
                        | BOOL_C
                        {
                          	$$ = boolConst($1);
                        }
                        | STRING_C
                        {
                          	$$ = strConst($1);
                        }
                        ;
/* expression */
expression              : ID
                        {
                          	IDclass *c = symbolTable.lookup(*$1);
                          	if (c == NULL) yyerror("undeclared indentifier"); /* declaration check */
                          	$$ = c;
                        }
                        | const_val
                        | ID '[' expression ']'
                        {
                          	IDclass *c = symbolTable.lookup(*$1);
                          	if (c == NULL) yyerror("undeclared identifier");
                          	else if (c->idType != arrayType) yyerror("not array type");
                          	else if ($3->idType != intType) yyerror("invalid index");
                          	else if ($3->idData.ival >= c->arrayValue.size()) yyerror("index out of range");                        
                          	$$ = new IDclass(c->arrayValue[$3->idData.ival]);
                        }
                        | function_invocation
                        | '-' expression %prec UMINUS
                        {
                          	Trace("-expression");
                          	if ($2->idType != intType && $2->idType != realType) yyerror("operator error"); /* operator check */
                          	IDclass *c = new IDclass(variableFlag,$2->idType,true);
                          	$$ = c;
                        }
                        | expression '*' expression
                        {
                          	Trace("expression * expression");
                          	if ($1->idType != $3->idType) yyerror("type not match"); /* type check */ 
                          	if ($1->idType != intType && $1->idType != realType) yyerror("operator error"); /* operator check */ 
							IDclass *c = new IDclass(variableFlag,$1->idType,false); 
                          	c->setValue (*$1 * *$3);
                          	$$ = c;
                        }
                        | expression '/' expression
                        {
                          	Trace("expression / expression");
							if ($1->idType != $3->idType) yyerror("type not match"); /* type check */ 
                          	if ($1->idType != intType && $1->idType != realType) yyerror("operator error"); /* operator check */ 
							IDclass *c = new IDclass(variableFlag,$1->idType,false); 
                          	c->setValue (*$1 / *$3);
                          	$$ = c;
                        }
                        | expression '+' expression
                        {
                          	Trace("expression + expression");
                          	if ($1->idType != $3->idType) yyerror("type not match"); /* type check */ 
                          	if ($1->idType != intType && $1->idType != realType) yyerror("operator error"); /* operator check */ 
							IDclass *c = new IDclass(variableFlag,$1->idType,true);
							c->setValue (*$1 + *$3);
                          	$$ = c;
                        }
                        | expression '-' expression
                        {
                          	Trace("expression - expression");
                          	if ($1->idType != $3->idType) yyerror("type not match"); /* type check */ 
                          	if ($1->idType != intType && $1->idType != realType) yyerror("operator error"); /* operator check */ 
							IDclass *c = new IDclass(variableFlag,$1->idType,false); 
                          	c->setValue (*$1 - *$3);
                          	$$ = c;
                        }
                        | expression '<' expression
                        {
                          	Trace("expression < expression");
                          	if ($1->idType != $3->idType) yyerror("type not match"); /* type check */	
                          	if ($1->idType != intType && $1->idType != realType) yyerror("operator error"); /* operator check */  
							IDclass *c = new IDclass(variableFlag,boolType,false); 
                          	$$ = c;	
                        }
                        | expression LE expression
                        {
                          	Trace("expression <= expression");
							if ($1->idType != $3->idType) yyerror("type not match"); /* type check */	
                          	if ($1->idType != intType && $1->idType != realType) yyerror("operator error"); /* operator check */  
							IDclass *c = new IDclass(variableFlag,boolType,false); 
                          	$$ = c;	                    
                        }
                        | expression EE expression
                        {
                            Trace("expression == expression");
                            if ($1->idType != $3->idType) yyerror("type not match"); /* type check */	
                          	if ($1->idType != intType && $1->idType != realType) yyerror("operator error"); /* operator check */  
							IDclass *c = new IDclass(variableFlag,boolType,false); 
                          	$$ = c;	
                        }
                        | expression GE expression
                        {
                          	Trace("expression >= expression");
                          	if ($1->idType != $3->idType) yyerror("type not match"); /* type check */	
                          	if ($1->idType != intType && $1->idType != realType) yyerror("operator error"); /* operator check */  
							IDclass *c = new IDclass(variableFlag,boolType,false); 
                          	$$ = c;	
                        }
                        | expression '>' expression
                        {
                          	Trace("expression > expression");
                          	if ($1->idType != $3->idType) yyerror("type not match"); /* type check */	
                          	if ($1->idType != intType && $1->idType != realType) yyerror("operator error"); /* operator check */  
							IDclass *c = new IDclass(variableFlag,boolType,false); 
                          	$$ = c;	
                        }
                        | expression NE expression
                        {
                          	Trace("expression != expression");
                          	if ($1->idType != $3->idType) yyerror("type not match"); /* type check */	
                          	if ($1->idType != intType && $1->idType != realType) yyerror("operator error"); /* operator check */  
							IDclass *c = new IDclass(variableFlag,boolType,false); 
                          	$$ = c;	
                        }
                        | '!' expression
                        {
                          	Trace("!expression");
                          	if ($2->idType != boolType) yyerror("operator error"); /* operator check */
                          	IDclass *c = new IDclass(variableFlag,boolType,false);
                          	$$ = c;
                        }
                        | expression AND expression
                        {
	                        Trace("expression && expression");
	                        if ($1->idType != $3->idType) yyerror("type not match"); /* type check */
	                        if ($1->idType != boolType) yyerror("operator error"); /* operator check */
	                        IDclass *c = new IDclass(variableFlag,boolType,false);
                          	$$ = c;
                        }
                        | expression OR expression
                        {
                          	Trace("expression || expression");
                          	if ($1->idType != $3->idType) yyerror("type not match"); /* type check */
	                        if ($1->idType != boolType) yyerror("operator error"); /* operator check */
	                        IDclass *c = new IDclass(variableFlag,boolType,false);
                          	$$ = c;
                        }
                        | '(' expression ')'
                        {
                          	Trace("(expression)");
                          	$$ = $2;
                        }
                        ;			
%%

void yyerror(string s){
	cerr << "yyerror: line " << linenum << ": " << s << endl;
  	exit(1);
}

int main(int argc, char *argv[])
{
if(argc==2){
	yyin = fopen(argv[1],"r");
}else{
	puts("Format error!");
	return 0 ;
}


yyparse();

}