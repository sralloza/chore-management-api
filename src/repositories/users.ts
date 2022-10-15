import { PrismaClient } from "@prisma/client";
import { randomUUID } from "crypto";

const prisma = new PrismaClient();

export const getUsers = async () => {
  const users = await prisma.user.findMany();
  return users;
};

export const getUserById = async (id: bigint) => {
  const user = await prisma.user.findUnique({
    where: {
      id,
    },
  });
  return user;
};

export const getUserByApiKey = async (apiKey: string) => {
  const user = await prisma.user.findFirst({
    where: {
      apiKey,
    },
  });
  return user;
};

export const addUser = async (
  user: UserCreate,
  flatName: string
): Promise<User> => {
  const newUser = await prisma.user.create({
    data: {
      id: user.id,
      username: user.username,
      apiKey: randomUUID(),
      flatName,
    },
  });
  return {
    id: newUser.id,
    username: newUser.username,
    api_key: newUser.apiKey,
    flat_name: newUser.flatName,
  };
};
