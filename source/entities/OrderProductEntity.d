module entities.OrderProductEntity;

import entities.BaseEntity;
import std.variant;
import std.conv;
import mysql;

@Table("orders_products")
class OrderProductEntity : BaseEntity
{

    long orderId;

    long productId;

    this(long orderId, long productId)
    {
        this.orderId = orderId;
        this.productId = productId;
    }

    this(Row row)
    {
        super(row);
        this.orderId = to!long(to!string(aa["order_id"]));
        this.productId = to!long(to!string(aa["product_id"]));
    }

    public override string getPersistString()
    {
        return "REPLACE INTO `orders_products` (`id`, `order_id`,  `product_id`) VALUES (?, ?, ?);";
    }

    public override Variant[] getPersistValues()
    {
        return to!(Variant[])([to!string(id), to!string(orderId), to!string(productId)]);
    }

}
