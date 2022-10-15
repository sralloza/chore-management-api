class Flat {
  name: string;
  assignment_order: number[];
  rotation_sign: RotationSign;
  api_key: string;
}

type RotationSign = "positive" | "negative";
