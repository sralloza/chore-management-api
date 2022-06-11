package es.sralloza.choremanagementbot.services;

import es.sralloza.choremanagementbot.builders.TransfersMapper;
import es.sralloza.choremanagementbot.exceptions.BadRequestException;
import es.sralloza.choremanagementbot.exceptions.ForbiddenException;
import es.sralloza.choremanagementbot.exceptions.NotFoundException;
import es.sralloza.choremanagementbot.models.custom.ChoreType;
import es.sralloza.choremanagementbot.models.custom.Tenant;
import es.sralloza.choremanagementbot.models.custom.Transfer;
import es.sralloza.choremanagementbot.models.db.DBChore;
import es.sralloza.choremanagementbot.models.db.DBTransfer;
import es.sralloza.choremanagementbot.repositories.db.DBChoresRepository;
import es.sralloza.choremanagementbot.repositories.db.DBTransfersRepository;
import es.sralloza.choremanagementbot.utils.DateProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.List;
import java.util.Optional;
import java.util.function.Supplier;
import java.util.stream.Collectors;

@Service
@Transactional
public class TransferChoresService {
    @Autowired
    private TenantsService tenantsService;
    @Autowired
    private TicketsService ticketsService;
    @Autowired
    private ChoreTypesService choreTypesService;
    @Autowired
    private DBChoresRepository dbChoresRepository;
    @Autowired
    private DBTransfersRepository repository;
    @Autowired
    private TransfersMapper mapper;
    @Autowired
    private DateProvider dateProvider;

    public List<Transfer> listTransfers() {
        return repository.findAll().stream()
                .map(mapper::build)
                .collect(Collectors.toList());
    }

    public Transfer getTransferById(Long id) {
        return repository.findById(id)
                .map(mapper::build)
                .orElseThrow(() -> new NotFoundException("No transfer found with id " + id));
    }

    public Transfer registerTransfer(Integer from, Integer to, String choreType, String weekId) {
        DBTransfer transfer = new DBTransfer()
                .setTenantIdFrom(from)
                .setTenantIdTo(to)
                .setChoreType(choreType)
                .setWeekId(weekId)
                .setTimestamp(dateProvider.getCurrentMillis())
                .setCompleted(false)
                .setAccepted(null);
        repository.save(transfer);
        return mapper.build(transfer);
    }

    public Transfer startTransfer(Integer from, Integer to, String choreTypeId, String weekId) {
        if (from.equals(to)) {
            throw new BadRequestException("Cannot transfer chore to the same tenant");
        }

        Optional<DBTransfer> existsInProgress = repository.findAll().stream()
                .filter(transfer -> transfer.getTenantIdFrom().equals(from))
                .filter(transfer -> transfer.getChoreType().equals(choreTypeId))
                .filter(transfer -> transfer.getWeekId().equals(weekId))
                .filter(transfer -> !transfer.getCompleted())
                .findAny();

        if (existsInProgress.isPresent()) {
            throw new BadRequestException("Cannot transfer chore to multiple tenants");
        }

        Tenant tenantOrigin = tenantsService.getTenantById(from, getTenantNotFoundException(from));
        tenantsService.getTenantById(to, getTenantNotFoundException(to));
        ChoreType choreType = choreTypesService.getChoreTypeById(choreTypeId,
                () -> new BadRequestException("Chore type with id " + choreTypeId + " does not exist"));

        DBChore originalChore = findChoreByTypeAndWeek(choreType.getId(), weekId);

        if (!originalChore.getTenantId().equals(tenantOrigin.getTenantId())) {
            var originalTenantName = tenantsService.getTenantById(originalChore.getTenantId()).getUsername();
            var msg = "You cannot transfer chores from other tenants. The chore you " +
                    "are trying to transfer is assigned to " + originalTenantName + ".";
            throw new ForbiddenException(msg);
        }
        return registerTransfer(from, to, choreTypeId, weekId);
    }

    private Transfer completeTransfer(Long id, Boolean accepted) {
        DBTransfer transfer = repository.findById(id)
                .orElseThrow(() -> new NotFoundException("No transfer found with id " + id));

        if (transfer.getCompleted()) {
            throw new BadRequestException("Transfer with id " + id + " is already completed");
        }

        if (accepted) {
            DBChore originalChore = findChoreByTypeAndWeek(transfer.getChoreType(), transfer.getWeekId());

            ticketsService.addTicketsToTenant(transfer.getTenantIdFrom(), transfer.getChoreType(), -1);
            ticketsService.addTicketsToTenant(transfer.getTenantIdTo(), transfer.getChoreType(), 1);
            originalChore.setTenantId(transfer.getTenantIdTo());
        }

        transfer.setTimestamp(dateProvider.getCurrentMillis());
        transfer.setCompleted(true);
        transfer.setAccepted(accepted);
        return mapper.build(transfer);
    }

    public Transfer acceptTransfer(Long id) {
        return completeTransfer(id, true);
    }

    public Transfer rejectTransfer(Long id) {
        return completeTransfer(id, false);
    }

    public void deleteTransfer(Long id) {
        repository.deleteById(id);
    }

    private DBChore findChoreByTypeAndWeek(String choreType, String weekId) {
        return dbChoresRepository.findAll().stream()
                .filter(dbChore -> dbChore.getChoreType().equals(choreType))
                .filter(dbChore -> dbChore.getWeekId().equals(weekId))
                .findAny()
                .orElseThrow(() -> new NotFoundException("Chore not found"));

    }

    private Supplier<BadRequestException> getTenantNotFoundException(Integer tenantId) {
        return () -> new BadRequestException("Tenant with id " + tenantId + " does not exist");
    }
}
