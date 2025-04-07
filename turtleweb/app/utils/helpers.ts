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
      return "bg-success";
    case "executing":
      return "bg-primary";
    case "offline":
      return "bg-danger";
    default:
      return "bg-gray-500";
  }
};

/**
 * Button styles
 */
export const buttonStyle = "bg-primary text-card border-none rounded-md py-3 px-4 text-sm font-medium cursor-pointer transition hover:brightness-110 hover:-translate-y-0.5 active:translate-y-0.5";