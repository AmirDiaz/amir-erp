import Decimal from 'decimal.js';

export function D(x: unknown): Decimal {
  if (x === null || x === undefined) return new Decimal(0);
  return new Decimal(String(x));
}

export function sum(values: Array<unknown>): Decimal {
  return values.reduce<Decimal>((acc, v) => acc.plus(D(v)), new Decimal(0));
}

export function round(x: Decimal | number, digits = 2): Decimal {
  return D(x).toDecimalPlaces(digits, Decimal.ROUND_HALF_UP);
}
