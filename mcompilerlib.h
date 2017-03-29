#include <iostream>
#include <cstring>
#include <vector>

class token{
public:
    std::string type;
    std::string value;
    token(std::string, std::string);
    token(std::string);
};
class return_code{
public:
    int code;
    std::string mes;
    return_code( int );
    return_code( std::string );
};
class symbol_table{
public:
    std::vector<std::string> names;
    std::vector<std::string> types;
    std::vector<std::string> vals;
    int operator[]( const std::string& );
    void add( std::string, std::string, std::string );
};
inline
bool operator==(const token& a, const token& b){
    if( b.type==a.type ){
        return 1;
    }else{
        return 0;
    }
}
inline
bool operator!=(const token& a, const token& b){
    if( b.type!=a.type ){
        return 1;
    }else{
        return 0;
    }
}

inline
bool operator!=(const return_code& eca, const return_code& ecb){
    if( eca.code==ecb.code ){
        return 0;
    }else{
        return 1;
    }
}
inline
bool operator==(const return_code& eca, const return_code& ecb){
    if( eca.code==ecb.code ){
        return 1;
    }else{
        return 0;
    }
}

inline
std::ostream & operator<<(std::ostream & Str, token const & v) {
    Str << v.type << "  " << v.value ;
    return Str;
}
inline
std::ostream & operator<<(std::ostream & Str, return_code const & ec) {
    Str << ec.mes ;
    return Str;
}

