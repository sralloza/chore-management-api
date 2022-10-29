import express from "express";
import flats from "./flats";
import weekId from "./weekId";
import users from "./users";

const router = express.Router();

router.use("/flats", flats);
router.use("/week-id", weekId);
router.use("/users", users);

export default router;
