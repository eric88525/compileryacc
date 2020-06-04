#include <iostream>
using namespace std;

enum ID_Type{
  intType,
  realType,
  boolType,
  strType,
  arrayType,
  voidType
};

enum ID_Flag {
  constValueFlag,
  constVariableFlag,
  variableFlag,
  functionFlag
};
union ID_Data{
	int ival;
	double dval;
	bool bval;
	string sval;
	idData(){
        ival = 0;
        dval = 0.0;
        bval = false;
        sval = "";
    }
}

class IDclass
{	
public:
	ID_Data idValue;
	int idType;
	int idFlag;
	int idIndex;
	bool init;
	vector<IDclass> arrayValue;

	IDclass(){
		idType = intType;
		idFlag = variableFlag;
		idIndex = 0;
		init = false;
	};
	IDclass(IDclass id){
		idType = id.idType;
		idFlag = id.idFlag;
		idIndex = idIndex;
		init = id.init;
		arrayValue = id.arrayValue;
	}
	~IDclass();	
	void setIDValue(ID_Data x){
		idValue = x;
	};
	void setIDType(int t){
		idType = t;
	};
	void setIDFlag(int f){
		idFlag = f;
	};

};