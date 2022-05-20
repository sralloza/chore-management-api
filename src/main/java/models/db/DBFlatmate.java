package models.db;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.util.UUID;

@Entity
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
