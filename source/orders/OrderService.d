module orders.OrderService;

import mysql;
import std.stdio;
import std.array;

import utils.DatabaseConnection;
import vibe.core.connectionpool;
import entities.UserEntity;
import vibe.vibe;
import vibe.web.auth;
import config.Config : Config;
import orders.OrderDtos;
import utils.LoggedUser;
import entities.ProductEntity;
import entities.OrderEntity;
import entities.OrderProductEntity;

interface PayPalAPI
{

    struct Ammount
    {
        string currency_code = "USD";
        int value;

        this(int value)
        {
            this.value = value;
        }
    }

    struct Breakdown
    {
        Ammount item_total;
    }

    struct AmmountWithBreakdown
    {
        string currency_code = "USD";
        int value;
        Breakdown breakdown;

        this(int value)
        {
            this.value = value;
            this.breakdown = Breakdown(Ammount(value));
        }
    }

    struct Item
    {
        string name;
        Ammount unit_amount;
        int quantity;

        this(string name, int quantity, int cost)
        {
            this.name = name;
            this.quantity = quantity;
            this.unit_amount = Ammount(cost);
        }
    }

    struct PurchaseUnits
    {
        AmmountWithBreakdown amount;
        Item[] items;

        this(Item[] items)
        {
            this.items = items;
            int totalItemsCost = 0;

            foreach (Item it; items)
            {
                totalItemsCost += it.unit_amount.value * it.quantity;
            }

            this.amount = AmmountWithBreakdown(totalItemsCost);
        }
    }

    struct ApplicationContext
    {
        string brand_name = "Project DLang";
        string shipping_preference = "NO_SHIPPING";
    }

    struct CreateOrderDto
    {
        string intent = "CAPTURE";
        PurchaseUnits[] purchase_units;
        ApplicationContext application_context = ApplicationContext();

        this(Item[] items)
        {
            this.purchase_units = [PurchaseUnits(items)];
        }
    }

    @path("/v2/checkout/orders") @method(HTTPMethod.POST)
    Json createOrder(@viaHeader("Authorization") string auth, @viaBody() CreateOrderDto dto);

    @path("/v2/checkout/orders/:orderId") @method(HTTPMethod.GET)
    Json getOrderDetails(@viaHeader("Authorization") string auth, string _orderId);

    @path("/v2/checkout/orders/:orderId/capture") @method(HTTPMethod.POST)
    Json capture(@viaHeader("Authorization") string auth, string _orderId);

}

class OrderService
{
    private DatabaseConnection databaseConnection;

    this(ref DatabaseConnection databaseConnection)
    {
        this.databaseConnection = databaseConnection;
    }

    public PaymentResponse buy(PaymentRequest dto, LoggedUser loggedUser)
    {
        return databaseConnection.runInTransaction((EntityManager em) {
            ProductEntity[] products = getProducts(em, dto.productIds);
            string paymentId = createPayment(createItems(products));
            OrderEntity order = em.save(new OrderEntity(loggedUser.id, Clock.currTime.toUnixTime(), paymentId, OrderStatus.PENDING));
            foreach (ProductEntity product; products)
            {
                em.save(new OrderProductEntity(order.id, product.id));
            }
            return new PaymentResponse(paymentId);
        });
    }

    public void completePayment(CompletePaymenDto dto)
    {
        databaseConnection.runInTransaction((EntityManager em) {
            OrderEntity order = findOrderByPaymentId(em, dto.paymentId);
            if (order is null)
            {
                throw new HTTPStatusException(HTTPStatus.Gone, "Order with paymentId " ~ dto.paymentId ~ " not found");
            }

            if (order.status == OrderStatus.PAID)
            {
                return;
            }

            string orderStatus = getPaymentStatus(dto.paymentId);

            if (orderStatus != "APPROVED" && orderStatus != "COMPLETED")
            {
                throw new HTTPStatusException(HTTPStatus.BadRequest, "Order not paid");
            }

            if (orderStatus == "APPROVED") {
                capturePayments(dto.paymentId);
            }
            
            order.status = OrderStatus.PAID;

            em.save(order);
        });
    }

    private OrderEntity findOrderByPaymentId(EntityManager em, string paymentId)
    {
        Row[] results = em.connection.query("SELECT * FROM `orders` WHERE `payment_id` = ?", paymentId).array;

        if (results.length == 0)
        {
            return null;
        }

        return new OrderEntity(results[0]);
    }

    private string createPayment(PayPalAPI.Item[] items)
    {
        PayPalAPI.CreateOrderDto createOrderDto = PayPalAPI.CreateOrderDto(items);
        RestInterfaceClient!PayPalAPI client = new RestInterfaceClient!PayPalAPI(Config.PAYPAL_API_URL);
        Json payment = client.createOrder(Config.PAYAPL_API_KEY, createOrderDto);
        return payment["id"].to!string;
    }

    private string getPaymentStatus(string paymentId)
    {
        RestInterfaceClient!PayPalAPI client = new RestInterfaceClient!PayPalAPI(Config.PAYPAL_API_URL);
        Json payment = client.getOrderDetails(Config.PAYAPL_API_KEY, paymentId);
        return payment["status"].to!string;
    }

    private void capturePayments(string paymentId)
    {
        RestInterfaceClient!PayPalAPI client = new RestInterfaceClient!PayPalAPI(Config.PAYPAL_API_URL);
        client.capture(Config.PAYAPL_API_KEY, paymentId);
    }

    private ProductEntity[] getProducts(EntityManager em, long[] productIds)
    {
        ProductEntity[] products = [];

        foreach (long productId; productIds)
        {
            ProductEntity product = em.findById!ProductEntity(productId);

            if (product is null)
            {
                throw new HTTPStatusException(HTTPStatus.Gone, "Product with id " ~ to!string(productId) ~ " not found");
            }

            products ~= product;
        }

        return products;
    }

    private PayPalAPI.Item[] createItems(ProductEntity[] products)
    {
        PayPalAPI.Item[] items = [];

        foreach (ProductEntity product; products)
        {
            items ~= PayPalAPI.Item(product.name, 1, product.price);
        }

        return items;
    }

}
