%{
#include <bits/stdc++.h>
#include<typeinfo>
using std::cerr;
using std::endl;
#include <fstream>
using std::ofstream;
#include <cstdlib>
using namespace std;
void yyerror(const char *s);
int yylex(void);
extern FILE* yyin;
extern int yylineno;
extern char* yytext;
ofstream myfile,fout; 
class activations{
    int num_of_actualparams;
    int addr_of_actual_params;
    int addr_of_saved_regs;
    int addr_of_locals;
};
vector<activations*> display;
int numt = 0, numl = 0;
stack<int> trul;
int flagr=0;
string retn;
int ind_lvl, curr_ind=0;
int noden=0,input=0,output=0,verbose=0;
string curr_identifier,curr_identifier2; //used to know the curreent class in a method call
int f2=0,flag=0,a=0,c=0; 
int global_type = 0;
int global_list_type = 0;
//a=class or function number eg 1,2,3,
//c = increases second levl scope eg 1.1,1.2,1.3
//flag -> we are inside class
// f2-> we are inside function  
class SymTabEnt {
    public:
    int line_no;
    int val;
    string name;
    float varf;
    bool varb;
    string syntactic_category;
    string type;
    string file_name;
    int size,offset;
    string return_type;
    string func_element_scope;
    vector<pair<string,string>>params_type;
    int number_of_parameters;
    string parent_class;
    bool isClass=false;
};
unordered_map<string, unordered_map<string, SymTabEnt >> symtab;
vector<pair<string,string>>params_type,params_type2;
vector<int> scope(10,0);
int lvl = 0;
class Datatype {
public:
    int type=0;  //1->int, 2->float,3->bool,4->string
    int num=0;
    string name;
    float varf;
    bool varb;
    string var_type_func;
    string addr, tru, fal;
    int func_type;
};
string get_scope(){
 string scopes="";
    if(flag==1){
            scopes+=to_string(a);
        if(f2==1){
            scopes+=".";
            scopes+=to_string(c);
        }
    }
    else if(f2==1){
        scopes+=to_string(a);
    }
    else
        scopes = "0";
    return scopes;
}
bool inside_function=false;string func_name="";
unordered_map<string,int>variable_to_number;
unordered_map<int,string>number_to_variable;
int get_type(string name){
    
    string scopes=get_scope();
     //Checking if element is in current scope
     while(scopes!=""){
        if(symtab[scopes].find(name)!=symtab[scopes].end()){
            if(symtab[scopes][name].type=="")return variable_to_number[symtab[scopes][name].return_type]; 
                return variable_to_number[symtab[scopes][name].type];  
            }
        scopes.pop_back();
        while(!scopes.empty() and scopes[scopes.size()-1]!='.')scopes.pop_back();
        }

     if( symtab["0"].find(name)!=symtab["0"].end()){
            return variable_to_number[symtab["0"][name].type];
        }else{
                string error_msg = "Undeclared variable ";
                error_msg += name;
                yyerror(error_msg.c_str());
                  
        }
     return -1;
}
void create_var_entry(char* name, string type,class Datatype* node,string syntactic_category){
    string scopes=get_scope();
    cout<<"type "<<type<<" "<<variable_to_number[type]<<endl;
    unordered_map<string, SymTabEnt >curr_sym=symtab[scopes];
    if(curr_sym.find(name)!=curr_sym.end()){
         yyerror("Redeclaration of variable ");
    }
    else{
    symtab[scopes][name].line_no=yylineno-1;
    symtab[scopes][name].syntactic_category=syntactic_category;
    symtab[scopes][name].type=type;
    int type1=node->type;
    cout<<"type1 "<<type1<<endl;
    if(type1==6){
        cout<<node->name<<" "<<type<<endl;
        if(node->name!=type){
            // yyerror("Wrong Constructor ");
        }
        return;
    }
    if(type1==5)type1=get_type(node->name);
    if(type1 == 1){
        if(variable_to_number[type]!=1 && variable_to_number[type]!=2 && variable_to_number[type]!=3){
            yyerror("Cannot assign value of different datatype1");
        }
    }
    else if(type1 == 2){
        if(variable_to_number[type]!=1 && variable_to_number[type]!=2){
            yyerror("Cannot assign value of different datatype2");
        }
    }
    else if(type1 == 3){
        if(variable_to_number[type]!=1 && variable_to_number[type]!=3){
            yyerror("Cannot assign value of different datatype3");
        }
    }
    switch (type1) {
    case 1:
        symtab[scopes][name].val=node->num;
        break;
    case 2:
            symtab[scopes][name].varf=node->varf;
        break;
    case 3:
            symtab[scopes][name].varb=node->varb;
        break;
    case 4:
        symtab[scopes][name].name=node->name;
        break;
    case 7: // case 7 is for list
        break;
    default:
        yyerror("Unsupported type1 ");
        break;
    }                 
    }
}
void create_func_entry(string name, string return_type,int element_scope,string syntactic_category, vector<pair<string,string>>params_type){
    
    string scopes=flag==0?"0":to_string(a);
    unordered_map<string, SymTabEnt >curr_sym=symtab[scopes];
    if(curr_sym.find(name)!=curr_sym.end()){
         yyerror("Redeclaration of function or name already used");
    }
    else{
    symtab[scopes][name].line_no=yylineno-1;
    symtab[scopes][name].syntactic_category=syntactic_category;
    symtab[scopes][name].return_type=return_type;
    if(flag)symtab[scopes][name].func_element_scope=to_string(a)+"."+to_string(element_scope);
    else symtab[scopes][name].func_element_scope=to_string(a);
    symtab[scopes][name].params_type=params_type;
    symtab[scopes][name].number_of_parameters=params_type.size();
    }
}

void create_class_entry(string name,string syntactic_category, string parent_class, int element_scope){
    
    string scopes="0";
    unordered_map<string, SymTabEnt >curr_sym=symtab[scopes];
    if(curr_sym.find(name)!=curr_sym.end()){
         yyerror("Redeclaration of class or name already used");
    }
    else{
    symtab[scopes][name].line_no=yylineno-1;
    symtab[scopes][name].syntactic_category=syntactic_category;
    symtab[scopes][name].parent_class=parent_class;
    symtab[scopes][name].func_element_scope=to_string(a);
    }
}

// Add value according to their type and check for typecasting between int<->bool and int<->float
void update_val(char* name, class Datatype* node){
    string scopes=get_scope();
    bool updated=false;
     //Checking if element is in current scope
     while(scopes!=""){
        if(symtab[scopes].find(name)!=symtab[scopes].end()){
            updated=true;
            cout<<"In update val function: ";
            cout<<node->type<<endl;
            if(node->type== variable_to_number[symtab[scopes][name].type]){
                 switch (node->type) {
                    case 1:
                        symtab[scopes][name].val=node->num;
                        break;
                    case 2:
                         symtab[scopes][name].varf=node->varf;
                        break;
                    case 3:
                         symtab[scopes][name].varb=node->varb;
                        break;
                    case 4:
                        symtab[scopes][name].name=node->name;
                        break;
                    default:
                        yyerror("Unsupported type2 ");
                        break;
                    }                 
            }else{
                 yyerror("Type mismatch  ");
            }
                break;
        }
        scopes.pop_back();
        while(!scopes.empty() and scopes[scopes.size()-1]!='.')scopes.pop_back();
     }
     if(!updated){
     if( symtab["0"].find(name)!=symtab["0"].end()){
        // symtab["0"][name].val=num;
         cout<<"In update val function: ";
        cout<<node->type<<endl;
         if(node->type== variable_to_number[symtab["0"][name].type]){
                 switch (node->type) {
                    case 1:
                        symtab["0"][name].val=node->num;
                        break;
                    case 2:
                         symtab["0"][name].varf=node->varf;
                        break;
                    case 3:
                         symtab["0"][name].varb=node->varb;
                        break;
                    case 4:
                        symtab["0"][name].name=node->name;
                        break;
                    default:
                        yyerror("Unsupported type3 ");
                        break;
                    }                 
            }else{
                 yyerror("Type mismatch  ");
            }
     }else{
        cout<<"Variable is not declared or out of scope"<<endl;
     }}
}

     
%}

%union {
    int num;
    char* name;
    bool bool_var;
    float float_var;
    class Datatype* node;
}

