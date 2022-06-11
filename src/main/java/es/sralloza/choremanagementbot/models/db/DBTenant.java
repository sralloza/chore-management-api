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
@Table(name = "Tenants")
@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class DBTenant {
    @Id
    private Integer tenantId;

    @Column(length = 50, nullable = false)
    private String username;

    @Column(length = 36, nullable = false)
    private String apiToken;
}
