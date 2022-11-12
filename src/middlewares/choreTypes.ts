import { NextFunction, Request, Response } from "express";
import {
  CHORE_TYPE_ALREADY_EXISTS,
  CHORE_TYPE_NOT_FOUND,
} from "../core/constants";
import choreTypesRepo from "../repositories/choreTypes";

export const choreType404 = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const choreType = await choreTypesRepo.getChoreTypeById(
    req.params.choreTypeId,
    req.params.flatName
  );
  if (!choreType) {
    return res.status(404).json(CHORE_TYPE_NOT_FOUND(req.params.choreTypeId));
  }
  req.choreType = choreType;
  next();
};

export const choreType409 = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const choreType = await choreTypesRepo.getChoreTypeById(
    req.body.id,
    req.params.flatName
  );
  if (choreType) {
    return res.status(409).json(CHORE_TYPE_ALREADY_EXISTS);
  }
  next();
};
