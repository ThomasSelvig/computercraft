import { useWebSocket } from './WebSocketProvider';

const ConnectionStatus = () => {
  const { connected } = useWebSocket();
  
  return (
    <div className="text-sm flex items-center gap-1.5">
      Status:{" "}
      <span className={`font-semibold flex items-center gap-1 ${connected ? 'text-green-500' : 'text-red-500'}`}>
        <span className={`inline-block w-2.5 h-2.5 rounded-full ${connected ? 'bg-green-500 animate-pulse' : 'bg-red-500'}`}></span>
        {connected ? "Connected" : "Disconnected"}
      </span>
    </div>
  );
};

export default ConnectionStatus;