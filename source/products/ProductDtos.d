module products.ProductDtos;

import vibe.data.json;
import entities.ProductEntity;

class ProductRowDto
{
    long id;
    string photoUrl;
    string name;
    string description;
    int price;

    this(ProductEntity product)
    {
        this.id = product.id;
        this.photoUrl = product.photoUrl;
        this.name = product.name;
        this.description = product.description;
        this.price = product.price;
    }
}

struct ProductPageDto
{
    ProductRowDto[] content;
    int pageSize;
    int pageNumber;
    int total;
}
