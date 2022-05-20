package models.db;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

@Entity
@Table(name = "ChoreTypes")
@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class DBChoreType {
    @Id
    private String id;

    @Column(length = 250, nullable = false)
    private String description;
}
