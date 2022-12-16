#include<string>

class SymbolInfo {
    std::string name, type;
    SymbolInfo *next;
public:
    SymbolInfo() {
        name = "";
        type = "";
        next = NULL;
    }
    SymbolInfo(std::string name, std::string type) {
        this->name = name;
        this->type = type;
        next = NULL;
    }
    //getters
    std::string getName() {
        return name;
    }
    std::string getType() {
        return type;
    }
    SymbolInfo* getNext() {
        return next;
    }
    //setter
    void setName(std::string name) {
        this->name = name;
    }
    void setType(std::string type) {
        this->type = type;
    }
    void setNext(SymbolInfo *next) {
        this->next = next;
    }
};