"use client";

import { useEffect, useState } from "react";
import AppShell from "@/components/AppShell";
import DashboardFeed from "@/components/DashboardFeed";
import {
  getActivePropositions,
  getMe,
  getPredictionsByPerson,
} from "@/lib/gathel-api";

const INITIAL_MONEY_BALANCE = 100;

export default function DashboardPage() {
  const [pointsBalance, setPointsBalance] = useState<number>(0);
  const [moneyBalance, setMoneyBalance] = useState<number>(0);
  const [activePropositionsCount, setActivePropositionsCount] = useState<number>(0);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadDashboardData() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const storedPersonId = localStorage.getItem("personId");

        if (!storedPersonId) {
          setErrorMessage("No se encontró el usuario en sesión.");
          return;
        }

        const personId = Number(storedPersonId);

        const [person, propositions, predictions] = await Promise.all([
          getMe(personId),
          getActivePropositions(),
          getPredictionsByPerson(personId),
        ]);

        const usedMoney = predictions.reduce(
          (total, prediction) => total + (prediction.moneyAmount ?? 0),
          0
        );

        const availableMoney = INITIAL_MONEY_BALANCE - usedMoney;

        setPointsBalance(person.pointsBalance ?? 0);
        setMoneyBalance(availableMoney);
        setActivePropositionsCount(propositions.length);
      } catch (error) {
        setErrorMessage(
          error instanceof Error
            ? error.message
            : "No se pudo cargar el dashboard."
        );
      } finally {
        setIsLoading(false);
      }
    }

    loadDashboardData();
  }, []);

  return (
    <AppShell active="/dashboard">
      <div className="mx-auto max-w-2xl">
        {errorMessage && (
          <div className="mb-4 rounded-2xl border border-red-500/40 bg-red-500/10 p-4 text-sm text-red-300">
            {errorMessage}
          </div>
        )}

        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
          <div className="rounded-2xl border border-(--border) bg-(--surface) p-4">
            <p className="text-xs text-(--muted)">Puntos</p>
            <p className="mt-1 font-display text-2xl font-semibold text-(--foreground)">
              {isLoading ? "..." : pointsBalance}
            </p>
          </div>

          <div className="rounded-2xl border border-(--border) bg-(--surface) p-4">
            <p className="text-xs text-(--muted)">Dinero real</p>
            <p className="mt-1 font-display text-2xl font-semibold text-(--foreground)">
              {isLoading ? "..." : `$${moneyBalance.toFixed(2)}`}
            </p>
          </div>

          <div className="col-span-2 rounded-2xl border border-(--border) bg-(--surface) p-4 sm:col-span-1">
            <p className="text-xs text-(--muted)">Proposiciones activas</p>
            <p className="mt-1 font-display text-2xl font-semibold text-(--foreground)">
              {isLoading ? "..." : activePropositionsCount}
            </p>
          </div>
        </div>

        <div className="mt-8">
          <DashboardFeed />
        </div>
      </div>
    </AppShell>
  );
}