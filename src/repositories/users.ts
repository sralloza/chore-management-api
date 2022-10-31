import { randomUUID } from "crypto";
import dataSource from "../core/datasource";
import UserDB from "../models/db/UserDB";

const repo = dataSource.getRepository(UserDB);

const mapper = (user: UserDB): User => {
  if (user === null) return null;
  return {
    id: user.id,
    username: user.username,
    api_key: user.apiKey,
  };
};

const userRepo = {
  listUsers: async (flatName: string): Promise<User[]> => {
    const users = await repo.find({ where: { flatName } });
    return users
      .map(mapper)
      .sort((a, b) =>
        a.username.toLowerCase().localeCompare(b.username.toLowerCase())
      );
  },

  getUserById: async (id: string, flatName: string): Promise<User | null> => {
    const user = await repo.findOne({ where: { id, flatName } });
    return mapper(user);
  },

  getUserByApiKey: async (apiKey: string): Promise<User | null> => {
    const user = await repo.findOne({ where: { apiKey } });
    return mapper(user);
  },

  createUser: async (user: UserCreate, flatName: string): Promise<User> => {
    const newUser = repo.create({
      id: user.id,
      username: user.username,
      apiKey: randomUUID(),
      flatName,
    });
    await repo.save(newUser);
    return mapper(newUser);
  },
};

export default userRepo;
