import bunyan from "bunyan";
import express from "express";
import { INTERNAL } from "../core/constants";
import { flatAuth } from "../middlewares/auth";
import { user409 } from "../middlewares/users";
import parseXFlatHeader from "../middlewares/xFlatHeader";
import usersRepo from "../repositories/users";
import validate from "../validators";
import { userCreateValidator } from "../validators/user";

const router = express.Router();
const logger = bunyan.createLogger({ name: "choreTypesController" });

router.post(
  "",
  flatAuth,
  parseXFlatHeader,
  validate(userCreateValidator),
  user409,
  async (req, res) => {
    try {
      const user = await usersRepo.createUser(req.body, req.params.flatName);
      res.status(200).json(user);
    } catch (err) {
      logger.error(err);
      return res.status(500).json(INTERNAL);
    }
  }
);

router.get("", flatAuth, parseXFlatHeader, async (req, res) => {
  const user = await usersRepo.listUsers(req.params.flatName);
  res.status(200).json(user);
});

export default router;
