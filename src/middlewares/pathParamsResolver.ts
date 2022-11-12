import bunyan from "bunyan";
import { NextFunction, Request, Response } from "express";
import { isAdmin, isFlatAdmin } from "../core/auth";
import {
  ADMIN_KEY_ME,
  FLAT_ADMIN_KEY_ME,
  FORBIDDEN_FLAT_DATA,
  FORBIDDEN_USER_DATA,
} from "../core/constants";
import flatsRepo from "../repositories/flats";
import usersRepo from "../repositories/users";

const logger = bunyan.createLogger({ name: "pathParamsResolver" });

export const flatNamePathResolver = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const flatNamePath = req.params.flatName;
  const apiKey = req.get("x-token");
  const isAdminResult = isAdmin(apiKey);

  if (flatNamePath === "me") {
    // "me" keyword can't be used by the admin
    if (isAdminResult) {
      return res.status(400).json(ADMIN_KEY_ME);
    }
    req.params.flatName = (await flatsRepo.getFlatByApiKey(apiKey)).name;
  } else if (!isAdminResult) {
    // Check if the flat admin is trying to access a flat that is not his
    const flat = await flatsRepo.getFlatByApiKey(apiKey);
    if (flat?.name !== flatNamePath) {
      return res.status(403).json(FORBIDDEN_FLAT_DATA);
    }
  }

  next();
};

export const userIdPathResolver = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const apiKey = req.get("x-token");

  if (isAdmin(apiKey)) {
    if (req.params.userId === "me") return res.status(400).json(ADMIN_KEY_ME);
  } else if (await isFlatAdmin(apiKey)) {
    if (req.params.userId === "me")
      return res.status(400).json(FLAT_ADMIN_KEY_ME);
  } else {
    const user = await usersRepo.getUserByApiKey(apiKey);
    if (req.params.userId === "me") {
      req.params.userId = user.id;
    } else {
      if (req.params.userId !== user.id) {
        return res.status(403).json(FORBIDDEN_USER_DATA);
      }
    }
  }
  next();
};
