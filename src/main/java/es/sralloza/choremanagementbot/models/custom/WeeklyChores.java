package es.sralloza.choremanagementbot.models.custom;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.util.List;

@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class WeeklyChores {
    private String weekId;
    private List<Chore> chores;
    private Integer rotation;
}
