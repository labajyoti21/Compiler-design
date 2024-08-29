#include<bits/stdc++.h>
#include<fstream>
#include <sstream>
using namespace std;
ofstream file;
int flag=0,curr=0,flagr=0;
queue<string> registers;
unordered_map<string,string> rd; // rd= register to variable , ad =variable to register
unordered_map<string,string>ad;
bool isInteger(string str) {
    if(str.empty())return 0;
    for(char i:str){
        if(i<'0' or i>'9') return 0;
    } 
    return 1;
}

void freereg(string regist){
    if(rd.find(regist)!=rd.end()){
        string var = rd[regist];
        ad[var] = "";
        file<<"    "<<"mov "<<regist<<" , %"<<var<<endl;
        return;
    }
}


string getReg(string var){
    string regist;
    regist = ad[var];
    if(regist != "")
        return regist;
    else{
        regist = registers.front();
        registers.push(regist);
        registers.pop();
        if(rd.find(regist)==rd.end()){
            rd[regist] = var;
            ad[var] = regist;
            file<<"    "<<"mov "<<var<<" , %"<<regist<<endl;
            return regist;
        }
        else{
            string pvar = rd[regist];
            ad[pvar] = "";
            file<<"    "<<"mov "<<regist<<" , %"<<pvar<<endl;
            rd[regist] = var;
            ad[var] = regist;
            file<<"    "<<"mov "<<var<<" , %"<<regist<<endl;
            return regist;
        }
    }
}

int expr_type(string line){
    // variable = number
    return -1;
}



