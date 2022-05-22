package es.sralloza.choremanagementbot.models.custom;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.util.List;
import java.util.UUID;

@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class Flatmate {
    Integer telegramId;
    String username;
    UUID apiToken;
    List<Chore> pendingChores;
}
