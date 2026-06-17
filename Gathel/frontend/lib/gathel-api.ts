import { apiGet, apiPost } from "./api";

export type PersonResponse = {
  personId: number;
  name: string;
  lastName: string;
  username: string;
  email: string;
  isVerified: boolean;
  isActive: boolean;
  pointsBalance: number;
};

export type LoginResponse = {
  message: string;
  person: {
    personId: number;
    name: string;
    lastName: string;
    username: string;
    email: string;
    isVerified: boolean;
    isActive: boolean;
  };
};

export type PropositionResponse = {
  propositionId: number;
  title: string;
  description: string;
  creatorPersonId: number;
  targetPersonId: number;
  startPredictionDateTime: string;
  endPredictionDateTime: string;
  minimumEntryPointsAmount: number;
  winningProfitPercentage: number;
  status: string;
};

export function login(data: {
  identifier: string;
  password: string;
}) {
  return apiPost<LoginResponse>("/api/auth/login", data);
}

export function getMe(personId: number) {
  return apiGet<PersonResponse>(`/api/people/me?personId=${personId}`);
}

export function getActivePropositions() {
  return apiGet<PropositionResponse[]>("/api/propositions/active");
}

export function createPointPrediction(data: {
  propositionId: number;
  personId: number;
  predictionValue: boolean;
}) {
  return apiPost<{ message: string }>("/api/predictions/points", data);
}

export function createMoneyPrediction(data: {
  propositionId: number;
  personId: number;
  predictionValue: boolean;
  moneyAmount: number;
}) {
  return apiPost<{ message: string }>("/api/predictions/money", data);
}