%token<num> NUMBER;
%token<node> If
%token<node> ':' ';' ')' '(' Return '=' tripleDot '|' '-' '_'
%token<node> elif Else arrow global nonlocal match Case Raise
%token<node> While Type singleDot
%token<node> For as
%token<node> def
%token<bool_var> True False
%token<node> from
%token<node> None in 
%token<float_var>FLOATLITERAL
%token<node> NEWLINE KEYWORD  STRINGLITERAL IMAGINARYLITERAL  NUMERICALLITERAL BYTESLITERAL INDENT DEDENT PRINT 
%token<node> PLUS MINUS MULTIPLY DIVIDE FLOORDIV MODULO EXPONENT EQUALITY NOTEQUAL GREATERTHAN LESSTHAN GTEQUAL LSEQUAL AND OR NOT ;
%token<node> CLASS Break Continue  
%token<name> IDENTIFIER STRING VARIABLETYPE COMMENT INPLACEADD INPLACESUB INPLACEMULT INPLACEDIV INPLACEMOD INPLACEEXPO INPLACEBITAND INPLACEBITOR INPLACEBITXOR INPLACELEFTSHIFT INPLACERIGHTSHIFT INPLACEFLOORDIV BITAND, BITOR,BITXOR, NEG,LEFTSHIFT, RIGHTSHIFT;
%type<node> statements class_pattern closed_pattern t_primary or_pattern pattern_capture_target case_block params patterns subject_expr maystarpat slices single_target input statement atom primary await_primary simple_stmts simple_stmt compound_stmt expression disjunction conjunction inversion comparison
%type<node> assignment as_id_nt as_pattern sing_nt p_tem keyword_patterns keyword_pattern k_tem positional_patterns star_nt id_nt type_alias star_expressions return_stmt raise_stmt global_stmt nonlocal_stmt print_statement function_def class_def for_stmt while_stmt match_stmt 
%type<node> comparison_par type_params_opt star_targets par_atom augassign star_expression pattern star_pattern wildcard_pattern maybe_sequence_pattern maybe_star_pattern Id_comma open_sequence_pattern guard case_block_plus star_tar_equals function_name function_return single_subscript_attribute_target  variablename col_var_nt list star_named_expressions star_named_expression key_tem key_value_pattern literal_expr type_param_bound assignment_expression sequence_pattern mapping_pattern double_star_pattern items_pattern type_param named_expression dedent_nt if_stmt block arithematic shift_expr term factor power compare_op_bitwise_or_pair gt_bitwise_or bitwise_and bitwise_or bitwise_xor
%type<node> capture_pattern value_pattern group_pattern attr name_or_attr literal_pattern signed_number complex_number signed_real_number real_number imaginary_number arguments elif_stmt else_block elifnt elsenonter tem star_targets_list_seq tem2 star_targets_tuple_seq tem3 star_target target_with_star_atom star_atom t_lookahead print_par method_call method function_call arguments_opt type_param_seq var_nt genexp slice_pieces slice starred_expression listcomp for_if_clause for_if_clauses if_disjuction group eq_bitwise_or noteq_bitwise_or lt_bitwise_or lte_bitwise_or gte_bitwise_or 
%%
input: statements {cout << "#R1" <<endl;}| {cout << "#R3" <<endl;}
statements: statement statements {cout << "#R3.2" <<endl;} | {cout << "#R3.3" <<endl;}
statement: simple_stmts {cout << "#R4" <<endl;noden++;} |  compound_stmt {cout << "#R5" <<endl;} 
simple_stmts: simple_stmt NEWLINE {cout<<"R6"<<endl;} | simple_stmt ';' simple_stmts {cout << "#R11" <<endl;} | NEWLINE {cout << "#R12" <<endl;} | ';' NEWLINE {cout << "#R13" <<endl;} | {cout << "#R13.1" <<endl;} | COMMENT {cout << "#R13.2" <<endl;}
simple_stmt: assignment {cout << "#R14" <<endl;}
    | type_alias {cout << "#R15" <<endl;}
    | star_expressions {
        cout << "#R16" <<endl;
        cout<<"IN SIMPLE STMT: "<<$1->type<<" : "<<$1->func_type<<endl;
        if($1->type == 6){
            myfile<<"    "<<"call "<<$1->addr<<endl;
        }
    }
    | return_stmt {cout << "#R17" <<endl;}
    | raise_stmt {cout << "#R18" <<endl;}
    | Break {cout << "#R22" <<endl;}
    | Continue {cout << "#R23" <<endl;}
    | global_stmt {cout << "#R24" <<endl;}
    | nonlocal_stmt {cout << "#R25" <<endl;}
    |print_statement {cout<<"#R25.2"<<endl;}
compound_stmt:
     function_def {cout << "#R26" <<endl;f2=0;if(curr_ind==0 && flag==1){flag=0;c=0;}}
    | if_stmt {cout << "#R27" <<endl;if(curr_ind==0 && flag==1){flag=0;c=0;f2=0;}}
    | class_def {cout << "#R28" <<endl;flag=0;c=0;f2=0;}
    | for_stmt {cout << "#R29" <<endl;if(curr_ind==0 && flag==1){flag=0;c=0;f2=0;}}
    | while_stmt {cout << "#R30" <<endl;if(curr_ind==0 && flag==1){flag=0;c=0;f2=0;}}
    | match_stmt {cout << "#R31" <<endl;if(curr_ind==0 && flag==1){flag=0;c=0;f2=0;}}

     
return_stmt:
     Return {flagr=1;} star_expressions {cout << "#R51" <<endl;myfile<<"    return ";
     string name=retn;
        if(inside_function ){
            for(auto i:params_type2){
                if(i.first==name and symtab["0"].find(name)!=symtab["0"].end()){
                    name+="_func_";name+=func_name;
                    break;
                }
            }
        }
     myfile<<name<<endl;
     } | Return {cout << "#R52" <<endl;myfile<<"    return"<<endl;}

star_expressions: {cout << "#R52.1" <<endl;}
    | star_expression {cout << "#R53" <<endl;$$=$1;}
    | star_expression ',' star_expressions {cout << "#R55" <<endl;}
    | star_expression ',' {cout << "#R56" <<endl;}

star_expression: {cout << "#R56.1" <<endl;}
    | '*' bitwise_or {cout << "#R57" <<endl;}
    | expression star_nt {cout << "#R58" <<endl;$$=$1;}

star_nt: {cout << "#R58.1" <<endl;} | augassign star_expressions {cout<<"#R58.3"<<endl;}

