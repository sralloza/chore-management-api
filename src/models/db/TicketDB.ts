import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity({ name: "tickets" })
class UserDB {
  @PrimaryGeneratedColumn("increment")
  id: number;
  @Column("varchar", { length: 25 })
  chore_type_id: string;
  @Column("varchar", { length: 40 })
  user_id: string;
  @Column("integer")
  tickets: number;
  @Column("varchar", { length: 20 })
  flatName: string;
}

export default UserDB;
