package es.sralloza.choremanagementapi.models.io;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.experimental.Accessors;

import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;

@Data
@Accessors(chain = true)
public class FlatCreate {
    @NotNull(message = "{validation.body.flat.createCode.notnull}")
    @NotEmpty(message = "{validation.body.flat.createCode.empty}")
    @JsonProperty("create_code")
    private String createCode;

    @NotNull(message = "{validation.body.flat.name.notnull}")
    @NotEmpty(message = "{validation.body.flat.name.empty}")
    @Pattern(message = "{validation.body.flat.name.regex}", regexp = "^[a-z-]+$")
    private String name;
}