assignment: {cout << "#R58.2" <<endl;}
    | IDENTIFIER ':' expression {global_type = variable_to_number[$3->name];} as_id_nt {
        cout << "#R59" <<endl;
        cout<< "IN ASSIGNMENT: "<<global_type <<" : "<<$5->func_type<<" : "<<$5->type<<endl; 
        if($5->type == 6){
            if($5->name == "len")$5->func_type=1;
            if(variable_to_number[$3->name] != $5->func_type){
                yyerror("Function return type does not match variable");
            }
        }
        create_var_entry($1,$3->name,$5,"Identifier");
        string name=$1;
        if(inside_function and symtab["0"].find(name)!=symtab["0"].end()){
            name+="_func_";name+=func_name;
        }
        if($5->type == 6){
            myfile<<"    "<<name<<" = call "<<$5->addr<<endl;
        }
        else{           
            string str = $5->addr;
            if(str.find("&")!= string::npos){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$5->addr<<endl;
                myfile<<"    "<<$1<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if(str.find("^")!= string::npos){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$5->addr<<endl;
                myfile<<"    "<<$1<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if(str.find("|")!= string::npos){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$5->addr<<endl;
                myfile<<"    "<<$1<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if(str.find("~")!= string::npos){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$5->addr<<endl;
                myfile<<"    "<<$1<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if(str.find("<<")!= string::npos){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$5->addr<<endl;
                myfile<<"    "<<$1<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if(str.find(">>")!= string::npos){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$5->addr<<endl;
                myfile<<"    "<<$1<<" = "<<"t"+to_string(numt)<<endl;
            }
            else{
                myfile<<"    "<<name<<" = "<<$5->addr<<endl;
            }
            
            
        }
        }
    | '(' single_target ')' ':' expression '=' star_expressions {cout << "#R64" <<endl;}
    | single_subscript_attribute_target ':' expression '=' star_expressions {cout << "#R67" <<endl;}
    | '(' single_target ')' ':' expression {cout << "#R69" <<endl;}
    | single_subscript_attribute_target ':' expression {cout << "#R71" <<endl;}
    | star_tar_equals star_expressions {cout << "#R75" <<endl;}
    | single_target augassign {if($1->type == 5){global_type=get_type($1->name);}else{global_type = $1->type;}} star_expressions {
        cout<<"R77.2"<<endl;
        int type1=$1->type,type2=$4->type;
        cout<<"INSIDE ASSIGN1: "<<type1<<" "<<type2<<endl;
        if(type1==5)type1=get_type($1->name);
        if(type2==5)type2=get_type($4->name);
        if(type2==6){
            if($4->name == "len"){
                type2=1;
            }
            else{
                type2=$4->func_type;
            }
        }
        cout <<"GLOBAL: "<< global_type <<endl;
        cout<<"INSIDE ASSIGN2: "<<type1<<" "<<type2<<endl;
        if(type1!=type2){yyerror("Type mismatch in assignment");}
        // update_val($1->name,$4);
        string name=$1->addr;
        if(inside_function ){
            for(auto i:params_type2){
                if(i.first==$1->addr and symtab["0"].find($1->addr)!=symtab["0"].end()){
                    name+="_func_";name+=func_name;
                    break;
                }
            }
        }
        if($4->type == 6){
            myfile<<"    "<<name<<" = call "<<$4->addr<<endl;
        }
        else{
            if($2->name == "+="){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" + "<<$4->addr<<endl;
                myfile<<"    "<<$1->addr<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if($2->name == "-="){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" - "<<$4->addr<<endl;
                myfile<<"    "<<$1->addr<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if($2->name == "*="){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" * "<<$4->addr<<endl;
                myfile<<"    "<<$1->addr<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if($2->name == "/="){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" / "<<$4->addr<<endl;
                myfile<<"    "<<$1->addr<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if($2->name == "%="){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" % "<<$4->addr<<endl;
                myfile<<"    "<<$1->addr<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if($2->name == "**="){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" ** "<<$4->addr<<endl;
                myfile<<"    "<<$1->addr<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if($2->name == "&="){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" & "<<$4->addr<<endl;
                myfile<<"    "<<$1->addr<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if($2->name == "|="){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" | "<<$4->addr<<endl;
                myfile<<"    "<<$1->addr<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if($2->name == "^="){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" ^ "<<$4->addr<<endl;
                myfile<<"    "<<$1->addr<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if($2->name == "<<="){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" << "<<$4->addr<<endl;
                myfile<<"    "<<$1->addr<<" = "<<"t"+to_string(numt)<<endl;
            }
            else if($2->name == ">>="){
                myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" >> "<<$4->addr<<endl;
                myfile<<"    "<<$1->addr<<" = "<<"t"+to_string(numt)<<endl;
            }
            else{
                myfile<<"    "<<name<<" = "<<$4->addr<<endl;
            }
        }
        }

as_id_nt: '=' star_expressions {cout << "#R61"<<endl;$$=$2;} | {cout << "#R61.1" <<endl;}


single_target: {cout << "#R61.2" <<endl;}
    | single_subscript_attribute_target {cout << "#R84" <<endl;}
    | IDENTIFIER sing_nt  {cout<<"#R85.2"<<endl;if($2==nullptr){$$=new Datatype(); $$->name= $1;$$->type=5;}else $$=$2;$$->addr=$1;;}
    | '(' single_target ')' {cout << "#R86" <<endl;}

sing_nt: {cout << "#R61.2" <<endl;$$=nullptr;} 
        | id_nt {cout << "#R62" <<endl;$$=$1;}

single_subscript_attribute_target: {cout << "#R86.1" <<endl;}
    | t_primary '.' IDENTIFIER  {cout << "#R87" <<endl;}
    | t_primary '[' slices ']' {cout << "#R89" <<endl;} 

type_alias: {cout << "#R89.1" <<endl;}
    | Type IDENTIFIER type_params_opt '=' expression {cout << "#R91" <<endl;}
    | Type IDENTIFIER '=' expression {cout << "#R92" <<endl;}

raise_stmt: {cout << "#R92.1" <<endl;}
    | Raise expression from expression {cout << "#R95" <<endl;}
    | Raise expression {cout << "#R96" <<endl;}
    | Raise {cout << "#R97" <<endl;}

star_tar_equals: star_targets '=' star_tar_equals {cout << "#R99" <<endl;}
    | {cout << "#R99.1" <<endl;}


function_def:
     def function_name {if(flag==1){c++;f2=1;}else{a++;f2=1;} myfile<<$2->name<<":"<<endl; inside_function=true;func_name=$2->name;} type_params_opt '('  params ')' function_return {
        string return_type="";
       for(auto i:params_type){
            myfile<<"    "<<"param "<<i.first;
            if(symtab["0"].find(i.first)!=symtab["0"].end())myfile<<"func"<<$2->name;
            myfile<<endl;
        }
        if($8)return_type=$8->name;
        create_func_entry($2->name,return_type,c,"Function",params_type);
        for(auto pr:params_type){
            string func_scopes=flag==0?"0":to_string(a);
            string scopes_local=symtab[func_scopes][$2->name].func_element_scope;
            symtab[scopes_local][pr.first].type=pr.second;
        }
        params_type2=params_type;
        params_type.clear();
     } ':' block {cout << "#R103" <<endl; inside_function=false;} 

function_return: arrow var_nt {cout << "#R103.1" <<endl;$$=$2; cout<<"in function return "<<$2->name<<endl;} | {cout << "#R103.2" <<endl;$$=nullptr;}

function_name: IDENTIFIER {cout << "#R104" <<endl;$$=new Datatype();$$->name=$1;}

par_atom: variablename {cout << "#R104.1" <<endl;} 
        |True {cout<<"#R104.2"<<endl; params_type.push_back({"True","bool"});}
        |False  {params_type.push_back({"False","bool"});}
        |NUMBER {cout<<"PARATOM NUMBER"<<endl;params_type.push_back({to_string($1),"int"});}
        |None   {params_type.push_back({"None","none"});}
        |STRING  {params_type.push_back({$1,"str"});}
        |FLOATLITERAL {params_type.push_back({to_string($1),"float"});}
        |arithematic {cout<<"#IN PARATOM ARITH"<<endl ;params_type.push_back({($1->addr),number_to_variable[$1->type]});}


params: par_atom {cout << "#R105" <<endl;} | par_atom ',' params {cout << "#R107" <<endl;} | {cout << "#R108" <<endl;$$=nullptr;}

expression:
     disjunction If disjunction Else expression {cout << "#R115" <<endl;}
    | disjunction {cout << "#R116" <<endl;$$=$1;}

disjunction:
     conjunction OR disjunction {cout << "#R118" <<endl;$$->addr = $1->addr + " or " + $3->addr;}
    | conjunction {cout << "#R119" <<endl;$$=$1;}

conjunction:
     inversion AND conjunction {cout << "#R121" <<endl;$$->addr = $1->addr + " and " + $3->addr;}
    | inversion {cout << "#R122" <<endl;$$=$1;}

inversion:
     NOT inversion {cout << "#R123" <<endl;$$=new Datatype();$$->addr = " not " + $2->addr;}
    | comparison {cout << "#R124" <<endl;$$=$1;}

global_stmt: global Id_comma {cout << "#R125" <<endl;}
nonlocal_stmt: nonlocal Id_comma {cout << "#R126" <<endl;}
Id_comma: IDENTIFIER {cout << "#R127" <<endl;} | IDENTIFIER ',' Id_comma {cout << "#R128" <<endl;} | IDENTIFIER ',' {cout << "#R129" <<endl;}

match_stmt: {cout << "#R129.1" <<endl;}
    | match subject_expr ':' NEWLINE INDENT case_block_plus DEDENT {cout << "#R131" <<endl;} 

subject_expr: {cout << "#R131.1" <<endl;}
    | star_named_expression ',' star_named_expressions {cout << "#R132" <<endl;}
    | named_expression {cout << "#R133" <<endl;}
    |star_named_expression ',' {cout << "#R134" <<endl;}

case_block_plus: case_block case_block_plus {cout << "#R136" <<endl;} | {cout << "#R137" <<endl;}

case_block: {cout << "#R137.1" <<endl;}
    | Case patterns ':' block {cout << "#R139" <<endl;}
    | Case patterns guard ':' block {cout << "#R141" <<endl;}

guard: If named_expression {cout << "#R142" <<endl;}

patterns: {cout << "#R142.1" <<endl;}
    | open_sequence_pattern {cout << "#R143" <<endl;}
    | pattern {cout << "#R144" <<endl;}

open_sequence_pattern: {cout << "#R144.1" <<endl;}
    | maybe_star_pattern ',' maybe_sequence_pattern {cout << "#R146" <<endl;}
    | maybe_star_pattern ',' {cout << "#R147" <<endl;}

maybe_star_pattern: {cout << "#R147.1" <<endl;}
    | star_pattern {cout << "#R148" <<endl;}
    | pattern {cout << "#R149" <<endl;}

maybe_sequence_pattern: {cout << "#R149.1" <<endl;}
    | maystarpat ',' {cout << "#R150" <<endl;}
    | maystarpat {cout << "#R151" <<endl;}

maystarpat: {cout << "#R151.1" <<endl;}
    | maybe_star_pattern {cout << "#R152" <<endl;}
    | maybe_star_pattern ',' {cout << "#R153" <<endl;}
    | maybe_star_pattern ',' maystarpat {cout << "#R155" <<endl;}
        

star_pattern: {cout << "#R155.1" <<endl;}
    | '*' pattern_capture_target {cout << "#R156" <<endl;}
    | '*' wildcard_pattern {cout << "#R157" <<endl;}

wildcard_pattern: {cout << "#R157.1" <<endl;}
    | '_'  {cout << "#R158" <<endl;}

pattern: 
    | as_pattern {cout << "#R159" <<endl;}
    | or_pattern {cout << "#R160" <<endl;}

as_pattern: 
    | or_pattern as pattern_capture_target {cout << "#R162" <<endl;}

pattern_capture_target: 
    | IDENTIFIER {cout << "#R163" <<endl;}

or_pattern: 
    | closed_pattern '|' {cout << "#R164" <<endl;} | closed_pattern '|' closed_pattern {cout << "#R166" <<endl;}  | closed_pattern {cout << "#R167" <<endl;}

closed_pattern: 
    | literal_pattern {cout << "#R168" <<endl;}
    | capture_pattern {cout << "#R169" <<endl;}
    | wildcard_pattern {cout << "#R170" <<endl;}
    | value_pattern {cout << "#R171" <<endl;}
    | group_pattern {cout << "#R172" <<endl;}
    | sequence_pattern {cout << "#R173" <<endl;}
    | mapping_pattern {cout << "#R174" <<endl;}
    | class_pattern {cout << "#R175" <<endl;}

class_pattern: 
    | name_or_attr '(' ')' {cout << "#R176" <<endl;}
    | name_or_attr '(' positional_patterns ',' ')' {cout << "#R178" <<endl;}
    | name_or_attr '(' positional_patterns  ')' {cout << "#R180" <<endl;}
    | name_or_attr '(' keyword_patterns ',' ')' {cout << "#R182" <<endl;}
    | name_or_attr '(' keyword_patterns  ')' {cout << "#R184" <<endl;}
    | name_or_attr '(' positional_patterns ',' keyword_patterns ',' ')' {cout << "#R186" <<endl;}
    | name_or_attr '(' positional_patterns ',' keyword_patterns  ')' {cout << "#R189" <<endl;}

positional_patterns: 
    | pattern {cout<<"#A1"<<endl; }
    | pattern  p_tem {cout<<"#A3"<<endl;}

p_tem: 
    | ',' pattern p_tem {cout<<"#A5"<<endl;}
    | ',' pattern {cout<<"#A6"<<endl;}

keyword_patterns: 
    | keyword_pattern {cout<<"#A7"<<endl;}
    | keyword_pattern  k_tem {cout<<"#A9"<<endl;}

k_tem: 
    | ',' keyword_pattern k_tem {cout<<"#A11"<<endl;}
    | ',' keyword_pattern {cout<<"#A12"<<endl;}

keyword_pattern: 
    | IDENTIFIER '=' pattern {cout<<"#A13"<<endl;}

sequence_pattern: 
    | '[' maybe_sequence_pattern ']'  {cout<<"#A14"<<endl;}
    | '[' ']' {cout<<"#A15"<<endl;}
    | '(' open_sequence_pattern ')'  {cout<<"#A16"<<endl;}
    | '(' ')' {cout<<"#A17"<<endl;}

mapping_pattern: 
    | '{' '}'   {cout<<"#A18"<<endl;}
    | '{' double_star_pattern ',' '}'  {cout<<"#A19"<<endl;}
    | '{' double_star_pattern  '}'  {cout<<"#A20"<<endl;}
    | '{' items_pattern  ',' double_star_pattern ',' '}'  {cout<<"#A22"<<endl;}
    | '{' items_pattern ',' double_star_pattern  '}'  {cout<<"#A24"<<endl;}
    | '{' items_pattern ',' '}' {cout<<"#A25"<<endl;}
    | '{' items_pattern  '}' {cout<<"#A26"<<endl;}

double_star_pattern: 
    | EXPONENT pattern_capture_target {cout<<"#A27"<<endl;}


items_pattern: 
    | key_value_pattern   {cout<<"#A28"<<endl;}
    | key_value_pattern key_tem {cout<<"#A30"<<endl;}
key_tem: 
    | ',' key_value_pattern key_tem {cout<<"#A32"<<endl;}
    | ','key_value_pattern {cout<<"#A33"<<endl;}

key_value_pattern: 
    |  attr  ':' pattern  {cout<<"#A35"<<endl;}
    | literal_expr ':' pattern  {cout<<"#A37"<<endl;}

literal_expr: 
    | signed_number {cout<<"#A38"<<endl;}
    | complex_number {cout<<"#A39"<<endl;}
    | STRING {cout<<"#A40"<<endl;}
    | None  {cout<<"#A41"<<endl;}
    | True {cout<<"#A42"<<endl;}
    | False {cout<<"#A43"<<endl;}

capture_pattern: 
    | pattern_capture_target {cout<<"#A44"<<endl;}

value_pattern:
    | attr  {cout<<"#A45"<<endl;}

group_pattern: 
    | '(' pattern ')' {cout<<"#A46"<<endl;}

attr: 
    | name_or_attr '.' IDENTIFIER {cout<<"#A47"<<endl;}

name_or_attr: 
    | attr {cout<<"#A48"<<endl;}
    | IDENTIFIER 

literal_pattern: 
    | signed_number  {cout<<"#A49"<<endl;}
    | complex_number {cout<<"#A50"<<endl;}
    | STRING {cout<<"#A51"<<endl;}
    | None {cout<<"#A52"<<endl;}
    | True {cout<<"#A53"<<endl;}
    | False {cout<<"#A54"<<endl;}

signed_number: 
    | NUMBER  {cout<<"#A55"<<endl;}
    | '-' NUMBER  {cout<<"#A56"<<endl;}

complex_number: 
    | signed_real_number  '+' imaginary_number {cout<<"#A58"<<endl;}
    | signed_real_number  '-' imaginary_number {cout<<"#A60"<<endl;}

signed_real_number: 
    | real_number {cout<<"#A61"<<endl;}
    | '-' real_number {cout<<"#A62"<<endl;}

real_number: 
    | NUMBER {cout<<"#A63"<<endl;}

imaginary_number: 
    | NUMBER {cout<<"#A64"<<endl;}


comparison:
    | bitwise_or comparison_par {
        cout<<"#A65.2"<<endl;
        $$=$1;
        cout<<"COMAPARAND: "<<$1->addr<<endl;
        if($1!=nullptr and $2!=nullptr){
            $$->addr = $1->addr + $2->addr;
            cout<<"COMPARISONNNNN: "<<$1->addr<<" : "<<$2->addr<<" : "<<$$->addr<<endl;
        }
        if($2!=nullptr){$$->type=3;}
        
        }

comparison_par : compare_op_bitwise_or_pair {cout<<"#A66"<<endl;$$=$1;}
    |  {cout<<"#A67"<<endl;$$=nullptr;}

arguments: starred_expression {cout<<"#A78"<<endl;}
        | assignment_expression {cout<<"#A79"<<endl;}
        | expression {cout<<"#A80"<<endl;}  

if_stmt: 
    | If named_expression ':' {myfile<<"if "<<$2->addr<<" goto: "<<$2->tru<<endl<<"goto: "<<$2->fal<<endl<<$2->tru<<":"<<endl;} block{myfile<<$2->fal<<":"<<endl;} elifnt {cout<<"#A96.1"<<endl;}

elif_stmt: 
    elif named_expression{myfile<<"if "<<$2->addr<<" goto: "<<$2->tru<<endl<<"goto: "<<$2->fal<<endl<<$2->tru<<":"<<endl;} ':' block{myfile<<$2->fal<<":"<<endl;} elifnt {cout<<"#A102.1"<<endl;}

else_block:|
    Else ':' block {cout<<"#A105"<<endl;}

elifnt: elif_stmt {cout<<"#A105.1"<<endl;} 
        | else_block {cout<<"#A105.2"<<endl;} 
        | {cout<<"#A105.3"<<endl;}

comment_stmt: {cout<<"#A105.4"<<endl;}
        | dedent_nt COMMENT comment_stmt {cout<<"#A105.6"<<endl;}

while_stmt: 
    | While {myfile<<"L"+to_string(++numl)<<":"<<endl;trul.push(numl);} named_expression ':' {myfile<<"if "<<$3->addr<<" goto: "<<$3->tru<<endl<<"goto: "<<$3->fal<<endl<<$3->tru<<":"<<endl;} block {myfile<<"goto L"<<to_string(trul.top())<<endl;myfile<<$3->fal<<":"<<endl;trul.pop();  cout<<"#A107"<<endl;} else_block {cout<<"#A109"<<endl;}

for_stmt: 
    | For star_targets  in  star_expressions {
        string str = $4->addr;
        string first_arg="",second_arg="";bool comma_seen=false;
        cout<<str.size()<<endl;
        if(str.size()>5 && str.substr(0,5)=="range"){
            for(int i=6;i<str.size()-1;i++){
                if(str[i]==','){
                    comma_seen=true;continue;
                }
                if(!comma_seen){
                    first_arg+=str[i];
                }else{
                    second_arg+=str[i];
                }
            }
            if(comma_seen){
                myfile<<"    "<<$2->addr<<" = "<<first_arg<<endl;
                myfile<<"L"+to_string(++numl)<<":"<<endl;trul.push(numl);
                $4->tru = "L"+to_string(++numl);$4->fal = "L"+to_string(++numl);
                myfile<<"if "<<$2->addr<<" < "<<second_arg<<" goto: "<<$4->tru<<endl<<"goto: "<<$4->fal<<endl<<$4->tru<<":"<<endl;   
            }
            else{
                myfile<<"    "<<$2->addr<<" = 0"<<endl;
                myfile<<"L"+to_string(++numl)<<":"<<endl;trul.push(numl);
                $4->tru = "L"+to_string(++numl);$4->fal = "L"+to_string(++numl);
                myfile<<"if "<<$2->addr<<" < "<<first_arg<<" goto: "<<$4->tru<<endl<<"goto: "<<$4->fal<<endl<<$4->tru<<":"<<endl;
            }
           
        }
        else{
            myfile<<"    "<<$2->addr<<" = "<<$4->addr<<".first"<<endl;
            myfile<<"L"+to_string(++numl)<<":"<<endl;trul.push(numl);
            $4->tru = "L"+to_string(++numl);$4->fal = "L"+to_string(++numl);
            myfile<<"if "<<$2->addr<<" != "<<$4->addr<<".end goto "<<$4->tru<<endl<<"goto: "<<$4->fal<<endl<<$4->tru<<":"<<endl;
            
        }
        symtab["0"][$2->addr].type="int";
    } ':' block {myfile<<"    "<<$2->addr<<"="<<$2->addr+"+1"<<endl;myfile<<"goto L"<<to_string(trul.top())<<endl;myfile<<$4->fal<<":"<<endl;trul.pop();symtab["0"].erase($2->addr);} 


star_targets: 
    | star_target {cout<<"#A113"<<endl;$$=$1;}
    | star_target tem {cout<<"#A115"<<endl;}

tem:  
    | ',' {cout<<"#A116"<<endl;}
    | ',' star_target tem {cout<<"#A118"<<endl;}



star_targets_list_seq: star_target tem2 {cout<<"#A120"<<endl;}

tem2: 
    | ',' {cout<<"#A121"<<endl;}
    | ',' star_target tem2 {cout<<"#A124"<<endl;}

star_targets_tuple_seq: 
    | star_target ',' star_target tem3 {cout<<"#A127"<<endl;}
    | star_target ',' {cout<<"#A128"<<endl;}

tem3: 
    | ',' {cout<<"#A130"<<endl;}
    | ',' star_target tem3 {cout<<"#A132"<<endl;}

star_target: 
    | '*'  star_target {cout<<"#A133"<<endl;}
    | target_with_star_atom {cout<<"#A134"<<endl;$$=$1;}

target_with_star_atom: 
    | t_primary '.' IDENTIFIER {cout<<"#A135"<<endl;}
    | t_primary '[' slices ']'  {cout<<"#A137"<<endl;}
    | star_atom {cout<<"#A138"<<endl;$$=$1;}

star_atom:
    | IDENTIFIER {cout<<"#A139 "<<$1<<endl;$$=new Datatype();$$->addr=$1;}
    | '(' ')' {cout<<"#A140"<<endl;}
    | '['']' {cout<<"#A141"<<endl;}
    | '(' target_with_star_atom ')'  {cout<<"#A142"<<endl;}
    | '(' star_targets_tuple_seq ')' {cout<<"#A143"<<endl;}
    | '[' star_targets_list_seq ']' {cout<<"#A144"<<endl;}

t_primary:
    | t_primary '.' IDENTIFIER t_lookahead {cout<<"#A146"<<endl;}
    | t_primary  '[' slices ']' t_lookahead {cout<<"#A149"<<endl;}
    | t_primary  genexp t_lookahead {cout<<"#A152"<<endl;}
    | t_primary '(' arguments  ')' t_lookahead {cout<<"#A155"<<endl;}
    | atom t_lookahead {cout<<"#A156"<<endl;}

t_lookahead: '(' {cout<<"#A157"<<endl;}
            | '[' {cout<<"#A158"<<endl;} 
            | '.' {cout<<"#A159"<<endl;}

print_statement: PRINT '(' print_par ')' {cout<<"#A160"<<endl;}
print_par: 
    | atom {cout<<"#A161"<<endl;}
    | IDENTIFIER method_call{cout<<"#A163"<<endl;}
    

method_call:   singleDot {cout<<"#A165.1"<<endl;curr_identifier2=curr_identifier;} method method_call {cout<<"#A165"<<endl;$$=$3;} 
        |  {cout<<"#A165.2"<<endl;$$=nullptr;}

method : IDENTIFIER col_var_nt { 
            cout<<"#A165.3"<<endl;
            if($2==nullptr){
                // Find identifier in class p1.a=5 find scope of class whose object is p1
                //check if attribute a is in scope...if yes, then assign type
                cout<<"herherehrehrbhe "<<curr_identifier2<<endl;
                string scope=get_scope();
                 string scope1="";bool flag=false;
                    for(auto i:scope){
                        if(i=='.'){
                            flag=true;break;
                        }
                        scope1+=i;
                    }
                    if(scope!="0")scope=scope1;
                    cout<<scope<<endl;
                if(curr_identifier2=="self"){
                     $$=new Datatype();
                    
                    $$->type=variable_to_number[symtab[scope][$1].type]; 
                    }
                else if(curr_identifier2!="self" and symtab[scope].find(curr_identifier2)==symtab[scope].end()){
                    yyerror("Undefined object");
                }else{
                    string class_name=symtab["0"][curr_identifier2].type;
                    string ele_scope= symtab["0"][class_name].func_element_scope;
                    if(scope=="0" and symtab[ele_scope].find($1)==symtab[ele_scope].end()){
                        yyerror("Undefined attribute");
                    }
                    $$=new Datatype();
                    
                    $$->type=variable_to_number[symtab[ele_scope][$1].type];                
                    }

            }else{
                cout<<curr_identifier2<<endl;
                if(curr_identifier2=="self"){
                    string scope=get_scope();
                    string scope1="";bool flag=false;
                    for(auto i:scope){
                        if(i=='.'){
                            flag=true;break;
                        }
                        scope1+=i;
                    }
                    if(!flag){yyerror("Initialization error: self not in init");}
                    unordered_map<string, SymTabEnt >curr_sym=symtab[scope1];
                    for(auto i:curr_sym){
                        if(i.first.length()>=6 and i.first.substr(2,4)=="init"){
                            if(scope!=i.second.func_element_scope){
                                yyerror("Initialization error: self not in init");
                            }
                            break;
                        }
                    }
                    string var_name=$1, var_type=$2->name;
                    symtab[scope1][var_name].type=var_type;
                    symtab[scope1][var_name].syntactic_category="Identifier";
                    $$=$2;$$->type=variable_to_number[var_type];
                }else{
                    yyerror("Declaration error: Self keyword missing ");
                }
            }
        }
        | obj_function_call  {cout<<"#A166"<<endl;}

obj_function_call: IDENTIFIER '(' params ')' {
    cout<<"In obj fun call"<<endl;
    cout<<curr_identifier<<endl;
    cout<<curr_identifier2<<endl;
    string class_name=symtab["0"][curr_identifier2].type;
    cout<<class_name<<endl;
    unordered_map<string, SymTabEnt >curr_sym=symtab[symtab["0"][class_name].func_element_scope];
    if(curr_sym.find($1)==curr_sym.end()){
        yyerror("Unsupported Method call");
    }
    vector<pair<string,string>>curr=curr_sym[$1].params_type;
            cout<<params_type.size()<<endl;
            if(curr[0].first!="self"){

                if(curr.size()!=params_type.size()){
                    yyerror(("Number of arguments should be1 "+to_string(curr.size())).c_str());
                }
                for(int i=0;i<params_type.size();i++){
                    if(get_type(params_type[i].first)!=variable_to_number[curr[i].second]){
                        yyerror(("TypeError: Expected Argument type is " + curr[i].second).c_str());
                    }
                }
            }else{
                if(curr.size()-1!=params_type.size()){
                    yyerror(("Number of arguments should be2 "+to_string(curr.size()-1)).c_str());
                }
                for(int i=0;i<params_type.size();i++){
                    if(get_type(params_type[i].first)!=variable_to_number[curr[i+1].second]){
                        yyerror(("TypeError: Expected Argument type is " + curr[i].second).c_str());
                    }
                }
            }
            params_type.clear();
}

function_call: IDENTIFIER '(' params ')' { 
    cout<<"#A167"<<endl;
    cout<<"In func call "<<endl;
    $$=new Datatype();$$->name=$1;
    // Checking if identifier is a class name
    string to_send="";
    to_send+=$1;to_send+='(';
    for(auto i:params_type){
        to_send+=i.first;
          string name=$1;
        if(inside_function and symtab["0"].find(i.first)!=symtab["0"].end()){
             to_send+="func";name+=func_name;
        }
        to_send+=",";
    }
    if(params_type.size())
        to_send.pop_back();
        to_send+=')';
    cout<<to_send<<endl;
    $$->addr=to_send;

    unordered_map<string, SymTabEnt >curr_sym=symtab["0"];
    if(curr_sym.find($1)!=curr_sym.end()){
        if(curr_sym[$1].syntactic_category=="Class"){
            // Check if parameters are same as init, init is in scope a
           unordered_map<string, SymTabEnt >init_sym=symtab[curr_sym[$1].func_element_scope];
           for(auto i:init_sym){
            if(i.first.length()>=6 and i.first.substr(2,4)=="init"){
                vector<pair<string,string>>init_params=i.second.params_type;
                if(params_type.size()!=init_params.size()-1){
                     yyerror(("Number of arguments in constructor should be "+to_string(init_params.size()-1)).c_str());
                }else{
                    for(int i=0;i<params_type.size();i++){
                        // cout<<params_type[i].second<<" "<<init_params[i+1].second
                        int par_int_type=-1;
                        if(params_type[i].second==""){
                            
                             par_int_type = get_type(params_type[i].first);
                        }
                        else par_int_type=variable_to_number[params_type[i].second];
                        if(par_int_type!=variable_to_number[init_params[i+1].second]){
                            yyerror("Wrong paramter type");
                        }
                    }
                }
            }
           }
        }
        else{
            cout<<"calling function"<<endl;
            vector<pair<string,string>>curr=symtab["0"][$1].params_type;
            string cf = symtab["0"][$1].return_type;
            $$->func_type = variable_to_number[cf];
            cout<<"CALL FUNCTION TYPE: "<<$$->type<<": "<<cf<<endl;
            cout<<params_type.size()<<endl;
            for(auto i:curr)cout<<i.first<<" "<<i.second<<" "; //curr is formal arguments
            cout<<endl;
              for(auto i:params_type)cout<<i.first<<" "<<i.second<<" "; //params is actual arguments
            cout<<endl;
            cout<<"CURR.SIZE()= "<<curr.size()<<endl;
            cout<<"PARAMTY.SIZE()= "<<params_type.size()<<endl;
            if(curr.size()!=params_type.size()){
                yyerror(("Number of arguments should be3 "+to_string(curr.size())).c_str());
            }
            for(int i=0;i<params_type.size();i++){
                //params[i].second == curr[i].second
                if(params_type[i].second!=""){
                    if(params_type[i].second!=curr[i].second){
                        yyerror(("TypeError: Expected Argument type is " + curr[i].second).c_str());
                    }
                }
                else if(get_type(params_type[i].first)!=variable_to_number[curr[i].second]){
                    yyerror(("TypeError: Expected Argument type is " + curr[i].second).c_str());
                }
            }
        }
    }
    else{
        string func_name=$1;
        if(func_name!="range" && func_name!="len" )yyerror("Function not declared");
        else{
            if(func_name == "range"){
                int size=params_type.size();
                if(size==2 || size==1 ){
                    for(auto i:params_type){
                        if(i.second==""){
                            int type=get_type(i.first);
                            if(type!=1){
                                yyerror("Range Error: Argument should be of type int");
                            }
                        }
                        else if(i.second!="int"){
                            yyerror("Range Error: Argument should be of type int");
                        }
                    }
                }
                else yyerror("Argument Error: Argument number should be 1 or 2");
            }
            else{
                int size=params_type.size();
                if(size == 1){
                    auto i=params_type[0];
                    int type=get_type(i.first);
                    cout<<"PARAM LEN : "<<i.first<<" : "<<type<<endl;
                    if(type!=4 && type!=7){
                        yyerror("len Error: Argument should be of type string");
                    }
                }
                else{
                    yyerror("Argument Error: Argument number should be 1");
                }
            }
        }
    }
   
    //From symbol table
        params_type.clear();
        cout<<"DONE FUNCTION CALL"<<endl;
}

class_def: CLASS{flag=1;a++;} IDENTIFIER {myfile<<"class "<<$3<<":"<<endl;} type_params_opt  arguments_opt {
            string parent_class="";
            // parent class empty means it is a base class, else derived class
            if($6)parent_class=$6->name;
            create_class_entry($3,"Class",parent_class,a);
        } ':' block {cout<<"#A170"<<endl;myfile<<"end of class "<<endl;}

arguments_opt: '(' IDENTIFIER ')'{cout<<"#A171"<<endl;$$=new Datatype();$$->name=$2;} 
        | {$$=nullptr;}

type_params_opt: '[' type_param_seq   ']'{cout<<"#A172"<<endl;} 
        | 

type_param_seq: type_param  ',' type_param_seq {cout<<"#A174"<<endl;} 
        | ',' {cout<<"#A175"<<endl;}| {cout<<"#A176"<<endl;}

type_param: 
    | IDENTIFIER type_param_bound {cout<<"#l1"<<endl;}
    | '*' IDENTIFIER ':' expression {cout<<"#l2"<<endl;}
    | '*' IDENTIFIER {cout<<"#l3"<<endl;}
    | EXPONENT IDENTIFIER ':' expression {cout<<"#l4"<<endl;}
    | EXPONENT IDENTIFIER {cout<<"#l5"<<endl;}
type_param_bound:':' expression {cout<<"#l6"<<endl;}
        |  {cout<<"#l7"<<endl;}
block:
    NEWLINE INDENT statements dedent_nt {cout<<"#l8"<<endl;}
    | simple_stmts {cout<<"#l9"<<endl;}
    | comment_stmt

dedent_nt: DEDENT {cout<<"#l8"<<endl;} 
    | 
assignment_expression:
    | IDENTIFIER '=' expression {cout<<"#l10"<<endl;}

named_expression: assignment_expression {cout<<"#l11"<<endl;}
    | expression {cout<<"#l12"<<endl;$$=$1;$$->tru = "L"+to_string(++numl);$$->fal = "L"+to_string(++numl);}

variablename: IDENTIFIER  col_var_nt {
    cout<<"#l13"<<endl;
    string type="";
    if($2!=nullptr ){
        type=$2->name;
    }
    params_type.push_back({$1,type});
    }
col_var_nt:':' var_nt {cout<<"#l13.3"<<endl;$$=$2;} | {$$=nullptr;}
var_nt: IDENTIFIER '[' VARIABLETYPE ']' {cout<<"#l13.4"<<endl;$$=new Datatype();string var_name=$1;string var_type=$3;string ans=var_name+"["+var_type+"]";$$->name=var_name;global_list_type = variable_to_number[var_type];}
    |  VARIABLETYPE {cout<<"#l13.5"<<endl;cout<<"in vrbtype "<<($1)<<endl;$$=new Datatype();$$->name=$1;}
    | None {cout<<"#l13.6"<<endl;}
list: {$$=nullptr;}
    | '[' star_named_expressions ']' {cout<<"#l14"<<endl;}

star_named_expressions:
    | star_named_expression {cout<<"#l15"<<endl;}
    | star_named_expression ',' {cout<<"#l16"<<endl;}
    | star_named_expression ',' star_named_expressions {
        cout<<"#l17"<<endl;
        cout << "STAR ELEMENTS: "<<$1->type<<" "<<$3->type<<endl;
        cout << "GLOBAL LIST TYPE: "<<global_list_type<<endl;
        if($1->type!=global_list_type || $3->type!=global_list_type){
            yyerror("List element type unacceptable");
        }
    }

star_named_expression:
    | '*' bitwise_or {cout<<"#l18"<<endl;}
    | named_expression {cout<<"#l19"<<endl;$$=$1;}



arithematic:
    | arithematic PLUS term {
            cout<<"#l26"<<endl;int type1=$1->type,type2=$3->type;
            if(type1==5){
                type1=get_type($1->name);
            }
            if(type2==5){
                type2=get_type($3->name);
            }
             if(type1==4 or type2==4){
                yyerror("+ operator not allowed on string data type");
            }
            $$->type=global_type;
            cout << "DolarDolar type=" << $$->type << endl;
            if($$->type == 1){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 2){
                    if(type2 == 1 or type2 == 2){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("+ operator not allowed on float and bool");}
                }
                else if(type1 == 3){
                    if(type2 == 1 or type2 == 3){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("+ operator not allowed on float and bool");}
                }
            } 
            else if($$->type == 2){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 2){
                    if(type2 == 1 or type2 == 2){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("+ operator not allowed on float and bool");}
                }
                else{yyerror("= operator not allowed on float and bool");}
            }
            else if($$->type == 3){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 3){
                    if(type2 == 1 or type2 == 3){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("+ operator not allowed on float and bool");}
                }
                else{yyerror("= operator not allowed on float and bool");}
            }
            
            cout << "type1="<<type1 << ",type2="<<type2<<",type0="<<$$->type<<endl;
            if(type1!=type2)yyerror("Type mismatch in arithematic1 ");
            myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" + "<<$3->addr<<endl;
            $$->addr = "t"+to_string(numt);
        }
    | arithematic MINUS term {
            cout<<"#l28"<<endl;
            int type1=$1->type,type2=$3->type;
            if(type1==5){
                type1=get_type($1->name);
            }
            if(type2==5){
                type2=get_type($3->name);
            }
            if(type1==4 or type2==4){
                yyerror("- operator not allowed on string data type");
            }
            $$->type=global_type;
            cout << "DolarDolar type=" << $$->type << endl;
            if($$->type == 1){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 2){
                    if(type2 == 1 or type2 == 2){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("- operator not allowed on float and bool");}
                }
                else if(type1 == 3){
                    if(type2 == 1 or type2 == 3){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("- operator not allowed on float and bool");}
                }
            } 
            else if($$->type == 2){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 2){
                    if(type2 == 1 or type2 == 2){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("- operator not allowed on float and bool");}
                }
                else{yyerror("= operator not allowed on float and bool");}
            }
            else if($$->type == 3){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 3){
                    if(type2 == 1 or type2 == 3){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("- operator not allowed on float and bool");}
                }
                else{yyerror("= operator not allowed on float and bool");}
            }
            
            cout << "type1="<<type1 << ",type2="<<type2<<",type0="<<$$->type<<endl;
            if(type1!=type2)yyerror("Type mismatch in arithematic2 ");
            myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" - "<<$3->addr<<endl;
            $$->addr = "t"+to_string(numt);
            }
    | term {cout<<"#l29"<<endl;$$=$1;cout<<"in terms "<<$$->addr<<endl;}
    ;

term:
    | term  MULTIPLY factor {
            cout<<"#l31"<<endl;
            int type1=$1->type,type2=$3->type;
            if(type1==5){
                type1=get_type($1->name);
            }
            if(type2==5){
                type2=get_type($3->name);
            }
            if(type1==4 or type2==4){
                yyerror("* operator not allowed on string data type");
            }
            $$->type=global_type;
            cout << "DolarDolar type=" << $$->type << endl;
            if($$->type == 1){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 2){
                    if(type2 == 1 or type2 == 2){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("* operator not allowed on float and bool");}
                }
                else if(type1 == 3){
                    if(type2 == 1 or type2 == 3){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("* operator not allowed on float and bool");}
                }
            } 
            else if($$->type == 2){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 2){
                    if(type2 == 1 or type2 == 2){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("* operator not allowed on float and bool");}
                }
                else{yyerror("= operator not allowed on float and bool");}
            }
            else if($$->type == 3){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 3){
                    if(type2 == 1 or type2 == 3){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("* operator not allowed on float and bool");}
                }
                else{yyerror("= operator not allowed on float and bool");}
            }
            
            cout << "type1="<<type1 << ",type2="<<type2<<",type0="<<$$->type<<endl;
            if(type1!=type2)yyerror("Type mismatch in arithematic3 ");
            myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" * "<<$3->addr<<endl;
            $$->addr = "t"+to_string(numt);
            }
    | term  DIVIDE factor {
            cout<<"#l33"<<endl;
            int type1=$1->type,type2=$3->type;
            if(type1==5){
                type1=get_type($1->name);
            }
            if(type2==5){
                type2=get_type($3->name);
            }
            if(type1==4 or type2==4){
                yyerror("/ operator not allowed on string data type");
            }
            $$->type=global_type;
            cout << "DolarDolar type=" << $$->type << endl;
            if($$->type == 1){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 2){
                    if(type2 == 1 or type2 == 2){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("/ operator not allowed on float and bool");}
                }
                else if(type1 == 3){
                    if(type2 == 1 or type2 == 3){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("/ operator not allowed on float and bool");}
                }
            } 
            else if($$->type == 2){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 2){
                    if(type2 == 1 or type2 == 2){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("/ operator not allowed on float and bool");}
                }
                else{yyerror("= operator not allowed on float and bool");}
            }
            else if($$->type == 3){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 3){
                    if(type2 == 1 or type2 == 3){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("/ operator not allowed on float and bool");}
                }
                else{yyerror("= operator not allowed on float and bool");}
            }
            
            cout << "type1="<<type1 << ",type2="<<type2<<",type0="<<$$->type<<endl;
            if(type1!=type2)yyerror("Type mismatch in arithematic4 ");
            myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" / "<<$3->addr<<endl;
            $$->addr = "t"+to_string(numt);
            }
    | term  FLOORDIV factor {
            cout<<"#l35"<<endl;
            int type1=$1->type,type2=$3->type;
            if(type1==5){
                type1=get_type($1->name);
            }
            if(type2==5){
                type2=get_type($3->name);
            }
            $$->type=global_type;
            cout << "DolarDolar type=" << $$->type << endl;
            if($$->type == 1){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 2){
                    if(type2 == 1 or type2 == 2){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("// operator not allowed on float and bool");}
                }
                else if(type1 == 3){
                    if(type2 == 1 or type2 == 3){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("// operator not allowed on float and bool");}
                }
            } 
            else if($$->type == 2){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 2){
                    if(type2 == 1 or type2 == 2){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("// operator not allowed on float and bool");}
                }
                else{yyerror("= operator not allowed on float and bool");}
            }
            else if($$->type == 3){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 3){
                    if(type2 == 1 or type2 == 3){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("// operator not allowed on float and bool");}
                }
                else{yyerror("= operator not allowed on float and bool");}
            }
            
            cout << "type1="<<type1 << ",type2="<<type2<<",type0="<<$$->type<<endl;
            if(type1!=type2)yyerror("Type mismatch in arithematic5 ");
            myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" // "<<$3->addr<<endl;
            $$->addr = "t"+to_string(numt);
            }
    | term  MODULO factor {
            cout<<"#l37"<<endl;
            int type1=$1->type,type2=$3->type;
            if(type1==5){
                type1=get_type($1->name);
            }
            if(type2==5){
                type2=get_type($3->name);
            }
            $$->type=global_type;
            cout << "DolarDolar type=" << $$->type << endl;
            if($$->type == 1){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 2){
                    if(type2 == 1 or type2 == 2){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("\% operator not allowed on float and bool");}
                }
                else if(type1 == 3){
                    if(type2 == 1 or type2 == 3){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("\% operator not allowed on float and bool");}
                }
            } 
            else if($$->type == 2){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 2){
                    if(type2 == 1 or type2 == 2){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("\% operator not allowed on float and bool");}
                }
                else{yyerror("= operator not allowed on float and bool");}
            }
            else if($$->type == 3){
                if(type1 == 1){
                    if(type2 == 2 or type2 == 3 or type2 == 1){
                        type1 = global_type;
                        type2 = global_type;
                    }
                }
                else if(type1 == 3){
                    if(type2 == 1 or type2 == 3){
                        type1 = global_type;
                        type2 = global_type;
                    }
                    else{yyerror("\% operator not allowed on float and bool");}
                }
                else{yyerror("= operator not allowed on float and bool");}
            }
            
            cout << "type1="<<type1 << ",type2="<<type2<<",type0="<<$$->type<<endl;
            if(type1!=type2)yyerror("Type mismatch in arithematic6 ");
            myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" % "<<$3->addr<<endl;
            $$->addr = "t"+to_string(numt);
        }
    | factor {cout<<"#l37.2"<<endl;$$=$1;}
    ;

