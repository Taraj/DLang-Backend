module entities.UserEntity;

import entities.BaseEntity;
import std.variant;
import std.conv;
import mysql;

@Table("users")
class UserEntity : BaseEntity
{

    string firstName;

    string lastName;

    string googleId;

    string email;

    this(string firstName, string lastName, string googleId, string email)
    {
        this.firstName = firstName;
        this.lastName = lastName;
        this.googleId = googleId;
        this.email = email;
    }

    this(Row row)
    {
        super(row);
        this.firstName = to!string(aa["first_name"]);
        this.lastName = to!string(aa["last_name"]);
        this.googleId = to!string(aa["google_id"]);
        this.email = to!string(aa["email"]);
    }

    public override string getPersistString()
    {
        return "REPLACE INTO `users` (`id`, `first_name`, `last_name`, `google_id`, `email`) VALUES (?, ?, ?, ?, ?);";
    }

    public override Variant[] getPersistValues()
    {
        return to!(Variant[])([ to!string(id), firstName, lastName, googleId, email ]);
    }

}
