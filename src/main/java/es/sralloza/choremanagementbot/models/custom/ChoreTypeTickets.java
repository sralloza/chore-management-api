package es.sralloza.choremanagementbot.models.custom;

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
    private Map<String, Integer> ticketsByTenant;
}