factor:
    | PLUS factor {
            cout<<"#l38"<<endl;
            cout<<"#l39"<<endl;
            $$=$2;
            int type1=$2->type;
            if(type1==5){
                type1=get_type($2->name);
            }
            if(type1==4){
                yyerror("TypeError: bad operand type for unary -: 'str'");
            }
            }
    | MINUS factor {
            cout<<"#l39"<<endl;
            $$=$2;
            int type1=$2->type;
            if(type1==5){
                type1=get_type($2->name);
            }
            if(type1==4){
                yyerror("TypeError: bad operand type for unary -: 'str'");
            }
            // $$->num=-$2->num;
            }
    | NEG factor {
        cout<<"#l40"<<endl;
        $$=new Datatype();
        int type1 = get_type($2->name);
        $$->addr=" ~ "+$2->addr;
        if(type1!=1){
            yyerror("~ operation allowed with integer only");
        }
        else{
            $$->type = 1;
        }
    }
    | power {cout<<"#l41"<<endl;$$=$1;}
    ;

power:  
    | await_primary EXPONENT factor {
        cout<<"#l43"<<endl;
        int type1=$1->type,type2=$3->type;
        if(type1==5){
            type1=get_type($1->name);
        }
        if(type2==5){
            type2=get_type($3->name);
        }
        if(type1==4 or type2==4){
            yyerror("** operator not allowed on string data type");
        }
        $$->type=global_type;
        cout << "DolarDolar type=" << $$->type << endl;
        if($$->type == 1){
            if(type1 == 1){
                if(type2 == 2 or type2 == 3 or type2 == 1){
                    type1 = global_type;
                    type2 = global_type;
                }
            }
            else if(type1 == 2){
                if(type2 == 1 or type2 == 2){
                    type1 = global_type;
                    type2 = global_type;
                }
                else{yyerror("** operator not allowed on float and bool");}
            }
            else if(type1 == 3){
                if(type2 == 1 or type2 == 3){
                    type1 = global_type;
                    type2 = global_type;
                }
                else{yyerror("** operator not allowed on float and bool");}
            }
        } 
        else if($$->type == 2){
            if(type1 == 1){
                if(type2 == 2 or type2 == 3 or type2 == 1){
                    type1 = global_type;
                    type2 = global_type;
                }
            }
            else if(type1 == 2){
                if(type2 == 1 or type2 == 2){
                    type1 = global_type;
                    type2 = global_type;
                }
                else{yyerror("** operator not allowed on float and bool");}
            }
            else{yyerror("= operator not allowed on float and bool");}
        }
        else if($$->type == 3){
            if(type1 == 1){
                if(type2 == 2 or type2 == 3 or type2 == 1){
                    type1 = global_type;
                    type2 = global_type;
                }
            }
            else if(type1 == 3){
                if(type2 == 1 or type2 == 3){
                    type1 = global_type;
                    type2 = global_type;
                }
                else{yyerror("** operator not allowed on float and bool");}
            }
            else{yyerror("= operator not allowed on float and bool");}
        }
        cout << "type1="<<type1 << ",type2="<<type2<<",type0="<<$$->type<<endl;
        if(type1!=type2)yyerror("Type mismatch in arithematic1 ");
        myfile<<"    "<<"t"+to_string(++numt)<<" = "<<$1->addr<<" ** "<<$3->addr<<endl;
        $$->addr = "t"+to_string(numt);
    }
    | await_primary {cout<<"#l44"<<endl;$$=$1;}

