import express from "express";
import choreTypes from "./choreTypes";
import flats from "./flats";
import users from "./users";
import weekId from "./weekId";

const router = express.Router();

router.use("/chore-types", choreTypes);
router.use("/flats", flats);
router.use("/users", users);
router.use("/week-id", weekId);

export default router;
