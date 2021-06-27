import vibe.vibe;
import std.stdio;
import mysql;
import vibe.core.connectionpool;
import utils.DatabaseConnection;

import auth.AuthController;
import auth.AuthService;
import products.ProductService;
import products.ProductController;
import orders.OrderService;
import orders.OrderController;


void main()
{
	HTTPServerSettings settings = new HTTPServerSettings;
	settings.port = 8080;

	URLRouter router = new URLRouter();

	DatabaseConnection connection = new DatabaseConnection();

	//////////////////////////////////////////////////// DI container ////////////////////////////////////////////////////
	AuthService authService = new AuthService(connection);
	ProductService productService = new ProductService(connection);
	OrderService orderService = new OrderService(connection);

	AuthController authController = new AuthController(authService);
	ProductController productController = new ProductController(productService);
	OrderController orderController = new OrderController(orderService);
	//////////////////////////////////////////////////// DI container ////////////////////////////////////////////////////

	router.registerWebInterface(authController);
	router.registerWebInterface(productController);
	router.registerWebInterface(orderController);

	router.any("*", (HTTPServerRequest req, HTTPServerResponse res) {
		res.headers["Access-Control-Allow-Origin"] = "*";
		res.headers["Access-Control-Allow-Headers"] = "*";
		res.writeBody("");
	});

	HTTPServerRequestDelegate handleCORS()
	{
		return (HTTPServerRequest req, HTTPServerResponse res) {
			res.headers["Access-Control-Allow-Origin"] = "*";
			res.headers["Access-Control-Allow-Headers"] = "*";
			router.handleRequest(req, res);
		};
	}

	HTTPListener listener = listenHTTP(settings, handleCORS());

	scope (exit)
	{
		listener.stopListening();
	}

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	runApplication();
}
