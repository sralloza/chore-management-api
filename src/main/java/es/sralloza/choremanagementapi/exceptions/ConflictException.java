package es.sralloza.choremanagementapi.exceptions;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(code = HttpStatus.CONFLICT)
public class ConflictException extends RuntimeException {
    public ConflictException(String msg) {
        super(msg);
    }
}
