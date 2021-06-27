module utils.DatabaseConnection;

import mysql;
import std.stdio;
import std.array;
import entities.BaseEntity;

import vibe.core.connectionpool;
import config.Config;

import std.stdio;
class EntityManager
{
    LockedConnection!Connection connection;

    this(LockedConnection!Connection connection)
    {
        this.connection = connection;
    }

    template save(T : BaseEntity)
    {
        T save(T entity)
        {
            string tableName = __traits(getAttributes, T)[0].name;
            connection.exec(entity.getPersistString(), entity.getPersistValues());
            
            if (entity.id == 0) {
                Row[] results = connection.query("SELECT * FROM `" ~ tableName ~ "` WHERE id = LAST_INSERT_ID()").array;
                return new T(results[0]);
            }
           
            Row[] results = connection.query("SELECT * FROM `" ~ tableName ~ "` WHERE id = ?", entity.id).array;
            return new T(results[0]);
        }
    }

    template findById(T : BaseEntity)
    {
        T findById(long id)
        {
            string tableName = __traits(getAttributes, T)[0].name;
            Row[] results = connection.query("SELECT * FROM `" ~ tableName ~ "` WHERE id = ?", id).array;
            if (results.length == 0)
            {
                return null;
            }
            return new T(results[0]);
        }
    }
}

class DatabaseConnection
{
    private MySQLPool connectionPool;

    this()
    {
        connectionPool = new MySQLPool(Config.DATABASE_URL, Config.DATABASE_USERNAME, Config.DATABASE_PASSWORD, Config.DATABASE_NAME, 3306);
        connectionPool.lockConnection();
    }

    void runInTransaction(void delegate(EntityManager) fun)
    {
        LockedConnection!Connection connection = connectionPool.lockConnection();
        connection.exec("START TRANSACTION;");
        try
        {
            fun(new EntityManager(connection));
        }
        catch (Throwable e)
        {
            connection.exec("ROLLBACK;");
            throw e;
        }

        connection.exec("COMMIT;");
    }

    template runInTransaction(T)
    {
        T runInTransaction(T delegate(EntityManager) fun)
        {
            LockedConnection!Connection connection = connectionPool.lockConnection();
            connection.exec("START TRANSACTION;");
            try
            {
                T val = fun(new EntityManager(connection));
                connection.exec("COMMIT;");
                return val;
            }
            catch (Throwable e)
            {
                connection.exec("ROLLBACK;");
                throw e;
            }
        }

    }

}
