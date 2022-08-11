package es.sralloza.choremanagementapi.utils;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class ChoreUtils {
    public <T> List<T> repeatArray(List<T> input, int size) {
        List<T> result = new ArrayList<>();
        int i = 0;
        while (result.size() != size) {
            if (i >= input.size()) {
                i -= input.size();
            }
            result.add(input.get(i));
            i++;
        }
        return result;
    }
}
