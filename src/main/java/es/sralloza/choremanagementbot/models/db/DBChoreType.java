package es.sralloza.choremanagementbot.models.db;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "ChoreTypes")
@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class DBChoreType {
    @Id
    private String id;

    @Column(nullable = false)
    private String description;
}
