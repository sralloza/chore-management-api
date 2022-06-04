package es.sralloza.choremanagementbot.models.db;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.util.UUID;

@Entity
@Table(name = "Tenants")
@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class DBTenant {
    @Id
    @JsonProperty("telegram_id")
    private Integer telegramId;

    @Column(length = 50, nullable = false)
    private String username;

    @Column(nullable = false)
    @JsonProperty("api_token")
    private UUID apiToken;
}
