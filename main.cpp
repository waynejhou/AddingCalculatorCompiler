//
//  main.cpp
//  adding_calculator
//
//  Created by Wayne on 2017/3/4.
//  Copyright © 2017年 Wayne. All rights reserved.
//

#include <iostream>
#include <cstring>
#include <vector>

using namespace std;

class token{
public:
    string type;
    string value;
    token(string , string );
};
token::token(string _type, string _value){
    type = _type;
    value = _value;
}
vector<token> token_stream;




int main(int argc, const char * argv[]) {
    switch (<#expression#>) {
        case <#constant#>:
            <#statements#>
            break;
            
        default:
            break;
    }
    vector<string> a;
    
    return 0;
}
