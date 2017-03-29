#include "mcompilerlib.h"

using namespace std;

token::token( string _type ){
    type = _type;
    value = "none";
}
token::token( string _type, string _value ){
    type = _type;
    value = _value;
}

return_code::return_code( int _code ){
    code = _code;
    switch( _code ){
        case 0:
                mes = "No error";
            break;
        case 1:
                mes = "parsing \"Prog()\" error";
            break;
        case 2:
                mes = "parsing \"Dcls()\" error";
            break;
        case 3:
                mes = "parsing \"Dcl()\" error\n";
                mes+= "except id here";
            break;
        case 4:
                mes = "parsing \"Stmts()\" error";
            break;
        case 5:
                mes = "parsing \"Stmt()\" error";
            break;
        case 6:
                mes = "parsing \"Stmt()\" error\n";
                mes+= "except assign here";
            break;
        case 7:
                mes = "parsing \"Stmt()\" error\n";
                mes+= "except id here";
            break;
        case 8:
                mes = "parsing \"Val()\" error";
            break;
        case 9:
                mes = "parsing \"Expr()\" error";
            break;
        case 10:
                mes = "parsing \"Dcl()\" error";
            break;
        default:
                mes = "unknow error";
            break;
    }
}
return_code::return_code( string _mes ){
    code = -1;
    mes = _mes;
}

int symbol_table::operator[]( const string& index ){
    for( int i = 0 ; i < names.size() ; i++ ){
        if( names[i] == index ){
            return i;
        }
    }
    cerr <<"\""<<index << "\""<< "Symbol not found !!" << endl;
    throw(std::exception());
}
void symbol_table::add( string _type, string _name, string _val ){
    types.push_back( _type );
    names.push_back( _name );
    vals.push_back( _val );
}
