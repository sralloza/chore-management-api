package es.sralloza.choremanagementbot.models.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.util.List;

@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class Chore {
    @JsonProperty("week_id")
    private String weekId;
    private String type;
    @JsonProperty("assigned_ids")
    private List<Long> assignedIds;
    @JsonProperty("assigned_usernames")
    private List<String> assignedUsernames;
    private Boolean done;
}
