import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

export interface ActivityPoint {
  lat: number;
  lon: number;
  speed: number;
  time: number;
}

export interface ActivityRecord {
  id: string;
  startTime: number;
  endTime?: number;
  distance: number;
  avgSpeed: number;
  points: ActivityPoint[];
}

export class ActivityStore {
  private static activities: ActivityRecord[] = [];
  private static rdbStore: relationalStore.RdbStore | null = null;
  private static readonly TABLE_NAME = 'activities';
  private static readonly SQL_CREATE_TABLE = 'CREATE TABLE IF NOT EXISTS activities (id TEXT PRIMARY KEY, startTime INTEGER, endTime INTEGER, distance REAL, avgSpeed REAL, points TEXT)';

  static async init(context: common.Context) {
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'Activity.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    try {
      ActivityStore.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await ActivityStore.rdbStore.executeSql(ActivityStore.SQL_CREATE_TABLE);
      await ActivityStore.loadFromDb();
    } catch (err) {
      console.error('Failed to init RDB', err);
    }
  }

  private static async loadFromDb() {
    if (!ActivityStore.rdbStore) return;
    let predicates = new relationalStore.RdbPredicates(ActivityStore.TABLE_NAME);
    predicates.orderByDesc('startTime');
    let resultSet = await ActivityStore.rdbStore.query(predicates);
    const list: ActivityRecord[] = [];
    while (resultSet.goToNextRow()) {
      list.push({
        id: resultSet.getString(resultSet.getColumnIndex('id')),
        startTime: resultSet.getLong(resultSet.getColumnIndex('startTime')),
        endTime: resultSet.getLong(resultSet.getColumnIndex('endTime')),
        distance: resultSet.getDouble(resultSet.getColumnIndex('distance')),
        avgSpeed: resultSet.getDouble(resultSet.getColumnIndex('avgSpeed')),
        points: JSON.parse(resultSet.getString(resultSet.getColumnIndex('points'))) as ActivityPoint[]
      });
    }
    ActivityStore.activities = list;
    resultSet.close();
  }

  static startNewActivity(): ActivityRecord {
    const rec: ActivityRecord = {
      id: Date.now().toString(),
      startTime: Date.now(),
      distance: 0,
      avgSpeed: 0,
      points: []
    };
    return rec;
  }

  static async addRecord(record: ActivityRecord) {
    ActivityStore.activities.unshift(record);
    if (!ActivityStore.rdbStore) return;
    const valueBucket: relationalStore.ValuesBucket = {
      'id': record.id,
      'startTime': record.startTime,
      'endTime': record.endTime,
      'distance': record.distance,
      'avgSpeed': record.avgSpeed,
      'points': JSON.stringify(record.points)
    };
    try {
      await ActivityStore.rdbStore.insert(ActivityStore.TABLE_NAME, valueBucket);
    } catch (err) {
      console.error('Failed to insert record', err);
    }
  }

  static getRecords(): ActivityRecord[] {
    return ActivityStore.activities;
  }

  static latest(): ActivityRecord | null {
    return ActivityStore.activities.length > 0 ? ActivityStore.activities[0] : null;
  }
}
