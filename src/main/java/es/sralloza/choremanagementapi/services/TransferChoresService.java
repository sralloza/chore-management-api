package es.sralloza.choremanagementapi.services;

import es.sralloza.choremanagementapi.builders.TransfersMapper;
import es.sralloza.choremanagementapi.exceptions.BadRequestException;
import es.sralloza.choremanagementapi.exceptions.ForbiddenException;
import es.sralloza.choremanagementapi.exceptions.NotFoundException;
import es.sralloza.choremanagementapi.models.custom.ChoreType;
import es.sralloza.choremanagementapi.models.custom.Tenant;
import es.sralloza.choremanagementapi.models.custom.Transfer;
import es.sralloza.choremanagementapi.models.db.DBChore;
import es.sralloza.choremanagementapi.models.db.DBTransfer;
import es.sralloza.choremanagementapi.repositories.db.DBChoresRepository;
import es.sralloza.choremanagementapi.repositories.db.DBTransfersRepository;
import es.sralloza.choremanagementapi.utils.DateProvider;
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

    public Transfer registerTransfer(Long from, Long to, String choreType, String weekId) {
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

    public Transfer startTransfer(Long from, Long to, String choreTypeId, String weekId) {
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

    private Supplier<BadRequestException> getTenantNotFoundException(Long tenantId) {
        return () -> new BadRequestException("Tenant with id " + tenantId + " does not exist");
    }
}