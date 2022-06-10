package es.sralloza.choremanagementbot.models.io;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Positive;

@Data
@NoArgsConstructor
public class TransferCreate {
    @JsonProperty("tenant_id_from")
    @NotNull(message = "tenant_id_from is required")
    @Positive(message = "tenant_id_from must be positive")
    private Integer tenantIdFrom;
    @JsonProperty("tenant_id_to")
    @NotNull(message = "tenant_id_to is required")
    @Positive(message = "tenant_id_to must be positive")
    private Integer tenantIdTo;
    @JsonProperty("chore_type")
    @NotNull(message = "chore_type is required")
    @NotBlank(message = "chore_type can't be blank")
    private String choreType;
    @JsonProperty("week_id")
    @NotNull(message = "week_id is required")
    @NotBlank(message = "week_id can't be blank")
    private String weekId;
}
