import dotenv from "dotenv";
import { Secret } from "jsonwebtoken";

dotenv.config();

class DatabaseConfig {
  host: string;
  port: number;
  database: string;
  username: string;
  password: string;
  disableMigrations: boolean;
}

class RedisConfig {
  host: string;
  port: number;
}

class Config {
  redis: RedisConfig = {
    host: process.env.REDIS_HOST || "localhost",
    port: +process.env.REDIS_PORT || 6379,
  };

  database: DatabaseConfig = {
    host: process.env.DATABASE_HOST || "localhost",
    port: +process.env.DATABASE_PORT || 3306,
    database: process.env.DATABASE_NAME || "chore-management",
    username: process.env.DATABASE_USERNAME || "root",
    password: process.env.DATABASE_PASSWORD || "root",
    disableMigrations: process.env.DISABLE_MIGRATIONS?.toLowerCase() === "true",
  };

  adminApiKey: string = process.env.ADMIN_API_KEY;
  applicationSecret: Secret = process.env.APPLICATION_SECRET;
}

export default Config;
