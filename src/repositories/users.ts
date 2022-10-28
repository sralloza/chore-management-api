import { randomUUID } from "crypto";
import dataSource from "../core/datasource";
import UserDB from "../models/UserDB";

const repo = dataSource.getRepository(UserDB);

const mapper = (user: UserDB): User => {
  if (user === null) return null;
  return {
    id: user.id,
    username: user.username,
    api_key: user.apiKey,
    flat_name: user.flatName,
  };
};

export const getUsers = async (): Promise<User[]> => {
  const users = await repo.find();
  return users.map(mapper);
};

export const getUserById = async (id: bigint): Promise<User | null> => {
  const user = await repo.findOne({ where: { id } });
  return mapper(user);
};

export const getUserByApiKey = async (apiKey: string): Promise<User | null> => {
  const user = await repo.findOne({ where: { apiKey } });
  return mapper(user);
};

export const addUser = async (
  user: UserCreate,
  flatName: string
): Promise<User> => {
  const newUser = repo.create({
    id: user.id,
    username: user.username,
    apiKey: randomUUID(),
    flatName,
  });
  await repo.save(newUser);
  return mapper(newUser);
};
