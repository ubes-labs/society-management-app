import { baseEntity } from '../..';

export interface userProfile extends baseEntity {
  name: string;
  contactNumber: number;
}
