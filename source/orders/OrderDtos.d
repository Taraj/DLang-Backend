module orders.OrderDtos;

import vibe.data.json;
import vibe.vibe;
import std.array;
import std.stdio;

class PaymentResponse
{
    string paymentId;

    this(string paymentId)
    {
        this.paymentId = paymentId;
    }
}

class CompletePaymenDto
{
    string paymentId;

    this(Json body)
    {
        if (body["paymentId"].type == Json.Type.String)
        {
            this.paymentId = body["paymentId"].to!string;
        }
        else
        {
            throw new HTTPStatusException(HTTPStatus.BadRequest, "\"paymentId\" missing");
        }
    }
}

class PaymentRequest
{
    long[] productIds;
    this(Json body)
    {
        if (body["productIds"].type == Json.Type.Array)
        {
            this.productIds = [];
            foreach (Json value; body["productIds"])
            {
                this.productIds ~= toLong(value);
            }
        }
        else
        {
            throw new HTTPStatusException(HTTPStatus.BadRequest, "\"productIds\" missing");
        }
    }

    private long toLong(Json value)
    {
        if (value.type == Json.Type.Int)
        {
            return value.to!long;
        }
        else
        {
            throw new HTTPStatusException(HTTPStatus.BadRequest, "\"productIds\" must be int");
        }
    }
}
