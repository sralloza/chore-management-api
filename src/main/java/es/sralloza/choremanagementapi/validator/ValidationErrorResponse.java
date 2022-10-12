package es.sralloza.choremanagementapi.validator;

import lombok.Data;
import lombok.experimental.Accessors;

import java.util.List;

@Data
@Accessors(chain = true)
public class ValidationErrorResponse {
    private List<ValidationError> errors;
}
