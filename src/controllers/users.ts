import bunyan from "bunyan";
import express from "express";
import ticketsRepo from "../repositories/tickets";
import { INTERNAL } from "../core/constants";
import { flatAuth, userAuth } from "../middlewares/auth";
import { userIdPathResolver } from "../middlewares/pathParamsResolver";
import { user404, user409 } from "../middlewares/users";
import parseXFlatHeader from "../middlewares/xFlatHeader";
import flatsRepo from "../repositories/flats";
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
      await ticketsRepo.createTicketsForUser(req.body.id, req.params.flatName);
      await flatsRepo.resetAssignmentOrder(req.params.flatName);
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

router.get(
  "/:userId",
  userAuth,
  parseXFlatHeader,
  userIdPathResolver,
  user404,
  async (req, res) => {
    const user = await usersRepo.getUserById(
      req.params.userId,
      req.params.flatName
    );
    delete user.api_key;
    res.status(200).json(user);
  }
);

export default router;