await_primary:
    | primary {cout<<"#l45"<<endl;$$=$1;}

primary:
    | primary '.' IDENTIFIER {cout<<"#l45"<<endl;}
    | primary genexp {cout<<"#l47"<<endl;}
    | primary '(' arguments ')' {cout<<"#l49"<<endl;}
    | primary '[' slices ']' {cout<<"#l51"<<endl;}
    | atom {cout<<"#l52"<<endl;$$=$1;}

genexp:
    | '(' assignment_expression for_if_clauses ')' {cout<<"#l53"<<endl;}
    | '(' expression for_if_clauses ')' {cout<<"#l54"<<endl;}

slices:
    | slice {cout<<"#l55"<<endl;}
    | slice_pieces {cout<<"#l56"<<endl;}

slice_pieces: slice {cout<<"#l57"<<endl;}
    | star_expression {cout<<"#l58"<<endl;}
    | slice  ',' slice_pieces {cout<<"#l60"<<endl;}
    | star_expression ',' slice_pieces {cout<<"#l62"<<endl;}
    | {cout<<"#l63"<<endl;}


slice:
    | ':' 
    | expression ':' {cout<<"#l65"<<endl;}
    | ':' expression {cout<<"#l66"<<endl;}
    | expression  ':' expression {cout<<"#l68"<<endl;}
    | ':' ':' {cout<<"#l69"<<endl;}
    | expression ':' ':' {cout<<"#l70"<<endl;}
    | ':' expression ':' {cout<<"#l71"<<endl;}
    | expression ':' expression ':' {cout<<"#l73"<<endl;}
    | ':' ':' expression {cout<<"#l74"<<endl;}
    | expression  ':' ':' expression {cout<<"#l76"<<endl;}
    | ':' expression ':' expression {cout<<"#l78"<<endl;}
    | expression ':' expression  ':' expression  {cout<<"#l81"<<endl;}
    | named_expression {cout<<"#l82"<<endl;}

