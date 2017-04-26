%{
    #include <iostream>
    #include <cstring>
    #include <vector>
    #include <sstream>
    #include "mcompilerlib.h"
    using namespace std;
    vector<token> token_stream;
    vector<token> parsed_stream;
    token peek( vector<token> vt ){
        return vt[0];
    }
    token tail( vector<token> vt ){
        return vt[vt.size()-1];
    }
    void pop( vector<token>& vt ){
        vt.erase(vt.begin());
    }
    void pop_back( vector<token>& vt ){
        vt.erase(vt.end()-1);
    }
    return_code rc(0);
    symbol_table stable;
    return_code Prog();
    return_code Dcls();
    return_code Dcl();
    return_code Stmts();
    return_code Stmt();
    return_code Expr();
    return_code Val();
%}

floatdcl float
intdcl   int
print    print
id       [_a-zA-Z]+[a-zA-Z0-9]*
assign   "="
plus     "+"
minus    "-"
inum     [0-9]+
fnum     [0-9]+\.[0-9]+
blank    (" ")+
eol      [\n\t\r]

%X COMMENT
%X STRING 
%%
{floatdcl}  { token_stream.push_back( token("float"  ,yytext) ); }
{intdcl}    { token_stream.push_back( token("int"    ,yytext) ); }
{print}     { token_stream.push_back( token("print"  ,yytext) ); }
{id}        { token_stream.push_back( token("id"     ,yytext) ); }
{assign}    { token_stream.push_back( token("assign" ,yytext) ); }
{plus}      { token_stream.push_back( token("plus"   ,yytext) ); }
{minus}     { token_stream.push_back( token("minus"  ,yytext) ); }
{inum}      { token_stream.push_back( token("inum"   ,yytext) ); }
{fnum}      { token_stream.push_back( token("fnum"   ,yytext) ); }
{blank}
"/*"          { BEGIN COMMENT;}
<COMMENT>.|{eol} { }
<COMMENT>"*/" { BEGIN INITIAL;}
"\""          { BEGIN STRING; }
<STRING>[^\"\n]*\" { string t = string(yytext).substr(0,strlen(yytext)-1);token_stream.push_back( token("string"  , t)); BEGIN INITIAL; }
{eol}         {} 
.             {}

%%

int main(int argc, const char * argv[]) {
    yylex();
    token_stream.push_back( token("END"   ,"$"));
    rc = Prog();
    if( rc != return_code(0) ){
        cout << "error" << endl;
        cerr << rc << endl;
        cerr << "============================" << endl;
        for( int i = 0 ; i < token_stream.size() ; i++ ){
            cerr << token_stream[i] << " ";
        }
        cerr << endl<<"============================" << endl;
        for( int i = 0 ; i < parsed_stream.size() ; i++ ){
            cout << parsed_stream[i] << " ";
        }
        cerr << endl << "========end=================" << endl;
    }else{
        cout << "success" << endl;
    }
    return 0;
}
/*
grammar

Prog  -> Dcls Stmts

Dcls  -> Dcl Dcls
       | λ

Dcl   -> floatdcl id
       | intdcl id

Stmts -> Stmt Stmts
       | λ

Stmt  -> id assign Val Expr
       | print id

Expr  -> plus Val Expr
       | minus Val Expr
       | λ

Val   -> id
       | inum
       | fnum

FIRST set
Dcls  λ, floatdcl, intdcl
Dcl   floatdcl, intdcl
Stmts λ, id, print
Stmt  id, print
Expr  plus, minus, λ
Val   id, inum, fnum
Prog  λ, floatdcl, intdcl, id, print

FOLLOW set
Prog  $
Dcls  id, print, $
Dcl   floatdcl, intdcl, id, print, $
Stmts $
Stmt  id, print, $
Expr  id, print, $
Val   plus, minus, id, print, $

Predict Set
1     Prog → Dcls Stmts          floatdcl, intdcl, id, print
2     Dcls → Dcl Dcls            floatdcl, intdcl
3     Dcls → λ                   id, print, $
4     Dcl → floatdcl id          floatdcl
5     Dcl → intdcl id            intdcl
6     Stmts → Stmt Stmts         id, print
7     Stmts → λ                  $ 
8     Stmt → id assign Val Expr  id
9     Stmt → print id            print
10    Expr → plus Val Expr       plus
11    Expr → minus Val Expr      minus
12    Expr → λ                   id, print, $
13    Val → id                   id
14    Val → inum                 inum
15    Val → fnum                 fnum
*/


return_code Prog(){
    if( 
        peek(token_stream) == token("float") ||
        peek(token_stream) == token("int")   ||
        peek(token_stream) == token("id")       ||
        peek(token_stream) == token("print")
      )
    {
        if( (rc = Dcls())!=return_code(0)){
            return rc;
        }
        return Stmts();
    }else if( peek(token_stream) == token("END") ){
        return return_code(0);
    }
    else{
        return return_code(1);
    }
}

return_code Dcls(){
    if( 
        peek(token_stream) == token("float") ||
        peek(token_stream) == token("int")
      )
    {
        if( ( rc=Dcl() ) != return_code(0) ){
            return rc;
         }
    }else if( 
        peek(token_stream) == token("id")       ||
        peek(token_stream) == token("print")    ||
        peek(token_stream) == token("END")
            )
    {
        return return_code(0);
    }else{
        return return_code(2);
    }
    return Dcls();
}

return_code Dcl(){
    if( peek(token_stream) == token("float") ){
        parsed_stream.push_back(peek(token_stream));
        pop(token_stream);
        if( peek(token_stream)!=token("id") )
            return return_code(3);
        stable.add("float", peek(token_stream).value, "0.0");
        parsed_stream.push_back(peek(token_stream));
        pop(token_stream);
    }else if( peek(token_stream) == token("int") ){
        parsed_stream.push_back(peek(token_stream));
        pop(token_stream);
        if( peek(token_stream)!=token("id") )
            return return_code(3);
        stable.add("int", peek(token_stream).value, "0");
        parsed_stream.push_back(peek(token_stream));
        pop(token_stream);
    }else{
        return return_code(10);
    }
    return return_code(0);
}

return_code Stmts(){
    if( 
        peek(token_stream) == token("id") ||
        peek(token_stream) == token("print")
      )
    {
        if( ( rc=Stmt() ) != return_code(0) ){
            return rc;
        }
    }else if( 
        peek(token_stream) == token("END")
            )
    {
        return return_code(0);
    }else{
        return return_code(4);
    }
    return Stmts();
}

return_code Stmt(){
    if( peek(token_stream) == token("id") ){
        string tid =  peek(token_stream).value; 
        parsed_stream.push_back(peek(token_stream));
        pop(token_stream);
        if(  peek(token_stream) == token("assign")  ){
            parsed_stream.push_back(peek(token_stream));
            pop(token_stream);
            if( (rc = Val())!=0 ){
                return rc;
            }
            if( (rc = Expr())!=0 ){
                return rc;
            }
            int index = stable[tid];
            stable.vals[index]=tail(parsed_stream).value;
        }else{
            return return_code(6);
        }
    }else if( peek(token_stream) == token("print") ){
        parsed_stream.push_back(peek(token_stream));
        pop(token_stream);
        if(  peek(token_stream) == token("id")  ){
            cout << stable.vals[stable[ peek(token_stream).value ]] << endl;
            parsed_stream.push_back(peek(token_stream));
            pop(token_stream);
        }else if( peek(token_stream) == token("string") ){
            cout << peek(token_stream).value << endl;
            parsed_stream.push_back(peek(token_stream));
            pop(token_stream);
        }else{
            return return_code(7);
        }
    }
    else{
        return return_code(5);
    }
    return return_code(0);
}
return_code Val(){
    if( 
        peek(token_stream) == token("id")    ||
        peek(token_stream) == token("inum")  ||
        peek(token_stream) == token("fnum")
      )
    {
        parsed_stream.push_back(peek(token_stream));
        pop(token_stream);
        return return_code(0);
    }else{
        return return_code(8);
    }
}

void alu( string op,string a, string b ){
    stringstream ss;
    ss << a;
    float numa;
    ss >> numa;
    ss.str("");
    ss.clear();

    ss << b;
    float numb;
    ss >> numb;
    ss.str("");
    ss.clear();
    float num;
    if( op == "plus"){
        num = numa + numb;
    }
    else if( op == "minus" ){
        num = numb - numa;
    }
    string result;
    pop(token_stream);
    pop_back(parsed_stream);
    if( num == (int)num ){
       ss << (int)num;
       ss >> result;
       parsed_stream.push_back( token("inum", result) );
    }
    else{
       ss << num;
       ss >> result;
       parsed_stream.push_back( token("fnum", result) );
    }
    
}

return_code Expr(){
    if(  peek(token_stream) == token("plus")  ){
        pop(token_stream);
        if( peek(token_stream)!=token("id") && tail(parsed_stream)!=token("id") )
            alu( "plus", peek(token_stream).value, tail(parsed_stream).value );
        else{
            string a, b;
            if(peek(token_stream)==token("id")){
                a = stable.vals[stable[peek(token_stream).value]];
            }else
                a = peek(token_stream).value;
            if(tail(parsed_stream)==token("id")){
                b = stable.vals[stable[tail(parsed_stream).value]];
            }else
                b = tail(parsed_stream).value;
            alu( "plus", a, b );
        }
    }else if(  peek(token_stream) == token("minus")  ){
        pop(token_stream);
        if( peek(token_stream)!=token("id") && tail(parsed_stream)!=token("id") )
            alu( "minus", peek(token_stream).value, tail(parsed_stream).value );
        else{
            string a, b;
            if(peek(token_stream)==token("id")){
                a = stable.vals[stable[peek(token_stream).value]];
            }else
                a = peek(token_stream).value;
            if(tail(parsed_stream)==token("id")){
                b = stable.vals[stable[tail(parsed_stream).value]];
            }else
                b = tail(parsed_stream).value;
            alu( "minus", a, b );
        }
    }else if( 
        peek(token_stream) == token("id")       ||
        peek(token_stream) == token("print")    ||
        peek(token_stream) == token("END")
            )
    {
        return return_code(0);
    }else{
        return return_code(9);
    }
    return Expr();
}

