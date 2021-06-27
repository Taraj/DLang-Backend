module config.Config;

import std.process;

class Config
{
     @property static string GOOGLE_API_URL()
    {
        return environment.get("GOOGLE_API_URL");
    }

    @property static string PAYAPL_API_KEY()
    {
        return "Basic " ~ environment.get("PAYAPL_API_KEY");
    }

    @property static string PAYPAL_API_URL()
    {
        return environment.get("PAYPAL_API_URL");
    }

    @property static string DATABASE_URL()
    {
        return environment.get("DATABASE_URL");
    }

    @property static string DATABASE_NAME()
    {
        return environment.get("DATABASE_NAME");
    }

    @property static string DATABASE_USERNAME()
    {
        return environment.get("DATABASE_USERNAME");
    }

    @property static string DATABASE_PASSWORD()
    {
        return environment.get("DATABASE_PASSWORD");
    }

     @property static string JWT_SECRET()
    {
        return environment.get("JWT_SECRET");
    }

}
