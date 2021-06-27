module utils.RestController;

import vibe.vibe;
import vibe.web.auth;
import utils.LoggedUser;
import std.stdio;
import jwt.jwt;
import jwt.exceptions;
import jwt.algorithms;
import std.range;
import std.algorithm;
import std.string;
import config.Config;

@requiresAuth abstract class RestController
{
    @noRoute LoggedUser authenticate(HTTPServerRequest req, HTTPServerResponse res)
    {
        if ("Authorization" in req.headers)
        {

            Token token = verify(req.headers["Authorization"].dropExactly("Bearer ".length), Config.JWT_SECRET, [JWTAlgorithm.HS512, JWTAlgorithm.HS256]);

            return LoggedUser(token.claims.getInt("userId"));

        }

        throw new HTTPStatusException(HTTPStatus.forbidden, "Not authorized to perform this action!");
    }
}
