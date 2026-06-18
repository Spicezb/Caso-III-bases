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

export type RegisterResponse = {
  message: string;
  person: {
    personId: number;
    name: string;
    lastName: string;
    username: string;
    email: string;
  };
};

export type PropositionResponse = {
  propositionId: number;
  title: string;
  description: string | null;
  creatorPersonId: number;
  targetPersonId: number;
  startPredictionDateTime: string;
  endPredictionDateTime: string;
  minimumEntryPointsAmount: number | null;
  winningProfitPercentage: number | null;
  status: string;
};

export type CreatePropositionResponse = {
  message: string;
  propositionId?: number;
  proposition?: {
    propositionId: number;
  };
};

export type NotificationResponse = {
  notificationId: number;
  notificationType: string;
  title: string;
  body: string;
  createdAt: string;
  isRead: boolean;
};

export function register(data: {
  name: string;
  lastName: string;
  username: string;
  email: string;
  password: string;
}) {
  return apiPost<RegisterResponse>("/api/auth/register", data);
}

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

export function createProposition(data: {
  creatorPersonId: number;
  targetPersonId: number;
  targetSocialAccountId?: number | null;
  title: string;
  description?: string | null;
  startPredictionDateTime: string;
  endPredictionDateTime: string;
  minimumEntryPointsAmount?: number | null;
  winningProfitPercentage?: number | null;
}) {
  return apiPost<CreatePropositionResponse>("/api/propositions", data);
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

export async function getMyNotifications(
  personId: number
): Promise<NotificationResponse[]> {
  try {
    return await apiGet<NotificationResponse[]>(
      `/api/notifications?personId=${personId}`
    );
  } catch {
    return [];
  }
}

export function markNotificationRead(notificationId: number) {
  return apiPost<{ message: string }>(
    `/api/notifications/${notificationId}/read`,
    {}
  );
}

export function getPropositionById(propositionId: number) {
  return apiGet<PropositionResponse>(`/api/propositions/${propositionId}`);
}

export type PredictionResponse = {
  predictionId: number;
  propositionId: number;
  personId: number;
  user: string;
  handle: string;
  predictionValue: boolean;
  pointsAmount: number | null;
  moneyAmount: number | null;
  predictionDateTime: string;
};

export type MyPredictionResponse = {
  predictionId: number;
  propositionId: number;
  personId: number;
  user: string;
  handle: string;
  predictionValue: boolean;
  pointsAmount: number | null;
  moneyAmount: number | null;
  predictionDateTime: string;
  propositionTitle: string | null;
  propositionDescription: string | null;
  propositionEndDateTime: string;
  isWinner: boolean;
};

export function getPredictionsByProposition(propositionId: number) {
  return apiGet<PredictionResponse[]>(
    `/api/predictions/proposition/${propositionId}`
  );
}

export function markAllNotificationsRead(personId: number) {
  return apiPost<{ message: string }>(
    `/api/notifications/read-all?personId=${personId}`,
    {}
  );
}

export function getPredictionsByPerson(personId: number) {
  return apiGet<MyPredictionResponse[]>(
    `/api/predictions/person/${personId}`
  );
}