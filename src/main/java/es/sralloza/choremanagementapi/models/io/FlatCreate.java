package es.sralloza.choremanagementapi.models.io;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.experimental.Accessors;

import javax.validation.constraints.NotNull;

@Data
@Accessors(chain = true)
public class FlatCreate {
    @NotNull
    @JsonProperty("create_code")
    private String createCode;
    @NotNull
    private String name;
}
