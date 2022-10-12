package es.sralloza.choremanagementapi.models.io;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Positive;

@Data
@NoArgsConstructor
public class TransferCreate {
    @JsonProperty("user_id_from")
    @NotNull(message = "user_id_from is required")
    private String userIdFrom;
    @JsonProperty("user_id_to")
    @NotNull(message = "user_id_to is required")
    @Positive(message = "user_id_to must be positive")
    private Long userIdTo;
    @JsonProperty("chore_type")
    @NotNull(message = "chore_type is required")
    @NotBlank(message = "chore_type can't be blank")
    private String choreType;
    @JsonProperty("week_id")
    @NotNull(message = "week_id is required")
    @NotBlank(message = "week_id can't be blank")
    private String weekId;
}
