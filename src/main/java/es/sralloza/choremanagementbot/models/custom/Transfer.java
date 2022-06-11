package es.sralloza.choremanagementbot.models.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.experimental.Accessors;

import java.time.LocalDateTime;

@Data
@Accessors(chain = true)
public class Transfer {
    private Long id;
    private LocalDateTime timestamp;
    @JsonProperty("tenant_id_from")
    private Integer tenantIdFrom;
    @JsonProperty("tenant_id_to")
    private Integer tenantIdTo;
    @JsonProperty("chore_type")
    private String choreType;
    @JsonProperty("week_id")
    private String weekId;
    private Boolean accepted;
    private Boolean completed;
}
