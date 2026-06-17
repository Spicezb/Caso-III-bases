"use client";

import { createContext, useContext, useState } from "react";

export type MockUser = {
  id: string;
  personId: number;
  name: string;
  handle: string;
  email: string;
  avatarFallback: string;
  pointsBalance: number;
  moneyBalance: number;
  activePropositions: number;
  followers: number;
  following: number;
  joinedAt: string;
  connectedNetworks: ("instagram" | "tiktok")[];
};

const DEFAULT_USER: MockUser = {
  id: "usr_001",
  personId: 1,
  name: "Sebastian Aguilar",
  handle: "@sebas_test",
  email: "sebastian@test.com",
  avatarFallback: "SA",
  pointsBalance: 0,
  moneyBalance: 0,
  activePropositions: 0,
  followers: 0,
  following: 0,
  joinedAt: "Junio 2026",
  connectedNetworks: ["instagram"],
};

type UserContextType = {
  user: MockUser;
  setUser: (u: MockUser) => void;
};

const UserContext = createContext<UserContextType>({
  user: DEFAULT_USER,
  setUser: () => {},
});

export function MockUserProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<MockUser>(DEFAULT_USER);

  return (
    <UserContext.Provider value={{ user, setUser }}>
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  return useContext(UserContext);
}