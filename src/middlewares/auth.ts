import { NextFunction, Request, Response } from "express";
import {
  ADMIN_ACCESS_REQUIRED,
  FLAT_ADMIN_ACCESS_REQUIRED,
  MISSING_API_KEY,
  USER_ACCESS_REQUIRED,
} from "../core/constants";
import { authPresent, isAdmin, isFlatAdmin, isUser } from "../core/auth";

export const adminAuth = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers["x-token"] as string;
  if (!authPresent(token)) {
    return res.status(401).json(MISSING_API_KEY);
  }

  if (!isAdmin(token)) {
    return res.status(403).json(ADMIN_ACCESS_REQUIRED);
  }
  next();
};

export const flatAuth = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const token = req.headers["x-token"] as string;
  if (!authPresent(token)) {
    return res.status(401).json(MISSING_API_KEY);
  }
  if (isAdmin(token)) {
    return next();
  }

  const isFlatAdminResult = await isFlatAdmin(token);
  if (!isFlatAdminResult) {
    return res.status(403).json(FLAT_ADMIN_ACCESS_REQUIRED);
  }
  next();
};

export const userAuth = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const token = req.headers["x-token"] as string;
  if (!authPresent(token)) {
    return res.status(401).json(MISSING_API_KEY);
  }
  if (isAdmin(token)) {
    return next();
  }

  const isFlatAdminResult = await isFlatAdmin(token);
  if (isFlatAdminResult) {
    return next();
  }
  const isUserResult = await isUser(token);
  if (!isUserResult) {
    // TODO: I don't think this is a possible state
    // Maybe if an invalid API key is provided?
    return res.status(403).json(USER_ACCESS_REQUIRED);
  }

  next();
};
