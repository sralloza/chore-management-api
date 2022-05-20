package models.custom;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.util.List;

@Data
@Accessors(chain = true)
@NoArgsConstructor
@AllArgsConstructor
public class Chore {
    private String weekId;
    private String type;
    private List<Integer> assigned;
    private List<Integer> originalAssigned;
    private Boolean done;
}
