package es.sralloza.choremanagementbot.builders;

import es.sralloza.choremanagementbot.models.custom.Transfer;
import es.sralloza.choremanagementbot.models.db.DBTransfer;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;

@Service
public class TransfersMapper {
    public Transfer build(DBTransfer transfer) {
        return new Transfer()
                .setId(transfer.getId())
                .setTimestamp(LocalDateTime.ofInstant(Instant.ofEpochMilli(transfer.getTimestamp()),
                        ZoneId.systemDefault()))
                .setTenantIdFrom(transfer.getTenantIdFrom())
                .setTenantIdTo(transfer.getTenantIdTo())
                .setChoreType(transfer.getChoreType())
                .setWeekId(transfer.getWeekId())
                .setAccepted(transfer.getAccepted())
                .setCompleted(transfer.getCompleted());
    }
}
