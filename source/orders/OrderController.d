module orders.OrderController;

import vibe.http.common : HTTPMethod;
import vibe.web.rest;
import vibe.vibe;
import vibe.web.auth;
import utils.RestController : RestController;
import utils.LoggedUser;
import orders.OrderService : OrderService;
import orders.OrderDtos;
import utils.LoggedUser;

@path("/orders")
class OrderController : RestController
{
    private OrderService orderService;

    this(ref OrderService orderService)
    {
        this.orderService = orderService;
    }

    @anyAuth @method(HTTPMethod.POST)
    @path("/init")
    void buy(LoggedUser loggedUser, HTTPServerRequest req, HTTPServerResponse res)
    {
        res.writePrettyJsonBody(orderService.buy(new PaymentRequest(req.json()), loggedUser));
    }

    @noAuth @method(HTTPMethod.POST)
    @path("/complete")
    void complete(HTTPServerRequest req, HTTPServerResponse res)
    {
      orderService.completePayment(new CompletePaymenDto(req.json()));
      res.writeBody("");
    }

}
