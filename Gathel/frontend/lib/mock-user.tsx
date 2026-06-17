"use client";

/**
 * MVP Mock User Context
 *
 * Simula la sesión autenticada del usuario mientras el backend de auth
 * no está integrado. Cuando el REST API esté listo, reemplazar este
 * contexto con la respuesta real del endpoint de /auth/me o similar.
 *
 * TODO: reemplazar con contexto real conectado al backend
 */

import { createContext, useContext, useState } from "react";

export type MockUser = {
  id: string;
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
  name: "Elizabeth Vargas",
  handle: "@eliruns",
  email: "elizabeth@example.com",
  avatarFallback: "EV",
  pointsBalance: 128,
  moneyBalance: 42.5,
  activePropositions: 5,
  followers: 312,
  following: 87,
  joinedAt: "Mayo 2025",
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
    <UserContext value={{ user, setUser }}>
      {children}
    </UserContext>
  );
}

export function useUser() {
  return useContext(UserContext);
}
