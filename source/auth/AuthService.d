module auth.AuthService;

import std.array;
import vibe.core.connectionpool;
import vibe.vibe;
import mysql;
import jwt.jwt;
import jwt.algorithms;
import utils.DatabaseConnection;
import entities.UserEntity;
import auth.AuthDtos;
import config.Config;


interface GoogleAPI
{
    struct UserInfo
    {
        string email;
        string id;
        bool verified_email;
        string name;
        string given_name;
        string family_name;
        string picture;
        string locale;
    }

    @path("/oauth2/v2/userinfo")
    UserInfo getUserProfile(@viaHeader("Authorization") string param);
}

class AuthService
{
    private DatabaseConnection databaseConnection;

    this(ref DatabaseConnection databaseConnection)
    {
        this.databaseConnection = databaseConnection;
    }

    public LoginResponseDto login(LoginRequestDto dto)
    {
        RestInterfaceClient!GoogleAPI client = new RestInterfaceClient!GoogleAPI(Config.GOOGLE_API_URL);
        GoogleAPI.UserInfo userInfo;
        try
        {
            userInfo = client.getUserProfile("Bearer " ~ dto.accessToken);
        }
        catch (Throwable _)
        {
            throw new HTTPStatusException(HTTPStatus.Unauthorized, "Invalid token");
        }

        return databaseConnection.runInTransaction((EntityManager em) {
            UserEntity user = findUserByGoogleId(em, userInfo.id);

            if (user is null)
            {
                user = em.save(new UserEntity(userInfo.given_name, userInfo.family_name, userInfo.id, userInfo.email));
            }

            Token token = new Token(JWTAlgorithm.HS512);
            token.claims.set("userId", user.id);

            return new LoginResponseDto(token.encode(Config.JWT_SECRET), user.id, user.firstName, user.lastName);
        });

    }

    private UserEntity findUserByGoogleId(EntityManager em, string googleId)
    {
        Row[] results = em.connection.query("SELECT * FROM `users` WHERE `google_id` = ?", googleId).array;

        if (results.length == 0)
        {
            return null;
        }

        return new UserEntity(results[0]);
    }

}