starred_expression:
    | '*' expression {cout<<"#l83"<<endl;}

atom: function_call {cout<<"l83.1"<<endl; $$=$1;$$->type=6;}
    | IDENTIFIER id_nt {
        if(flagr){
            retn = $1;
            flagr=0;
        }
        cout<<"#l84 "<<$1<<endl;$$=new Datatype();if($2==nullptr)$$->type=5;else $$->type=$2->type;$$->name=$1;
        string name=$1;
        $$->addr = $1;
        }
    | True {cout<<"#l85"<<endl;$$=new Datatype();$$->type=3;$$->varb=$1;$$->addr = "true";}
    | False {cout<<"#l86"<<endl;$$=new Datatype();$$->type=3;$$->varb=$1;$$->addr = "false";}
    | None {cout<<"#l87"<<endl;}
    | STRING {cout<<"#l88"<<endl;$$=new Datatype();$$->type=4;$$->name=$1;}
    | NUMBER {cout<<"#l90"<<endl;$$=new Datatype();$$->type=1;$$->num=$1;$$->addr = to_string($1);}
    | group {cout<<"#l91"<<endl;$$=$1;}
    | genexp {cout<<"#l92"<<endl;}
    | list {cout<<"#l93"<<endl;$$=new Datatype();$$->type=7;}
    | listcomp {cout<<"#l94"<<endl;}
    | tripleDot {cout<<"#l95"<<endl;}
    | var_nt {cout<<"#l95.1"<<endl;$$=$1;}
    |FLOATLITERAL {cout<<"#l95.2"<<endl;$$=new Datatype();$$->type=2;$$->varf=$1;}

