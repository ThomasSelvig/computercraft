/**
 * Format time difference
 */
export const formatTimeDiff = (timestamp: number) => {
  const now = Date.now();
  const diff = now - timestamp;

  if (diff < 1000) return "just now";
  if (diff < 60000) return `${Math.floor(diff / 1000)}s ago`;
  if (diff < 3600000) return `${Math.floor(diff / 60000)}m ago`;
  return `${Math.floor(diff / 3600000)}h ago`;
};

/**
 * Determine status color
 */
export const getStatusColor = (status: string) => {
  switch (status) {
    case "idle":
      return "bg-green-500";
    case "executing":
      return "bg-blue-500";
    case "offline":
      return "bg-red-500";
    default:
      return "bg-gray-500";
  }
};