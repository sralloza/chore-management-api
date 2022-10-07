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
@Table(name = "Tickets")
@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class DBTicket {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;

    @Column(length = 50, nullable = false)
    private String choreType;

    @Column(length = 50, nullable = false)
    private Long userId;

    @Column(nullable = false)
    private Long tickets;
}
