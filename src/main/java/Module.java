import com.google.inject.AbstractModule;
import com.typesafe.config.Config;
import com.typesafe.config.ConfigFactory;
import repositories.custom.ChoresRepository;
import repositories.custom.ChoresRepositoryImp;
import repositories.db.DBChoreTypesRepository;
import repositories.db.DBChoreTypesRepositoryImp;
import repositories.db.DBChoresRepository;
import repositories.db.DBChoresRepositoryImp;
import repositories.db.DBFlatmatesRepository;
import repositories.db.DBFlatmatesRepositoryImp;
import repositories.custom.FlatmatesRepository;
import repositories.custom.FlatmatesRepositoryImp;
import repositories.custom.WeeklyChoresRepository;
import repositories.custom.WeeklyChoresRepositoryImp;
import repositories.db.DBTicketsRepository;
import repositories.db.DBTicketsRepositoryImp;

public class Module extends AbstractModule {
    @Override
    protected void configure() {
        bind(ChoresRepository.class).to(ChoresRepositoryImp.class);
        bind(DBChoreTypesRepository.class).to(DBChoreTypesRepositoryImp.class);
        bind(DBChoresRepository.class).to(DBChoresRepositoryImp.class);
        bind(DBFlatmatesRepository.class).to(DBFlatmatesRepositoryImp.class);
        bind(DBTicketsRepository.class).to(DBTicketsRepositoryImp.class);
        bind(FlatmatesRepository.class).to(FlatmatesRepositoryImp.class);
        bind(WeeklyChoresRepository.class).to(WeeklyChoresRepositoryImp.class);

        bind(Config.class).toInstance(ConfigFactory.load());
    }
}
