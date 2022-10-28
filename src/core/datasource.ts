import { DataSource } from "typeorm";
import config from "./config";

const dataSource = new DataSource({
  type: "mysql",
  host: config.database.host,
  port: config.database.port,
  username: config.database.username,
  password: config.database.password,
  database: config.database.database,
  entities: ["dist/models/*DB.js"],
  synchronize: true,
  logging: false,
  migrationsRun: !config.database.disableMigrations,
  migrations: ["migrations/*.js"],
});

export default dataSource;
