import express from "express";

import api from "./controllers";


const app = express();

app.use(express.json());
app.disable("x-powered-by");

app.use("/api/v1", api);

const port = process.env.PORT || 8080;

app.get("*", (req, res) => {
  console.log("Hello World");
  res.status(404).json({ message: "Not Found" });
});

app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ message: "Internal Server Error" });
});

app.listen(port, () => {
  console.log("Server running on port " + port);
});
