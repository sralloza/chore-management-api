package es.sralloza.choremanagementapi.models.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.util.Map;

@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class ChoreTypeTickets {
    private String id;
    private String description;
    @JsonProperty("tickets_by_user")
    private Map<String, Long> ticketsByUser;
}
