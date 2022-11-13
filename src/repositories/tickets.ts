import bunyan from "bunyan";
import dataSource from "../core/datasource";
import mapper from "../mappers/tickets";
import TicketDB from "../models/db/TicketDB";
import choreTypesRepo from "./choreTypes";
import usersRepo from "./users";

const logger = bunyan.createLogger({ name: "ticketsController" });
const repo = dataSource.getRepository(TicketDB);

const ticketsRepo = {
  async listTickets(flatName: string): Promise<Ticket[]> {
    const ticketsDB = await repo.find({ where: { flatName } });
    const choreTypes = await choreTypesRepo.listChoreTypes(flatName);
    const users = await usersRepo.listUsers(flatName);
    return mapper(ticketsDB, choreTypes, users);
  },

  async createTicketsForChoreType(
    choreTypeId: string,
    flatName: string
  ): Promise<void> {
    const users = await usersRepo.listUsers(flatName);
    const tickets: TicketDB[] = users.map((u) => ({
      id: null,
      chore_type_id: choreTypeId,
      user_id: u.id,
      tickets: 0,
      flatName,
    }));
    await repo.save(tickets);
  },

  async createTicketsForUser(userId: string, flatName: string): Promise<void> {
    const choreTypes = await choreTypesRepo.listChoreTypes(flatName);
    const tickets: TicketDB[] = choreTypes.map((choreType) => {
      return {
        id: null,
        chore_type_id: choreType.id,
        user_id: userId,
        tickets: 0,
        flatName,
      };
    });
    await repo.save(tickets);
  },
};
export default ticketsRepo;
