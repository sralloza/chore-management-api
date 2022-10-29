import { NextFunction, Request, Response } from "express";
import { isAdmin } from "../core/auth";

const parseXFlatHeader = (req: Request, res: Response, next: NextFunction) => {
  const xFlatHeader = req.get("x-flat") as string;
  const headerDefined = xFlatHeader !== undefined;
  const isAdminResult = isAdmin(req.get("x-token"));
  if (headerDefined && !isAdminResult) {
    return res.status(400).json({
      message: "Can't use the x-flat header without the admin API key",
    });
  }
  if (!headerDefined && isAdminResult) {
    return res
      .status(400)
      .json({ message: "Must use the x-flat header with the admin API key" });
  }

  next();
};

export default parseXFlatHeader;
