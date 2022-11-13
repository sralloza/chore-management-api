class Ticket {
  id: string;
  name: string;
  description: string;
  tickets_by_user_id: { [k: string]: number };
  tickets_by_user_name: { [k: string]: number };
}
