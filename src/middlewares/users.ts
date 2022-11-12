import { NextFunction, Request, Response } from "express";
import { USER_ALREADY_EXISTS, USER_NOT_FOUND } from "../core/constants";
import usersRepo from "../repositories/users";

export const user404 = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const user = await usersRepo.getUserById(
    req.params.userId,
    req.params.flatName
  );
  if (!user) {
    return res.status(404).json(USER_NOT_FOUND(req.params.userId));
  }
  req.user = user;
  next();
};

export const user409 = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const user = await usersRepo.getUserById(req.body.id, req.params.flatName);
  if (user) {
    return res.status(409).json(USER_ALREADY_EXISTS);
  }
  next();
};
