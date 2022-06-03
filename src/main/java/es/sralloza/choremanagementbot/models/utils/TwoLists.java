package es.sralloza.choremanagementbot.models.utils;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class TwoLists<A, B> {
    private List<A> listA;
    private List<B> listB;
}
