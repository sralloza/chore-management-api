package es.sralloza.choremanagementapi.services;

import es.sralloza.choremanagementapi.builders.FlatMapper;
import es.sralloza.choremanagementapi.exceptions.ConflictException;
import es.sralloza.choremanagementapi.exceptions.ForbiddenException;
import es.sralloza.choremanagementapi.models.custom.Flat;
import es.sralloza.choremanagementapi.models.custom.FlatCreateCode;
import es.sralloza.choremanagementapi.models.db.DBFlat;
import es.sralloza.choremanagementapi.models.io.FlatCreate;
import es.sralloza.choremanagementapi.repositories.db.DBFlatsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class FlatsService {
    @Autowired
    private JWTService jwtService;
    @Autowired
    private DBFlatsRepository dbFlatsRepository;
    @Autowired
    private RedisService redisService;
    @Autowired
    private FlatMapper flatMapper;

    public FlatCreateCode requestFlatCreateCode() {
        long now = System.currentTimeMillis();
        long next5Mins = now + 5 * 60 * 1000;

        var code = jwtService.generateToken(now, next5Mins);
        return new FlatCreateCode()
            .setCode(code)
            .setExpiresAt(OffsetDateTime.ofInstant(Instant.ofEpochMilli(next5Mins), ZoneId.systemDefault()));
    }

    public List<Flat> listFlats() {
        return dbFlatsRepository.findAll().stream()
            .map(flatMapper::build)
            .collect(Collectors.toList());
    }

    public Optional<Flat> getFlatByApiKey(String apiKey) {
        return dbFlatsRepository.findByApiKey(apiKey)
            .map(flatMapper::build);
    }

    public Flat createFlat(FlatCreate flatCreate) {
        if (!jwtService.isTokenValid(flatCreate.getCreateCode())) {
            throw new ForbiddenException("Invalid create code");
        }

        if (redisService.get(flatCreate.getCreateCode()) != null) {
            throw new ForbiddenException("Invalid create code");
        }

        if (dbFlatsRepository.existsById(flatCreate.getName())) {
            throw new ConflictException("Flat already exists");
        }

        var dbFlat = new DBFlat()
            .setName(flatCreate.getName())
            .setApiKey(UUID.randomUUID().toString())
            .setAssignmentOrder("")
            .setRotationSign("positive");
        DBFlat result = dbFlatsRepository.save(dbFlat);

        redisService.set(flatCreate.getCreateCode(), result.getName(), 5 * 60);
        return flatMapper.build(result);
    }
}
