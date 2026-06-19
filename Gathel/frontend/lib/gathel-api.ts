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
  parentPropositionId: number | null | undefined;
  propositionId: number;
  parentProposition?: number | null;
  title: string;
  description: string | null;
  creatorPersonId: number;
  targetPersonId: number;
  targetSocialAccountId?: number | null;
  startPredictionDateTime: string;
  endPredictionDateTime: string;
  minimumEntryPointsAmount: number | null;
  winningProfitPercentage: number | null;
  winningOption?: boolean | null;
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

export type VotingCandidateResponse = {
  propositionId: number;
  parentPropositionId: number;
  title: string;
  description?: string | null;
  creatorPersonId: number;
  targetPersonId: number;
  targetSocialAccountId?: number | null;
  startPredictionDateTime: string;
  endPredictionDateTime: string;
  status: string;
};

export type VotingPropositionGroupResponse = {
  propositionId: number;
  title: string;
  description?: string | null;
  creatorPersonId: number;
  targetPersonId: number;
  targetSocialAccountId?: number | null;
  startPredictionDateTime: string;
  endPredictionDateTime: string;
  status: string;
  candidates: VotingCandidateResponse[];
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

export function createProposition(data: {
  creatorPersonId: number;
  targetPersonId: number;
  targetSocialAccountId?: number | null;
  title: string;
  description?: string | null;
  startPredictionDateTime: string;
  endPredictionDateTime: string;
  minimumEntryPointsAmount?: number | null;
  parentProposition?: number | null;
  parentPropositionId?: number | null;
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

export type VoteForCandidateResponse = {
  message: string;
};

export type AcceptPropositionResponse = {
  message: string;
};

export type RejectPropositionResponse = {
  message: string;
};

export type SelectWinnerResponse = {
  message: string;
};

export function getVotingPropositions() {
  return apiGet<VotingPropositionGroupResponse[]>("/api/propositions/voting");
}

export function getPendingApprovalPropositions(targetPersonId: number) {
  return apiGet<PropositionResponse[]>(
    `/api/propositions/pending-approval?targetPersonId=${targetPersonId}`
  );
}

export function voteForCandidateProposition(data: {
  propositionId: number;
  personId: number;
  voteValue?: boolean;
}) {
  return apiPost<VoteForCandidateResponse>(
    `/api/propositions/${data.propositionId}/vote`,
    {
      personId: data.personId,
      voteValue: data.voteValue ?? true,
    }
  );
}

export function selectWinningProposition(parentPropositionId: number) {
  return apiPost<SelectWinnerResponse>(
    `/api/propositions/${parentPropositionId}/select-winner`,
    {}
  );
}

export function acceptWinningProposition(data: {
  propositionId: number;
  targetPersonId: number;
  startPredictionDateTime: string;
  endPredictionDateTime: string;
}) {
  return apiPost<AcceptPropositionResponse>(
    `/api/propositions/${data.propositionId}/accept`,
    {
      targetPersonId: data.targetPersonId,
      startPredictionDateTime: data.startPredictionDateTime,
      endPredictionDateTime: data.endPredictionDateTime,
    }
  );
}

export function rejectWinningProposition(data: {
  propositionId: number;
  targetPersonId: number;
}) {
  return apiPost<RejectPropositionResponse>(
    `/api/propositions/${data.propositionId}/reject`,
    {
      targetPersonId: data.targetPersonId,
    }
  );
}

export type VotingVoteResponse = {
  parentPropositionId: number;
  candidatePropositionId: number;
};

export function getMyVotingVotes(personId: number) {
  return apiGet<VotingVoteResponse[]>(
    `/api/propositions/voting/my-votes?personId=${personId}`
  );
}