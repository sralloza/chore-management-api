import { NextFunction, Request, Response } from "express";
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
    return res
      .status(404)
      .json({ message: "Chore type not found: " + req.params.choreTypeId });
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
    return res.status(409).json({ message: "Chore type already exists" });
  }
  next();
};
