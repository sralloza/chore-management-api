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
@Table(name = "Users")
@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class DBUser {
    @Id
    private Long userId;

    @Column(length = 50, nullable = false)
    private String username;

    @Column(length = 36, nullable = false)
    private String apiToken;

    @Column(nullable = false)
    private String flatName;
}
