package es.sralloza.choremanagementbot.models.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class WeekId {
    @JsonProperty("week_id")
    private String weekId;
}
