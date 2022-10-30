import express from "express";
import parseXFlatHeader from "../middlewares/xFlatHeader";
import usersRepo from "../repositories/users";

const router = express.Router();

router.post("", parseXFlatHeader, async (req, res) => {
  const existingFlat = await usersRepo.getUserByApiKey(req.body.username);
  if (existingFlat) {
    return res
      .status(409)
      .json({ message: "User already exists: " + req.body.username });
  }

  const flat = await usersRepo.createUser(req.body, req.params.flatName);
  res.status(200).json(flat);
});

export default router;
