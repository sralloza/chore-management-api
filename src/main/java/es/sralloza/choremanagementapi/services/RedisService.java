package es.sralloza.choremanagementapi.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import redis.clients.jedis.Jedis;

@Service
public class RedisService {
    private final Jedis jedis;

    public RedisService(@Value("${redis.host}") String host,
                        @Value("${redis.port}") int port) {
        jedis = new Jedis(host, port);
    }

    public void set(String key, String value, int ttl) {
        jedis.setex(key, ttl, value);
    }

    public String get(String key) {
        return jedis.get(key);
    }
}
