import { NextFunction, Request, Response } from "express";
import {
  FLAT_ALREADY_EXISTS,
  FLAT_NOT_FOUND,
  INVALID_CREATE_CODE,
} from "../core/constants";
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
    return res.status(404).json(FLAT_NOT_FOUND(req.params.flatName));
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
    return res.status(409).json(FLAT_ALREADY_EXISTS);
  }
  next();
};

export const verifyCreateCode403 = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (!verifyJWT(req.body.create_code)) {
    return res.status(403).json(INVALID_CREATE_CODE);
  }

  const savedCreateCode = await redisClient.get(req.body.create_code);
  if (savedCreateCode) {
    return res.status(403).json(INVALID_CREATE_CODE);
  }
  next();
};
