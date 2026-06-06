import { baseEntity } from '../..';

export interface society extends baseEntity {
  name: string;
  description: string;
  contactEmail: string;
  contactPhone: string;
  websiteUrl?: string;
  completionDate: Date;
  builder: string;
  promoter?: string;
}

export interface societyLocation extends baseEntity {
  address: string;
  city: string;
  state: string;
  postalCode: string;
  country: string;
  district?: string;
  societyId: string;
}

export interface societyLocationUnit extends baseEntity {
  name: string;
  description: string;
}

export interface apartment extends baseEntity {
  name: string;
  floor: number;
  type: string;
  size: number;
  initialSellPrice: number;
  societyLocationUnitId: string;
}
