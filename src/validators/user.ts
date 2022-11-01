import { body } from "express-validator";

export const userCreateValidator = [
  body("id")
    .exists({ checkNull: true })
    .withMessage("body.id is required")
    .bail()
    .custom((value: string | number) => {
      if (String(value).toLowerCase() === "me") return Promise.reject();
      return true;
    })
    .withMessage((value) => {
      return "Forbidden user ID: " + value.toLowerCase();
    })
    .bail()
    .isLength({ min: 4, max: 40 })
    .withMessage("body.id must be between 4 and 40 characters long"),
  body("username")
    .exists({ checkNull: true })
    .withMessage("body.username is required")
    .bail()
    .trim()
    .isLength({ min: 2, max: 25 })
    .withMessage("body.username must be between 2 and 25 characters long")
    .bail(),
];
