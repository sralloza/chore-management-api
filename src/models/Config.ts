import { Secret } from "jsonwebtoken";

class Config {
  serverPort: number = +process.env.PORT || 8080;
  redisHost: string = process.env.REDIS_HOST || "localhost";
  redisPort: number = +process.env.REDIS_PORT || 6379;

  adminApiKey: string = process.env.ADMIN_API_KEY || "admin";
  applicationSecret: Secret = process.env.APPLICATION_SECRET;
}

export default Config;
