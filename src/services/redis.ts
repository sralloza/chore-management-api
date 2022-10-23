import { createClient } from "redis";

const host = process.env.REDIS_HOST || "localhost";
const port = process.env.REDIS_PORT || 6379;

const url = `redis://${host}:${port}`;
const client = createClient({ url });

class RedisClient {
  async connect() {
    await client.connect();
  }

  async set(key: string, value: string, expiresMinutes: number) {
    await client.setEx(key, expiresMinutes * 60, value);
  }

  async get(key: string) {
    return await client.get(key);
  }
}

const redisClient = new RedisClient();
export default redisClient;
