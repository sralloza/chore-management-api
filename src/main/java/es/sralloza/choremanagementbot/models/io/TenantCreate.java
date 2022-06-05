package es.sralloza.choremanagementbot.models.io;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Positive;
import javax.validation.constraints.Size;

@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class TenantCreate {
    @JsonProperty("telegram_id")
    @NotNull(message = "telegram_id is required")
    @Positive(message = "telegram_id must be positive")
    Integer telegramId;

    @NotNull(message = "username is required")
    @NotBlank(message = "username can't be blank")
    @Size(min = 3, message = "username size must be at least 3")
    String username;
}
