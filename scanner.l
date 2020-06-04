%{
#include "y.tab.hpp"
#define LIST	strcat(buf,yytext)
#define token(t) {LIST; if(tokenDebug)printf("<%s>\n",#t);}
#define tokenInteger(t,i) {LIST; if(tokenDebug)printf("<%s:%d>\n",t,i);}
#define tokenChar(t) { LIST; if(tokenDebug) printf("<'%c'>\n", t); }
#define tokenString(t,s) {LIST; if(tokenDebug)printf("<%s:%s>\n",t,s);}
#define tokenDoubleOperator(t) { LIST; if(tokenDebug) printf("<'%s'>\n", t);}
#define MAX_LINE_LENG 256
int linenum = 1,i=0,j=0,tokenDebug=1;
char buf[MAX_LINE_LENG];
char tmp[MAX_LINE_LENG];
char tmp1[MAX_LINE_LENG];
char c;
char *locate;
%}
DELIMITER               ([,:;()[\]{}])
ARITHMETIC              ([-+*/%])
RELATIONAL              ([<>!=])
IDENTIFIER [a-zA-Z]+[0-9]*[A-Za-z]*
INTEGER [0-9]+
REAL [0-9]+\.[0-9]+
IDERROR [0-9]+[A-Za-z]+
NOTHING "//".*
STRING \"[^"^\n]*\"
%x C_COMMENT

%% 
	/* single character token */
{DELIMITER}  |
{ARITHMETIC} |
{RELATIONAL}    { tokenChar(yytext[0]); return yytext[0]; }

	/* double operator*/
"=="      		{tokenDoubleOperator("=="); return EE; }
"<="      		{tokenDoubleOperator("<="); return LE;}
">="      		{tokenDoubleOperator(">="); return GE;}
"!="      		{tokenDoubleOperator("!="); return NE;}
"||"      		{tokenDoubleOperator("||"); return OR;}
"&&"      		{tokenDoubleOperator("&&"); return AND;}

	/* keyword */
boolean			{token(BOOLEAN);}
break			{token(BREAK);}
char			{token(CHAR);}
case			{token(CASE);}
class			{token(CLASS);}
continue		{token(CONTINUE);}
def				{token(DEF);}
do				{token(DO);}
else			{token(ELSE);}
exit			{token(EXIT);}
float			{token(FLOAT);}
for				{token(FOR);}
if				{token(IF);}
int				{token(INT);}
object			{token(OBJECT);}
print			{token(PRINT);}
println			{token(PRINTLN);}
repeat			{token(REPEAT);}
return			{token(RETURN);}
string			{token(STRING);}
to				{token(TO);}
type			{token(TYPE);}
val				{token(VAL);}
var				{token(VAR);}
while			{token(WHILE);}
read      		{token(READ);}
false           { 	
					token(FALSE);
                    yylval.bval = false;
                    return BOOL_C;
                }
true            { 	
					token(TRUE);
                    yylval.bval = true;
                    return BOOL_C;
                }
{IDENTIFIER} 	{
					yylval.sval = new string(yytext);
  					tokenString("ID", yytext);
  					return ID;
				}
{REAL} 			{	
					tokenString("real",yytext);
					yylval.fval = atof(yytext);
					return FLOAT_C;
				}
{INTEGER} 		{
					tokenInteger("integer",atoi(yytext));
					yylval.ival = value;
  					return INT_C;
				}
"/*"            { 	
					LIST;
					BEGIN(C_COMMENT); 
				}
<C_COMMENT>"*/" { 	
					LIST;
					BEGIN(INITIAL); 
				}
<C_COMMENT>\n   {  	LIST;
        			printf("%d: %s", linenum++, buf);
        			buf[0] = '\0';
        		}
<C_COMMENT>.    { 	LIST;}
{NOTHING} 		{	LIST;};
{IDERROR} 		{
					LIST;
		 			printf("%d:%s\n", linenum+1, buf);
         			printf("bad character:'%s'\n",yytext);
         			exit(-1);
         		}

{STRING} 		{
					c = input();
					if(c=='"'){
						yymore();
					}else{	
						tmp[0]='"';
						tmp[1]='"';
						tmp[2]= 0;
						memset(tmp1,0,MAX_LINE_LENG);
						strcpy(tmp1,yytext);
						locate = strstr(tmp1,tmp);
						i=locate-tmp1;
						while(i>0){
							for(j=i;j<strlen(tmp1)-1;j++){
								tmp1[j]=tmp1[j+1];
							}
							tmp1[strlen(tmp1)-1]=0;
							locate = strstr(tmp1,tmp);
							i=locate-tmp1;
						}
						tokenString("string",tmp1);
					}
					yylval.sval = new string(tmp1);  
					memset(tmp,0,MAX_LINE_LENG);
					memset(tmp1,0,MAX_LINE_LENG);
					unput(c);
					return STRING_C;
				}			
\n      		{
        			LIST;
        			printf("%d: %s", linenum++, buf);
        			buf[0] = '\0';
		        }
[\t ]*  		{LIST;}
. 				{
        			LIST;
        			printf("%d:%s\n", linenum+1, buf);
			        printf("bad character:'%s'\n",yytext);
			        exit(-1);
    			}	

%%
