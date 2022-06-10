package es.sralloza.choremanagementbot.builders;

import es.sralloza.choremanagementbot.models.custom.Transfer;
import es.sralloza.choremanagementbot.models.db.DBTransfer;
import org.springframework.stereotype.Service;

@Service
public class TransfersMapper {
    public Transfer build(DBTransfer transfer) {
        return new Transfer()
                .setId(transfer.getId())
                .setTimestamp(transfer.getTimestamp())
                .setTenantIdFrom(transfer.getTenantIdFrom())
                .setTenantIdTo(transfer.getTenantIdTo())
                .setChoreType(transfer.getChoreType())
                .setWeekId(transfer.getWeekId())
                .setCompleted(transfer.getCompleted());
    }
}
