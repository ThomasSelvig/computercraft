import WebSocketProvider from './components/WebSocketProvider';
import Header from './components/Header';
import TurtleList from './components/TurtleList';
import ControlPanel from './components/ControlPanel';
import CommandHistory from './components/CommandHistory';
import GamepadController from './components/GamepadController';

function App() {
  return (
    <WebSocketProvider>
      <div className="flex flex-col min-h-screen bg-background text-text">
        <Header />
        
        <div className="flex flex-1 p-4 gap-4">
          <TurtleList />
          
          <div className="flex-1 flex flex-col gap-4">
            <ControlPanel />
            <CommandHistory />
          </div>
        </div>
        
        {/* Invisible component that handles gamepad input */}
        <GamepadController />
      </div>
    </WebSocketProvider>
  );
}

export default App;