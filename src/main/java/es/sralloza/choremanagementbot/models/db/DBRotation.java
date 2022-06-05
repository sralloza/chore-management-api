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
@Table(name = "Rotations")
@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class DBRotation {
    @Id
    private String weekId;

    @Column(nullable = false)
    private Integer rotation;

    @Column(nullable = false)
    private String tenantIdsHash;
}
