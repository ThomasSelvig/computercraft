// "use client";

import type { Metadata } from "next";
import WebSocketProvider from "../components/WebSocketProvider";
import Header from "../components/Header";
import Navigation from "./components/Navigation";
import "./globals.css";

export const metadata: Metadata = {
  title: "ComputerCraft Control Dashboard",
  description:
    "Modern dashboard system for monitoring and controlling ComputerCraft turtles",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <WebSocketProvider>
          <div className="flex flex-col min-h-screen bg-background text-text">
            <Header />
            <div className="container mx-auto px-4">
              <Navigation />
              <main className="flex-1">{children}</main>
            </div>
            {/* GamepadController will be added at the page level where needed */}
          </div>
        </WebSocketProvider>
      </body>
    </html>
  );
}
