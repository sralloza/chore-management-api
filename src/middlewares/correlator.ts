import { randomUUID } from "crypto";
import { NextFunction, Request, Response } from "express";

const correlatorMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const correlationId = req.headers["x-correlator"] || randomUUID();
  res.set("X-Correlator", correlationId);
  next();
};
export default correlatorMiddleware;
