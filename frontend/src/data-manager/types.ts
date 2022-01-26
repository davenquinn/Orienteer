import { Point } from "geojson";
import { Vector3 } from "@attitude/core/src/math";
import { AttitudeFilterData } from "./filter";

export interface AttitudeCore {
  strike: number;
  dip: number;
  rake: number;
  center: Point;
  in_group: boolean;
  min_angular_error: number;
  max_angular_error: number;
  axes: [Vector3, Vector3, Vector3];
  hyperbolic_axes: Vector3;
}

export interface Attitude extends AttitudeCore {
  id: number;
  tags: Set<string>;
  is_group: boolean;
  in_group: boolean;
}

export interface GroupedAttitude extends Attitude {
  is_group: true;
  in_group: false;
  measurements: Attitude[];
}

export type AttitudeData = Attitude[];

export interface AppState {
  data: AttitudeData;
  hovered: Attitude | null;
  focused: Attitude | null;
  selected: Set<Attitude>;
  filterData: AttitudeFilterData | null;
}

export const initialState: AppState = {
  data: [],
  hovered: null,
  focused: null,
  selected: new Set(),
  filterData: null,
};
