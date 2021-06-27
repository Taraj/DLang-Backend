module entities.OrderEntity;

import entities.BaseEntity;
import std.variant;
import std.conv;
import mysql;

enum OrderStatus
{
    PENDING = "PENDING",
    PAID = "PAID"
}

@Table("orders")
class OrderEntity : BaseEntity
{

    long userId;

    long createdAt;

    string paymentId;

    OrderStatus status;

    this(long userId, long createdAt, string paymentId, OrderStatus status)
    {
        this.userId = userId;
        this.createdAt = createdAt;
        this.paymentId = paymentId;
        this.status = status;
    }

    this(Row row)
    {
        super(row);
        this.userId = to!long(to!string(aa["user_id"]));
        this.createdAt = to!long(to!string(aa["created_at"]));
        this.paymentId = to!string(aa["payment_id"]);
        this.status = to!OrderStatus(to!string(aa["status"]));
    }

    public override string getPersistString()
    {
        if (this.id == 0)
        {
            return "INSERT INTO `orders` (`id`, `user_id`, `created_at`, `status`, `payment_id`) VALUES (?, ?, ?, ?, ?);";
        }
        else
        {
            return "UPDATE `orders` SET `user_id`= ?, `payment_id`= ?, `status`= ?, `created_at`= ? WHERE id = ?";
        }
    }

    public override Variant[] getPersistValues()
    {
        if (this.id == 0)
        {
            return to!(Variant[])([to!string(id), to!string(userId), to!string(createdAt), to!string(status), paymentId]);
        }
        else
        {
            return to!(Variant[])([to!string(userId), paymentId, to!string(status), to!string(createdAt), to!string(id)]);
        }
    }

}
