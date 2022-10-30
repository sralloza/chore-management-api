import { NextFunction, Request, Response } from "express";
import flatsRepo from "../repositories/flats";
import { verifyJWT } from "../services/jwt";
import redisClient from "../services/redis";

export const flat404 = async (
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

export const flat409 = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const existingFlat = await flatsRepo.getFlatByName(req.body.name);
  if (existingFlat) {
    return res.status(409).json({ message: "Flat already exists" });
  }
  next();
};

export const verifyCreateCode403 = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (!verifyJWT(req.body.create_code)) {
    return res.status(403).json({ message: "Invalid create code" });
  }

  const savedCreateCode = await redisClient.get(req.body.create_code);
  if (savedCreateCode) {
    return res.status(403).json({ message: "Invalid create code" });
  }
  next();
};
