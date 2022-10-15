import { NextFunction, Request, Response } from "express";
import { authRequired, isAdmin, isFlatAdmin, isUser } from "../core/auth";

export const adminAuth = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers["x-token"] as string;
  if (!authRequired(token)) {
    return res.status(401).json({ message: "Missing API key" });
  }

  if (!isAdmin(token)) {
    return res.status(401).json({ message: "Admin access required" });
  }
  next();
};

export const flatAuth = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers["x-token"] as string;
  if (!authRequired(token)) {
    return res.status(401).json({ message: "Missing API key" });
  }
  if (isAdmin(token)) {
    return next();
  }
  if (!isFlatAdmin(token)) {
    return res.status(401).json({ message: "Flat admin access required" });
  }
  next();
};

export const userAuth = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers["x-token"] as string;
  if (!authRequired(token)) {
    return res.status(401).json({ message: "Missing API key" });
  }
  if (isAdmin(token)) {
    return next();
  }
  if (isFlatAdmin(token)) {
    return next();
  }
  if (!isUser(token)) {
    // TODO: I don't think this is a possible state
    // Maybe if an invalid API key is provided?
    return res.status(401).json({ message: "User access required" });
  }

  next();
};
