"use client";

import { useEffect, useState } from "react";
import { useGamepads } from "react-gamepads";
import { useWebSocket } from "./WebSocketProvider";

const GamepadController = () => {
  const { sendCommand } = useWebSocket();
  const [gamepads, setGamepads] = useState<Record<string, any>>({});

  useGamepads((gamepadList) => {
    setGamepads(gamepadList as Record<string, any>);
  });

  useEffect(() => {
    // Process gamepad input here
    // This is a placeholder for future gamepad control implementation
    const gamepadArr = Object.values(gamepads);

    if (gamepadArr.length > 0) {
      const gamepad = gamepadArr[0];
      console.log("Active gamepad:", gamepad);

      // Example of how to handle gamepad buttons:
      // if (gamepad.buttons[0].pressed) {
      //   sendCommand("move", { direction: "forward" });
      // }
    }
  }, [gamepads, sendCommand]);

  return null; // This component doesn't render anything
};

export default GamepadController;
