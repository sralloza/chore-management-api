import { NextFunction, Request, Response } from "express";
import { ValidationChain, validationResult } from "express-validator";
// can be reused by many routes

// parallel processing
const validate = (validations: ValidationChain[]) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    // await validations.run(req);
    await Promise.all(validations.map((validation) => validation.run(req)));

    const errors = validationResult(req);
    if (errors.isEmpty()) {
      return next();
    }

    res.status(422).json({ errors: errors.array() });
  };
};

export default validate;
