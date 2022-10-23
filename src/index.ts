import dotenv from "dotenv";
import express, { Request, Response } from "express";
import morgan from "morgan";
import api from "./controllers";
import config from "./core/config";
import { INTERNAL } from "./core/constants";
import correlatorMiddleware from "./middlewares/ correlator";
import redisClient from "./services/redis";

(BigInt.prototype as any).toJSON = function () {
  return this.toString();
};

dotenv.config();
const app = express();

const validateEmptyBody = (req: Request, res: Response, buf: Buffer, encoding: string) => {
  const body = buf.toString();
  console.log({body, encoding});

  if (body.length === 0) {
    return res.status(400).json({ message: "Missing request body" });
  }
}

app.use(express.json({verify: validateEmptyBody}));
app.disable("x-powered-by");
app.use(morgan("dev"));
app.use(correlatorMiddleware);

app.use("/api/v1", api);

const port = config.serverPort;

app.all("*", (req, res) => {
  res.status(404).json({ message: "Not Found" });
});

app.use((err: any, req: any, res: any, next: any) => {
  if (
    err?.statusCode === 400 &&
    err?.status === 400 &&
    err?.type === "entity.parse.failed"
  ) {
    return res.status(400).json({ message: "Request body is not a valid JSON" });
  }
  res.status(500).json(INTERNAL);
});

app.listen(port, async () => {
  await redisClient.connect();
  console.log("Server running on port " + port);
});
