package es.sralloza.choremanagementapi.models.io;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.experimental.Accessors;

import javax.annotation.RegEx;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;

@Data
@Accessors(chain = true)
public class FlatCreate {
    @NotNull(message = "{validation.flat.createCode.notnull}")
    @NotEmpty(message = "{validation.flat.createCode.empty}")
    @JsonProperty("create_code")
    private String createCode;

    @NotNull(message = "{validation.flat.name.notnull}")
    @NotEmpty(message = "{validation.flat.name.empty}")
    @Pattern(message = "{validation.flat.name.regex}", regexp = "^[a-z-]+$")
    private String name;
}