id_nt:  list {cout<<"#l95.3"<<endl;}   | method_call {cout<<"#l95.4"<<endl;$$=$1;}

listcomp: 
    | '[' named_expression for_if_clauses ']' {cout<<"#l97"<<endl;}

for_if_clauses: 
    | for_if_clause {cout<<"#l98"<<endl;}
    | for_if_clause for_if_clauses {cout<<"#l99"<<endl;}

for_if_clause: 
    | For star_targets  in disjunction if_disjuction {cout<<"#l101"<<endl; }

if_disjuction: If disjunction {cout<<"#l102"<<endl;}
    | If disjunction if_disjuction {cout<<"#l104"<<endl;}
    | {cout<<"#l105"<<endl;}

group:
    | '(' named_expression ')' {cout<<"#l107"<<endl;$$=$2;}

compare_op_bitwise_or_pair: 
    | eq_bitwise_or {cout<<"#l113"<<endl;$$=$1;}
    | noteq_bitwise_or {cout<<"#l114"<<endl;$$=$1;}
    | lte_bitwise_or {cout<<"#l115"<<endl;$$=$1;}
    | lt_bitwise_or {cout<<"#l116"<<endl;$$=$1;}
    | gte_bitwise_or {cout<<"#l117"<<endl;$$=$1;}
    | gt_bitwise_or {cout<<"#l118"<<endl;$$=$1;}
    ;

eq_bitwise_or: EQUALITY bitwise_or {cout<<"#l119"<<endl;$$=new Datatype();$$->addr=" = "+$2->addr;}
    ;
noteq_bitwise_or: 
    | NOTEQUAL bitwise_or {cout<<"#l120"<<endl;$$=new Datatype();$$->addr=" != "+$2->addr;}
    ;
lte_bitwise_or: LSEQUAL bitwise_or {cout<<"#l121"<<endl;$$=new Datatype();$$->addr=" <= "+$2->addr;}
    ;
