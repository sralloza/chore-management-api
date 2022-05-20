import com.google.inject.Guice;
import com.google.inject.Injector;
import repositories.custom.FlatmatesRepository;
import repositories.custom.WeeklyChoresRepository;

public class Test {
    public static void main(String[] args) {
        Injector injector = Guice.createInjector(new Module());
        var weeklyChoresRepository = injector.getInstance(WeeklyChoresRepository.class);
        var flatmatesRepository = injector.getInstance(FlatmatesRepository.class);

        flatmatesRepository.getAll().forEach(System.out::println);
        weeklyChoresRepository.getAll().forEach(System.out::println);
    }
}
