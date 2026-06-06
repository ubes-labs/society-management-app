export abstract class baseEntity {
  id?: string;
  enabled: boolean = true;
  deleted: boolean = false;
  status: status = status.Active;
  createdAt?: Date;
  createdBy?: string;
  updatedAt: Date = new Date();
  updatedBy = '';
  societyLocationId?: string;
}

export type status = (typeof status)[keyof typeof status];

const status = {
  Active: 'active',
};
