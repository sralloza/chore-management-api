import bunyan from "bunyan";
import express from "express";
import morgan from "morgan";
import api from "./controllers";
import { INTERNAL } from "./core/constants";
import dataSource from "./core/datasource";
import correlatorMiddleware from "./middlewares/correlator";
import redisClient from "./services/redis";

const logger = bunyan.createLogger({ name: "main" });
const app = express();

app.disable("x-powered-by");
app.use(express.json());
app.use(morgan("dev"));
app.use(correlatorMiddleware);

app.get("/health", (req, res) => {
  res.status(200).send({ status: "OK" });
});

app.use("/api/v1", api);

const port = 8080;

app.all("*", (req, res) => {
  res.status(404).json({ message: "Not Found" });
});

app.use((err: any, req: any, res: any, next: any) => {
  // Workaround for returning 404 instead of 500 when the client sends an invalid json in the request body
  if (
    err?.statusCode === 400 &&
    err?.status === 400 &&
    err?.type === "entity.parse.failed"
  ) {
    return res
      .status(400)
      .json({ message: "Request body is not a valid JSON" });
  }
  const info = {
    err,
    path: req.path,
    params: req.params,
    query: req.query,
    body: req.body,
  };
  logger.error({ info }, "Unhandled error");
  res.status(500).json(INTERNAL);
});

app.listen(port, async () => {
  await redisClient.connect();
  dataSource
    .initialize()
    .then(() => {
      logger.info("Data Source has been initialized!");
    })
    .catch((err) => {
      logger.error({ err }, "Error during Data Source initialization:");
      process.exit(1);
    });

  logger.info({ port }, "Server running on port " + port);
});
