"use client";

import WebSocketProvider from "./WebSocketProvider";

export default function WebSocketProviderWrapper({
  children,
}: {
  children: React.ReactNode;
}) {
  return <WebSocketProvider>{children}</WebSocketProvider>;
}