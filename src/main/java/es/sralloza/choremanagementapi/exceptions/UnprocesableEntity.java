package es.sralloza.choremanagementapi.exceptions;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(code = HttpStatus.UNPROCESSABLE_ENTITY)
public class UnprocesableEntity extends RuntimeException {
    public UnprocesableEntity(String message) {
        super(message);
    }
}
