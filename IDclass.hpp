
#include <iostream>
#include <string>
#include <vector>
using namespace std;

struct ID_Data {
	int ival = 0;
	float fval = 0.0;
	bool bval = false;
	string sval = "";
};

enum type {
	intType,
	realType,
	boolType,
	strType,
	arrayType,
	voidType,
	None
};

enum idFlag {
	constValueFlag,
	constVariableFlag,
	variableFlag,
	functionFlag,
	objectFlag
};


class IDclass
{
public:
	string id;
	ID_Data idData;
	int idType;
	int idFlag;
	int idIndex;
	bool init;
	vector<IDclass> arrayValue;

	IDclass() {
		idType = intType;
		idFlag = variableFlag;
		idIndex = 0;
		init = false;
	}
	IDclass(const IDclass& c) {
		idType = c.idType;
		idFlag = c.idFlag;
		idIndex = c.idIndex;
		id = c.id;
		init = c.init;
		setValue(c);
	}

	IDclass(int idF, int idT, bool idInit) {
		idType = idT;
		idFlag = idF;
		init = idInit;
	}
	~IDclass() {};
	void setValue(const IDclass &c) {
		idData.ival = c.idData.ival;
		idData.fval = c.idData.fval;
		idData.bval = c.idData.bval;
		idData.sval = c.idData.sval;
		arrayValue = c.arrayValue;
	}
};

IDclass *intConst(int val)
{
	IDclass* c = new IDclass(constValueFlag, intType, true);
	c->idIndex = 0;
	c->idData.ival = val;
	return c;
}

IDclass *realConst(float val)
{
	IDclass* c = new IDclass(constValueFlag, realType, false);
	c->idIndex = 0;
	c->idData.fval = val;
	return c;
}

IDclass *boolConst(bool val)
{
	IDclass* c = new IDclass(constValueFlag, boolType, false);
	c->idIndex = 0;
	c->idData.bval = val;
	return c;
}

IDclass *strConst(string *val)
{
	IDclass* c = new IDclass(constValueFlag, strType, false);
	c->idIndex = 0;
	c->idData.sval = *val;
	return c;
}

/*IDclass operator + (IDclass lhs, const IDclass& rhs)
{
	IDclass c = IDclass();
	if(!(lhs.init && rhs.init))
		return c;
	switch(c.idType)
	{
		case intType: c.idData.ival=(lhs.ival + rhs.ival); break;
		case realType: cidData.fval=(lhs.fval + rhs.fval); break;
	}
	return c;
}

IDclass operator - (IDclass lhs, const IDclass& rhs)
{
	IDclass c = IDclass();
	if(!(lhs.init && rhs.init))
		return c;
	switch(c.idType)
	{
		case intType: c.idData.ival=(lhs.idData.ival - rhs.idData.ival); break;
		case realType: c.idData.fval=(lhs.idData.fval - rhs.idData.fval); break;
	}
	return c;
}

IDclass operator * (IDclass lhs, const IDclass& rhs)
{
	IDclass c = IDclass();
	if(!(lhs.init && rhs.init))
		return c;
	switch(c.idType)
	{
		case intType: c.idData.ival=(lhs.idData.ival * rhs.idData.ival); break;
		case realType: c.idData.fval=(lhs.idData.fval * rhs.idData.fval); break;
	}
	return c;
}

IDclass operator / (IDclass lhs, const IDclass& rhs)
{
	IDclass c = IDclass();
	if(!(lhs.init && rhs.init))
		return c;
	switch(c.idType)
	{
		case intType: c.idData.ival=(lhs.idData.ival / rhs.idData.ival); break;
		case realType: c.idData.fval=(lhs.idData.fval / rhs.idData.fval); break;
	}
	return c;
}

IDclass operator < (IDclass lhs, const IDclass& rhs)
{
	IDclass c = IDclass(Boolean);
	if(!(lhs.init && rhs.init))
		return c;
	switch()
	{
		case intType: c.set_boolean(lhs.ival < rhs.ival); break;
		case realType: c.set_boolean(lhs.fval < rhs.fval); break;
		case Boolean: c.set_boolean(lhs.bval < rhs.bval); break;
	}
	
	return c;
}

IDclass operator > (IDclass lhs, const IDclass& rhs)
{
	IDclass c = IDclass(Boolean);
	if(!(lhs.init && rhs.init))
		return c;
	switch()
	{
		case intType: c.set_boolean(lhs.ival > rhs.ival); break;
		case realType: c.set_boolean(lhs.fval > rhs.fval); break;
		case Boolean: c.set_boolean(lhs.bval > rhs.bval); break;
	}
	return c;
}

IDclass operator <= (IDclass lhs, const IDclass& rhs)
{
	IDclass c = IDclass(Boolean);
	if(!(lhs.init && rhs.init))
		return c;
	switch()
	{
		case intType: c.set_boolean(lhs.ival <= rhs.ival); break;
		case realType: c.set_boolean(lhs.fval <= rhs.fval); break;
		case Boolean: c.set_boolean(lhs.bval <= rhs.bval); break;
	}
	return c;
}

IDclass operator == (IDclass lhs, const IDclass& rhs)
{
	IDclass c = IDclass(Boolean);
	if(!(lhs.init && rhs.init))
		return c;
	switch()
	{
		case intType: c.set_boolean(lhs.ival == rhs.ival); break;
		case realType: c.set_boolean(lhs.fval == rhs.fval); break;
		case Boolean: c.set_boolean(lhs.bval == rhs.bval); break;
	}
	return c;
}

IDclass operator >= (IDclass lhs, const IDclass& rhs)
{
	IDclass c = IDclass(Boolean);
	if(!(lhs.init && rhs.init))
		return c;
	switch()
	{
		case intType: c.set_boolean(lhs.ival >= rhs.ival); break;
		case realType: c.set_boolean(lhs.fval >= rhs.fval); break;
		case Boolean: c.set_boolean(lhs.bval >= rhs.bval); break;
	}
	return c;
}

IDclass operator != (IDclass lhs, const IDclass& rhs)
{
	IDclass c = IDclass(Boolean);
	if(!(lhs.init && rhs.init))
		return c;
	switch()
	{
		case intType: c.set_boolean(lhs.ival != rhs.ival); break;
		case realType: c.set_boolean(lhs.fval != rhs.fval); break;
		case Boolean: c.set_boolean(lhs.bval != rhs.bval); break;
	}
	return c;
}

IDclass operator && (IDclass lhs, const IDclass& rhs)
{
	IDclass c = IDclass(Boolean);
	if(!(lhs.init && rhs.init))
		return c;
	switch()
	{
		case intType: c.set_boolean(lhs.ival != rhs.ival); break;
		case realType: c.set_boolean(lhs.fval != rhs.fval); break;
		case Boolean: c.set_boolean(lhs.bval != rhs.bval); break;
	}
	return c;
}*/