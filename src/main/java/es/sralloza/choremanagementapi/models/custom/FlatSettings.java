package es.sralloza.choremanagementapi.models.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.experimental.Accessors;

import java.util.List;

@Data
@Accessors(chain = true)
public class FlatSettings {
    @JsonProperty("assignment_order")
    private List<Long> assignmentOrder;
    @JsonProperty("rotation_sign")
    private String rotationSign;
}
