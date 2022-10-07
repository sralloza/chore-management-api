package es.sralloza.choremanagementapi.models.db;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "Flats")
@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class DBFlat {
    @Id
    private String name;

    @Column(nullable = false)
    private String assignmentOrder;

    @Column(nullable = false)
    private String rotationSign;

    @Column(nullable = false)
    private String apiKey;
}
