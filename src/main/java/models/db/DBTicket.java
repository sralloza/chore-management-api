package models.db;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

@Entity
@Table(name = "Tickets")
@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class DBTicket {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(length = 50, nullable = false)
    private String choreType;

    @Column(length = 50, nullable = false)
    private String username;

    @Column(nullable = false)
    private Integer tickets;
}
