import express, { Request, Response } from "express";
import morgan from "morgan";
import api from "./controllers";
import config from "./core/config";
import { INTERNAL } from "./core/constants";
import dataSource from "./core/datasource";
import correlatorMiddleware from "./middlewares/ correlator";
import redisClient from "./services/redis";

(BigInt.prototype as any).toJSON = function () {
  return this.toString();
};

const app = express();

// XXX: I think this can be removed
const validateEmptyBody = (
  req: Request,
  res: Response,
  buf: Buffer,
  encoding: string
) => {
  const body = buf.toString();

  if (body.length === 0) {
    return res.status(400).json({ message: "Missing request body" });
  }
};

app.use(express.json({ verify: validateEmptyBody }));
app.disable("x-powered-by");
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
  res.status(500).json(INTERNAL);
});

app.listen(port, async () => {
  await redisClient.connect();
  dataSource
    .initialize()
    .then(() => {
      console.log("Data Source has been initialized!");
    })
    .catch((err) => {
      console.error("Error during Data Source initialization:", err);
      process.exit(1);
    });

  console.log("Server running on port " + port);
});
