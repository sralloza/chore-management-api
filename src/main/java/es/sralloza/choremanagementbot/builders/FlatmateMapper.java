package es.sralloza.choremanagementbot.builders;

import es.sralloza.choremanagementbot.models.custom.Chore;
import es.sralloza.choremanagementbot.models.custom.Flatmate;
import es.sralloza.choremanagementbot.models.db.DBFlatmate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class FlatmateMapper {
    public Flatmate build(DBFlatmate dbFlatmate, List<Chore> chores) {
        var userPendingChores = chores.stream()
                .filter(chore -> chore.getAssigned().contains(dbFlatmate.getTelegramId()))
                .filter(chore -> !chore.getDone())
                .collect(Collectors.toList());
        return new Flatmate()
                .setTelegramId(dbFlatmate.getTelegramId())
                .setUsername(dbFlatmate.getUsername())
                .setApiToken(dbFlatmate.getApiToken())
                .setPendingChores(userPendingChores);
    }
}
