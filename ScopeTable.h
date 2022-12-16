#include <string>
#include <fstream>
#include "SymbolInfo.h"

class ScopeTable {
    SymbolInfo **table;
    int size, id;
    ScopeTable *parentScope;
public:
    //hash function
    unsigned int SDBMHash(std::string str){
        unsigned int hash = 0;
        for (int i = 0; i < str.length(); i++)
        {
            hash = (str[i] + (hash << 6) + (hash << 16) - hash)%size;
        }
        return hash;
    }
    //constructor
    ScopeTable(int size, int id, ScopeTable *parentScope) {
        this->size = size;
        this->id = id;
        this->parentScope = parentScope;
        table = new SymbolInfo*[size];
        for (int i = 0; i < size; i++) {
            table[i] = NULL;
        }
    }
    //destructor
    ~ScopeTable() {
        for (int i = 0; i < size; i++) {
            while(table[i]!=NULL){
                SymbolInfo *temp = table[i];
                table[i] = table[i]->getNext();
                delete temp;
            }
        }
        delete[] table;
    }

    //getters
    int getId() {
        return id;
    }
    ScopeTable* getParentScope() {
        return parentScope;
    }

    //insert
    bool insertSymbol(std::string name, std::string type){
        unsigned int hash=SDBMHash(name)%size,pos=1;
        SymbolInfo *temp = table[hash];
        if(temp==NULL){
            table[hash] = new SymbolInfo(name,type);
            pos=0;
        }
        else {
            while(temp->getNext()!=NULL){
                if(temp->getName()==name){
                    return false;
                }
                temp = temp->getNext();
                pos++;
            }
            if(temp->getName()==name){
                return false;
            }
            temp->setNext(new SymbolInfo(name,type));
        }
        return true;
    }

    //search
    SymbolInfo* lookUpSymbol(std::string name){
        int pos=1;
        unsigned int hash=SDBMHash(name)%size;
        SymbolInfo *temp = table[hash];
        while(temp!=NULL){
            if(temp->getName()==name){
                return temp;
            }
            temp=temp->getNext();
            pos++;
        }
        return NULL;
    }

    //delete
    bool deleteSymbol(std::string name){
        unsigned int hash=SDBMHash(name)%size,pos=1;
        SymbolInfo *temp = table[hash],*pre=NULL;
        if(temp==NULL){
            return false;
        }
        while(temp!=NULL){
            if(temp->getName()==name){
                if(pre==NULL)
                    table[hash] = temp->getNext();
                else
                    pre->setNext(temp->getNext());
                
                delete temp;
                return true;
            }
            pre = temp;
            temp = temp->getNext();
            pos++;
        }
        return false;
    }

    //print Table
    void printTable(std::ofstream &out){
        for (int i = 1; i <= size; i++) {
            SymbolInfo *temp = table[i-1];
            if(temp!=NULL)out<<"\t"<<i<<"--> ";
            while(temp!=NULL){
                out<<"<"<<temp->getName()<<","<<temp->getType()<<"> ";
                temp = temp->getNext();
            }
        }
    }

};