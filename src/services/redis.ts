import { createClient } from "redis";
import config from "../core/config";

const url = `redis://${config.redis.host}:${config.redis.port}`;
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
