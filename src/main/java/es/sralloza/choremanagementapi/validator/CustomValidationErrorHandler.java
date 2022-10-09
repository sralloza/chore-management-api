package es.sralloza.choremanagementapi.validator;

import es.sralloza.choremanagementapi.utils.StringUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import javax.validation.ConstraintViolation;
import javax.validation.ConstraintViolationException;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestControllerAdvice
public class CustomValidationErrorHandler {

    @ExceptionHandler({MethodArgumentNotValidException.class})
    public ResponseEntity<ValidationErrorResponse> handle(MethodArgumentNotValidException exception) {
        var response = new ValidationErrorResponse().setErrors(parseErrors(exception));
        return new ResponseEntity<>(response, null, HttpStatus.UNPROCESSABLE_ENTITY);
    }

    @ExceptionHandler({ConstraintViolationException.class})
    public ResponseEntity<ValidationErrorResponse> handle(ConstraintViolationException exception) {
        var response = new ValidationErrorResponse().setErrors(parseErrors(exception));
        return new ResponseEntity<>(response, null, HttpStatus.UNPROCESSABLE_ENTITY);
    }

    @ExceptionHandler({HttpMessageNotReadableException.class})
    public ResponseEntity<ErrorResponse> handle(HttpMessageNotReadableException exception) {
        var response = new ErrorResponse().setMessage(exception.getMessage());
        var exceptionMessage = Optional.ofNullable(exception.getMessage()).orElse("");
        if (exceptionMessage.contains("Required request body is missing")) {
            response.setMessage("Missing request body");
        } else if (exceptionMessage.contains("JSON parse error")) {
            response.setMessage("Invalid request body");
        }
        return new ResponseEntity<>(response, null, HttpStatus.BAD_REQUEST);
    }

//    @ExceptionHandler({Exception.class})
//    public ResponseEntity<String> handleAll(Exception ex, WebRequest request) {
//        System.err.println(ex);
//        return new ResponseEntity<>("error", new HttpHeaders(), 500);
//    }

    private List<ValidationError> parseErrors(MethodArgumentNotValidException exception) {
        boolean inBody = exception.getParameter().getParameterAnnotation(RequestBody.class) != null;
        return exception.getBindingResult().getFieldErrors().stream()
            .map(fieldError -> parseError(fieldError, inBody))
            .collect(Collectors.toList());
    }

    private List<ValidationError> parseErrors(ConstraintViolationException exception) {
        return exception.getConstraintViolations().stream()
            .map(this::parseError)
            .collect(Collectors.toList());
    }

    private ValidationError parseError(FieldError fieldError, boolean inBody) {
        String location = StringUtils.camelToSnake(fieldError.getField());
        if (inBody) {
            location = "body." + location;
        }
        return new ValidationError()
            .setLocation(location)
            .setMessage(fieldError.getDefaultMessage())
            .setValue(fieldError.getRejectedValue());
    }

    private ValidationError parseError(ConstraintViolation<?> constraintViolation) {
        return new ValidationError()
            .setLocation(constraintViolation.getPropertyPath().toString())
            .setMessage(constraintViolation.getMessage())
            .setValue(constraintViolation.getInvalidValue());
    }
}
