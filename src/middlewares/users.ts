import { NextFunction, Request, Response } from "express";
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
    return res
      .status(404)
      .json({ message: "User not found: " + req.params.flatName });
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
    return res.status(409).json({ message: "User already exists" });
  }
  next();
};
