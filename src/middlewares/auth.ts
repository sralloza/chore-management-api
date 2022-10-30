import { NextFunction, Request, Response } from "express";
import { authPresent, isAdmin, isFlatAdmin, isUser } from "../core/auth";

export const adminAuth = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers["x-token"] as string;
  if (!authPresent(token)) {
    return res.status(401).json({ message: "Missing API key" });
  }

  if (!isAdmin(token)) {
    return res.status(403).json({ message: "Admin access required" });
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
    return res.status(401).json({ message: "Missing API key" });
  }
  if (isAdmin(token)) {
    return next();
  }

  const isFlatAdminResult = await isFlatAdmin(token);
  if (!isFlatAdminResult) {
    return res
      .status(403)
      .json({ message: "Flat administration access required" });
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
    return res.status(401).json({ message: "Missing API key" });
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
    return res.status(403).json({ message: "User access required" });
  }

  next();
};
