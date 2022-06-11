package es.sralloza.choremanagementbot.models.custom;

import lombok.Data;
import lombok.experimental.Accessors;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

@Data
@Accessors(chain = true)
public class ChoreType {
    @NotNull(message = "choreType.id cannot be null")
    @NotBlank(message = "choreType.id cannot be blank")
    @Size(max = 25, message = "choreType.id must have between 1 and 25 characters")
    private String id;

    @NotNull(message = "choreType.description cannot be null")
    @NotBlank(message = "choreType.description cannot be blank")
    @Size(max = 255, message = "choreType.description must have between 1 and 255 characters")
    private String description;
}
