import express from "express";
import { addUser, getUserByApiKey } from "../repositories/users";

const router = express();

router.post("", async (req, res) => {
  const existingFlat = await getUserByApiKey(req.body.name);
  if (existingFlat) {
    return res.status(409).json({ message: "Flat already exists" });
  }

  const flat = await addUser(req.body, "flat-name");
  res.status(200).json(flat);
});

export default router;
