package es.sralloza.choremanagementbot.models.db;

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
@Table(name = "Flatmates")
@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class DBFlatmate {
    @Id
    private Integer telegramId;

    @Column(length = 50, nullable = false)
    private String username;

    @Column(nullable = false)
    private UUID apiToken;
}
