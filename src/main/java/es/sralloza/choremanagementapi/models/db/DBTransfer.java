package es.sralloza.choremanagementapi.models.db;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "Transfers")
@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class DBTransfer {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(nullable = false)
    private Long timestamp;

    @Column(nullable = false)
    private Long userIdFrom;

    @Column(nullable = false)
    private Long userIdTo;

    @Column(length = 50, nullable = false)
    private String choreType;

    @Column(length = 50, nullable = false)
    private String weekId;

    @Column(nullable = false)
    private Boolean completed;

    @Column()
    private Boolean accepted;
}
