import dotenv from "dotenv";
import express from "express";
import morgan from "morgan";
import api from "./controllers";

(BigInt.prototype as any).toJSON = function () {
  return this.toString();
};

dotenv.config();
const app = express();

app.use(express.json());
app.disable("x-powered-by");
app.use(morgan("dev"));

app.use("/api/v1", api);

const port = process.env.PORT || 8080;

app.all("*", (req, res) => {
  res.status(404).json({ message: "Not Found" });
});

app.use((err: any, req: any, res: any, next: any) => {
  console.error(err.stack);
  res.status(500).json({ message: "Internal Server Error" });
});

app.listen(port, () => {
  console.log("Server running on port " + port);
});
