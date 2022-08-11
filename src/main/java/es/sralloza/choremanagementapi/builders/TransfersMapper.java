package es.sralloza.choremanagementapi.builders;

import es.sralloza.choremanagementapi.models.custom.Transfer;
import es.sralloza.choremanagementapi.models.db.DBTransfer;
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
