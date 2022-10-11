package es.sralloza.choremanagementapi.validator;

import es.sralloza.choremanagementapi.exceptions.BadRequestException;
import es.sralloza.choremanagementapi.exceptions.ConflictException;
import es.sralloza.choremanagementapi.exceptions.ForbiddenException;
import es.sralloza.choremanagementapi.exceptions.NotFoundException;
import es.sralloza.choremanagementapi.exceptions.UnauthorizedException;
import es.sralloza.choremanagementapi.exceptions.UnprocesableEntity;
import es.sralloza.choremanagementapi.utils.StringUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.NoHandlerFoundException;

import javax.validation.ConstraintViolation;
import javax.validation.ConstraintViolationException;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@RestControllerAdvice
public class CustomValidationErrorHandler {
    private static final List<Class<? extends RuntimeException>> VALIDATION_EXCEPTIONS = List.of(
        BadRequestException.class,
        ConflictException.class,
        ForbiddenException.class,
        NotFoundException.class,
        UnauthorizedException.class,
        UnprocesableEntity.class
    );

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

    @ExceptionHandler({HttpRequestMethodNotSupportedException.class})
    public ResponseEntity<ErrorResponse> handle(HttpRequestMethodNotSupportedException exception) {
        var response = new ErrorResponse().setMessage(exception.getMessage());
        return new ResponseEntity<>(response, null, HttpStatus.METHOD_NOT_ALLOWED);
    }

    @ExceptionHandler({NoHandlerFoundException.class})
    public ResponseEntity<ErrorResponse> handle(NoHandlerFoundException exception) {
        var response = new ErrorResponse().setMessage("Not found");
        return new ResponseEntity<>(response, null, HttpStatus.NOT_FOUND);
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

    @ExceptionHandler({Exception.class})
    public ResponseEntity<ErrorResponse> handleAll(Exception ex, WebRequest request) {
        for (var exceptionClass : VALIDATION_EXCEPTIONS) {
            if (exceptionClass.isInstance(ex)) {
                var response = new ErrorResponse().setMessage(ex.getMessage());
                HttpStatus code = exceptionClass.getAnnotation(ResponseStatus.class).code();
                return new ResponseEntity<>(response, null, code);
            }
        }
        log.error("Unexpected error", ex);
        var response = new ErrorResponse().setMessage("Internal Server Error");
        return new ResponseEntity<>(response, null, 500);
    }

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
