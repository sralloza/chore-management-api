import bunyan from "bunyan";
import express from "express";
import { userAuth } from "../middlewares/auth";
import parseXFlatHeader from "../middlewares/xFlatHeader";
import ticketsRepo from "../repositories/tickets";

const logger = bunyan.createLogger({ name: "ticketsController" });
const router = express.Router();

router.get("", userAuth, parseXFlatHeader, async (req, res) => {
  const tickets = await ticketsRepo.listTickets(req.params.flatName);
  res.status(200).json(tickets);
});

export default router;
