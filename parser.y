%{
#include<iostream>
#include "symbols.hpp"
#include "lex.yy.cpp"
#define Trace(t) if (Opt_P) cout << "TRACE => " << t << endl;
int Opt_P = 1;
void yyerror(string s);
SymbolTableList symbolTable;
vector<vector<idInfo> > functions;
void insertSymboltable();
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
%token <dval> DOUBLE_C
%token <bval> BOOL_C
%token <sval> STRING_C
%token <ival> INT_C


%type <idClassval> const_val expression call_function
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
/*IDclass(int idF,int idT,bool idInit){*/
program: 				OBJECT ID
						{
							IDclass id;
							symbolTable.insert(*$2,id);
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
						| LET ID '=' expression
						{
							Trace("LET ID = expression");
							$4->idFlag = constVariableFlag;
							$4->int = true;
							if(symbolTable.insert(*$2,*$4) == -1) yyerror("const redefine");
						}
var_dec:				VAR ID ':' var_type
						{
							Trace("VAR ID : var_type");
							IDclass* c = new IDclass(variableFlag,*$3,false);
							if(symbolTable.insert(*$2,*c) == -1) yyerror("var_dec redefine");
						}
						| VAR ID ':' var_type '[' INT_C ']'
						{
							Trace("VAR ID ':' var_type '[' INT_C ']'");
							symbolTable.insert(*$2,$4,$6);
						}
						| VAR ID '=' var_type
						{
							Trace("VAR ID '=' var_type");
							symbolTable.insert(*$2,$4,false);
						}
						| VAR ID ':' var_type '=' expression
						{
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
                        | BOOL
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
method_desc:			DEF ID '(' args ')' return_type
						{
							IDclass *c = new IDclass(functionFlag,,False);
						}
						'{' zero_more_staments var_const_decs '}'
						{
							Trace("method_desc");
							symbols.dump();
							symbols.pop();
						}
						;
args:					arg ',' args
						|  arg
						;
arg:					ID ':' var_type
    					{
        					IDclass* c = new IDclass(variableFlag,$3,false);
        					if(symbolTable.insert(*$1,$3) == -1) yyerror("variable redefine");
        					symbols.addFuncArg(*$1, *c);
    					}
    					;
return_type:			':' var_type
						{
							$$ = $2;
						}
						| /*empty*/
						{
							return None;
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
						| call_function	
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
								yyerror("this is not array")
							}else if(c->idFlag!=variableFlag){
								yyerror("this is not variable array");
							}else{
								c->arrayValue[$3] = $6';
							}
						}
						|  PRINT '(' expression ')' 
						{
							Trace("print expression");
						}
						|  PRINTLN '(' expression ')'
							Trace("println expression"); 
						|  READ ID
							Trace("Read id");
						|  RETURN
							Trace("return");
						|  RETURN expression
							Trace("return expression");
						;
block:					'{'
						{
							symbolTable.push();
						}
							var_const_decs one_more_staments 
							'}'
						{
                          symbols.dump();
                          symbols.pop();
                        }
                        ;
conditional:			IF '(' expression ')' 
						{
							if(*$3->idType != boolType) yyerror("Conditional not bool");
						}
						a_block_or_statement
						{

						} 
						ELSE a_block_or_statement	
						{

						}
						| IF '(' expression ')' a_block_or_statement
						; 	
block_statement:		block
						| stament
						;

else_block_statement:	
expression
%%
void yyerror(string s){
	cerr << "line " << linenum << ": " << s << endl;
  	exit(1);
}
main()
{
yyparse();
}