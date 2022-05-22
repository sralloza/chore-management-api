package es.sralloza.choremanagementbot.models.db;

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
@Table(name = "Chores")
@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class DBChore {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(length = 50, nullable = false)
    private String choreType;

    @Column(nullable = false)
    private Integer userId;

    @Column(length = 50, nullable = false)
    private String weekId;

    @Column(nullable = false)
    private Boolean done;
}
