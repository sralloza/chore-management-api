package es.sralloza.choremanagementbot.models.io;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class TenantCreate {
    @JsonProperty("telegram_id")
    Integer telegramId;
    String username;
}
