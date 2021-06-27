module entities.BaseEntity;

import std.variant;
import std.conv;
import mysql;
import std.stdio;

struct Table
{
    string name;
}

abstract class BaseEntity
{

    long id;

    protected Variant[string] aa;

    this(Row row)
    {

        for (int i = 0; i < row.length; i++)
        {
            aa[row.getName(i)] = row[i];
        }

        this.id = to!long(to!string(aa["id"]));
    }

    this()
    {

    }

    abstract public string getPersistString();

    abstract public Variant[] getPersistValues();

}
