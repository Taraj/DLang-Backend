module products.ProductController;

import vibe.http.common : HTTPMethod;
import vibe.web.rest;
import vibe.vibe;
import vibe.web.auth;

import utils.RestController : RestController;
import utils.LoggedUser;

import products.ProductService : ProductService;

@path("/products")
class ProductController : RestController
{
    private ProductService productService;

    this(ref ProductService productService)
    {
        this.productService = productService;
    }

    @anyAuth @method(HTTPMethod.GET)
    @path("")
    void login(HTTPServerRequest req, HTTPServerResponse res)
    {
        if ("pageSize" !in req.query || "pageNumber" !in req.query)
        {
            throw new HTTPStatusException(HTTPStatus.BadRequest, "\"pageNumber\" or \"pageSize\" missing");
        }
        res.writePrettyJsonBody(productService.getProducts(to!int(req.query.get("pageSize")), to!int(req.query.get("pageNumber"))));
    }
}
