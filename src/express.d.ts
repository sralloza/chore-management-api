declare namespace Express {
  export interface Request {
    choreType?: ChoreType;
    flat?: Flat;
    user?: User;
  }
}
