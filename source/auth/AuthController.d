module auth.AuthController;

import vibe.http.common : HTTPMethod;
import vibe.web.rest;
import vibe.vibe;
import vibe.web.auth;
import utils.RestController : RestController;
import utils.LoggedUser;
import auth.AuthService : AuthService;
import auth.AuthDtos : LoginRequestDto;

@path("/auth")
class AuthController : RestController
{
    private AuthService authService;

    this(ref AuthService authService)
    {
        this.authService = authService;
    }

    @noAuth @method(HTTPMethod.POST)
    @path("/login")
    void login(HTTPServerRequest req, HTTPServerResponse res)
    {
        res.writePrettyJsonBody(authService.login(new LoginRequestDto(req.json())));
    }

}
