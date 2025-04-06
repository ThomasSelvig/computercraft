import { useWebSocket } from './WebSocketProvider';

const ConnectionStatus = () => {
  const { connected } = useWebSocket();
  
  return (
    <div className="text-sm flex items-center gap-1.5">
      Status:{" "}
      <span className={`font-semibold flex items-center gap-1 ${connected ? 'text-success' : 'text-danger'}`}>
        <span className={`inline-block w-2.5 h-2.5 rounded-full ${connected ? 'bg-success animate-pulse' : 'bg-danger'}`}></span>
        {connected ? "Connected" : "Disconnected"}
      </span>
    </div>
  );
};

export default ConnectionStatus;