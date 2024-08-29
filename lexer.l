%{
#include "parser.tab.h"
#include<bits/stdc++.h>
#include<stack>
#include<string>
#include<queue>
using namespace std;
extern int lvl;
extern string curr_identifier;
class SymTabEnt {
    public:
    int line_no;
    string syntactic_category;
    string type;
    string file_name;
    int size,offset;
    
};
class Datatype {
public:
    int num=0;
    char* name;
};
extern unordered_map<string, unordered_map<string, SymTabEnt >> symtab;
int spaceCounter=0, tabCounter=0, newline=0, ind=0, ded=0;
stack<int> stk;
queue<int> qu,qu2;
extern int ind_lvl, curr_ind;
extern vector<int>scope;
%}


%option noyywrap
%option yylineno

%%
 {
     while(!qu.empty()){
         if(qu.front()==1){
            qu.pop();
            curr_ind++;
            return INDENT;}
          if(qu.front()==2){
            ind_lvl = qu2.size();
            while(!qu2.empty()){
                curr_ind--;
                qu2.pop();
            }
            qu.pop();
            return DEDENT;}
        
    }
 }
\n([ ][ ])* { //line jinong to be considered
    int count =0;
    string str = yytext;
    qu.push(0);
    for(int i=1; i<str.length(); i+=2){
        if(str[i] == ' ' and str[i+1]==' ')
            count++;

    }
    if(stk.empty()){
        stk.push(0);
    }
    if(stk.top( ) < count){
        stk.push(count);
        qu.push(1);
    }
    else if(stk.top() > count){
        while(!stk.empty() and stk.top() != count){
            stk.pop();
            qu2.push(3);
        }
           qu.push(2);
    }
    if(qu.front()==0){
            qu.pop();
            return NEWLINE;
        }
}
print {
    return PRINT;
}
int|float|str|bool {
    
    char* a = new char[strlen(yytext) + 1];
    strcpy(a, yytext);
    yylval.name = a;
    return VARIABLETYPE;
}
if {
    return If;
}
in {
    return in;
}
[\:] {
    return ':';
}
elif {
    return elif;
}
else  {
    return Else;
}
while {
    return While;
}
for {
    return For;
}
def {
    return def;
}

[\(] {return '(';}
[\)] {return ')';}
[\[] {return '[';}
[\]] {return ']';}
class {
    return CLASS;
}

return {
    return Return;
}

True {
    yylval.bool_var=true;
    return True;
}

False {
    yylval.bool_var=false;
    return False;
}

None {
    return None;
}
[\#].* {}
from {
    return from;
}
[\-][\>] {
    return arrow;
}

break {
    return Break;
}
global {
    return global;
}
nonlocal {
    return nonlocal;
}
continue {
    return Continue;
}
as {
    return as;
}

[0-9]+ {
    yylval.num=atoi(yytext);
    return NUMBER;
}

[;] {
    return ';' ;
}

[,] {
    return ',' ;
}

[\+] {
    return PLUS;
}
[\~] {
    return NEG;
}
[\-] {
    return MINUS;
}

[\*] {
    return MULTIPLY;
}

[\/] {
    return DIVIDE;
}

[\/][\/] {
    return FLOORDIV;
}

[\%] {
    return MODULO;
}

[\*][\*] {
    return EXPONENT;
}

[\=][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return EQUALITY;
}

[\!][\=] {
    return NOTEQUAL; 
}

[\>] {
    return GREATERTHAN;
}

[\<] {
    return LESSTHAN;
}

[\>][\=] {
    return GTEQUAL;
}

[\<][\=] {
    return LSEQUAL;
}
[\=] {
    return '=';
}
[\.] {
    return singleDot;
}
[\.][\.][\.] {
    return tripleDot;
}
and {
    return AND;
}

or {
    return OR;
}

not {
    return NOT;
}

[\&] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return BITAND;
}

[\^] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return BITXOR;
} 

[\<][\<] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return LEFTSHIFT;
}

[\>][\>] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return RIGHTSHIFT;
}
[\+][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return INPLACEADD;
}

[\-][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return INPLACESUB;
}

[\*][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return INPLACEMULT;
}

[\/][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return INPLACEDIV;
}

[\%][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return INPLACEMOD;
}

[\*][\*][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return INPLACEEXPO;
}

[\&][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return INPLACEBITAND;
}

[\|][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return INPLACEBITOR;
}

[\^][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return INPLACEBITXOR;
}

[\<][\<][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return INPLACELEFTSHIFT;
}

[\>][\>][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return INPLACERIGHTSHIFT;
}

[\/][\/][\=] {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    return INPLACEFLOORDIV;
}

match {
    return match;
}

case {
    return Case;
}

type {
    return Type;
}
[\|] {
    return BITOR;

}
[\_] {
    return '_';
} 
(r|u|R|U|f|F|fr|Fr|fR|FR|rf|rF|Rf|RF)((\'([^\n\\\'\\]|\\.)*\')|(\"([^\n\\\"\\]|\\.)*\"))|(''''([^\n]|\\'|\\)*'''|\"\"\"\"([^\n]|\\\"|\\)*\"\"\") {
    return STRINGLITERAL;
}

(b|B|br|Br|bR|BR|rb|rB|Rb|RB)((\'([^\n\\\'\\]|\\.)*\')|(\"([^\n\\\"\\]|\\.)*\"))|(''''([^\n]|\\'|\\)*'''|\"\"\"\"([^\n]|\\\"|\\)*\"\"\") {
    return BYTESLITERAL;
}

(0[bB]([01](_?[01])*)+|0[oO]([0-7](_?[0-7])*)+|0[xX]([0-9a-fA-F](_?[0-9a-fA-F])*)+|[1-9](_?[0-9])*) {
    return NUMERICALLITERAL;
}

((([0-9](_?[0-9])*\.[0-9](_?[0-9])*)|(\.[0-9](_?[0-9])+))([eE][-+]?[0-9](_?[0-9])*)?)|(([0-9](_?[0-9])*|[0-9](_?[0-9])*\.)[eE][-+]?[0-9](_?[0-9])*) {
    yylval.float_var = stof(yytext);
    return FLOATLITERAL;
}

((([0-9](_?[0-9])*\.[0-9](_?[0-9])*)|(\.[0-9](_?[0-9])+)|([0-9](_?[0-9])*|[0-9](_?[0-9])*\.))[jJ]) {
    return IMAGINARYLITERAL;
}

except|finally|for|global|import|in|is|lambda|nonlocal|not|pass|raise|return|try|while|with { 
    return KEYWORD;    
}

[a-zA-Z_][a-zA-Z_0-9]* {
    char* a = new char[strlen(yytext) +1];
    strcpy(a, yytext);
    yylval.name = a;
    curr_identifier=yytext;
    return IDENTIFIER;
}

\"([^\"\\]|\\.)*\"|\'([^\'\\]|\\.)*\' {
    char* a = new char[strlen(yytext) + 1];
    strcpy(a, yytext);
    yylval.name = a;
    return STRING;
}

. {
   
}
%%
