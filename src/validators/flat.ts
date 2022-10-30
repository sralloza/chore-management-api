import { body } from "express-validator";
import dataSource from "../core/datasource";
import UserDB from "../models/db/UserDB";

const usersRepo = dataSource.getRepository(UserDB);
const flatNamePattern = /^[a-z-]+$/;

export const flatCreateValidator = [
  body("name")
    .exists({ checkFalsy: false, checkNull: true })
    .withMessage("body.name is required")
    .not()
    .isEmpty({ ignore_whitespace: true })
    .withMessage("body.name can't be empty")
    .bail()
    .custom((value) => {
      if (!flatNamePattern.test(value)) {
        return Promise.reject();
      }
      return true;
    })
    .withMessage("body.name does not match the pattern '^[a-z-]+$'")
    .bail()
    .custom((value) => {
      if (value === "me") {
        return Promise.reject();
      }
      return true;
    })
    .withMessage((value) => {
      return "Forbidden flat name: " + value;
    }),
  body("create_code")
    .exists({ checkNull: true })
    .withMessage("body.create_code is required")
    .bail()
    .isJWT()
    .withMessage("body.create_code is not a valid JWT"),
];

const eqSet = (xs: Set<bigint>, ys: Set<bigint>) =>
  xs.size === ys.size && [...xs].every((x) => ys.has(x));

export const flatSettingsUpdateValidator = [
  body("rotation_sign")
    .optional({ checkFalsy: true })
    // .bail()
    .isIn(["positive", "negative"])
    .withMessage("body.rotation_sign must be either 'positive' or 'negative'"),
  body("assignment_order")
    .optional({ checkFalsy: true })
    // .bail()
    .isArray()
    .withMessage("body.assignment_order must be an array")
    .custom(async (value) => {
      const dbUserIds = new Set(
        (await usersRepo.find()).map((user) => BigInt(user.id))
      );
      const requestUserIds: Set<bigint> = new Set(
        value.map((id: string) => BigInt(id))
      );

      if (!eqSet(dbUserIds, requestUserIds)) {
        return Promise.reject();
      }
      return true;
    })
    .withMessage(
      "body.assignment_order contains invalid user ids or is missing some"
    ),
];
