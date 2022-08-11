package es.sralloza.choremanagementapi.validator;


import org.springframework.core.MethodParameter;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice;

import java.util.Map;
import java.util.Optional;

@RestControllerAdvice
public class CustomValidationErrors implements ResponseBodyAdvice<Map<String, Object>> {

  @Override
  public boolean supports(MethodParameter returnType, Class<? extends HttpMessageConverter<?>> converterType) {
    var model = returnType.getGenericParameterType().getTypeName();
    return model.contains("java.util.Map");
  }

  @Override
  public Map<String, Object> beforeBodyWrite(Map<String, Object> body,
                                             MethodParameter returnType, MediaType selectedContentType,
                                             Class<? extends HttpMessageConverter<?>> selectedConverterType,
                                             ServerHttpRequest request, ServerHttpResponse response) {
    Integer statusCode = Optional.ofNullable(body)
        .map(b -> b.get("status"))
        .map(Object::toString)
        .map(Integer::parseInt)
        .orElse(0);
    if (statusCode == 400) {
      String msg = Optional.ofNullable(body.get("message"))
          .map(Object::toString)
          .orElse(null);
      if (msg != null) {
        if (msg.contains("Required request body is missing:")) {
          body.put("message", "Missing request body");
        }
        else if (msg.contains("JSON parse error:")) {
          body.put("message", "Invalid request body");
        }
      }

    }
    return body;
  }
}