lt_bitwise_or: LESSTHAN bitwise_or {cout<<"#l122"<<endl;$$=new Datatype();$$->addr="<"+$2->addr;}
    ;
gte_bitwise_or: GTEQUAL bitwise_or {cout<<"#l123"<<endl;$$=new Datatype();$$->addr=">="+$2->addr;}
    ;
gt_bitwise_or: GREATERTHAN bitwise_or {cout<<"#l124"<<endl;$$=new Datatype();$$->addr=">"+$2->addr;cout<<"in gt bitwise "<<$$->addr<<endl;}
    ;


bitwise_or: {$$=nullptr;}
    | bitwise_or BITOR bitwise_xor {
        cout<<"#l130"<<endl;
        int type1 = get_type($1->name);
        int type2 = get_type($3->name);
        $$=new Datatype();
        $$->addr=$1->addr+" | "+$3->addr;
        if(type1!=1 || type2!=1){
            yyerror("| operation allowed with integer only");
        }
        else{
            $$->type = 1;
        }
    }
    | bitwise_xor {cout<<"#l131"<<endl;$$=$1;}
    ;

bitwise_xor:
    | bitwise_xor BITXOR bitwise_and {
        cout<<"#l133"<<endl;
        int type1 = get_type($1->name);
        int type2 = get_type($3->name);
        $$=new Datatype();
        $$->addr=$1->addr+" ^ "+$3->addr;
        if(type1!=1 || type2!=1){
            yyerror("^ operation allowed with integer only");
        }
        else{
            $$->type = 1;
        }
    }
    | bitwise_and {cout<<"#l134"<<endl;$$=$1;}
    ;

bitwise_and:
    | bitwise_and  BITAND shift_expr {
        cout<<"#l136"<<endl;
        int type1 = get_type($1->name);
        int type2 = get_type($3->name);
        $$=new Datatype();
        $$->addr=$1->addr+" & "+$3->addr;
        if(type1!=1 || type2!=1){
            yyerror("& operation allowed with integer only");
        }
        else{
            $$->type = 1;
        }
    }
    | shift_expr {cout<<"#l137"<<endl;$$=$1;}
    ;

shift_expr:
    | shift_expr  LEFTSHIFT arithematic {
        cout<<"#l139"<<endl;
        int type1 = get_type($1->name);
        int type2 = get_type($3->name);
        $$=new Datatype();
        $$->addr=$1->addr+" << "+$3->addr;
        if(type1!=1 || type2!=1){
            yyerror("<< operation allowed with integer only");
        }
        else{
            $$->type = 1;
        }
    }
    | shift_expr  RIGHTSHIFT arithematic {
        cout<<"#l141.1"<<endl;
        int type1 = get_type($1->name);
        int type2 = get_type($3->name);
        $$=new Datatype();
        $$->addr=$1->addr+" >> "+$3->addr;
        if(type1!=1 || type2!=1){
            yyerror(">> operation allowed with integer only");
        }
        else{
            $$->type = 1;
        }
    }
    | arithematic {cout<<"#l141.2"<<endl;$$=$1;}
    ;

    
augassign:
     INPLACEADD {cout<<"#l142"<<endl;$$=new Datatype();$$->name=$1;}
    | INPLACESUB {cout<<"#l143"<<endl;$$=new Datatype();$$->name=$1;}
    | INPLACEMULT {cout<<"#l144"<<endl;$$=new Datatype();$$->name=$1;}
    | INPLACEDIV {cout<<"#l145"<<endl;$$=new Datatype();$$->name=$1;}
    | INPLACEMOD {cout<<"#l146"<<endl;$$=new Datatype();$$->name=$1;}
    | INPLACEBITAND {cout<<"#l147"<<endl;$$=new Datatype();$$->name=$1;}
    | INPLACEBITOR {cout<<"#l148"<<endl;$$=new Datatype();$$->name=$1;}
    | INPLACEBITXOR {cout<<"#l149"<<endl;$$=new Datatype();$$->name=$1;}
    | INPLACELEFTSHIFT {cout<<"#l150"<<endl;$$=new Datatype();$$->name=$1;}
    | INPLACERIGHTSHIFT {cout<<"#l151"<<endl;$$=new Datatype();$$->name=$1;}
    | INPLACEFLOORDIV {cout<<"#l151.1"<<endl;$$=new Datatype();$$->name=$1;}
    | INPLACEEXPO {cout<<"#l152"<<endl;$$=new Datatype();$$->name=$1;}
    | '=' {cout<<"#l153"<<endl;}
    ;


%%
void yyerror(const char* s) {
    cerr << s<<" at line no: "<<yylineno-1<<"-"<<yylineno<< endl;
    exit(0);
}
void argparse(int argc, char *argv[]){
 const char *input_file_name = nullptr,*output_file_name=nullptr;

    // Parse command line arguments
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "-input") == 0) {
            // Check if the next argument exists and is not another option
            if (i + 1 < argc && argv[i + 1][0] != '-') {
                input_file_name = argv[i + 1];
                // Skip the next argument since it's the input file name
                ++i;
            } else {
                cerr << "Error: Missing file name after -input option" << endl;
                exit(0);
            }
        }
         if (strcmp(argv[i], "-output") == 0) {
            // Check if the next argument exists and is not another option
            if (i + 1 < argc && argv[i + 1][0] != '-') {
                output_file_name = argv[i + 1];
                // Skip the next argument since it's the input file name
                ++i;
            } else {
                cerr << "Error: Missing file name after -output option" << endl;
                exit(0);
            }
        }
         if (strcmp(argv[i], "-verbose") == 0) {
            verbose=1;
        }
         if (strcmp(argv[i], "-help") == 0) {
             cout << "Usage: program_name [OPTIONS]" << endl;
             cout<<endl<<endl;
            cout << "Options:" << endl;
            cout << "  -input <input_file>    Specifies the input file to be processed." << endl;
            cout << "  -output <output_file>  Specifies the output file to write the processed data." << endl;
            cout << "  -verbose               Enables verbose mode, providing detailed information during execution." << endl;
            cout << "  -help                  Displays this help message and exits." << endl;
            exit(0);
        }

    }
      if (input_file_name != nullptr) {  
        FILE *input_file = fopen(input_file_name, "r");
        if(!input_file){
            cout<<"Error:Missing or Invalid file"<<endl;
            exit(0);
        }
        yyin = input_file;
         if(output_file_name)
            myfile.open(output_file_name);
        else{
            myfile.open("3AC.txt");
        }
    }else{
        FILE *input_file = fopen(argv[1], "r");
        if(!input_file){
            cout<<"Error:Missing or Invalid file"<<endl;
            exit(0);
        }
        yyin = input_file;
        myfile.open("3AC.txt");
    }
   
}
void create(unordered_map<string, unordered_map<string, SymTabEnt >> &symtab) 
{ 
	// file pointer,  
    
	// opens an existing csv file or creates a new file. 
	fout.open("symbolTable.csv", ios::out | ios::app); 
 


    fout<<"Scope"<<","<<"Syntactic Category"<<","<<"Lexeme"<<","<<"Type"<<","<<"Line Number"<<"\n";
	// Read the input 
	for (auto i:symtab) {
        unordered_map<string,SymTabEnt>m=i.second; 
        for(auto j:m){
            fout<<i.first<<","<<j.second.syntactic_category<<","<<j.first<<","<<j.second.type<<","<<j.second.line_no<<"\n";

        }
	} 
} 

int main(int argc, char *argv[]){
     argparse( argc, argv);
    variable_to_number["int"]=1;variable_to_number["float"]=2;variable_to_number["bool"]=3;variable_to_number["str"]=4;
    variable_to_number["list"]=7;variable_to_number["none"]=8;
    number_to_variable[1]="int";number_to_variable[2]="float";number_to_variable[3]="bool";number_to_variable[4]="str";
    number_to_variable[7]="list";number_to_variable[8]="none";
    yyparse();
    myfile.close();
    /* if(!verbose){
        system("clear");
    } */
    /* unordered_map<string, unordered_map<string, SymTabEnt >> symtab; */
    for(auto i:symtab){
        cout<<"#####################################################################################################################################"<<endl;
        cout<<"Scope "<<i.first<<endl;
        unordered_map<string,SymTabEnt>m=i.second;
        for(auto j:m){
            if(j.second.syntactic_category=="Class"){
                cout<<j.first<<" "<<j.second.syntactic_category<<" "<<j.second.func_element_scope<<" Parent Class is: "<<j.second.parent_class<<endl;
            }
            else if(j.second.syntactic_category!="Function"){
              switch (variable_to_number[j.second.type]) {
                    case 1:
                        cout<<j.first<<" "<<j.second.val<<" "<<j.second.type<<" "<<j.second.syntactic_category<<" "<<endl;
                        break;
                    case 2:
                         cout<<j.first<<" "<<j.second.varf<<" "<<j.second.type<<" "<<j.second.syntactic_category<<" "<<endl;
                        break;
                    case 3:
                        cout<<j.first<<" "<<j.second.varb<<" "<<j.second.type<<" "<<j.second.syntactic_category<<" "<<endl;
                        break;
                    case 4:
                        cout<<j.first<<" "<<j.second.name<<" "<<j.second.type<<" "<<j.second.syntactic_category<<" "<<endl;
                        break;
                    default:
                       cout<<j.first<<" "<<j.second.type<<" "<<j.second.syntactic_category<<" "<<endl;
                        break;
                    }
            }else{
                    cout<<j.first<<" "<<j.second.return_type<<" "<<j.second.syntactic_category<<" ";
                    cout<< "element scope "<<j.second.func_element_scope<<endl;
                    cout<<j.second.params_type.size()<<endl;
                    for(auto ele:j.second.params_type)cout<<ele.first<<" "<<ele.second<<endl;
            }
        }

    }
    cout<<"Calling create"<<endl;
    create(symtab);

    return 0;

}