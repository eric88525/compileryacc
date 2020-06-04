#include<iostream>
#include<vector>
#include<map>
#include "IDclass.hpp"
using namespace std;


class symboltable
{
	// use in record id name
	vector<string> symbolIndex;
	// save id data
	map <string,IDclass> tableMap;
	int index;
public:
	symboltable(){
		index = 0;
	};
	~symboltable();
	int insert(string id,IDclass c){
		if(hasSymbol(id)){
			return -1;
		}else{
			symbolIndex.push_back(id);
			tableMap[id] = c;
			tableMap[id].idIndex = index;
			return index++;
		}
	};
	IDclass* lookup(string id){
		if(hasSymbol(id)){
			return new IDclass(tableMap[id]);
		}
		return null;
	};
	bool hasSymbol(string id){
		if(tableMap.count(id)){
			return true;
		}else{
			return false;
		}
	};
	void dump();
	void setFunctionType(int type){
		int i = symbolIndex.size()-1;
		tableMap[symbolIndex[i]].type = type;
	};
	void addFunctionArg(string id,IDclass c){
		int i = symbolIndex.size()-1;
		tableMap[symbolIndex[i]].type = type;
	}
	
};

class symboltableList
{
	vector<symboltable> list;
	int stackTop;
public:
	symboltableList(){
		stackTop = -1;
		push();
	};
	~symboltableList();
	void push(){
		list.push_back(symboltable());
		stackTop++;
	};
	bool pop(){
		if(stackTop>=0){
			list.pop_back();
			stackTop--;
			return true;
		}else{
			return false;
		}
	};
	IDclass *lookup(string id){
		for(int i = stackTop;i>=0;i--){
			if(list[i].hasSymbol(id)){
				return list[i].lookup(id);
			}
		}
		return null;
	};
	void dump();
	int insert(string id,IDclass c){
		return list[stackTop].insert(id,c);
	};
	int insert(string id,int type,int size){
		IDclass x;
		x.arrayValue = std::vector<IDclass>(size);
		for(auto &i:x.arrayValue){
			i.idIndex = -1;
			i.idType = type;
			i.idFlag = variableFlag;
		}
		return list[stackTop].insert(id,x);
	};
	void setFunctionType(int type){
		list[stackTop-1].setFunctionType(type);
	};
	void addFunctionArg(string id,IDclass c){
		list[stackTop-1].addFunctionArg(id,c);
	};
};