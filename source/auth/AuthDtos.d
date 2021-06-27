module auth.AuthDtos;

import vibe.data.json;
import vibe.vibe;

class LoginResponseDto
{
    string accessToken;
    long id;
    string firstName;
    string lastName;

    this(string accessToken, long id, string firstName, string lastName)
    {
        this.id = id;
        this.accessToken = accessToken;
        this.firstName = firstName;
        this.lastName = lastName;
    }
}

class LoginRequestDto
{
    string accessToken;

    this(Json body)
    {
        if (body["accessToken"].type == Json.Type.string)
        {
            this.accessToken = body["accessToken"].to!string;
        }
        else
        {
            throw new HTTPStatusException(HTTPStatus.BadRequest, "\"accessToken\" missing");
        }
    }
}
