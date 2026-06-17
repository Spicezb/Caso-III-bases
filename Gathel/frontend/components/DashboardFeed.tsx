"use client";

import { Tabs } from "@heroui/react";
import PropositionCard, { Proposition } from "@/components/PropositionCard";

const PARA_TI: Proposition[] = [
  {
    id: "1",
    author: "Karina M.",
    handle: "@karina",
    text: "Elizabeth terminará la maratón dentro de los primeros 30 lugares.",
    probability: 64,
    pool: "812 pts",
    timeLeft: "quedan 6 h",
    votes: 304,
    status: "activa",
    mode: "puntos",
  },
  {
    id: "2",
    author: "Diego F.",
    handle: "@diegof",
    text: "Subo el video del lanzamiento del producto antes del viernes a medianoche.",
    probability: 78,
    pool: "$64",
    timeLeft: "quedan 2 días",
    votes: 132,
    status: "activa",
    mode: "dinero",
  },
  {
    id: "3",
    author: "Luis C.",
    handle: "@luisc",
    text: "Llego al gimnasio los 5 días de esta semana.",
    probability: 55,
    pool: "390 pts",
    timeLeft: "quedan 18 h",
    votes: 211,
    status: "activa",
    mode: "puntos",
  },
];

const SIGUIENDO: Proposition[] = [
  {
    id: "4",
    author: "Marian Q.",
    handle: "@marianq",
    text: "No publica nada en redes sociales este fin de semana.",
    probability: 23,
    pool: "205 pts",
    timeLeft: "finalizó",
    votes: 89,
    status: "no cumplida",
    mode: "puntos",
  },
  {
    id: "5",
    author: "Pablo N.",
    handle: "@pablon",
    text: "Su equipo gana el partido del domingo por más de 2 goles.",
    probability: 18,
    pool: "150 pts",
    timeLeft: "quedan 3 días",
    votes: 162,
    status: "activa",
    mode: "puntos",
  },
];

const MIAS: Proposition[] = [
  {
    id: "6",
    author: "Elizabeth V.",
    handle: "@eliruns",
    text: "Voy a lograr al menos el décimo lugar en la maratón.",
    probability: 41,
    pool: "$128",
    timeLeft: "quedan 6 h",
    votes: 87,
    status: "activa",
    mode: "ambos",
  },
  {
    id: "7",
    author: "Elizabeth V.",
    handle: "@eliruns",
    text: "Termino de leer el libro antes de fin de mes.",
    probability: 91,
    pool: "$30",
    timeLeft: "finalizó",
    votes: 47,
    status: "cumplida",
    mode: "dinero",
  },
];

export default function DashboardFeed() {
  return (
    <Tabs defaultSelectedKey="para-ti">
      <Tabs.ListContainer>
        <Tabs.List>
          <Tabs.Tab id="para-ti">Para ti</Tabs.Tab>
          <Tabs.Tab id="siguiendo">Siguiendo</Tabs.Tab>
          <Tabs.Tab id="mias">Mías</Tabs.Tab>
        </Tabs.List>

      </Tabs.ListContainer>

      <Tabs.Panel id="para-ti">
        <div className="mt-4 flex flex-col gap-4">
          {PARA_TI.map((item) => (
            <PropositionCard key={item.id} item={item} />
          ))}
        </div>
      </Tabs.Panel>

      <Tabs.Panel id="siguiendo">
        <div className="mt-4 flex flex-col gap-4">
          {SIGUIENDO.map((item) => (
            <PropositionCard key={item.id} item={item} />
          ))}
        </div>
      </Tabs.Panel>

      <Tabs.Panel id="mias">
        <div className="mt-4 flex flex-col gap-4">
          {MIAS.map((item) => (
            <PropositionCard key={item.id} item={item} />
          ))}
        </div>
      </Tabs.Panel>
    </Tabs>
  );
}
