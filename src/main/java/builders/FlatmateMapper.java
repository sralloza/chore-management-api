package builders;

import models.custom.Chore;
import models.db.DBFlatmate;
import models.custom.Flatmate;

import java.util.List;
import java.util.stream.Collectors;

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
