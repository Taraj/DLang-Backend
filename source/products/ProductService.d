module products.ProductService;

import mysql;
import std.stdio;
import std.array;

import utils.DatabaseConnection;
import vibe.core.connectionpool;
import entities.UserEntity;
import vibe.vibe;
import vibe.web.auth;

import products.ProductDtos;
import entities.ProductEntity;

class ProductService
{
    private DatabaseConnection databaseConnection;

    this(ref DatabaseConnection databaseConnection)
    {
        this.databaseConnection = databaseConnection;
    }

    public ProductPageDto getProducts(int pageSize, int pageNumber)
    {
        return databaseConnection.runInTransaction((EntityManager em) {
            Row[] results = em.connection.query("SELECT * FROM `products` LIMIT ? OFFSET ?", pageSize, pageSize * pageNumber).array;

            return ProductPageDto(mapRowToDtos(results), pageSize,
                pageNumber, getProductsCount(em));
        });
    }

    private ProductRowDto[] mapRowToDtos(Row[] rows)
    {
        ProductRowDto[] dtos = [];

        foreach (Row row; rows)
        {
            dtos ~= new ProductRowDto(new ProductEntity(row));
        }

        return dtos;
    }

    private int getProductsCount(EntityManager em)
    {
        Row[] results = em.connection.query("SELECT COUNT(*) FROM `products`",).array;

        return to!int(to!string(results[0][0]));
    }
}
