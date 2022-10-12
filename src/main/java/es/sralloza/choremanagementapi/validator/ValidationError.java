package es.sralloza.choremanagementapi.validator;

import lombok.Data;
import lombok.experimental.Accessors;

@Data
@Accessors(chain = true)
public class ValidationError {
    private String location;
    private String message;
    private Object value;
}
