package es.sralloza.choremanagementapi.models.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.experimental.Accessors;

import java.time.LocalDateTime;

@Data
@Accessors(chain = true)
public class Transfer {
    private Long id;
    private LocalDateTime timestamp;
    @JsonProperty("user_id_from")
    private Long userIdFrom;
    @JsonProperty("user_id_to")
    private Long userIdTo;
    @JsonProperty("chore_type")
    private String choreType;
    @JsonProperty("week_id")
    private String weekId;
    private Boolean accepted;
    private Boolean completed;
}
