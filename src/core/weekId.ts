import { DateTime } from "luxon";

const getWeekNumberFromDate = (weeks = 0) => {
  const date = DateTime.now().plus({ weeks });
  const weekNumber = date.weekNumber;
  return date.year + "." + weekNumber.toString().padStart(2, "0");
};

export default class WeekIdUtils {
  static getCurrentWeekId() {
    return getWeekNumberFromDate();
  }
  static getNextWeekId() {
    return getWeekNumberFromDate(1);
  }
  static getLastWeekId() {
    return getWeekNumberFromDate(-1);
  }
}
