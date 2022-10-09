package es.sralloza.choremanagementapi.services;

import es.sralloza.choremanagementapi.builders.SimpleUserMapper;
import es.sralloza.choremanagementapi.builders.UserMapper;
import es.sralloza.choremanagementapi.exceptions.BadRequestException;
import es.sralloza.choremanagementapi.exceptions.ConflictException;
import es.sralloza.choremanagementapi.exceptions.NotFoundException;
import es.sralloza.choremanagementapi.models.custom.ChoreTypeTickets;
import es.sralloza.choremanagementapi.models.custom.SimpleUser;
import es.sralloza.choremanagementapi.models.custom.User;
import es.sralloza.choremanagementapi.models.db.DBUser;
import es.sralloza.choremanagementapi.models.io.UserCreate;
import es.sralloza.choremanagementapi.repositories.db.DBChoresRepository;
import es.sralloza.choremanagementapi.repositories.db.DBUsersRepository;
import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Supplier;
import java.util.stream.Collectors;

@Service
public class UsersService {
    @Autowired
    private DBUsersRepository repository;
    @Autowired
    private SkipWeeksService skipWeeksService;
    @Autowired
    private TicketsService ticketsService;
    @Autowired
    private DBChoresRepository dbChoresRepository;
    @Autowired
    private UserMapper userMapper;
    @Autowired
    private SimpleUserMapper simpleUserMapper;

    public List<User> listUsers() {
        return repository.findAll().stream()
                .map(userMapper::build)
                .collect(Collectors.toList());
    }

    public SimpleUser getSimpleUserById(Long userId) {
        return simpleUserMapper.build(getUserById(userId));
    }

    public User getUserById(Long userId) {
        return getUserById(userId, getNotFoundException(userId));
    }

    public User getUserById(Long userId, Supplier<? extends RuntimeException> exceptionSupplier) {
        return repository.findById(userId)
                .map(userMapper::build)
                .orElseThrow(exceptionSupplier);
    }

    public String getUsersHash() {
        Set<Long> userIds = listUsers().stream()
                .map(User::getUserId)
                .collect(Collectors.toSet());
        return DigestUtils.sha256Hex(userIds.toString());
    }

    public User createUser(UserCreate userCreate, String flatName) {
        if (repository.existsById(userCreate.getUser_id())) {
            throw new ConflictException("User with id " + userCreate.getUser_id() + " already exists");
        }
        String uuid = UUID.randomUUID().toString();
        var user = new DBUser(userCreate.getUser_id(), userCreate.getUsername(), uuid, flatName);
        repository.save(user);
        ticketsService.createTicketsForUser(user.getUserId());
        return userMapper.build(user);
    }

    public void deleteUserById(Long userId) {
        if (!repository.existsById(userId)) {
            throw getNotFoundException(userId).get();
        }

        User user = getUserById(userId);
        List<ChoreTypeTickets> tickets = ticketsService.listChoreTypeTickets();
        for (var choreTypeTickets : tickets) {
            Map<String, Long> ticketsMap = choreTypeTickets.getTicketsByUser();
            if (ticketsMap.get(user.getUsername()) != 0) {
                throw new BadRequestException("User has unbalanced tickets");
            }
        }

        var pendingChores = dbChoresRepository.findAll().stream()
                .filter(dbChore -> dbChore.getUserId().equals(userId))
                .filter(dbChore -> dbChore.getDone().equals(false))
                .count();
        if (pendingChores != 0) {
            throw new BadRequestException("User has " + pendingChores + " pending chores");
        }

        repository.deleteById(userId);

        skipWeeksService.deleteSkipWeeksByUserId(userId);
        ticketsService.deleteTicketsByUser(userId);
    }

    private Supplier<NotFoundException> getNotFoundException(Long userId) {
        return () -> new NotFoundException("No user found with id " + userId);
    }

    public User recreateUserToken(Long id) {
        User user = getUserById(id);
        UUID uuid = UUID.randomUUID();
        user.setApiKey(uuid);
        repository.save(userMapper.build(user));
        return user;
    }
}