int main(){
    registers.push("rax");
    registers.push("rbx");
    registers.push("rcx");
    registers.push("rdx");
    registers.push("rsi");
    registers.push("rdi");
    registers.push("rbp");
    registers.push("rsp");
    registers.push("r8");
    registers.push("r9");
    registers.push("r10");
    registers.push("r11");
    registers.push("r12");
    registers.push("r13");
    registers.push("r14");
    registers.push("r15");
    string line;
    file.open("test.s");
    ifstream inputFile("3AC.txt"); // Open the file for reading
    file<<".section  .data"<<endl;
    while (getline(inputFile, line)) {
        // if(line=="\n")
        //     break;
        // if(line == "")
        //     continue;
        string str="";
        int ind=0; 
        while(ind<line.size() and line[ind]==' ')ind++;
        if(ind==line.size())continue;
        string temp="";
        while(ind<line.size()) temp+=line[ind++];
        if(temp[0]=='\n' || line=="" || line[line.size()-1]==':') continue;
        line=temp;
        // if(line=="")
        //     continue;
        char i = '0';
        int k=0;
        while(i!=' ' && k<line.size()){
            str+=line[k];
            k++;
            i= line[k];
        }
        bool isparam=false;
        if(str== "call")
        continue;
        if(str== "return")
        continue;
        if(str=="param"){
            while(k<line.size() and line[k]==' ')k++;
            str="";
            while(k<line.size() and line[k]!=' ')str+=line[k++];
            if(ad.find(str)==ad.end())
            file<<"    "<<str<<":"<<endl <<"    .long 0"<<endl;
            ad[str] = "";
            continue;
        }
        if(str == "call" || str == "if" || str[0] == 'L'){
            continue;
        }
        if(str!="param" and str!="" && str != "call" && str != "if" && str[0] != 'L'){
            if(ad.find(str)==ad.end())
            file<<"    "<<str<<":"<<endl <<"    .long 0"<<endl;
            ad[str] = "";
        }
        if(k == line.size())
            continue;
        k++;
        i='0';
        while(i!=' ' && i!='\n' && k<line.size()){
            // str+=line[k];
            if(line[k]=='=')break;
            k++;
            i= line[k];
        }
        k++;
        // if(str=="="){cout<<str<<" printed k"<<endl;}
        while(k<line.size() and line[k]==' ' )k++;
        if(k == line.size())
            continue;
        str = "";
        i='0';
      
        while(i!=' '&& i!='\n' && k<line.size()){
            str+=line[k];
            k++;
            i= line[k];
        }
        if(str== "call")
        continue;
        if(str!="" && str != "call" && str != "if" && str[0] != 'L'&& (!(str[0]>='0' && str[0]<='9')) ){
            if(ad.find(str)==ad.end())
            file<<"    "<<str<<":"<<endl <<"    .long 0"<<endl;
            // cout<<str<<" printed d"<<endl;
            ad[str] = "";
        }
        while(k<line.size() and line[k]==' ' )k++;
        
         
        if(k == line.size())continue;
        
        str = "";
        i='0';
        while(i!=' '&& i!='\n' && k<line.size()){
            str+=line[k];
            k++;
            i= line[k];
        }
        if(str!="" && str != "call" && str != "if" && str[0] != 'L'&& (!(str[0]>='0' && str[0]<='9')) && str!="+" && str!="-" && str[0]!='*' && str!="/"){
            if(ad.find(str)==ad.end())
            file<<"    "<<str<<":"<<endl <<"    .long 0"<<endl;
            cout<<str<<" printed p"<<endl;
            ad[str] = "";
        }
        while(k<line.size() and line[k]==' ' )k++;
        if(k == line.size())
            continue;
        str = "";
        i='0';
        while(i!=' ' && i!='\0' && k<line.size()){
            str+=line[k];
            k++;
            i= line[k];
        }
        if(str!="" && str != "call" && str != "if" && str[0] != 'L'&& (!(str[0]>='0' && str[0]<='9')) && str!="+" && str!="-" && str[0]!='*' && str!="/"){
           cout<<str<<endl;
            if(ad.find(str)==ad.end()){
                file<<"    "<<str<<":"<<endl <<"    .long 0"<<endl;
            }
            ad[str] = "";
        }
    }
    inputFile.close();
    cout<<"Labajyoti part done\n";
    ifstream inputFile2("3AC.txt"); // Open the file for reading
    if (!inputFile2.is_open()) {
        cerr << "Failed to open the file.\n";
        return 1; // Exit with an error
    }

    file<<".section .text"<<endl;
    file<<".global main"<<endl;
    file<<"\n\n";
    file<<"main:"<<endl;

    while (getline(inputFile2, line)) {
        // Removing spaces from the starting
        int i=0;
        while(i<line.size() and line[i]==' ')i++;
        string var="";
        cout<<line<<"\n";
        //extracting the lhs
        // After this loop, var will have a,t1 or any other part of 3AC before enocuntering space
        while(i<line.size() and line[i]!=' '){
            if(line[i]=='=')break; 
            var+=line[i];
            i++;
        }
        cout<<"here"<<endl;
        cout<<var<<endl<<" here call is"<<endl;
        i++;  //Doing this to go to next token after '=' or space
        if(line[line.size()-1]==':'){file<<line<<endl;
            if(var[0]!='L'){
                freereg("rsp");
                freereg("rbp");
                file<<"    pushq %rbp        # Save the old base pointer"<<endl<<"    movq %rsp, %rbp   # Set up the new base pointer"<<endl;
                continue; 
            }
        }
        else if(var == "call"){
            cout<<"in block"<<endl;
                vector<string> params;
                string function = "";
                while((line[i]>='a' && line[i]<='z') || (line[i]>='A' && line[i]<='Z')|| (line[i]>='0' && line[i]<='9')){
                    function+=line[i++];
                }
                cout<<"is func"<<function<<endl;
                string str="";
                i++;
                while(i<line.length()){
                    while((line[i]>='a' && line[i]<='z') || (line[i]>='A' && line[i]<='Z') || (line[i]>='0' && line[i]<='9')){
                        str+=line[i++];
                    }
                    i++;
                    if(str.length()!=0)
                    params.push_back(str);
                    str="";
                }
                for(int i=0; i<params.size(); i++){
                    switch (i) {
                        case 0:{
                            freereg("rdi");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<", %rdi"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<", %rdi"<<endl;
                            }
                            flag++;
                            break;
                        }
                        case 1:{
                            freereg("rsi");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<", %rsi"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<", %rsi"<<endl;
                            }
                            flag++;
                            break;
                        }
                        case 2:{
                            freereg("rdx");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<", %rdx"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<", %rsdx"<<endl;
                            }
                            flag++;
                            break;
                        }
                        case 3:{
                            freereg("rcx");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<", %rcx"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<", %rcx"<<endl;
                            }
                            flag++;
                            break;
                        }
                        case 4:{
                            freereg("r8");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<", %r8"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<", %r8"<<endl;
                            }
                            flag++;
                            break;
                        }
                        case 5:{
                            freereg("r9");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<", %r9"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<", %r9"<<endl;
                            }
                            flag++;
                            break;
                        }
                    }
                }
                file<<"    call "<<function<<endl;
                file<<"#in here"<<endl;
                continue;
            }
        else if(var == "param"){
            string tmp = "";
            while(i<line.size() ) tmp += line[i++];
            switch (++curr){
                case 1:{
                    file<<"    mov %rdi , "<<tmp<<endl;
                    flag--;
                    break;
                }
                case 2:{
                    file<<"    mov %rsi , "<<tmp<<endl;
                    flag++;
                    break;
                }
                case 3:{
                    file<<"    mov %rdx , "<<tmp<<endl;
                    flag++;
                    break;
                }
                case 4:{
                    file<<"    mov %rcx , "<<tmp<<endl;
                    flag++;
                    break;
                }
                case 5:{
                    file<<"    mov %r8 , "<<tmp<<endl;
                    flag++;
                    break;
                }
                case 6:{
                    file<<"    mov %r9 , "<<tmp<<endl;
                    flag++;
                    break;
                }
            }
            if(curr==flag){
                curr=0;
                flag=0;
            }
            continue;
        }
        else if(var == "return"){
            cout<<"in ret"<<endl;
            string returnv = "";
            while(i<line.size()) returnv += line[i++];
            freereg("r8");
            if(returnv.size()!=0 && isInteger(returnv)){
                file<<"    mov $"<<returnv<<", %r8"<<endl;
            }
            else{
                if(returnv.size()!=0)
                file<<"    mov "<<returnv<<", %r8"<<endl;
                else
                file<<"    mov $0 , %r8"<<endl;
            }
            file<<"    leave"<<endl;
            file<<"    ret"<<endl;
            continue;
        }
        else if(var[0]=='t'){
            string operand_1="",operand_2="",op="";int flag=0;
            while(i<line.size() and (line[i]==' ' or line[i]=='='))i++;
            while(i<line.size() and line[i]!=' '){
                operand_1+=line[i];
                i++;
            }
            if(operand_1=="call"){
                vector<string> params;
                string function = "";
                while((line[i]>='a' && line[i]<='z') || (line[i]>='A' && line[i]<='Z')|| (line[i]>='0' && line[i]<='9')){
                    function+=line[i++];
                }
                string str="";
                i++;
                cout<<"f name"<<function<<endl;
                while(i<line.length()){
                    while((line[i]>='a' && line[i]<='z') || (line[i]>='A' && line[i]<='Z') || (line[i]>='0' && line[i]<='9')){
                        str+=line[i++];
                    }
                    i++;
                    if(str.length()!=0)
                    params.push_back(str);
                    str="";
                }
                for(int i=0; i<params.size(); i++){
                    switch (i) {
                        case 0:{
                            freereg("rdi");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<" , %rdi"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<" , %rdi"<<endl;
                            }
                            break;
                        }
                        case 1:{
                            freereg("rsi");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<" , %rsi"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<" , %rsi"<<endl;
                            }
                            break;
                        }
                        case 2:{
                            freereg("rdx");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<" , %rdx"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<" , %rsdx"<<endl;
                            }
                            break;
                        }
                        case 3:{
                            freereg("rcx");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<" , %rcx"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<" , %rcx"<<endl;
                            }
                            break;
                        }
                        case 4:{
                            freereg("r8");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<" , %r8"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<" , %r8"<<endl;
                            }
                            break;
                        }
                        case 5:{
                            freereg("r9");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<" , %r9"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<" , %r9"<<endl;
                            }
                            break;
                        }
                    }
                }
                file<<"    call "<<function<<endl;
                file<<"    mov %r8 , "<<var<<endl;
                continue;
            }
            while(i<line.size() and line[i]==' ')i++;
             while(i<line.size() and line[i]!=' '){
                op+=line[i];
                i++;
            }
            while(i<line.size() and line[i]==' ')i++;
             while(i<line.size() and line[i]!=' '){
                operand_2+=line[i];
                i++;
            }
            while(i<line.size() and line[i]==' ')i++;
            cout<<operand_1<<" "<<op<<" "<<operand_2<<endl;
            //Cases: t1 = a , t1=6 , t1 = 6 op 7, t1 = a op 6 , t1 = 6 op a t1= a op c
            
            bool ope1_isNum=false, ope2_isNum=false;
            ope1_isNum =isInteger(operand_1);
            string reg1,reg2;
            if(op.empty()){
                if(ope1_isNum){reg1=getReg(var);file<<"\tmov $"<<operand_1<<" , %"<<reg1<<endl;}
                else{
                    reg1=getReg(operand_1);reg2=getReg(var); 
                    file<<"\tmov %"<<reg1<<" , %"<<reg2<<endl;}
            }
            else{
                ope2_isNum=isInteger(operand_2);
                // Just temporarily written.
                //This needs to be done based on operator case wise
                if(op=="+"){
                    if(ope1_isNum && ope2_isNum){
                        reg1=getReg(var);
                        file<<"\tmov $"<<stoi(operand_1)+stoi(operand_2)<<" , %"<<reg1<<endl;
                    }else if(ope1_isNum){
                        reg1=getReg(var);reg2=getReg(operand_2);
                        file<<"\tadd $"<<stoi(operand_1)<<" , %"<<reg2<<endl;
                        file<<"\tmov %"<<reg2<<" , %"<<reg1<<endl;
                    }else if(ope2_isNum){
                        reg1=getReg(var);reg2=getReg(operand_1);
                       file<<"\tadd $"<<stoi(operand_2)<<" , %"<<reg2<<endl;
                        file<<"\tmov %"<<reg2<<" , %"<<reg1<<endl;
                    }else{
                        reg1=getReg(operand_1);reg2=getReg(operand_2);
                        file<<"\tadd %"<<reg2<<" , %"<<reg1<<endl;
                        reg2=getReg(var);
                        file<<"\tmov %"<<reg1<<" , %"<<reg2<<endl;
                    }
                }
                else if (op=="-"){
                     if(ope1_isNum && ope2_isNum){
                        reg1=getReg(var);
                        file<<"\tmov $"<<stoi(operand_1)-stoi(operand_2)<<" , %"<<reg1<<endl;
                    }else if(ope1_isNum){
                        reg1=getReg(var);reg2=getReg(operand_2);
                        file<<"\tsub $"<<stoi(operand_1)<<" , %"<<reg2<<endl;
                        file<<"\tmov %"<<reg2<<" , %"<<reg1<<endl;
                    }else if(ope2_isNum){
                        reg1=getReg(var);reg2=getReg(operand_1);
                       file<<"\tsub $"<<stoi(operand_2)<<" , %"<<reg2<<endl;
                        file<<"\tmov %"<<reg2<<" , %"<<reg1<<endl;
                    }else{
                        reg1=getReg(operand_1);reg2=getReg(operand_2);
                        file<<"\tsub %"<<reg2<<" , %"<<reg1<<endl;
                        reg2=getReg(var);
                        file<<"\tmov %"<<reg1<<" , %"<<reg2<<endl;
                    }
                }else if(op=="*"){
                    if(ope1_isNum && ope2_isNum){
                        reg1=getReg(var);
                        file<<"\tmov $"<<stoi(operand_1)*stoi(operand_2)<<" , %"<<reg1<<endl;
                    }else if(ope1_isNum){
                        reg1=getReg(var);reg2=getReg(operand_2);
                        file<<"\timul $"<<stoi(operand_1)<<" , %"<<reg2<<endl;
                        file<<"\tmov %"<<reg2<<" , %"<<reg1<<endl;
                    }else if(ope2_isNum){
                        reg1=getReg(var);reg2=getReg(operand_1);
                       file<<"\timul $"<<stoi(operand_2)<<" , %"<<reg2<<endl;
                        file<<"\tmov %"<<reg2<<" , %"<<reg1<<endl;
                    }else{
                        reg1=getReg(operand_1);reg2=getReg(operand_2);
                        file<<"\timul %"<<reg2<<" , %"<<reg1<<endl;
                        reg2=getReg(var);
                        file<<"\tmov %"<<reg1<<" , %"<<reg2<<endl;
                    }
                }else if(op=="/"){
                    // Dividend into rax 
                    cout<<ope1_isNum<<ope2_isNum<<endl;
                    if(ope1_isNum && ope2_isNum){
                        reg1=getReg(var);
                        file<<"\tmov $"<<stoi(operand_1)/stoi(operand_2)<<" , %"<<reg1<<endl;
                    }else if(ope1_isNum){
                        freereg("rax");freereg("rbx");
                        file<<"\tmov %"<<operand_2<<" , %"<<"rax"<<endl;
                        file<<"\tmov $"<<operand_1<<" ,%"<<"rbx"<<endl;
                        file<<"\tidiv %"<<"rbx"<<endl;
                        reg1=getReg(var);
                        file<<"\tmov %eax, %"<<reg1<<endl;
                    }else if(ope2_isNum){
                        reg1=getReg(operand_1);while(reg1!="rax")reg1=getReg(operand_1);
                        freereg("rax");
                        file<<"\tmov $"<<operand_2<<" , %"<<"rax"<<endl;
                        file<<"\tidiv %"<<reg1<<endl;
                        reg2=getReg(var);
                        file<<"\tmov %eax"<<" , %"<<reg2<<endl;
                    }else{  
                        cout<<"here"<<endl;
                       reg1=getReg(operand_1);while(reg1!="rax")reg1=getReg(operand_1);
                        freereg("rax");
                        file<<"\tmov %"<<operand_2<<" , %"<<"rax"<<endl;
                        file<<"\tidiv %"<<reg1<<endl;
                        reg2=getReg(var);
                        file<<"\tmov %eax"<<" , %"<<reg2<<endl;
                    }
                }
            }  

        } // After this only expression of the form a=b or a=t1 is left
        else{
            
                string isNum="";
                while(line[i]==' ' or line[i]=='=' ){
                    i++;
                }
                while(i<line.size() && line[i]!=' '){
                    isNum+=line[i++];
                }
                if(isNum.empty())continue;

                cout<<"isNum\n"<<isNum<<endl;
                // If flag is true, then expression is of type a = 5,
                // else expression is of type a = t_i
                //One more case left to see is when  a = func()
                if(isNum=="call"){
                vector<string> params;
                string function = "";
                i++;
                while((line[i]>='a' && line[i]<='z') || (line[i]>='A' && line[i]<='Z')|| (line[i]>='0' && line[i]<='9')){
                    function+=line[i++];
                }
                string str="";
                i++;
                cout<<"f name"<<function<<endl;
                while(i<line.length()){
                    while((line[i]>='a' && line[i]<='z') || (line[i]>='A' && line[i]<='Z') || (line[i]>='0' && line[i]<='9')){
                        str+=line[i++];
                    }
                    i++;
                    if(str.length()!=0)
                    params.push_back(str);
                    str="";
                }
                for(int i=0; i<params.size(); i++){
                    switch (i) {
                        case 0:{
                            freereg("rdi");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<" , %rdi"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<" , %rdi"<<endl;
                            }
                            break;
                        }
                        case 1:{
                            freereg("rsi");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<" , %rsi"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<" , %rsi"<<endl;
                            }
                            break;
                        }
                        case 2:{
                            freereg("rdx");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<" , %rdx"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<" , %rsdx"<<endl;
                            }
                            break;
                        }
                        case 3:{
                            freereg("rcx");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<" , %rcx"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<" , %rcx"<<endl;
                            }
                            break;
                        }
                        case 4:{
                            freereg("r8");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<" , %r8"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<" , %r8"<<endl;
                            }
                            break;
                        }
                        case 5:{
                            freereg("r9");
                            if(isInteger(params[i])){
                                file<<"    "<<"mov $"<<params[i]<<" , %r9"<<endl;
                            }
                            else{
                                file<<"    "<<"mov "<<params[i]<<" , %r9"<<endl;
                            }
                            break;
                        }
                    }
                }
                file<<"    call "<<function<<endl;
                file<<"    mov %r8 , "<<var<<endl;
                continue;
            }
                bool flag=isInteger(isNum);
                if(isNum.empty())flag=false;
                if(flag )
                {
                    cout<<"inside flag"<<endl;
                    int num=stoi(isNum);  //storing in the global num for further use
                    string str = getReg(var);
                    file<<"\tmov $"<<num<<" , %"<<str<<endl<<"#this is when inside flag\n";
                }else {
                    string str = getReg(var), str2 =getReg(isNum) ;
                    file<<"\tmov %"<<str2<<" , %"<<str<<endl;
                }
        }

        // // Printing the label
        // if(line[line.size()-1]==':'){
        //         file << line<<endl;
        //         continue;
        // }

        // int type =expr_type(line);
        // if(type==1){
        //     getReg();
        // }
        // for(auto i:ad){
        //     cout<<i.first<<" "<<i.second<<endl;
        // }
       
        // cout << "Read line: \n" << line << '\n';
        
    }

    //exiting from the program
    file<<"\tmov $60, %rax"<<endl;
    file<<"\txor %rdi, %rdi"<<endl; 
    file<<"\tsyscall"<<endl;
    inputFile2.close();
     

 }