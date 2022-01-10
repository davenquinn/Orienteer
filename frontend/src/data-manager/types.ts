import { Point } from "geojson";
import { Vector3 } from "@attitude/core/src/math";

interface AttitudeCore {
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
}

export type AttitudeData = Attitude[];

export interface AppState {
  data: AttitudeData;
  hovered: Attitude | null;
  focused: Attitude | null;
  selected: Set<Attitude>;
}
