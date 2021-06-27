module entities.ProductEntity;

import entities.BaseEntity;
import std.variant;
import std.conv;
import mysql;

@Table("products")
class ProductEntity : BaseEntity
{

    string name;

    string photoUrl;

    int price;

    string description;

    this(Row row)
    {
        super(row);
        this.name = to!string(aa["name"]);
        this.description = to!string(aa["description"]);
        this.photoUrl = to!string(aa["photo_url"]);
        this.price = to!int(to!string(aa["price"]));
    }

    public override string getPersistString()
    {
        return "REPLACE INTO `products` (`id`, `name`, `photo_url`, `price`, `description`) VALUES (?, ?, ?, ?, ?);";
    }

    public override Variant[] getPersistValues()
    {
        return to!(Variant[])([to!string(id), name, photoUrl, to!string(price), description]);
    }

}
