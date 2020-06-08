
#include<map>
#include "IDclass.hpp"

using namespace std;

class symboltable
{
	// use in record id name
	vector<string> symbolIndex;
	// save id data
	map <string, IDclass> tableMap;
	int index;
public:
	symboltable() {
		index = 0;
	};
	~symboltable() {};
	int insert(string id, const IDclass &c) {
		cout << "symboltable insert ID: "<<id<<"\n";
		if (hasSymbol(id)) {
			return -1;
		}
		else {
			symbolIndex.push_back(id);
			tableMap[id].id = id;
			tableMap[id].idType = c.idType;
			tableMap[id].idFlag = c.idFlag;
			tableMap[id].init = c.init;
			tableMap[id].idIndex = index;
			tableMap[id].setValue(c);
			return index++;
		}
	};
	IDclass* lookup(string id) {
		IDclass * c;
		if (hasSymbol(id)) {
			c = &tableMap[id];
			return c;
		}
		return NULL;
	};
	bool hasSymbol(string id) {
		if (tableMap.count(id)) {
			return true;
		}
		else {
			return false;
		}
	};
	void setFunctionType(int type) {
		int i = symbolIndex.size() - 1;
		tableMap[symbolIndex[i]].idType = type;
	};
	void addFunctionArg(string id, IDclass c) {
		int i = symbolIndex.size() - 1;
		tableMap[symbolIndex[i]].arrayValue.push_back(c);
	}
	void dump() {
		cout << "<id>\t<flag>\t<type>\t<value>" << endl;
		string s;
		for (int i = 0; i < index; ++i)
		{
			IDclass info;
			info = tableMap[symbolIndex[i]];
			//info.copy(tableMap[symbolIndex[i]]);
			//info.id = symbolIndex[i];
			s = info.id + "\t";
			switch (info.idFlag) {
			case constVariableFlag: s += "val\t"; break;
			case variableFlag: s += "var\t"; break;
			case functionFlag: s += "method\t"; break;
			case objectFlag:   s += "object\t"; break;
			}
			switch (info.idType) {
			case intType: s += "int\t"; break;
			case realType: s += "float\t"; break;
			case boolType: s += "bool\t"; break;
			case charType: s+= "char\t"; break;
			case strType: s += "str\t"; break;
			case arrayType: s += "array\t"; break;
			case voidType: s += "void\t"; break;
			case None:		s+= "none\t"; break;
			}
			if (info.init) {
				switch (info.idType) {
				case intType: s += to_string(info.idData.ival); break;
				case realType: s += to_string(info.idData.fval); break;
				case boolType: s += (info.idData.bval) ? "true" : "false"; break;
				case strType: s += info.idData.sval; break;
				case charType: s+= info.idData.cval; break;
				}
			}
			if (info.idFlag == functionFlag) {
				s += "{ ";
				for (int i = 0; i < info.arrayValue.size(); ++i) {
					switch (info.arrayValue[i].idType) {
					case intType: s += "int "; break;
					case realType: s += "float "; break;
					case boolType: s += "bool "; break;
					case strType: s += "str "; break;
					case charType: s+= "char";break;
					}
				}
				s += "}";
			}
			if (info.idType == arrayType) {
				s += "{ ";
				switch (info.arrayValue[0].idType) {
				case intType: s += "int, "; break;
				case realType: s += "float, "; break;
				case boolType: s += "bool, "; break;
				case strType: s += "str, "; break;
				case charType: s+= "char, ";break;
				}
				s += to_string(info.arrayValue.size()) + " }";
			}
			cout << s << endl;
		}
		cout << endl;
	};

};

class symboltableList
{
	vector<symboltable> list;
	int stackTop;
public:
	symboltableList() {
		stackTop = -1;
		push();
	};
	~symboltableList() {};
	void push() {
		cout << "Add one frame,stack top now is " << stackTop + 1 << "\n";
		list.push_back(symboltable());
		stackTop++;
	};
	bool pop() {
		if (stackTop >= 0) {
			list.pop_back();
			stackTop--;
			return true;
		}
		else {
			return false;
		}
	};
	IDclass *lookup(string id) {
		for (int i = stackTop; i >= 0; i--) {
			if (list[i].hasSymbol(id)) {
				return list[i].lookup(id);
			}
		}
		return NULL;
	};
	void dump() {
		cout << "<--------- Dump Start --------->" << endl << endl;
		for (int i = stackTop; i >= 0; --i) {
			cout << "Frame index: " << i << endl;
			list[i].dump();
		}
		cout << "<---------- Dump End ---------->" << endl;
	};
	int insert(string id, const IDclass &c) {
		return list[stackTop].insert(id, c);
	};
	int insert(string id, int type, int size) {
		IDclass* c = new IDclass();
		c->idType = arrayType;
		c->idFlag = variableFlag;
		c->arrayValue = std::vector<IDclass>(size);
		for (auto &i : c->arrayValue) {
			i.idIndex = -1;
			i.idType = type;
			i.idFlag = variableFlag;
		}
		return list[stackTop].insert(id, *c);
	};
	void setFunctionType(int type) {
		list[stackTop - 1].setFunctionType(type);
	};
	void addFunctionArg(string id, IDclass c) {
		cout << "Now frame is " << stackTop << " adding function arg" << "\n";
		list[stackTop - 1].addFunctionArg(id, c);
	};
};