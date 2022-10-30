import express from "express";
import { addUser, getUserByApiKey } from "../repositories/users";

const router = express.Router();

router.post("", async (req, res) => {
  const existingFlat = await getUserByApiKey(req.body.username);
  if (existingFlat) {
    return res
      .status(409)
      .json({ message: "User already exists: " + req.body.username });
  }

  const flat = await addUser(req.body, "flat-name");
  res.status(200).json(flat);
});

export default router;
