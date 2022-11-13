import { groupBy } from "../core/utils";
import TicketDB from "../models/db/TicketDB";

const mapper = (
  ticketsDB: TicketDB[],
  choreTypes: ChoreType[],
  users: User[]
): Ticket[] => {
  if (choreTypes.length === 0) return [];

  if (ticketsDB.length === 0) {
    return choreTypes.map((choreType) => ({
      id: choreType.id,
      name: choreType.name,
      description: choreType.description,
      tickets_by_user_id: {},
      tickets_by_user_name: {},
    }));
  }

  const ticketsGroupedByChoreTypeId = groupBy(
    ticketsDB,
    (ticket) => ticket.chore_type_id,
    (x) => x
  );

  return Array.from(ticketsGroupedByChoreTypeId).map(
    ([choreTypeId, tickets]) => {
      tickets.sort();
      const _ticketsGroupedByUserId = Object.fromEntries(
        groupBy(
          tickets,
          (ticket) => ticket.user_id,
          (ticket) => ticket.tickets
        )
      );
      const ticketsGroupedByUserId: { [k: string]: number } = {};
      Object.keys(_ticketsGroupedByUserId).forEach((key, index) => {
        ticketsGroupedByUserId[key] = _ticketsGroupedByUserId[key][0];
      });

      const _ticketsGroupedByUserName = Object.fromEntries(
        groupBy(
          tickets,
          (ticket) => users.find((u) => u.id === ticket.user_id).username,
          (ticket) => ticket.tickets
        )
      );
      const ticketsGroupedByUserName: { [k: string]: number } = {};
      Object.keys(_ticketsGroupedByUserName).forEach((key, index) => {
        ticketsGroupedByUserName[key] = _ticketsGroupedByUserName[key][0];
      });

      return {
        id: choreTypeId,
        name: choreTypes.find((c) => c.id === choreTypeId).name,
        description: choreTypes.find((c) => c.id === choreTypeId).description,
        tickets_by_user_id: ticketsGroupedByUserId,
        tickets_by_user_name: ticketsGroupedByUserName,
      };
    }
  );
};

export default mapper;
