import { NextFunction, Request, Response } from "express";
import flatsRepo from "../repositories/flats";

export const flatNotFoundMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const flat = await flatsRepo.getFlatByName(req.params.flatName);
  if (!flat) {
    return res
      .status(404)
      .json({ message: "Flat not found: " + req.params.flatName });
  }
  req.flat = flat;
  next();
};
