import { Flat as PFlat } from "@prisma/client";
import { randomUUID } from "crypto";
import prisma from "./client";

const buildFlat = (flat: PFlat): Flat => {
  if (flat === null) return null;
  return {
    name: flat.name,
    settings: {
      assignment_order: [],
      rotation_sign: flat.rotationSign as RotationSign,
    },
    api_key: flat.apiKey,
  };
};

export const getFlats = async () => {
  const flats = await prisma.flat.findMany();
  return flats.map(buildFlat);
};

export const getFlatByName = async (name: string): Promise<Flat> => {
  const flat = await prisma.flat.findUnique({ where: { name } });
  return buildFlat(flat);
};

export const getFlatByApiKey = async (apiKey: string): Promise<Flat> => {
  const flat = await prisma.flat.findFirst({ where: { apiKey } });
  return buildFlat(flat);
};

export const addFlat = async (flat: FlatCreate): Promise<Flat> => {
  const newFlat = await prisma.flat.create({
    data: {
      name: flat.name,
      assignmentOrder: "",
      rotationSign: "positive",
      apiKey: randomUUID(),
    },
  });
  return buildFlat(newFlat);
};

export const deleteFlat = async (name: string): Promise<void> => {
  await prisma.flat.delete({ where: { name } });
  return;
};
